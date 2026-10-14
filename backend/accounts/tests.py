import json
import re
from datetime import timedelta
from pathlib import Path
from unittest.mock import patch

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import identify_hasher
from django.core import mail
from django.core.management import call_command
from django.test import Client, TestCase, override_settings
from django.utils import timezone

from .catalog import DEFAULT, OPTIONS, valid_appearance
from .models import Authority, Character, GameTicket, LoginBucket


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
        self.assertRedirects(fresh.get("/"), "/play/", fetch_redirect_response=False)
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

    def test_ticket_single_use_expiry_and_logout(self):
        epoch, ticket, char = self.connect()
        self.assertEqual(self.private("consume", {"epoch": epoch, "ticket": ticket}).status_code, 401)
        self.client.post("/api/ticket/")
        GameTicket.objects.update(expires_at=timezone.now() - timedelta(seconds=1))
        self.client.post("/logout/")
        self.assertFalse(GameTicket.objects.exists())
        self.assertGreater(Character.objects.get().generation, char["generation"])

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
