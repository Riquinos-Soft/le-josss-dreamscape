import json
import importlib
import re
from datetime import timedelta
from pathlib import Path
from unittest.mock import patch
from types import SimpleNamespace

from django.conf import settings
from django.apps import apps
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import identify_hasher
from django.core import mail
from django.core.management import call_command
from django.test import Client, TestCase, override_settings
from django.db import connection
from django.utils import timezone

from .catalog import DEFAULT, OPTIONS, valid_appearance
from .models import Authority, Character, GameTicket, LoginBucket
from .places import ARRIVAL, PLACE_ID


@override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend")
class AccountTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user("test@example.invalid", "test")

    def login(self, client=None):
        return (client or self.client).post("/", {"email": "test", "password": "test"})

    def create_character(self, client=None, name="Jose"):
        self.login(client)
        return (client or self.client).post("/character/create/", {"name": name, **DEFAULT})

    def private(self, endpoint, data=None):
        return self.client.post("/internal/" + endpoint + "/", json.dumps(data or {}),
            content_type="application/json", HTTP_AUTHORIZATION="Bearer " + settings.AUTHORITY_SECRET)

    def connect(self):
        self.create_character()
        epoch = self.private("start").json()["epoch"]
        ticket = self.client.post("/api/ticket/").json()["ticket"]
        character = self.private("consume", {"epoch": epoch, "ticket": ticket}).json()
        return epoch, ticket, character

    def test_first_login_and_owned_character_resume(self):
        self.assertContains(self.client.get("/"), "Vuelve a tu mundo")
        self.assertRedirects(self.login(), "/", fetch_redirect_response=False)
        self.assertRedirects(self.client.get("/"), "/character/create/", fetch_redirect_response=False)
        self.create_character(name="Álex Ríos")
        first = Character.objects.get()
        self.client.post("/logout/")
        fresh = Client()
        self.login(fresh)
        self.assertRedirects(fresh.get("/"), "/character/edit/", fetch_redirect_response=False)
        self.assertContains(fresh.get("/play/"), "Álex Ríos")
        self.assertEqual(Character.objects.get().id, first.id)
        self.assertEqual(identify_hasher(self.user.password).algorithm, "argon2")

    def test_single_character_and_invalid_creation(self):
        self.login()
        response = self.client.post("/character/create/", {"name": "<script>", **DEFAULT})
        self.assertEqual(response.status_code, 200)
        self.assertFalse(Character.objects.exists())
        self.client.post("/character/create/", {"name": "Jose", **DEFAULT, "hair": "invented"})
        self.assertFalse(Character.objects.exists())
        self.create_character()
        self.client.post("/character/create/", {"name": "Replacement", **DEFAULT})
        self.assertEqual(Character.objects.count(), 1)
        self.assertEqual(Character.objects.get().name, "Jose")

    def test_cross_account_and_anonymous_access(self):
        self.create_character()
        other = get_user_model().objects.create_user("other@example.invalid", "safe-password-3278")
        client = Client()
        client.force_login(other)
        self.assertRedirects(client.get("/play/"), "/character/create/", fetch_redirect_response=False)
        self.assertEqual(client.post("/api/ticket/").status_code, 409)
        self.assertEqual(Client().post("/api/ticket/").status_code, 401)
        self.assertEqual(Client().post("/internal/checkpoint/", {}).status_code, 403)

    def test_csrf_enforced_and_session_rotates(self):
        client = Client(enforce_csrf_checks=True)
        client.get("/")
        self.assertEqual(client.post("/", {"email": "test", "password": "test"}).status_code, 403)
        token = client.cookies["csrftoken"].value
        response = client.post("/", {"email": "test", "password": "test", "csrfmiddlewaretoken": token})
        self.assertEqual(response.status_code, 302)
        self.assertEqual(client.post("/logout/").status_code, 403)
        self.assertTrue(client.cookies["sessionid"]["httponly"])

    def test_registration_disabled_and_seed_idempotent(self):
        self.assertEqual(self.client.get("/register/").status_code, 503)
        self.create_character()
        before = Character.objects.get().id
        call_command("seed_test_account")
        self.assertEqual(Character.objects.get().id, before)
        self.assertEqual(get_user_model().objects.count(), 1)

    def test_login_throttle_survives_new_client(self):
        for _ in range(10):
            self.client.post("/", {"email": "test", "password": "wrong"})
        self.assertContains(Client().post("/", {"email": "test", "password": "test"}), "Demasiados intentos")

    def test_second_account_is_independent_and_seed_preserves_both(self):
        self.create_character()
        first = Character.objects.get()
        call_command("seed_test_account", second=True)
        second = Client()
        self.assertEqual(second.post("/", {"email": "test2", "password": "test2"}).status_code, 302)
        self.assertRedirects(second.get("/"), "/character/create/", fetch_redirect_response=False)
        second.post("/character/create/", {"name": "Segundo", **DEFAULT, "hair_palette": "blond"})
        other = Character.objects.exclude(id=first.id).get()
        account = other.account
        password = account.password
        call_command("seed_test_account", second=True)
        call_command("seed_test_account")
        account.refresh_from_db()
        first.refresh_from_db()
        other.refresh_from_db()
        self.assertEqual(account.password, password)
        self.assertEqual(first.account_id, self.user.id)
        self.assertNotEqual(first.account_id, other.account_id)
        self.assertEqual(first.appearance, DEFAULT)
        self.assertEqual(other.appearance["hair_palette"], "blond")
        response = second.get("/play/")
        self.assertContains(response, 'role="status" hidden')
        self.assertNotContains(response, "Conectando")

    @override_settings(REGISTRATION_ENABLED=True)
    def test_registration_verification_and_duplicate(self):
        data = {"email": "NEW@example.invalid", "password": "A-strong-8430-password", "confirmation": "A-strong-8430-password"}
        self.client.post("/register/", data)
        account = get_user_model().objects.get(email="new@example.invalid")
        self.assertFalse(account.is_active)
        self.client.post("/register/", {**data, "email": "new@example.invalid"})
        self.assertEqual(len(mail.outbox), 1)
        url = re.search(r"http[^\s]+", mail.outbox[0].body)[0].split(settings.PUBLIC_ORIGIN)[1]
        self.client.get(url)
        account.refresh_from_db()
        self.assertFalse(account.is_active)
        self.client.post(url)
        account.refresh_from_db()
        self.assertTrue(account.is_active)

    @override_settings(REGISTRATION_ENABLED=True)
    def test_registered_account_creates_and_resumes_owned_character(self):
        data = {"email": "traveler@example.invalid", "password": "A-strong-8430-password", "confirmation": "A-strong-8430-password"}
        self.client.post("/register/", data)
        account = get_user_model().objects.get(email=data["email"])
        self.client.post("/", data)
        self.assertNotIn("_auth_user_id", self.client.session)
        url = re.search(r"http[^\s]+", mail.outbox[0].body)[0].split(settings.PUBLIC_ORIGIN)[1]
        self.client.post(url)
        self.client.post("/", data)
        self.assertRedirects(self.client.get("/"), "/character/create/", fetch_redirect_response=False)
        self.client.post("/character/create/", {"name": "Viajera", **DEFAULT})
        character = Character.objects.get(account=account)
        self.client.post("/logout/")
        fresh = Client()
        fresh.post("/", data)
        self.assertRedirects(fresh.get("/"), "/character/edit/", fetch_redirect_response=False)
        self.assertContains(fresh.get("/play/"), "Viajera")
        self.assertEqual(Character.objects.get(account=account).id, character.id)
        self.assertFalse(Character.objects.filter(account=self.user).exists())

    def test_edit_preserves_progress_and_fences_previous_game(self):
        epoch, _, char = self.connect()
        body = {"epoch": epoch, "character_id": char["id"], "generation": char["generation"], "sequence": 1, "position": [2.5, 0, 2]}
        self.private("checkpoint", body)
        before = Character.objects.get()
        page = self.client.get("/", follow=True)
        self.assertContains(page, "Tu personaje")
        self.assertContains(page, 'value="Jose"')
        self.assertContains(page, "Continuar sin cambios")
        self.assertEqual(Character.objects.get().generation, before.generation)
        self.client.post("/api/ticket/")
        self.assertTrue(GameTicket.objects.exists())
        response = self.client.post("/character/edit/", {"name": "Viajera", **DEFAULT, "hair": "tied", "position": [999, 0, 0]})
        self.assertRedirects(response, "/play/", fetch_redirect_response=False)
        after = Character.objects.get()
        self.assertEqual((after.id, after.account_id, after.place, after.position),
                         (before.id, before.account_id, before.place, before.position))
        self.assertEqual(after.name, "Viajera")
        self.assertEqual(after.appearance["hair"], "tied")
        self.assertEqual(after.generation, before.generation + 1)
        self.assertFalse(after.active_session)
        self.assertFalse(GameTicket.objects.exists())
        self.assertEqual(self.private("checkpoint", {**body, "sequence": 2}).status_code, 409)
        self.assertEqual(Character.objects.get().position, before.position)

    def test_edit_rejects_invalid_changes_and_other_account_selection(self):
        self.assertRedirects(Client().get("/character/edit/"), "/?next=/character/edit/", fetch_redirect_response=False)
        self.login()
        self.assertRedirects(self.client.get("/character/edit/"), "/character/create/", fetch_redirect_response=False)
        self.create_character()
        original = Character.objects.get()
        for changes in [{"name": "<script>"}, {"hair": "unknown"}]:
            response = self.client.post("/character/edit/", {"name": "Jose", **DEFAULT, **changes})
            self.assertEqual(response.status_code, 200)
            unchanged = Character.objects.get()
            self.assertEqual((unchanged.name, unchanged.appearance, unchanged.generation),
                             (original.name, original.appearance, original.generation))
        other = get_user_model().objects.create_user("other@example.invalid", "safe-password-3278")
        other_character = Character.objects.create(account=other, name="Otro", appearance=DEFAULT, position=[1, 0, 2])
        self.client.post("/character/edit/", {"name": "Propio", **DEFAULT, "character_id": str(other_character.id), "account": str(other.id)})
        other_character.refresh_from_db()
        self.assertEqual(other_character.name, "Otro")
        self.assertEqual(Character.objects.get(account=self.user).name, "Propio")

    def test_ticket_single_use_expiry_and_logout(self):
        epoch, ticket, char = self.connect()
        self.assertEqual(self.private("consume", {"epoch": epoch, "ticket": ticket}).status_code, 401)
        self.client.post("/api/ticket/")
        GameTicket.objects.update(expires_at=timezone.now() - timedelta(seconds=1))
        self.client.post("/logout/")
        self.assertFalse(GameTicket.objects.exists())
        self.assertGreater(Character.objects.get().generation, char["generation"])

    def test_lourizan_checkpoint_and_fullscreen_play(self):
        epoch, _, char = self.connect()
        self.assertEqual(char["place"], PLACE_ID)
        self.assertEqual(char["position"], ARRIVAL)
        page = self.client.get("/play/")
        self.assertNotContains(page, "<header")
        self.assertNotContains(page, "Cerrar sesión")
        self.assertNotContains(page, "Mi personaje")
        body = {"epoch": epoch, "character_id": char["id"], "generation": char["generation"], "sequence": 1, "position": [9.6, 0, 15]}
        self.assertEqual(self.private("checkpoint", body).json()["position"], [9.6, 0, 15])
        self.assertEqual(self.private("checkpoint", {**body, "sequence": 2, "position": [35, 0, 0]}).status_code, 400)
        self.assertEqual(Character.objects.get().position, [9.6, 0, 15])

    def test_test_room_migration_preserves_identity_and_real_world_progress(self):
        self.create_character()
        original = Character.objects.get()
        Character.objects.filter(pk=original.id).update(place="laboratory_v1", position=[-2, 0.05, 1])
        self.client.post("/api/ticket/")
        other = get_user_model().objects.create_user("settled@example.invalid", "safe-password-3278")
        settled = Character.objects.create(account=other, name="Estable", appearance=DEFAULT, place=PLACE_ID, position=[12, 0, 16], revision=8)
        migrate = importlib.import_module("accounts.migrations.0002_lourizan_entry").relocate_test_characters
        migrate(apps, SimpleNamespace(connection=connection))
        migrated = Character.objects.get(account=self.user)
        self.assertEqual((migrated.id, migrated.name, migrated.appearance), (original.id, original.name, original.appearance))
        self.assertEqual((migrated.place, migrated.position), (PLACE_ID, ARRIVAL))
        self.assertEqual(migrated.generation, original.generation + 1)
        self.assertFalse(GameTicket.objects.filter(character=migrated).exists())
        migrate(apps, SimpleNamespace(connection=connection))
        self.assertEqual(Character.objects.get(account=self.user).generation, migrated.generation)
        settled.refresh_from_db()
        self.assertEqual((settled.position, settled.revision), ([12, 0, 16], 8))

    def test_destination_and_position_commit_atomically_and_resume(self):
        epoch, _, char = self.connect()
        body = {"epoch": epoch, "character_id": char["id"], "generation": char["generation"],
                "sequence": 1, "place": "scandale", "position": [1, .05, 3.5]}
        saved = self.private("checkpoint", body).json()
        self.assertEqual((saved["place"], saved["position"]), ("scandale", [1, .05, 3.5]))
        for place, position in [("home", [0, 0, 0]), ("invented", [0, 0, 0]),
                                ("scandale", [20, 0, 0]), ("street", [0, float("nan"), 0])]:
            self.assertEqual(self.private("checkpoint", {**body, "sequence": 2,
                             "place": place, "position": position}).status_code, 400)
            current = Character.objects.get()
            self.assertEqual((current.place, current.position), ("scandale", [1, .05, 3.5]))
        ticket = self.client.post("/api/ticket/").json()["ticket"]
        resumed = self.private("consume", {"epoch": epoch, "ticket": ticket}).json()
        self.assertEqual((resumed["id"], resumed["place"], resumed["position"]),
                         (char["id"], "scandale", [1, .05, 3.5]))
        body.update(generation=resumed["generation"], sequence=1, place="lourizan", position=[-90, .05, 5.9])
        self.assertEqual(self.private("checkpoint", body).json()["position"], [-90, .05, 5.9])

    def test_checkpoint_replay_generation_restart_and_ownership(self):
        epoch, _, char = self.connect()
        body = {"epoch": epoch, "character_id": char["id"], "generation": char["generation"], "sequence": 1, "position": [2.5, 0, 2]}
        saved = self.private("checkpoint", body).json()
        self.assertEqual(saved["position"], [2.5, 0, 2])
        self.assertEqual(saved["revision"], 1)
        replay = self.private("checkpoint", {**body, "position": [0, 0, 0]}).json()
        self.assertEqual(replay["position"], [2.5, 0, 2])
        self.assertEqual(replay["revision"], 1)
        epoch2 = self.private("start").json()["epoch"]
        self.assertEqual(self.private("checkpoint", {**body, "sequence": 2}).status_code, 409)
        ticket = self.client.post("/api/ticket/").json()["ticket"]
        restored = self.private("consume", {"epoch": epoch2, "ticket": ticket}).json()
        self.assertEqual(restored["position"], saved["position"])
        self.assertEqual(restored["id"], saved["id"])
        self.assertEqual(self.private("checkpoint", {**body, "epoch": epoch2, "sequence": 2}).status_code, 409)

    def test_invalid_position_expired_lease_and_session(self):
        epoch, _, char = self.connect()
        body = {"epoch": epoch, "character_id": char["id"], "generation": char["generation"], "sequence": 1, "position": [999, 0, 0]}
        self.assertEqual(self.private("checkpoint", body).status_code, 400)
        self.user.set_password("replacement-pass-1234")
        self.user.save()
        self.assertEqual(self.private("checkpoint", {**body, "position": [1, 0, 1]}).status_code, 409)
        Authority.objects.update(expires_at=timezone.now() - timedelta(seconds=1))
        self.assertEqual(self.private("heartbeat", {"epoch": epoch}).status_code, 409)

    def test_catalog_matches_godot_and_rejects_extra_fields(self):
        text = (settings.BASE_DIR.parent / "game/v2/characters/appearance_catalog.gd").read_text()
        wire = json.loads(re.search(r"const OPTIONS := (\{.*?\})", text, re.S)[1])
        self.assertEqual(OPTIONS, wire)
        self.assertTrue(valid_appearance(DEFAULT))
        self.assertFalse(valid_appearance({**DEFAULT, "version": True}))
        self.assertFalse(valid_appearance({**DEFAULT, "extra": "x"}))

    def test_failed_database_load_does_not_create_character(self):
        from django.db import DatabaseError
        self.login()
        with patch("accounts.views.Character.objects.filter", side_effect=DatabaseError("offline")):
            with self.assertRaises(DatabaseError):
                self.client.get("/")
        self.assertFalse(Character.objects.exists())
