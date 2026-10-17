import hashlib
import secrets
import time
from datetime import timedelta

from django.conf import settings
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.tokens import default_token_generator
from django.core import signing
from django.core.mail import send_mail
from django.db import IntegrityError, transaction
from django.db.models import F
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.utils import timezone
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from django.views.decorators.http import require_POST

from .catalog import DEFAULT
from .forms import CharacterForm, Credentials, Registration
from .models import Account, Character, GameTicket, LoginBucket


def limited(request, identity=""):
    """Durable fixed windows, independently bounded by IP and account identity."""
    window = int(time.time()) // 900
    identities = [("ip:" + request.META.get("REMOTE_ADDR", ""), 30)]
    if identity:
        identities.append(("account:" + identity.strip().lower(), 10))
    denied = False
    with transaction.atomic():
        for identity, limit in identities:
            key = hashlib.sha256(identity.encode()).hexdigest()
            LoginBucket.objects.get_or_create(key=key, defaults={"window": window})
            bucket = LoginBucket.objects.select_for_update().get(pk=key)
            if bucket.window != window:
                bucket.window, bucket.attempts = window, 0
            bucket.attempts += 1
            bucket.save()
            denied |= bucket.attempts > limit
        LoginBucket.objects.filter(window__lt=window - 2).delete()
    return denied


def notice(request, message, status=200):
    return render(request, "accounts/notice.html", {"message": message}, status=status)


def entry(request):
    if request.user.is_authenticated:
        return redirect("edit" if Character.objects.filter(account=request.user).exists() else "create")
    form = Credentials(request.POST or None)
    if request.method == "POST":
        if limited(request, request.POST.get("email", "")):
            form.add_error(None, "Demasiados intentos. Espera 15 minutos.")
        elif form.is_valid():
            identifier = form.cleaned_data["email"].strip().lower()
            if identifier == "test":
                identifier = "test@example.invalid"
            user = authenticate(request, email=identifier, password=form.cleaned_data["password"])
            if user:
                login(request, user)
                return redirect("entry")
            form.add_error(None, "No se pudo acceder. Revisa tus datos y verifica tu correo.")
    return render(request, "accounts/entry.html", {"form": form, "register": False})


def register(request):
    if request.user.is_authenticated:
        return redirect("entry")
    if not settings.REGISTRATION_ENABLED:
        return notice(request, "El registro todavía no está disponible.", 503)
    form = Registration(request.POST or None)
    if request.method == "POST":
        if limited(request, request.POST.get("email", "")):
            form.add_error(None, "Demasiados intentos. Espera 15 minutos.")
        elif form.is_valid():
            email = form.cleaned_data["email"].strip().lower()
            # Do not replace a password when an unverified address is registered again.
            try:
                with transaction.atomic():
                    account = Account.objects.create_user(email, form.cleaned_data["password"], is_active=False)
            except IntegrityError:
                account = None
            if account:
                token = signing.dumps(str(account.id), salt="verify-account")
                url = settings.PUBLIC_ORIGIN + "/verify/" + token + "/"
                send_mail("Verifica tu cuenta de Dreamscape", "Confirma tu correo (enlace válido 24 h):\n" + url,
                          settings.DEFAULT_FROM_EMAIL, [email])
            return notice(request, "Si el correo es nuevo, recibirás un enlace para verificarlo. Si ya tienes cuenta, accede o recupera la contraseña.")
    return render(request, "accounts/entry.html", {"form": form, "register": True})


def verify(request, token):
    try:
        account_id = signing.loads(token, salt="verify-account", max_age=86400)
        account = Account.objects.get(pk=account_id)
    except (signing.BadSignature, Account.DoesNotExist, ValueError):
        return notice(request, "Este enlace no es válido o ha caducado. Usa Recuperar contraseña para obtener uno nuevo.", 400)
    # A POST confirmation prevents mail scanners from activating accounts.
    if request.method == "POST":
        account.is_active = True
        account.save(update_fields=["is_active"])
        return notice(request, "Correo verificado. Ya puedes acceder y crear tu personaje.")
    return render(request, "accounts/confirm.html", {"message": "Confirma tu correo para activar la cuenta."})


def recover(request):
    if not settings.REGISTRATION_ENABLED:
        return notice(request, "En esta fase de pruebas solo está disponible la cuenta test.")
    from django import forms
    class RecoveryForm(forms.Form):
        email = forms.EmailField(label="Correo", max_length=254)
    form = RecoveryForm(request.POST or None)
    if request.method == "POST":
        if limited(request, request.POST.get("email", "")):
            form.add_error(None, "Demasiados intentos. Espera 15 minutos.")
        elif form.is_valid():
            account = Account.objects.filter(email=form.cleaned_data["email"].strip().lower()).first()
            if account:
                if not account.is_active:
                    token = signing.dumps(str(account.id), salt="verify-account")
                    url = settings.PUBLIC_ORIGIN + "/verify/" + token + "/"
                else:
                    uid = urlsafe_base64_encode(force_bytes(account.pk))
                    token = default_token_generator.make_token(account)
                    url = settings.PUBLIC_ORIGIN + f"/reset/{uid}/{token}/"
                send_mail("Recuperar acceso a Dreamscape", "Abre este enlace para recuperar el acceso:\n" + url,
                          settings.DEFAULT_FROM_EMAIL, [account.email])
            return notice(request, "Si existe una cuenta, recibirás un correo para recuperar el acceso.")
    return render(request, "accounts/form.html", {"form": form, "title": "Recuperar contraseña", "submit": "Enviar enlace"})


@login_required(login_url="/")
def create(request):
    if Character.objects.filter(account=request.user).exists():
        return redirect("play")
    form = CharacterForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        # Account row serializes double-clicks and concurrent creation requests.
        with transaction.atomic():
            Account.objects.select_for_update().get(pk=request.user.pk)
            Character.objects.get_or_create(account=request.user, defaults={
                "name": form.cleaned_data["name"], "appearance": form.appearance(), "position": [-2, 0.05, 1]})
        return redirect("play")
    return render(request, "accounts/create.html", {"form": form, "appearance": DEFAULT})


@login_required(login_url="/")
def edit(request):
    character = Character.objects.filter(account=request.user).first()
    if character is None:
        return redirect("create")
    form = CharacterForm(request.POST or None, initial={"name": character.name, **character.appearance})
    if request.method == "POST" and form.is_valid():
        with transaction.atomic():
            Account.objects.select_for_update().get(pk=request.user.pk)
            character = Character.objects.select_for_update().get(account=request.user)
            character.name = form.cleaned_data["name"]
            character.appearance = form.appearance()
            character.generation += 1
            character.revision += 1
            character.active_session = ""
            character.save(update_fields=["name", "appearance", "generation", "revision", "active_session", "saved_at"])
            GameTicket.objects.filter(character=character).delete()
        return redirect("play")
    return render(request, "accounts/create.html", {"form": form, "appearance": character.appearance, "editing": True})


@login_required(login_url="/")
def play(request):
    character = Character.objects.filter(account=request.user).first()
    if character is None:
        return redirect("create")
    return render(request, "accounts/play.html", {"character": character})


@require_POST
def sign_out(request):
    if request.user.is_authenticated:
        Character.objects.filter(account=request.user).update(generation=F("generation") + 1, active_session="")
        GameTicket.objects.filter(character__account=request.user).delete()
    logout(request)
    return redirect("entry")


def character_json(character):
    return {"id": str(character.id), "name": character.name, "appearance": character.appearance,
            "place": character.place, "position": character.position, "revision": character.revision,
            "generation": character.generation, "saved_at": character.saved_at.isoformat()}


@require_POST
def ticket(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "session_expired"}, status=401)
    character = Character.objects.filter(account=request.user).first()
    if character is None:
        return JsonResponse({"error": "character_required"}, status=409)
    if limited(request, "ticket:" + str(request.user.id)):
        return JsonResponse({"error": "try_later"}, status=429)
    token = secrets.token_urlsafe(32)
    GameTicket.objects.filter(character=character).delete()
    GameTicket.objects.filter(expires_at__lt=timezone.now()).delete()
    GameTicket.objects.create(digest=hashlib.sha256(token.encode()).hexdigest(), character=character,
                             session_key=request.session.session_key, expires_at=timezone.now() + timedelta(seconds=30))
    return JsonResponse({"ticket": token, "socket_url": settings.GAME_SOCKET_URL})
