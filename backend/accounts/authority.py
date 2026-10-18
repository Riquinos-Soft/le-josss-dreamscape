"""Private simulation boundary. Never route /internal/ through the public proxy."""
import hashlib
import json
import secrets
import uuid
from datetime import timedelta
from functools import wraps

from django.conf import settings
from django.contrib.auth import HASH_SESSION_KEY, SESSION_KEY
from django.contrib.sessions.models import Session
from django.db import transaction
from django.http import JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from .models import Account, Authority, Character, GameTicket
from .views import character_json
from .places import valid_position


def private(view):
    @csrf_exempt
    @require_POST
    @wraps(view)
    def guarded(request):
        supplied = request.headers.get("Authorization", "")
        if len(settings.AUTHORITY_SECRET) < 32 or not secrets.compare_digest(supplied, "Bearer " + settings.AUTHORITY_SECRET):
            return JsonResponse({"error": "forbidden"}, status=403)
        try:
            if len(request.body) > 4096:
                raise ValueError()
            data = json.loads(request.body)
            if not isinstance(data, dict):
                raise ValueError()
            with transaction.atomic():
                return view(request, data)
        except (ValueError, TypeError, KeyError, Character.DoesNotExist, json.JSONDecodeError):
            return JsonResponse({"error": "invalid_request"}, status=400)
    return guarded


def valid_session(key, account):
    session = Session.objects.filter(session_key=key, expire_date__gt=timezone.now()).first()
    data = session.get_decoded() if session else {}
    return (account.is_active and data.get(SESSION_KEY) == str(account.id)
            and secrets.compare_digest(data.get(HASH_SESSION_KEY, ""), account.get_session_auth_hash()))


def lease(data):
    return Authority.objects.select_for_update().filter(pk=1, epoch=data["epoch"], expires_at__gt=timezone.now()).first()


@private
def start(request, data):
    # Starting a replacement fences every commit from the previous process.
    authority, _ = Authority.objects.select_for_update().update_or_create(pk=1, defaults={
        "epoch": uuid.uuid4(), "expires_at": timezone.now() + timedelta(seconds=20)})
    return JsonResponse({"epoch": str(authority.epoch)})


@private
def heartbeat(request, data):
    authority = lease(data)
    if not authority:
        return JsonResponse({"error": "authority_lost"}, status=409)
    authority.expires_at = timezone.now() + timedelta(seconds=20)
    authority.save()
    return JsonResponse({"ok": True})


@private
def consume(request, data):
    if not lease(data):
        return JsonResponse({"error": "authority_lost"}, status=409)
    digest = hashlib.sha256(data["ticket"].encode()).hexdigest()
    ticket = GameTicket.objects.select_for_update().filter(pk=digest, expires_at__gt=timezone.now()).first()
    if not ticket:
        return JsonResponse({"error": "invalid_ticket"}, status=401)
    character = Character.objects.select_for_update().select_related("account").get(pk=ticket.character_id)
    if not valid_session(ticket.session_key, character.account):
        ticket.delete()
        return JsonResponse({"error": "session_expired"}, status=401)
    if not valid_position(character.position, character.place):
        return JsonResponse({"error": "place_unavailable"}, status=409)
    character.generation += 1
    character.checkpoint_sequence = 0
    character.active_session = ticket.session_key
    character.save(update_fields=["generation", "checkpoint_sequence", "active_session"])
    ticket.delete()
    return JsonResponse(character_json(character))


@private
def checkpoint(request, data):
    if not lease(data):
        return JsonResponse({"error": "authority_lost"}, status=409)
    character = Character.objects.select_for_update().select_related("account").get(pk=data["character_id"])
    if character.generation != data["generation"] or not valid_session(character.active_session, character.account):
        return JsonResponse({"error": "session_replaced"}, status=409)
    sequence = data["sequence"]
    if type(sequence) is not int or sequence < 1:
        raise ValueError()
    if sequence <= character.checkpoint_sequence:
        return JsonResponse(character_json(character))
    position = data["position"]
    place = data.get("place", character.place)
    if not isinstance(place, str) or not valid_position(position, place):
        raise ValueError()
    # Only the trusted Godot authority supplies positions, after floor/collision validation.
    character.position = position
    character.place = place
    character.checkpoint_sequence = sequence
    character.revision += 1
    character.save()
    return JsonResponse(character_json(character))
