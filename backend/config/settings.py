"""Same-origin account service. Production secrets must be supplied by the operator."""
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG = os.environ.get("DREAMSCAPE_DEV") == "1"
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",")
ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"
INSTALLED_APPS = ["django.contrib.auth", "django.contrib.contenttypes", "django.contrib.sessions",
                  "django.contrib.staticfiles", "accounts"]
MIDDLEWARE = ["django.middleware.security.SecurityMiddleware", "django.contrib.sessions.middleware.SessionMiddleware",
              "django.middleware.common.CommonMiddleware", "django.middleware.csrf.CsrfViewMiddleware",
              "django.contrib.auth.middleware.AuthenticationMiddleware", "django.middleware.clickjacking.XFrameOptionsMiddleware", "accounts.middleware.NoStoreMiddleware"]
TEMPLATES = [{"BACKEND": "django.template.backends.django.DjangoTemplates", "APP_DIRS": True,
              "OPTIONS": {"context_processors": ["django.template.context_processors.request",
                                                  "django.contrib.auth.context_processors.auth"]}}]
DATABASES = {"default": {"ENGINE": "django.db.backends.postgresql",
    "NAME": os.environ.get("PGDATABASE", "dreamscape_accounts_dev"),
    "USER": os.environ.get("PGUSER", "dreamscape_dev"), "PASSWORD": os.environ["PGPASSWORD"],
    "HOST": os.environ.get("PGHOST", "127.0.0.1"), "PORT": os.environ.get("PGPORT", "55432")}}
AUTH_USER_MODEL = "accounts.Account"
PASSWORD_HASHERS = ["django.contrib.auth.hashers.Argon2PasswordHasher"]
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator", "OPTIONS": {"min_length": 10}},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"}]
LANGUAGE_CODE = "es"
USE_TZ = True
TIME_ZONE = "UTC"
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "static-collected"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_AGE = 604800
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "SAMEORIGIN"
# Proxy must overwrite this header; never expose the application port publicly.
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
CSRF_TRUSTED_ORIGINS = os.environ.get("DJANGO_TRUSTED_ORIGINS", "").split(",") if os.environ.get("DJANGO_TRUSTED_ORIGINS") else []
EMAIL_BACKEND = os.environ.get("EMAIL_BACKEND", "django.core.mail.backends.filebased.EmailBackend" if DEBUG else "django.core.mail.backends.smtp.EmailBackend")
EMAIL_FILE_PATH = os.environ.get("EMAIL_FILE_PATH", str(BASE_DIR.parent / "build/account-mail"))
EMAIL_HOST = os.environ.get("EMAIL_HOST", "")
EMAIL_PORT = int(os.environ.get("EMAIL_PORT", "587"))
EMAIL_USE_TLS = True
EMAIL_HOST_USER = os.environ.get("EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.environ.get("EMAIL_HOST_PASSWORD", "")
EMAIL_TIMEOUT = 10
DEFAULT_FROM_EMAIL = os.environ.get("DEFAULT_FROM_EMAIL", "Dreamscape <noreply@localhost>")
PUBLIC_ORIGIN = os.environ.get("PUBLIC_ORIGIN", "http://127.0.0.1:8008")
REGISTRATION_ENABLED = os.environ.get("REGISTRATION_ENABLED") == "1"
AUTHORITY_SECRET = os.environ["AUTHORITY_SECRET"]
GAME_SOCKET_URL = os.environ.get("GAME_SOCKET_URL", "ws://127.0.0.1:9080")
GAME_EXPORT_DIR = Path(os.environ.get("GAME_EXPORT_DIR", str(BASE_DIR.parent / "build/account-game")))
PASSWORD_RESET_TIMEOUT = 3600
