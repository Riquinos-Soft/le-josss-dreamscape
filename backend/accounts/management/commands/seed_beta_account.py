from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from accounts.models import Account


class Command(BaseCommand):
    help = "Provision the deliberate public beta:beta player without resetting its character."

    @transaction.atomic
    def handle(self, *args, **options):
        # This explicit demo bootstrap is the only beta password exception.
        # Registration and password recovery keep Django's normal validators.
        account, created = Account.objects.select_for_update().get_or_create(
            email="beta@example.invalid", defaults={"is_active": True})
        if (account.is_staff or account.is_superuser or not account.is_active
                or account.groups.exists() or account.user_permissions.exists()):
            raise CommandError("Beta identity is inactive or privileged; refusing to modify it.")
        if created or not account.check_password("beta"):
            account.set_password("beta")
            account.save(update_fields=["password"])
        self.stdout.write("Public beta player ready; existing character and progress preserved.")
