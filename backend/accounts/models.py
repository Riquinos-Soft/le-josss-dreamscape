import uuid
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.db.models.functions import Lower


class AccountManager(BaseUserManager):
    def create_user(self, email=None, password=None, **extra):
        if not email and not extra.get("username"):
            raise ValueError("An email or username is required.")
        user = self.model(email=email.strip().lower() if email else None, **extra)
        user.set_password(password)
        user.save(using=self._db)
        return user


    def get_by_natural_key(self, identifier):
        identifier = identifier.strip().lower()
        return self.get(**({"email": identifier} if "@" in identifier else {"username": identifier}))


class Account(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=24, unique=True, null=True, blank=True)
    email = models.EmailField(unique=True, null=True, blank=True)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []
    objects = AccountManager()

    def get_username(self):
        return self.username or self.email or ""

    class Meta:
        constraints = [models.UniqueConstraint(Lower("email"), name="account_email_case_unique"),
                       models.UniqueConstraint(Lower("username"), name="account_username_case_unique")]


class Character(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    account = models.OneToOneField(Account, on_delete=models.CASCADE)
    name = models.CharField(max_length=24)
    appearance = models.JSONField()
    place = models.CharField(max_length=40, default="lourizan")
    position = models.JSONField(default=list)
    revision = models.PositiveBigIntegerField(default=0)
    generation = models.PositiveBigIntegerField(default=0)
    checkpoint_sequence = models.PositiveBigIntegerField(default=0)
    active_session = models.CharField(max_length=40, blank=True)
    saved_at = models.DateTimeField(auto_now=True)


class LoginBucket(models.Model):
    key = models.CharField(max_length=64, primary_key=True)
    window = models.BigIntegerField()
    attempts = models.PositiveIntegerField(default=0)


class GameTicket(models.Model):
    digest = models.CharField(max_length=64, primary_key=True)
    character = models.ForeignKey(Character, on_delete=models.CASCADE)
    session_key = models.CharField(max_length=40)
    expires_at = models.DateTimeField()


class Authority(models.Model):
    id = models.PositiveSmallIntegerField(primary_key=True, default=1)
    epoch = models.UUIDField(default=uuid.uuid4)
    expires_at = models.DateTimeField()
