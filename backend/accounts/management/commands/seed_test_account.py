from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from accounts.models import Account


class Command(BaseCommand):
    help = "Create test:test, or test2:test2 with --second, without resetting existing state."

    def add_arguments(self, parser):
        parser.add_argument("--second", action="store_true", help="Provision the second independent test account.")

    def handle(self, *args, **options):
        if settings.REGISTRATION_ENABLED:
            raise CommandError("Disable public registration before provisioning the shared test account.")
        alias = "test2" if options["second"] else "test"
        email = alias + "@example.invalid"
        if Account.objects.filter(email=email).exists():
            self.stdout.write("Test account already exists; password and character preserved.")
            return
        Account.objects.create_user(email, alias, is_active=True)
        self.stdout.write("Test account created. No character created until first login.")
