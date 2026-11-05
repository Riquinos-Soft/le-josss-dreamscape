from django.core import mail
from django.db import IntegrityError, transaction
from django.test import Client, TestCase, override_settings

from .models import Account


@override_settings(EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend", REGISTRATION_ENABLED=False)
class UsernameSignupTests(TestCase):
    data = {"username": "joss_player", "password": "A-strong-8430-password", "confirmation": "A-strong-8430-password"}

    def test_three_fields_and_invalid_registration_never_creates_account(self):
        page = self.client.get("/register/")
        self.assertContains(page, 'name="username"')
        self.assertContains(page, 'name="password"')
        self.assertContains(page, 'name="confirmation"')
        self.assertNotContains(page, 'type="email"')
        for change in ({"confirmation": "different"}, {"password": "short", "confirmation": "short"},
                       {"username": "x"}, {"username": "a@b.com"}, {"username": "../path"},
                       {"username": "test"}, {"username": "test2"}, {"username": "BETA"},
                       {"username": "<script>"}, {"username": "1player"}):
            with self.subTest(change=change):
                # Isolate request throttling while testing independent invalid submissions.
                response = Client(REMOTE_ADDR="127.0.0." + str(len(change) + len(change.get("username", "")))).post("/register/", {**self.data, **change})
                self.assertEqual(response.status_code, 200)
                self.assertFalse(Account.objects.exists())
        self.assertEqual(len(mail.outbox), 0)

    def test_csrf_required_and_no_anonymous_ticket(self):
        browser = Client(enforce_csrf_checks=True)
        browser.get("/register/")
        self.assertEqual(browser.post("/register/", self.data).status_code, 403)
        token = browser.cookies["csrftoken"].value
        self.assertEqual(browser.post("/api/ticket/", {"csrfmiddlewaretoken": token}).status_code, 401)
        self.assertEqual(browser.post("/register/", {**self.data, "csrfmiddlewaretoken": token}).status_code, 302)
        self.assertIn("_auth_user_id", browser.session)
        self.assertEqual(browser.post("/api/ticket/", {"csrfmiddlewaretoken": browser.cookies["csrftoken"].value}).status_code, 409)

    def test_database_enforces_case_insensitive_identity_and_multiple_no_email_accounts(self):
        Account.objects.create_user(username="player", password=self.data["password"])
        Account.objects.create_user(username="other", password=self.data["password"])
        self.assertEqual(Account.objects.filter(email__isnull=True).count(), 2)
        with self.assertRaises(IntegrityError), transaction.atomic():
            Account.objects.create_user(username="PLAYER", password=self.data["password"])

    def test_rejected_login_and_login_throttle(self):
        self.client.post("/register/", self.data)
        self.client.post("/logout/")
        self.assertContains(self.client.post("/", {"email": "joss_player", "password": "wrong"}), "No se pudo acceder")
        self.assertNotIn("_auth_user_id", self.client.session)
        for _ in range(10):
            self.client.post("/", {"email": "joss_player", "password": "wrong"})
        self.assertContains(self.client.post("/", {"email": "joss_player", "password": self.data["password"]}), "Demasiados intentos")

    def test_authenticated_visitor_cannot_create_a_second_account(self):
        self.client.post("/register/", self.data)
        response = self.client.post("/register/", {**self.data, "username": "second"})
        self.assertEqual(response.status_code, 302)
        self.assertEqual(Account.objects.count(), 1)
