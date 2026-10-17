# Account service deployment

The single-test-account deployment was activated on OVH on 2026-10-17, after
administrator SSH access was restored. PostgreSQL migrations, HTTPS/WSS creation,
movement, logout/resume and service-restart recovery passed. The developer has
now authorized public registration; it remains disabled until outgoing mail and
the documented public launch requirements below are configured and verified.
The static-only Actions deployment cannot create services or migrate PostgreSQL.

## Reviewable deployment

Use the tested commit, copy its checkout to `/opt/dreamscape/source`, and copy
`compose.accounts.yaml`, `nginx.accounts.conf` and `prepare_accounts.py` from this
directory to `/opt/dreamscape`. Keep the existing `compose.yaml`, volume, secrets,
receiver, static releases and TLS gateway. Do not copy local build secrets.
CI now includes a third Web export at `account-game/` in the same release; ensure
that export has been deployed before activation. The combined payload remains
below the existing 256 MiB receiver limit (approximately 220 MiB locally).

The overlay adds Django and a headless Godot authority on an internal application
network. Only Django joins the data network. Neither exposes a host port.
The existing loopback Web host and Caddy HTTPS route are retained. The new nginx
configuration denies `/internal/`, forwards account pages and `/ws/`, and serves
`/game/`, `/static/` and `/parts/`. `/legacy/` preserves the old world and `/v2/`
preserves the character laboratory. The normal static-only Compose remains a
rollback path; activating this overlay is a separate explicit operator step.

On the host, after reviewing the checked-in helper and configuration:

```sh
cd /opt/dreamscape
sudo ./backup.sh
sudo python3 prepare_accounts.py init
sudo docker compose -f compose.yaml -f compose.accounts.yaml build accounts authority
sudo python3 prepare_accounts.py migrate
sudo docker compose -f compose.yaml -f compose.accounts.yaml config --quiet
# Activation after the additive migration and image builds succeed:
sudo docker compose -f compose.yaml -f compose.accounts.yaml up -d --force-recreate accounts authority web
sudo docker compose -f compose.yaml -f compose.accounts.yaml exec -T web nginx -t
```

`init` generates mode-600 runtime, migration and authority environment files once,
creates the isolated `accounts` schema inside the existing project database, and
creates restricted `dreamscape_runtime` / `dreamscape_migrator` roles. Repeating it
preserves credentials; an incomplete secret set stops instead of rotating values.
The runtime role gets data access through schema-scoped default privileges, not
DDL or administrative privileges. `migrate` uses migration credentials only for
Django's additive migration, then creates the test account with runtime credentials.
It does not delete or recreate an existing character. The helper never enables nginx.

The account health check gates authority startup; dependent restarts refresh
nginx upstream addresses after container replacement. Godot has a writable tmpfs
owned by UID/GID 10001, and Gunicorn disables its unused control socket so both
services can retain read-only root filesystems. `DJANGO_ALLOWED_HOSTS` must include
the private `accounts` service name as well as the public hostname. Existing
secret files are preserved by `init`; add that private hostname when upgrading
an earlier prepared environment, without changing any credentials.

Before calling activation successful, verify public login, first character creation,
logout/relogin, character personalization without position reset, and
changed-position recovery. Return logins show the existing character editor before
entering; `Mi personaje` returns there after the game save acknowledgement. Check that `/internal/start/` returns
404 publicly, `/ws/` connects over TLS, account cookies are Secure/HttpOnly, and
other hosted sites remain healthy. Confirm the 5-second save indicator and disconnect
feedback. Run a PostgreSQL dump/restore comparison with the actual test character
into a separate disposable database. Existing local-disk backups remain local-disk
backups; no offsite recovery claim is made.

A production service restart must restore the same character ID, appearance and
committed position. Two tabs with the shared account intentionally replace each
other's game connection. The initial scene is the validation room; this package
does not migrate the legacy world or enable multiplayer replication.

## Rollback and operational limits

If account activation fails, restore static-only hosting without dropping data:

```sh
cd /opt/dreamscape
sudo docker compose -f compose.yaml up -d --force-recreate web
sudo docker compose -f compose.yaml -f compose.accounts.yaml stop authority accounts
```

Do not run `down -v` or reverse/drop the account schema. Application rollback keeps
all committed characters for a later retry. An old static client cannot load account
progress; it is the preserved comparison release. Future account releases must
retain migration compatibility or use an expand/contract schema rollout.

Public registration was requested on 2026-10-17. It remains
`REGISTRATION_ENABLED=0` until actual mail delivery and recovery are verified; the seed password is the developer's
explicitly requested shared test credential. No real-user mail or personal data is
needed for this phase. Public registration requires mail delivery, test credential
retirement and the D4 retention/offsite recovery decisions. See
[backend operation](../../backend/README.md) and [Spec 020](../../docs/specs/020-persistent-online-vertical.md).

SMTP is not configured in the generated environment. Configure the selected
`EMAIL_HOST`, `EMAIL_PORT` (STARTTLS), `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD` and
`DEFAULT_FROM_EMAIL` directly in the protected runtime environment; never commit
them. The current account networks are internal, so SMTP setup must also provide
outbound connectivity for the account service while keeping PostgreSQL and the
authority private. Do not enable registration using a development mail sink.
