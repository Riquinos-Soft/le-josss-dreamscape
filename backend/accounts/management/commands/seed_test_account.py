from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from accounts.models import Account


class Command(BaseCommand):
    help = "Create the explicitly requested test:test account, without resetting existing state."

    def handle(self, *args, **options):
        if settings.REGISTRATION_ENABLED:
            raise CommandError("Disable public registration before provisioning the shared test account.")
        if Account.objects.filter(email="test@example.invalid").exists():
            self.stdout.write("Test account already exists; password and character preserved.")
            return
        Account.objects.create_user("test@example.invalid", "test", is_active=True)
        self.stdout.write("Test account created. No character created until first login.")
