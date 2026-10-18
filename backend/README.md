# Account entry and durable character test slice

Implements Spec 020's reprioritized entry flow: login → first character creation
or owned character personalization → an authenticated Godot session. The developer requested
one shared `test` / `test` account initially. `REGISTRATION_ENABLED=0` is the default;
`seed_test_account` creates only that account and never resets an existing password,
character or progress. It bypasses password validators only for this explicit seed.
No personal/customer data belongs in this shared test account.

Local account play now restores the authored Pazo (including its salon), Calle
Jacobo Risa and Bar Scandale, original NPCs and conversations, and detailed Joss
customization. Casa is excluded from map selection and trusted travel. Inventory,
quests, companion/surf systems and other-player replication are not migrated into
this durable slice. Physical phone acceptance remains pending. Production still
runs the previous deployment until the prepared correction is explicitly released.

## Local run

Requires Docker, Python 3.13 and Godot 4.7.2. From the repository root:

```sh
uv venv --python 3.13 build/account-venv
uv pip install --python build/account-venv/bin/python -r backend/requirements-test.txt
python3 tools/account_dev.py database
python3 tools/account_dev.py manage migrate
python3 tools/account_dev.py manage seed_test_account
python3 tools/export_v2_laboratory.py --godot /Applications/Godot.app/Contents/MacOS/Godot --scene account --output build/account-game
python3 tools/account_dev.py manage runserver 127.0.0.1:8008 --noreload
# In a second terminal:
python3 tools/account_dev.py /Applications/Godot.app/Contents/MacOS/Godot --headless --path game res://v2/network/authority.tscn
```

Open http://127.0.0.1:8008/ and sign in as `test` / `test`. On the first visit,
choose a name, face, hairstyle, skin, hair and clothing colors. The preview uses
the same canonical RGBA parts, material palettes and directional poses as Godot. Creation
is atomic and one character/account is enforced by a database uniqueness constraint.
A later login opens the saved character in the same preview/editor before play.
`Guardar y entrar` updates its name/appearance while preserving identity, ownership
and saved position; `Continuar sin cambios` enters without modifying it. Play fills the page without the former upper character/logout bar. Personalization
remains at account entry. An edit fences earlier game sessions and unused tickets. The HTML entry uses native
form controls for browser password managers and mobile keyboards.

`account_dev.py database` creates an isolated `dreamscape-accounts-dev` container
and volume, publishing PostgreSQL only to loopback port 55432. On subsequent runs,
use `docker start dreamscape-accounts-dev`. Generated local secrets are mode 600 in
ignored `build/account-dev.json`; preserve them alongside the Docker volume.
Stop the two terminal processes and the dev container when no longer needed.
The standalone native scene is not an account UI; the supported entry is Web.

## Persistence and failures

Django 5.2.18 LTS, PostgreSQL 18.4 and Django's Argon2id password hasher implement
the accepted ADR 007 boundary. Version selection follows the supported
[Django release list](https://www.djangoproject.com/download/) and
[password documentation](https://docs.djangoproject.com/en/5.2/topics/auth/passwords/).
Session cookies are HttpOnly/SameSite and Secure outside local development;
mutations require CSRF. Login attempts are limited in durable database windows.
Never expose the development server or the `/internal/` routes publicly.

The Web client receives a 30-second single-use ticket, held only in memory.
Headless Godot consumes it through the private API and simulates normalized movement
intents against the same authored location collision. It never trusts client positions.
A new connection fences the previous one. The authority's renewable epoch fences
restarted processes; no other service has direct database access.

The authority commits safe grounded positions every five seconds and on orderly
exit. Map travel requires overlap with the authored exit; only destination IDs are
accepted. The server selects and validates arrival, freezes movement during the
transaction and commits place/position together before acknowledging travel. Salon
passages use the same trusted floor/commit boundary. NPC conversations validate
speaker ID, reach and line of sight; patrol pauses during an accepted conversation.
An abrupt close/crash can lose movement after the last confirmed checkpoint.
A database/connection error stops play and offers reconnection; it never creates
an empty replacement character. The fullscreen UI shows connection errors temporarily.
No localStorage save is used. Gameplay objects/quests are not yet persisted.

Registration/verification and password recovery code is prepared and tested, but
public registration stays disabled pending a working outgoing-mail sender. Development mail
uses ignored `build/account-mail/`; it is not delivered. Public registration requires
working mail, removal/retirement of the shared test credential, operator retention
choices and offsite recovery arrangements from Spec 020 D4.

## Verification

```sh
python3 tools/account_dev.py manage test accounts
python3 tools/account_dev.py manage makemigrations --check --dry-run
python3 tools/account_dev.py build/account-venv/bin/python tools/test_account_roundtrip.py --godot /Applications/Godot.app/Contents/MacOS/Godot
```

The last command creates and removes a new disposable database on the local test
PostgreSQL server, starts HTTP/Godot processes on ports 8018/9090, and exercises real
HTTP/WebSocket creation, movement, logout/resume, ticket replay, connection fencing,
forged position rejection and authority restart. It also walks the palace stairs,
enters/returns from the salon, talks to Brais and the bartender, travels through all
public destinations, rejects Casa and verifies fresh-connection Scandale resume.
It does not reset the development
account. Logs go to ignored `build/verification/v2/accounts/`. CI runs both suites.
See [deployment instructions](../deploy/ovh/ACCOUNTS.md) before enabling the service.
