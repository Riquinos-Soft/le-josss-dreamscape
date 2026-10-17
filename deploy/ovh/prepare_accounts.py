"""Prepare isolated account roles/secrets or apply additive migrations; never enable the proxy."""
import argparse
import os
from pathlib import Path
import secrets
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("action", choices=["init", "migrate"])
parser.add_argument("--root", type=Path, default=Path("/opt/dreamscape"))
args = parser.parse_args()
root = args.root.resolve()
secret_dir = root / ".secrets"
compose = ["docker", "compose", "-f", str(root / "compose.yaml")]
account_compose = compose + ["-f", str(root / "compose.accounts.yaml")]


def read_env(path):
    return dict(line.split("=", 1) for line in path.read_text().splitlines() if line and not line.startswith("#"))


def write_env(path, values):
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, "w") as stream:
        stream.write("".join(key + "=" + value + "\n" for key, value in values.items()))


if args.action == "init":
    secret_dir.mkdir(mode=0o700, exist_ok=True)
    names = ["accounts.env", "authority.env", "migration.env"]
    present = [(secret_dir / name).exists() for name in names]
    if any(present) and not all(present):
        raise SystemExit("Incomplete secret set; restore the existing files before proceeding. Nothing rotated.")
    if not any(present):
        authority_secret = secrets.token_urlsafe(40)
        write_env(secret_dir / "accounts.env", {
            "DJANGO_SECRET_KEY": secrets.token_urlsafe(40), "AUTHORITY_SECRET": authority_secret,
            "PGHOST": "db", "PGPORT": "5432", "PGDATABASE": "dreamscape", "PGUSER": "dreamscape_runtime",
            "PGPASSWORD": secrets.token_urlsafe(40), "REGISTRATION_ENABLED": "0",
            "DJANGO_ALLOWED_HOSTS": "dreamscape.198.244.233.153.sslip.io,accounts",
            "DJANGO_TRUSTED_ORIGINS": "https://dreamscape.198.244.233.153.sslip.io",
            "PUBLIC_ORIGIN": "https://dreamscape.198.244.233.153.sslip.io",
            "GAME_SOCKET_URL": "wss://dreamscape.198.244.233.153.sslip.io/ws/"})
        write_env(secret_dir / "authority.env", {"AUTHORITY_SECRET": authority_secret})
        write_env(secret_dir / "migration.env", {"PGUSER": "dreamscape_migrator", "PGPASSWORD": secrets.token_urlsafe(40)})
    runtime = read_env(secret_dir / "accounts.env")
    migration = read_env(secret_dir / "migration.env")
    def quote(value):
        return "'" + value.replace("'", "''") + "'"
    statement = "BEGIN;\n"
    for name, password in [("dreamscape_runtime", runtime["PGPASSWORD"]), ("dreamscape_migrator", migration["PGPASSWORD"])]:
        statement += ("DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = " + quote(name) + ") THEN "
                      "CREATE ROLE " + name + " LOGIN PASSWORD " + quote(password) + "; END IF; END $$;\n")
    statement += """
CREATE SCHEMA IF NOT EXISTS accounts AUTHORIZATION dreamscape_migrator;
GRANT CONNECT ON DATABASE dreamscape TO dreamscape_runtime, dreamscape_migrator;
GRANT USAGE ON SCHEMA accounts TO dreamscape_runtime;
ALTER ROLE dreamscape_runtime IN DATABASE dreamscape SET search_path = accounts;
ALTER ROLE dreamscape_migrator IN DATABASE dreamscape SET search_path = accounts;
ALTER DEFAULT PRIVILEGES FOR ROLE dreamscape_migrator IN SCHEMA accounts GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO dreamscape_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE dreamscape_migrator IN SCHEMA accounts GRANT USAGE, SELECT ON SEQUENCES TO dreamscape_runtime;
COMMIT;
"""
    result = subprocess.run(compose + ["exec", "-T", "db", "psql", "-U", "dreamscape_admin", "-d", "dreamscape", "-v", "ON_ERROR_STOP=1"],
                            input=statement, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=root)
    if result.returncode:
        safe_error = result.stderr.replace(runtime["PGPASSWORD"], "[redacted]").replace(migration["PGPASSWORD"], "[redacted]")
        raise SystemExit(safe_error)
    print("Account schema/roles prepared; credentials preserved. Public proxy unchanged.")
else:
    env = {**os.environ, **read_env(secret_dir / "migration.env")}
    subprocess.run(account_compose + ["run", "--rm", "--no-deps", "-e", "PGUSER", "-e", "PGPASSWORD", "accounts",
                                     "python", "manage.py", "migrate", "--noinput"], env=env, cwd=root, check=True)
    subprocess.run(account_compose + ["run", "--rm", "--no-deps", "accounts", "python", "manage.py", "seed_test_account"], cwd=root, check=True)
