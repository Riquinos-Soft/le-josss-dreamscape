from io import StringIO

from django.contrib.auth.models import Group, Permission
from django.core.management import call_command, CommandError
from django.test import Client, TestCase, override_settings

from .catalog import DEFAULT
from .models import Account, Character
from .places import ARRIVAL, PLACE_ID


class BetaEntryTests(TestCase):
    def seed(self):
        call_command("seed_beta_account", stdout=StringIO())

    def test_public_panel_fill_button_and_normal_csrf_authentication(self):
        self.seed()
        browser = Client(enforce_csrf_checks=True)
        page = browser.get("/", secure=True)
        for label in ("Acceso a la beta", "Usuario:", "Contraseña:", "Usar cuenta beta",
                      "personaje compartido", "cuentas distintas"):
            self.assertContains(page, label)
        self.assertContains(page, 'type="button" id="use-beta"')
        self.assertNotContains(page, "example.invalid")
        self.assertEqual(browser.post("/", {"email": "beta", "password": "beta"}, secure=True).status_code, 403)
        data = {"email": "beta", "password": "wrong", "csrfmiddlewaretoken": browser.cookies["csrftoken"].value}
        browser.defaults["HTTP_REFERER"] = "https://testserver/"
        self.assertContains(browser.post("/", data, secure=True), "No se pudo acceder")
        self.assertNotIn("_auth_user_id", browser.session)
        self.assertEqual(browser.post("/api/ticket/", data, secure=True).status_code, 401)
        response = browser.post("/", {**data, "password": "beta"}, secure=True)
        self.assertEqual(response.status_code, 302)
        self.assertEqual(browser.session["_auth_user_id"], str(Account.objects.get().pk))
        self.assertEqual(browser.post("/api/ticket/", {"csrfmiddlewaretoken": browser.cookies["csrftoken"].value}, secure=True).status_code, 409)
        self.assertTrue(browser.cookies["sessionid"]["httponly"])

    def test_seed_and_reseed_preserve_character_and_unrelated_accounts(self):
        unrelated = Account.objects.create_user("other@example.invalid", "A-strong-8430-password")
        self.seed()
        account = Account.objects.get(email="beta@example.invalid")
        password = account.password
        self.assertFalse(account.is_staff or account.is_superuser)
        self.assertFalse(account.get_all_permissions())
        self.assertTrue(account.is_active)
        self.assertFalse(Character.objects.exists())
        self.client.post("/", {"email": "beta", "password": "beta"})
        self.assertRedirects(self.client.get("/"), "/character/create/", fetch_redirect_response=False)
        self.client.post("/character/create/", {"name": "Beta Viajero", **DEFAULT})
        character = Character.objects.get(account=account)
        self.assertEqual((character.place, character.position), (PLACE_ID, ARRIVAL))
        Character.objects.filter(pk=character.pk).update(position=[12, 0, 16], revision=8)
        self.seed()
        account.refresh_from_db()
        character.refresh_from_db()
        self.assertEqual(account.password, password)
        self.assertEqual((character.position, character.revision), ([12, 0, 16], 8))
        self.assertEqual(character.name, "Beta Viajero")
        self.assertEqual(character.appearance, DEFAULT)
        unrelated.refresh_from_db()
        self.assertTrue(unrelated.check_password("A-strong-8430-password"))
        self.client.post("/logout/")
        self.client.post("/", {"email": "beta", "password": "beta"})
        self.assertRedirects(self.client.get("/"), "/character/edit/", fetch_redirect_response=False)
        self.assertEqual(Character.objects.get().pk, character.pk)
        self.assertEqual(Character.objects.get().position, [12, 0, 16])

    def test_seed_restores_only_the_deliberate_demo_password(self):
        account = Account.objects.create_user("beta@example.invalid", "old-demo-password")
        self.seed()
        account.refresh_from_db()
        self.assertTrue(account.check_password("beta"))

    def test_seed_refuses_privileged_or_inactive_identity(self):
        for flags in ({"is_staff": True}, {"is_superuser": True}, {"is_active": False}):
            with self.subTest(flags=flags):
                account = Account.objects.create_user("beta@example.invalid", "untouched", **flags)
                with self.assertRaises(CommandError):
                    self.seed()
                account.refresh_from_db()
                self.assertTrue(account.check_password("untouched"))
                account.delete()
        for relation, value in (("groups", Group.objects.create(name="operators")),
                                ("user_permissions", Permission.objects.first())):
            account = Account.objects.create_user("beta@example.invalid", "untouched")
            getattr(account, relation).add(value)
            with self.assertRaises(CommandError):
                self.seed()
            account.refresh_from_db()
            self.assertTrue(account.check_password("untouched"))
            account.delete()

    @override_settings(REGISTRATION_ENABLED=True)
    def test_demo_exception_does_not_weaken_public_registration(self):
        self.seed()
        response = self.client.post("/register/", {"email": "new@example.invalid",
                                   "password": "beta", "confirmation": "beta"})
        self.assertEqual(response.status_code, 200)
        self.assertFalse(Account.objects.filter(email="new@example.invalid").exists())
