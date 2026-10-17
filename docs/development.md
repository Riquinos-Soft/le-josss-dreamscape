# Development setup and verified baseline

## Character personalization before returning to play — 2026-10-17

Follow-up to the deployment checkpoint below, based on `aea884e`. The developer
reported that login entered an unrelated room instead of character creation. The
shared test account had already been initialized by the production persistence
smoke check. Corrected the return flow: login now opens the owned character editor
with its current name and appearance, `Guardar y entrar` and `Continuar sin cambios`.
New accounts retain first creation. `Mi personaje` in play waits for a confirmed
movement save before navigating back to the editor. Editing updates only the
owned character's name/appearance and session fencing fields, preserving its ID,
ownership, place and position; unused tickets and older generations are invalidated.
No schema migration or game export change is required.

Checks:

- `python3 tools/account_dev.py manage test accounts`: 15 tests pass, including
  invalid edits, ownership, preserved progress, GET without mutation and fencing
  of the previous game generation/tickets.
- `python3 tools/account_dev.py build/account-venv/bin/python tools/test_account_roundtrip.py --godot /Applications/Godot.app/Contents/MacOS/Godot`:
  real HTTP/WebSocket/PostgreSQL round trip passes in a disposable local database,
  including appearance/name editing, unchanged position and returning to the editor.
- `node build/verification/v2/accounts/test_play_exit.cjs`: ignored fixture driver
  executes the actual `play.js`; both personalization and logout wait for a trusted
  `left` acknowledgement before form navigation, and forged-origin messages do not
  navigate. This is a bounded script check, not a full browser game interaction.
- Updated backend image built on OVH; account, authority and web recreation passed
  account readiness gating. Chrome desktop loaded the deployed `/character/edit/`
  page with current name/options, pixel preview and entry controls. Screenshot
  evidence: `build/verification/v2/accounts/personalization-chrome.png`. The page
  was visibly inspected with the computer-use skill; no complete manual save/return
  cycle, console review, Safari or physical iPhone acceptance is claimed.

The active location is still the P2 validation room. Public registration and real
verification/recovery mail remain disabled pending sender configuration and D4
launch choices. The developer has no domain; Gmail with an app password was offered
as a provisional sender, and a sender account is still required. No mail was sent.


## OVH account activation and registration checkpoint — 2026-10-17

This supersedes the historical administrator-SSH blocker below. Source baseline
`b5e9089` was staged from tracked files only at `/opt/dreamscape/source`.
Administrator SSH access was restored; existing PostgreSQL 18.4 data/volume,
static releases and TLS gateway were retained. A pre-migration dump was taken,
`prepare_accounts.py init` created isolated roles/schema, both images built, and
`prepare_accounts.py migrate` applied the additive migrations and seeded `test`.
No passwords or generated runtime credentials belong in this record.

Initial production logs exposed three deployment defects: the private `accounts`
hostname was absent from Django's allowlist, Godot's tmpfs was root-owned, and
Gunicorn's unused control socket targeted its read-only home. Corrected all three;
added account readiness gating and dependent restarts to avoid authority startup
races and stale nginx container addresses. The first HTTP smoke attempt overlapped
container replacement and returned 502; after nginx restart it passed. The final
Compose setup was then validated by recreating accounts, authority and web together.
The nginx entrypoint still reports that its read-only configuration cannot be
modified for IPv6; `nginx -t` passes and the explicit IPv4 listener serves the gateway.

Production checks using HTTPS and WSS at
`https://dreamscape.198.244.233.153.sslip.io/` passed: first character creation
(Joss on the shared test account), movement, acknowledged logout, Secure/HttpOnly
session cookie, fresh-session resume, and preservation of character ID, appearance
and position after service recreation. `/internal/start/` returned 404; `/game/`,
`/legacy/` and `/v2/` returned 200. Commands include the deployment sequence in
[ACCOUNTS.md](../deploy/ovh/ACCOUNTS.md), `nginx -t`, and the ignored HTTP/WSS driver
`build/account-venv/bin/python build/verification/v2/accounts/production_smoke.py`.
These are programmatic public endpoint checks, not a manual Chrome or physical
phone gameplay pass. No game/export code changed; the existing deployed Web export
was served successfully.

A fresh production dump, `dreamscape-20261017T211553Z.dump` (43,468 bytes), was
restored into a new disposable database. Character ID, ownership, name, appearance,
place and position matched production; the disposable database was removed.
The first comparison used a dump taken during the active smoke test and failed;
repeating after logout with a fresh dump passed. Helper/evidence is under ignored
`build/verification/v2/accounts/verify_production_restore.py`. Local disk backup
retention is seven days; offsite recovery and D4 operator choices remain unresolved.

The developer explicitly requested public self-registration and outgoing mail.
`python3 tools/account_dev.py manage test accounts` passes 13 tests, including a
new registration → verification → first creation → fresh-session resume/isolation
check with in-memory mail. No real sender/domain is configured; Gmail with an app
password was offered as a provisional option, pending operator selection. Public
registration is still disabled. Next: sender setup, actual verification/recovery
mail tests, test credential retirement and D4 recovery choices. The developer then
reported that the existing test character bypasses creation and requested clearer
access to personalization; the implemented follow-up above supersedes that UI
checkpoint without deleting or resetting the existing character or saved position.


## Bar Scandale — 2026-10-15

Follow-up release verification on 2026-10-15: all 23 suites in `make check`
pass, including 125 Scandale checks; import, format, lint and Web export pass.
Command: `PATH="$PWD/build/verification/scandale/tools-env/bin:$PATH" make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot` (one shell line).
Evidence: `build/verification/scandale/pre-push-check.log`. The initial attempt
stopped because `gdformat` was absent from PATH; an ignored local virtualenv using
`requirements-dev.txt` resolved it. The known `pkg_resources` warning remains;
no Godot runtime errors or warnings were reported.
Desktop Chrome loaded the existing Scandale Web export at `http://127.0.0.1:8013/`
and showed the initial Pazo scene with a small keyboard-driven movement. Browser
automation sent brief taps, so this is only a startup/input smoke check, not a
completed browser bar route. Native route evidence above remains authoritative
for the bar interactions; Safari and physical-device acceptance remain pending.
The developer explicitly authorized pushing the completed bar work, including
the preceding local account-first commit, on this continuation.


Spec 023 adds the requested destination to the existing travel map, with an authored
photo-inspired interior, blond/blue-shirt bartender and 12 Spanish dark jokes with
no immediate repeat. Five supplied HEIF photos were inspected via ignored PNG
conversions. No scan or measured dimensions were supplied; the 6 × 10 m cutaway is
an estimate. Provenance: `assets/source/environments/scandale/README.md`.
The new blond/navy palettes also appear consistently in account creation previews.

Godot 4.7.2 commands from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_scandale.gd
/Applications/Godot.app/Contents/MacOS/Godot --path game --script res://tests/test_scandale.gd -- --capture
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_location_travel.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_lourizan_dialogue.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_v2_appearance.gd
python3 tools/account_dev.py manage test accounts
mkdir -p build/scandale-web
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --export-release Web ../build/scandale-web/index.html
```

Scandale: 125 checks pass headless and natively on Apple M5 / OpenGL Compatibility.
Travel: 119; Lucas dialogue: 183; appearance: 203; backend/PostgreSQL: 12. Native captures inspected at
1280×720 and 844×390: arrival, conversation day/night and compact travel map.
The real controller walks the aisle, collides with the counter and returns to the
exit; keyboard and touch dialogue share the existing interaction flow. The hanging
ball and stool geometry were refined after capture inspection for player readability.
Logs/captures: ignored `build/verification/scandale/`; Web output: `build/scandale-web/`.

The existing Lucas dialogue test could randomly accept a surf offer and become
stuck in the minigame. Its dialogue-only setup now excludes that offer explicitly;
production surf behavior is unchanged. The first export attempt lacked its output
directory; creating it resolved the failure. gdtoolkit retains its existing
`pkg_resources` deprecation warning. Developer visual acceptance and browser/physical
iPhone 16 Pro + Chrome gameplay remain unverified for this increment. Account-service
production activation remains blocked on administrator SSH access; this location
uses existing world travel and makes no new durable-progress claim.

## Account-first test slice — 2026-10-14

Base `d89d3ec`, clean main. Developer corrected P3 priority to login/register →
first character creation or existing character resume, then explicitly requested
only `test:test` initially. Public registration is disabled; mail delivery is deferred.
Implemented Django/PostgreSQL account ownership and migrations, native HTML login
and creation with the P2 part preview, session/CSRF/rate limits, single-use tickets,
a private persistence boundary, headless Godot movement simulation, fenced sessions/
authority and 5-second grounded checkpoints. Logout waits for commit acknowledgement.
The playable location is the existing validation room, not migrated Jacobo Risa.

Checks: 12 backend tests on PostgreSQL 18.4; real HTTP/WebSocket round trip in a new
disposable database (creation, movement, fresh-browser resume, same appearance/ID,
replayed ticket, forged position, duplicate login fencing, authority restart and
unknown command rejection); 19 collision checks headless and natively; 203 appearance
checks; account Web export; backend Docker image build. A local PostgreSQL dump was
restored into a separate disposable database and compared for character ID, name,
appearance and position. No offsite/production restore or recovery-time claim.
Commands are in `backend/README.md`; logs/export are under ignored
`build/verification/v2/accounts/`, `build/account-*.log`, and `build/account-game/`.

Chrome UI evidence: login with `test:test`, first creation of local test character
Joss, preview with hairstyle/clothing options, Web entry, logout to login and return
login bypassing creation. Login layout inspected at 844×390. During the first UI
logout test the server committed but closed the WebSocket before the client consumed
its acknowledgement; the server now allows the client to close after `left`, with
a bounded timeout. Retested successfully in Chrome. A compact viewport is not a
physical iPhone test. Keyboard taps were exercised but no sustained manual traversal
is claimed; real movement/checkpoint evidence comes from the integration client.

Warnings: gdtoolkit emits its existing `pkg_resources` deprecation; Chrome emits
existing MetaMask extension listener/orphaned-stream warnings. An early disposable
integration script used a deprecated websockets call; the committed integration
uses context managers and passes without that warning. Native UI automation permissions
were unavailable, so browser verification used the existing Chrome extension.

Deployment: source and explicit opt-in Compose/nginx/migration helper are prepared;
CI tests accounts and packages the account Web client alongside legacy and `/v2/`.
Administrator SSH attempt returned `Permission denied (publickey,password)`; no
production schema/container/proxy changes were made. The restricted static receiver
cannot activate backend services. See `deploy/ovh/ACCOUNTS.md` for activation and
non-destructive rollback. Next: obtain administrator access, deploy the reviewed
services/roles/additive migration, verify public login/resume, then physical-device
and world migration work. Do not describe local success as a production fix.

## V2 production preview publication — 2026-10-14

Developer reported that the new work did not work in production. Investigation
confirmed successful CI/deployment run 38572860692 and public `/release.txt` at
`e5fab04725606bddad8fd0664952894bdd3d1015`; the root game loaded in desktop Chrome
155.0.8059.40 without engine errors. The laboratory had only a separate local
export, so pushing its source did not create a public laboratory entry. A more
specific iPhone failure description was requested; physical results remain pending.

The fix publishes the laboratory at `/v2/` in the same CI-tested release while the
root retains the existing game. `tools/export_v2_laboratory.py --output build/web/v2`
builds a disposable project copy. CI now runs the 203 appearance and 19 route checks,
exports both entries, and checks preview HTML/WASM/PCK on public HTTPS after deploy.
No server receiver, proxy, account, database or production main-scene change.
The nested export duplicates engine/game files on the host, but each entry loads
only its own files; the combined release remains below the receiver's 256 MiB limit.

First deployment attempt for this fix (run 38575219497) passed game tests but
failed at preview export with `python3: not found`. The Godot CI container now
installs Python 3 explicitly before running the export helper; this installation
is confined to the ephemeral build container. The next attempt (38575628340)
exposed `Unable to load fontconfig, system font support is disabled` during the
fresh preview import. Strict error scanning rejected that import despite Godot's
zero exit status. The job now installs `libfontconfig1` together with Python before
any import, addressing the missing system dependency for both exports. Production
remains on the prior working release until the new gates pass.

Local verification: both V2 tests pass; default and nested Web exports pass;
workflow YAML and all 12 shell steps parse; all five deployment receiver tests pass;
documentation and whitespace checks pass. Logs are in ignored
`build/verification/v2/production-preview/`. This is deployment packaging/tooling
work; the native route evidence from P2c is retained without another visual/art pass.
Existing gdtoolkit and browser extension warnings remain as previously recorded.

Successful publication: run **38576229271** passed lint/deployment safety, Godot
checks, both Web exports and OVH deployment. Public `/release.txt` returned
`fc009d24325b3ca64957d0b637f3c059aeb77cd2`; `/v2/` and `/v2/index.wasm` returned
200 with correct MIME. Desktop Chrome loaded the public preview and "Verificar
recorrido" returned **19/19**, with `{"checks":19,"errors":[],"failures":0}` at
14:01:33.770 UTC. The green result was inspected. Full CI log scan found no
`ERROR:`, `SCRIPT ERROR` or `WARNING:` entries. Browser extension warnings remain;
no game error was observed. Physical iPhone review and clarification of any
separate root-game/touch failure remain pending; this proves the previously missing
public laboratory entry works, not an unobserved phone result.

Release verification is enforced by the workflow after publication. Reproduce:
`gh run list --branch main`, inspect the new run's gates/deploy result, then verify
`/release.txt` and open
https://dreamscape.198.244.233.153.sslip.io/v2/ in Chrome. Use "Verificar recorrido"
for 19/19 before the iPhone 16 Pro + Chrome physical review. This preview is a
public review entry, not acceptance or a replacement of the production world.

## V2 P2c Web collision route and physical target — 2026-10-14

Base `7feec2d`, main synchronized; the requested push reported everything up to date.
Extracted the existing 19 collision/input checks into
`game/v2/validation/collision_route.gd`, reused by the native test and a laboratory
"Verificar recorrido" button. The route resets to its known spawn, disables the
appearance/route buttons and normal movement polling for collision cases, reports
failed assertions and positions, then restores local input. The native test starts
it below the fall threshold to verify repeatable initialization. It can also start
with `-- --verify-route` in a native laboratory launch. This adds validation tooling
in the isolated scene; no controller rule or production entry point changed.

Commands: Godot `--headless --path game --fixed-fps 60 --script
res://tests/test_v2_laboratory.gd` and the native repeat both pass **19/19**.
`test_v2_appearance.gd` still passes **203/203**. Targeted gdformat/gdlint,
`python3 tools/check_docs.py`, `git diff --check`, production Web export and
`python3 tools/export_v2_laboratory.py --godot /Applications/Godot.app/Contents/MacOS/Godot`
pass. Evidence is under ignored `build/verification/v2/P2c/`.

Chrome 155.0.8059.40 via the extension ran the real exported WebAssembly route:
19/19 at the normal desktop viewport, then 19/19 at 844×390 with the alternate
appearance. Console results: `{"checks":19,"errors":[],"failures":0}` at
13:26:22.554 UTC and 13:27:41.005 UTC; the green on-screen result was inspected.
After hardening route initialization, the final export also passed 19/19 at
13:33:09.669 UTC.
These are actual Web collision/animation/input-code assertions, with scripted
starting positions and movement intent. Synthetic touch/focus calls do not certify
OS touch delivery, finger ergonomics, manual traversal feel or background recovery
on a physical phone. No engine errors observed; the previously documented browser
extension warnings and gdtoolkit deprecation remain visible.

Developer confirmed **iPhone 16 Pro + Chrome** as the physical target in this turn.
iOS/Chrome versions, physical results and a sustained performance budget are not
assumed. A local HTTP server serves `build/v2-laboratory/` on the Mac's LAN IPv4,
port 8006; HTML and WASM respond 200 (WASM MIME `application/wasm`). Initial probes
timed out before the listener became ready; later probes succeeded. No firewall,
router, TLS or production hosting changes were made. Phone reachability remains
unverified until the developer opens it from the same Wi-Fi.

Physical review procedure: serve the export with `python3 -m http.server 8006
--bind MAC_LAN_IP --directory build/v2-laboratory` (replace MAC_LAN_IP with the
Mac's current Wi-Fi IPv4; `ipconfig getifaddr en0` on this Mac). On the iPhone,
open `http://MAC_LAN_IP:8006/` in Chrome, in landscape. Run "Verificar recorrido"
and wait for 19/19 without using movement. Then manually use the left-side touch
stick through the doorway, stairs and edges; release/drag a second finger, switch
appearance, background/return and rotate back to landscape. Review head identity,
feet/occlusion, HUD readability and sustained play feel. Record iOS/Chrome versions,
duration, exact failures/warnings and developer art verdict. A passing scripted
route alone does not mark physical acceptance.

Next: developer visual/physical review with the now-known target, then resolve the
P2 expansion gate. P3 remains pending the art/movement review required by Plan 016;
no approval inferred from the request to continue or from automated assertions.

## V2 P2b shared appearance laboratory — 2026-10-14

Base `adc6f6d`; clean tree after the developer-requested push of P1/P2a.
Shared 64px pose parts now compose two appearances and a patrolling NPC. The
player can switch appearance during motion. Catalog validation rejects unknown
IDs/palettes/fields and unsupported versions. Known unavailable optional hair/face
uses an explicit fallback without altering stored IDs; required parts fail clearly.
Matching configurations share SpriteFrames; the final presenter releases the cached
composition. Physics and animation phase survive an appearance change.

Editable master and reproduction notes:
[shared human parts](../assets/source/characters/parts/README.md). Original integer
pixel shapes use shared head/neck/pelvis/foot anchors for all eight directions and
five poses; runtime parts are lossless/no-mipmap, nearest-sampled at 0.0375m/pixel.
These sample characters require developer art review; they do not establish Joss's
final replacement design. The laboratory retains the calibrated camera/capsule.
Touch release now preserves a held keyboard action; focus loss still clears both.

Commands (engine: `/Applications/Godot.app/Contents/MacOS/Godot`):

- `--headless --script assets/source/characters/parts/author_parts.gd` from root,
  then `--headless --path game --import --quit`.
- `--headless --path game --fixed-fps 60 --script res://tests/test_v2_appearance.gd`:
  **203 checks pass**, including exact head-region pixels after translation in every
  walk phase, grounded idle/walk baselines, shared NPC compositions, optional fallback,
  schema rejection and actor/phase preservation. Native repeat also passes.
- `--headless --path game --fixed-fps 60 --script res://tests/test_v2_laboratory.gd`:
  **19 checks pass**, including held-key preservation after synthetic touch release.
  Native repeat passes with desktop/compact/stair captures under the P2 directory.
- `--path game --script ../tools/capture_v2_appearance.gd`: all eight native direction
  sheets captured under `build/verification/v2/P2b/`; inspected all directions and
  the revised profile strides, plus actual laboratory scale in native and Chrome.
- `make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passes;
  `python3 tools/export_v2_laboratory.py --godot /Applications/Godot.app/Contents/MacOS/Godot`
  exports a separate laboratory to `build/v2-laboratory/` using a disposable copy,
  keeping the production main scene intact. Serve it with `python3 -m http.server
  8004 --bind 127.0.0.1 --directory build/v2-laboratory`.
- Targeted gdformat/gdlint, `python3 tools/check_docs.py` and `git diff --check` pass.
  No complete legacy gameplay suite rerun for this isolated addition.

Chrome **155.0.8059.40**, automated via the connected extension: laboratory renders,
button switches to alternate parts, repeated D input changes position/facing, NPC
patrol is visible, 844×390 resize retains rendering and reload restores the default.
Screenshots were inspected in the tool transcript. This is a bounded desktop Chrome
check, not a complete Web collision route, touch-device or Safari acceptance.
Console has extension-origin MaxListenersExceededWarning/ObjectMultiplex warnings;
no new engine error after the separate laboratory export loaded/reloaded.
The first attempt used a scene argument on the release export and failed because
Godot disables path overrides (`null function` after startup rejection). The
separate export fixes this validation setup; no template or engine change was made.
The unavailable in-app browser was bypassed using the connected Chrome browser.

Successful native/import/export logs are clean. The existing gdtoolkit
`pkg_resources` deprecation persists. Initial author/test parse issues were fixed;
all logs are in ignored `build/verification/v2/P2b/`. Functional test timing was
157ms headless/293ms native on this machine; these include assertions/composition
and are not a sustained frame-time, browser latency or device performance budget.

Handoff: P2 implementation is ready for visual/gameplay review. Next unresolved
step is developer review of the shared-pose sample, full Web traversal and physical
phone/browser information. P3 remains gated by that review; accounts, backend,
production scene migration and deployment are not part of this increment.

## V2 P2a collision laboratory — 2026-10-14

Base `931fcc4` closes the inherited P1 contract documents and offline preview.
P2a adds an isolated `game/v2/validation/laboratory.tscn`, a world-intent actor and
keyboard/touch adapter. Floor, corner, 1.6m doorway, five 0.2m risers and a 1m ledge
have matching visible dimensions and colliders. The actor retains the 1.8m capsule,
4m/s speed, 0.25m step limit and safe fall respawn. It reuses Joss and the resolved-
motion presenter temporarily; no configurable appearance implementation is claimed.

Reproduce with `/Applications/Godot.app/Contents/MacOS/Godot --path game
res://v2/validation/laboratory.tscn`. Automated route:
`/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --fixed-fps 60
--script res://tests/test_v2_laboratory.gd`; omit `--headless` for native captures.
The test is included in `make test`. All 17 assertions pass headless and natively:
intent bounds/nonfinite rejection, grounded spawn, wall/corner/door, stair ascent/
descent, blocked high ledge, fall recovery, blocked idle, synthetic touch and focus
release. Synthetic touch invokes the adapter directly, not OS touch delivery.
The initial 70-frame stair route was too short; 130 frames covers the full ascent.
Native desktop/compact and landing captures are under `build/verification/v2/P2/`.
Desktop/compact framing inspected; these are calibration blocks, not finished art.

Godot import, targeted gdformat/gdlint, Web export (`make export-web
GODOT=/Applications/Godot.app/Contents/MacOS/Godot`), documentation and whitespace
checks pass. Production entry point remains unchanged. Web export packages the
laboratory; no Chrome/Safari or physical-device playtest is claimed. Successful
Godot runs contain no warnings/errors. Existing gdtoolkit `pkg_resources`
deprecation remains; tools were found at `/private/tmp/dreamscape-dev/bin` after
bare commands were unavailable. Initial test/lint failures were fixed before commit.

Next: P2b shared pose anchors and compatible body/face/hair/clothing parts, two
appearances and an NPC, eight-direction captures and Web/device review. P2 remains
in progress; do not start P3 or claim final art/collision feel acceptance. Services,
accounts and production deployment are outside this increment.

## V2 P1 contract review — 2026-10-14

Base `358be75`, clean working tree. User explicitly requested P1 and confirmed one
character/account, two-client correctness and personal quest beer; physical phone/
browser details remain requested. ADR 006 defines shared pose parts, scene ownership
and pixel calibration; ADR 007 settles Godot authority/WSS, Python/Django accounts
and PostgreSQL transactions, receipts, reconnect/save boundaries and reward policy.
It replaces ADR 004's provisional runtime boundary, preserving hosting isolation.
Review is this session's work; no external reviewer/model switch is claimed.

Native command: `/Applications/Godot.app/Contents/MacOS/Godot --path game --script
../tools/preview_v2_contract.gd`. Current sprites and a small authored surface sample
captured at 1280×720 and 844×390 in `build/verification/v2/P1/`; inspected both.
The preview is outside runtime and uses existing resources. It establishes scale/
comparison, not configurable-part identity, completed architecture or collision.
Common face/head anchors remain an explicit P2 requirement because current generated
poses still vary. No runtime entry/assets, database or provider configuration changed.

Read official Godot Web/WebSocket/JavaScriptBridge and Django auth/password docs
plus OWASP password storage for the service boundary; exact source links are in
ADR 007. No dependency installed or version pin guessed. Run targeted script
format/lint, `python3 tools/check_docs.py` and `git diff --check` for this package.
No gameplay test suite or Web export rerun for an offline preview/document change.
Existing gdtoolkit `pkg_resources` deprecation warning remains.

P1 technical work is complete; physical validation device is pending. P2 is ready
with a bounded first increment in Plan 016. D4 still blocks public account/durable
launch; documentation is not proof of recovery, multiplayer or production capacity.


## V2 P0 inventory complete — 2026-10-14

[Baseline/migration inventory](refactor-baseline.md) records actual dependencies,
retention/replacement boundaries and the finite P2–P9 checklist. Captured reference
`753e31c` passed CI/deployment (38487188852); surf `14d2be5` is a separate addition.
Eight native reference views include day/night, terrace, salon and compact street.
Commands: `python3 build/verification/v2/P0/inventory.py`, Godot
`--path game --script ../build/verification/v2/P0/capture.gd`, documentation check
and `git diff --check`. Existing successful Web export reused, not repeated for
documentation. Logs/scripts/captures are in `build/verification/v2/P0/`.

No identical complete tracked artwork files found. `gravel.tres` has no caller;
dynamic ornaments/plants, GLB-dependent JPEG and fixture scenes are retained.
Nothing deleted. Native samples are short, capped at 60fps and not browser/mobile
performance acceptance; initial unwarmed timing output was superseded explicitly.
World screenshots use scripted positioning, not a manual traversal claim. No
gameplay tests added/run for P0. Current uncompressed baseline export is 73.34 MiB.

Spec 020 is now in-progress: AC1 inventory/build reference complete, other V2 gates
open. Next is P1 contract review; registration, configurable parts and persistent
authority remain unimplemented. User authorized continuing after the Spec 003
review request; no model switch or external review is claimed.
Surf `14d2be5` subsequently passed CI and deployment in run 38487990020. These
existing CI gameplay checks are distinct from the local capture-only evidence.


## Lucas surf arcade — 2026-10-14

Spec 022 adds a 25% nonconsecutive invitation among Lucas's ordinary conversations;
beer introduction/delivery keep priority. Explicit yes/no choices lead to a local
beach arcade: 45 seconds, three hearts, coin lanes, rocks, touch/keyboard/drag
steering, focus pause and one reward on return. World simulation/input are suspended
under the arcade; the existing portrait blocker stays above it. Joss reuses the
canonical sprite, with a code-authored pixel ocean, shoreline, board and props.

Godot import; native `--path game --fixed-fps 60 --script
../build/verification/surf/capture.gd -- --touch`; targeted gdformat/gdlint;
`make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot`;
documentation and whitespace checks. Evidence: `build/verification/surf/`.
Capture shows invitation → accept → nine collected coins → early result → return
to Lourizán with nine coins and busy=false. The scene capture ends the run early;
full timer, repeated collisions, focus and physical touch are not accepted by it.
No gameplay tests added/run locally. Existing gdtoolkit deprecation warning remains.


## Chicken mount — 2026-10-14

Spec 021 adds a pixel-art hen at the lower-left street end, F/touch interaction,
1.8× movement and stationary rider legs. After first mounting, map travel and
salon transitions carry the hen, preserving mounted state. Dismount restores 1×;
respawn restores walking and brings the recruited hen to the spawn. The same
player collision body remains authoritative. Source/prompt: `assets/source/characters/chicken.md`;
runtime derivative: `game/assets/art/characters/chicken.png`.

Commands: Godot `--headless --script tools/normalize_chicken.gd`,
`--headless --path game --import --quit`, native
`--path game --fixed-fps 60 --script ../build/verification/mount/capture.gd`
(also with `-- --touch`), `make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot`,
targeted `gdformat`/`gdlint`, `python3 tools/check_docs.py`, `git diff --check`.
Evidence: `build/verification/mount/` import/export/native logs and screenshots.
Native captures cover idle/walk, dismount and mounted Pazo arrival; logged arrival
multiplier is 1.8. Export succeeds. No gameplay tests added/run locally; no browser
or physical-device validation. Existing gdtoolkit `pkg_resources` deprecation
warning persists. Developer art acceptance remains open.


## Persistent online V2 plan — 2026-10-13

At clean base `ab91b89`, the developer authorized a controlled rebuild plan and
explicitly added registration, character creation, online play and persistent
progress. Reserved Spec 020 and Plan 016 in their independent indexes. The roadmap
now prioritizes the small V2 street over further open-ended Pazo iterations.
Accounts, authority, durable item/reward transfers, reconnect/restart recovery,
backup restoration, art/collision gates and targeted retirement are explicit.
ADR 004's deployment direction is reused; its runtime proposal is not silently
promoted to a settled architecture. D1–D4 record the decisions and their owners.

No runtime files, service configuration, databases, providers or production state
changed. Next step: Plan 016 P0 inventory, then the consequential P1 review under
Spec 003 before dependent implementation. Earlier session-only and proposed-feature
records below are historical descriptions of V1. Documentation/whitespace checks
apply to this change; no runtime tests are needed for the planning documents.

## Terra incremental palace plan — 2026-10-13

Created [Plan 015](plans/015-terra-palace-pixel-polish.md) at base `7fff4ce`, clean
working tree. Seven serial packages: baseline, one approved gallery sample, arches,
stairs/sculptures, roofs/clock, integration and route review. Explicit file limits,
reference timestamps, matching captures and per-phase handoff prevent another
unbounded art rewrite. Terra was requested but not callable/selected here. The
subsequent explicit request authorized uninterrupted execution in the current
session. “House” is interpreted as the current Pazo; Casa needs a revised reference
contract if that assumption is wrong.

The implemented pass redraws canonical window, paired-arch, baluster, statue,
clock and dormer SVG ornaments. It keeps every structural/collision path intact.
Native 1280x720 and compact 844x390 captures at 13:00/01:00, `test_lourizan_exterior`
(41 checks), `test_location_travel` (119 checks), import/lint/format/docs and Web
export passed. Evidence is in `build/verification/terra-palace/`; existing
gdtoolkit deprecation warning remains. No physical browser/device review is claimed.


## Inactive exit and portrait HUD — 2026-10-13

The floating turquoise marker was the street Exit still visible during Pazo visits.
`set_street_active` now changes exit visibility together with monitoring. Active
place exits remain available. Portrait touch overlay moves to layer 100 (normal
landscape layer 10), covering BagUI layer 15 and other modals without losing state.
Evidence: `build/verification/night-lights/portrait.png` and native/export logs.
Native portrait rendering and Web export inspected; no physical Safari claim.


## Night sky and lanterns — 2026-10-13

Spec 019 follow-up separates bright daytime sky from night sky and pixel stars.
The same local clock controls four Pazo lanterns and exactly two Jacobo Risa
lanterns, replacing the Pazo's decorative posts with original pixel silhouettes.
Salon chandelier has permanent warm illumination and indoor ambient tint.
Bounded screen-space color pools illuminate the unshaded art; these are stylized
lights without physical shadow/occlusion, and may tint overlapping foreground art.
Only active-place/interior sources contribute; hidden street lanterns are disabled.

Godot import/native captures (13:00/01:00, garden/street/sky/salon), gdformat/gdlint,
docs check and Web export: `build/verification/night-lights/`. Known gdtoolkit
pkg_resources warning remains. No gameplay suite or physical browser review run.
Next: user visual acceptance. No push performed for this follow-up.


## Palace pixel architectural follow-up — 2026-10-13

Spec 019's first material pass did not satisfy the developer's architectural
request. Replaced decorative primitive geometry with seven original integer-grid
SVG ornaments, using the recent supplied video at 00:13/00:26/00:40/00:53.
Arches have recessed shading and concentric mouldings; galleries have drawn panes;
balusters/statues/clock/dormers/ivy use discrete silhouettes. Added continuous
stair rails, removed random stone grain, reduced harsh face shading. Retained
structural masses, stair ramps and all collision. Fixed camera-facing relief and
facade planes share batched alpha-scissor materials.

Evidence: `build/verification/palace-pixel/`. Godot import/native day-night captures,
`make export-web`, `gdformat --check game`, `gdlint game`, docs and whitespace
checks. Existing gdtoolkit deprecation warning remains. No full automated gameplay
tests or physical device/browser review run. Visual acceptance remains pending;
local commits only. The mobile hint fix is separate commit `c186472`.


## Mobile map hint removal — 2026-10-13

Developer requested removal of the map-exit/M instruction on mobile. TravelMap
now suppresses its keyboard prompt and direction/distance panel when touch controls
are enabled; the existing touch Map action and exit availability are unchanged.
Desktop retains its guide. Native `--touch` inspection and Web export are recorded
under `build/verification/pixel-environment/`. No physical-device acceptance claimed.


## Pixel environments and local day/night — 2026-10-13

[Spec 019](specs/019-coherent-pixel-environment.md) replaces the detailed foliage
and purple castle image with authored pixel art matching Jacobo Risa. Built-in
imagegen masters/prompts are in `assets/source/vegetation/` and
`assets/source/backgrounds/`. `tools/prepare_pixel_environment.gd` produces one
256x256 botanical atlas and a 480x270 nearest-sampled backdrop. Obsolete botanical
PNG/import/metadata were removed. Fixed cell baselines keep trunks on the ground;
existing placement/collision and architectural geometry remain intact.
Architecture and salon use discrete shade bands and local 12-sample/m patterns;
garden ground uses grouped patch colors. New-art guidance is in AGENTS.md and
place-authoring.md. No full-screen pixel mosaic was enabled.

The `Daylight` node samples local device time once per second and grades the
complete rendered world/background before HUD layers. Day is neutral, night cool
and dark, dawn/dusk transitional. This is approximate art timing, not astronomical
sunrise, and requires no network or persistence. Offline capture override uses
13:00 and 01:00; normal play uses device time after reload and across map travel.

Godot 4.7.2 import, `make export-web`, `gdformat --check game`, `gdlint game`,
`python3 tools/check_docs.py` and `git diff --check` passed. Native arrival/boundary
captures inspected at 1280x720 and 844x390, plus compact terrace captures. Evidence:
`build/verification/pixel-environment/`. One native capture waited while the app
was unfocused and completed after activation; no runtime errors were logged.
Existing gdtoolkit `pkg_resources` deprecation warning remains. No full gameplay
suite or physical mobile/browser acceptance is claimed. Local implementation is
ready for developer visual review and has not been pushed in this task.


## Roadmap reconciliation and release status — 2026-10-13

Developer requested a clear order after accumulated iterations. Replaced stale
roadmap proposals with one current acceptance checkpoint (Spec 018 beer route,
plus 015/016 visual/mobile review), configurable appearance as the proposed next
spec, Casa-to-Bar waiting for real references, and an unscheduled backlog.
Spec 009 is implemented, with its scan-only art scope explicitly superseded by
010/016/017. Spec 008 remains incomplete and is not active execution. Removed
obsolete "execute next" and "local pending publication" statements; plans are
historical execution records, not a competing queue. No IDs were renumbered or
reserved and no new gameplay work was authorized by this documentation update.

`gh run view 38328916165 --json status,conclusion` returned completed/success:
`b9a3ede` is deployed. This supersedes earlier local/pending-release statements
below. Developer art/device acceptance remains open. Documentation-only checks:
`python3 tools/check_docs.py` returned zero errors; `git diff --check` passed.
No gameplay tests were needed or run for this reconciliation.


## Residents, Lucas gait and beer errand — 2026-10-13

[Spec 018](specs/018-residents-and-beer-errand.md) implements the developer's
confirmed 20-coin errand. First Lucas conversation requests the beer; a subsequent
conversation transfers the expected real inventory instance, credits 20 coins,
and marks completion on the session root. Travel does not reset it. The bag shows
balance/objective; reload resets the session. Existing ten randomized conversations
remain after the offer/turn-in. No shops, persistence or generic quest system.

Alba is now Narci in runtime scene/resource paths and dialogue. Resident masters
were redrawn with Joss proportions. Lucas now has four generated walk phases per
direction at 6fps and a slightly quicker 1m/s patrol. Idle keeps straight legs and
the exact new walking upper body. The normalizer discards disconnected neighboring
row fragments before scale measurement. Removed the obsolete two-frame normalizer.
Only current masters remain, with built-in imagegen prompts beside them. Lucas
smokes during patrol pauses; ten small CPU particles stop emitting while walking
or talking. The safe patrol waypoints remain unchanged.

First, pushed `a5a0285` as requested; GitHub CI/deployment run `38327159982` succeeded.
For the new follow-up, native Godot 4.7.2 captures at 844x390 and 1280x720 inspect
NPCs, offer and reward bag. The capture script used the real street item pickup
and map travel calls after relocating the player. Logs show `PICKUP true`,
`DELIVERY coins=20 completed=true bag=0`, `REPEAT coins=20`.
Evidence: `build/verification/residents-errand/` (native logs and PNG captures).
Import and `make export-web` succeeded. `gdformat --check game`, `gdlint game`,
`python3 tools/check_docs.py` and whitespace checks passed. The existing gdtoolkit
`pkg_resources` deprecation warning remains. No full gameplay suite or physical
mobile acceptance is claimed. New follow-up remains local pending publication.


## Illustrated dream backdrop and stable furniture — 2026-10-13

Spec 016 follow-up replaces the rejected castle meshes/procedural star plane with
one full-viewport illustrated background. Built-in imagegen used the boot art as
style reference; the exact prompt is in
[background provenance](../assets/source/backgrounds/dream_castles.md). The original
PNG is used directly by Godot, so no redundant source copy is retained. The shader
preserves aspect and writes Compatibility reversed-Z far clip position (-1).
It retains depth testing and never writes depth or creates collision. Native
inspection caught and corrected an initial near-depth placement before completion.

Sofa seats/backs now fit between the arms (2.4m width), eliminating coincident
outer faces at x=+/-1.4m that produced depth fighting. This keeps outer dimensions
and blocks traversal through the furniture. The reported face mismatch matches
old production assets: `git ls-remote origin refs/heads/main` returned `45af87e`,
before local canonical character fix `eaae8ba`. That fix remains intact.

Godot 4.7.2 import and `make export-web` succeeded. Native scene captures at
1280x720 and 844x390 were inspected at the map boundary and inside the salon.
Evidence/logs: `build/verification/visual-polish/`; the temporary capture script
loads the real scene and relocates the player, without adding a test suite.
`python3 tools/check_docs.py` and `git diff --check` passed. No gameplay suite or
physical mobile/browser flicker validation is claimed. Changes remain local until
publication; developer visual acceptance remains pending.


## Asset workspace cleanup — 2026-10-13

[Spec 017](specs/017-asset-workspace-cleanup.md) documents the source/runtime
boundary. Root `assets/source/` keeps offline masters/provenance; `game/assets/`
keeps imported resources. SHA-256 audit found no identical complete tracked files.
Embedded-image inspection found two matching extracted JPEGs. Kept the home JPEG:
its imported material uses it in the emission channel, then the scene wrapper
assigns that to albedo. Removed the unused Lourizan JPEG (4,440,259 bytes) and its
import settings, plus the unreferenced legacy shrub SVG/import. Moved the unchanged
12,982,644-byte Lourizan reference GLB into `assets/source/lourizan/`, removed its
obsolete import settings/export exclusion, and updated the preparation output.
No source master, reference capture or historical verification evidence was lost.

Verification with Godot 4.7.2: `--headless --path game --import --quit` and
`make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot` succeeded.
`python3 tools/check_docs.py` and `git diff --check` passed. The imported home
material resolves its 4096x4096 texture. Logs and inventory live under
`build/verification/asset-cleanup/` (`import-final.log`, `export-final.log`,
`home-texture.log`, `inventory.txt`). An initial experiment changing home image
import reported a stale deleted-image UID; the original home files/settings were
restored. Final import/export report no warnings/errors. No gameplay suite or
manual browser/device validation was performed for this asset-only cleanup.


## Canonical character assets and matching idle identity — 2026-10-07

The developer requested a bounded character cleanup before further world work.
Runtime now contains five used PNG atlases and five SpriteFrames resources with
stable names and no version suffixes. Superseded runtime atlases, source drafts,
old character references and unused cardinal normalization helpers were removed;
Git retains their history. Current masters/prompts live in
[character sources](../assets/source/characters/README.md); the active layout
contract is in [runtime art](../game/assets/art/characters/README.md).

Fixed Joss idle addressing from an incorrect 4x2 layout to the actual 4x8 rows.
Lucas also mixed an obsolete two-directions-per-row walk layout and incorrect
idle diagonals; all clips now address the intended row. Generated standing legs
are composed with the exact canonical walk head/torso above y=43 so identity and
scale remain stable. Inés/Brais/Alba were restyled to compact large-head proportions.
No character generation/customization system is claimed: the requested next spec
will define face/hair/clothing configurations independently of these transitional
presentation resources.

Validation: `PATH=/private/tmp/lourizan-author313/bin:$PATH make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed 1138 checks with zero
failures, docs/format/lint/import and Web export. Log:
`build/verification/characters/full-check.log`. The native 1280x720 dialogue run
passed 184 checks (`build/verification/characters/native-dialogue.log`); inspected
`build/verification/lucas-patrol/lucas-dialogue.png` and the eight-facing comparison
`build/verification/characters/comparison.png` (columns: Joss walk/idle, Lucas
walk/idle; residents below). Tests ignore RGB padding beneath zero alpha when
comparing visible identity pixels. The street scene test now reads actual runtime
clips instead of the unused old sheet and checks their paired silhouette heights.
The canonical walk uses a maximum of 48px, with small per-pose differences.
Earlier asset-validation records below are historical and superseded by this
refactor. The gdtoolkit deprecation warning remains; physical-device and developer
art acceptance remain pending.

## Lourizán galleries, residents and dream salon — 2026-10-07

[Spec 016](specs/016-lourizan-galleries-and-salon.md) adds detailed gallery glazing,
pale stone/cornice work, large slab paving, stair statues, benches and lanterns
from the local video. Three original stationary residents (Inés, Alba and Brais)
use the existing collision/dialogue contract and nearest reachable speaker
selection. Their generated source, prompt and deterministic 64px normalization
are retained under `assets/source/ai/`. Lucas keeps his existing patrol/content.

A pair of walking doorways connects the terrace to a finite fictional salon with
marble, carpet, gilded paneling, curtains, chandelier, seating and fireplace.
Furniture collision is excluded from eligible item support; the floor remains
valid. Doorways reset input/camera, retain location inventory and block under
modals. The starry purple void and eight decorative floating castles take their
palette from the game cover and have no physics bodies.

Validation: native `Godot --path game --max-fps 60 --resolution 1280x720 --script
res://tests/test_lourizan_salon.gd -- --capture` and the 844x390 run each passed
25 checks. Logs: `build/verification/pazo-salon-native.log` and
`build/verification/pazo-salon-compact.log`. Inspected arrival, terrace, salon and
castle-edge captures under `build/verification/home-scan/pazo-*.png`.
`PATH=/private/tmp/lourizan-author313/bin:$PATH make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed the full suite and Web
export; log: `build/verification/pazo-expansion-check.log`. The existing
gdtoolkit deprecation warning remains. The salon is an imagined dream interior,
not a measured reconstruction. Browser/physical-device and developer art
acceptance remain pending.

## Lucas continuation pages — 2026-10-07

All eight ordinary conversation variants now split into two readable pages using
the existing `Continuar` → `Terminar` controls. Both Brazil jokes remain complete
on a single page with `Terminar`. Historical claims and random selection without
immediate repeats are preserved. This supersedes the single-page content record
below.

The dialogue test checks all ten variants, actual emulated-mouse button presses,
one-page advancement per fresh key, held-key rejection and locks through the
continuation. Native Compatibility run passed 168 checks; full headless gate
passed 167 (the random opening selects a one- or two-page variant). The same
`make check` and successful Web export log as the bag fix is recorded at
`build/verification/bag/mobile-icon-check.log`. No physical mobile gameplay is
claimed.

## Mobile backpack icon input — 2026-10-07

The touch controller consumed screen and emulated mouse events before the bag
Control could receive them. The session now binds the actual bag button to the
touch controller, which routes a press within its visible, enabled rectangle
through the existing bag signal. Empty and occupied bags open from the icon;
opening clears held joystick movement and retains the existing modal gates.

Validation: `test_bag_ui.gd` passed 33 checks headlessly and natively at 844x390.
Regression inputs include touch press/release and emulated mouse pairs, initial
empty Pazo inventory, compact occupied inventory, held steering and no placement
click-through. Inspected `build/verification/bag/bag-compact.png`. Full
`PATH=/private/tmp/lourizan-author313/bin:$PATH make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed, including Web export;
log: `build/verification/bag/mobile-icon-check.log`. The existing gdtoolkit
`pkg_resources` deprecation warning remains. Physical mobile gameplay is pending.

## Lucas walk atlas correction — 2026-10-07

Production review found Lucas's animation reading 64px atlas regions from a
313px-cell walk sheet, which showed a large clipped fragment while moving. The
runtime now uses the existing olive Lucas candidate normalized into a 4x8 sheet:
two distinct poses per direction, 48px body height and feet baseline y=60. The
idle sheet now also uses the matching olive field-worker art instead of the
incorrect blue sheet. The source prompt for the walk candidate is unavailable;
the metadata records that limitation.

The focused route/dialogue test passed 130 checks with zero failures. A native
1280x720 walking capture was inspected at
`build/verification/lucas-patrol/lucas-walking.png`; the Pazo arches, stair route
and central paving remain readable around the corrected sprite. Full suite and
Web export are pending. This native capture is not browser or mobile gameplay
acceptance.

## Pazo start, straight-leg idle poses and Lucas conversations — 2026-10-07

Fresh sessions now load Lourizán and bind Lucas; the street exit and map still
return to Calle Jacobo Risa, including its saved beer item. Joss and Lucas use
replaced eight-direction idle atlases with straight, side-by-side legs and planted
boots. Native captures at 1280×720 show both standing silhouettes clearly; the
conversation screenshot also confirms Lucas stays idle while speaking. Inspected
`build/verification/lucas-patrol/lucas-approach.png` and `lucas-dialogue.png`.

Lucas now has ten distinct one-page Spanish conversations. Each talk is randomly
selected and cannot repeat the previous choice; exactly two variants joke about
Brazil. Historical facts remain within the four source-backed statements.

`make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed all 989
automated checks, documentation, GDScript formatting/lint, Godot import and Web
export. Focused startup/travel, bag/support, dialogue and character tests passed;
`test_lourizan_dialogue.gd` reports 82 checks, `test_location_travel.gd` 119,
`test_street_character.gd` 156, and the full export produced HTML/WASM/PCK. The
local gdtoolkit installation emits its existing `pkg_resources` deprecation
warning. The production release is commit
`0aaed2ec34aa4364d2d7b302c89f461a6a016e9b`; [CI run 37547803085](https://github.com/Riquinos-Soft/le-josss-dreamscape/actions/runs/37547803085)
passed tests/export and deployed that exact SHA. Chrome loaded the production
game at the Pazo spawn; this did not cover a full browser gameplay route. Safari,
physical-device and developer visual/mobile acceptance remain pending.

## Lucas standing poses and Lourizán facade — 2026-10-07

[Plan 014](plans/014-lucas-atlas-and-pazo-refinement.md) is implemented in two
working units. Commit `3451cb8` adds original eight-direction standing atlases
for Joss and Lucas. Both use planted feet at cell y=60, a natural straight-legged
rest pose distinct from the walk frame, with consistent 1.8 m apparent height.
Joss retains four alternating walk frames at 8 fps. Lucas keeps his existing v02
eight-direction, two-pose walk at 4 fps; runtime does not use the defective pending
v03 walk candidate. `game/npcs/lourizan_guide.tscn` uses 64 px cells at 0.0375 m/px
and puts the foot baseline on the ground. The original generator sheets are local
inputs under `~/.codex/generated_images/`; adjacent JSON records prompt, source
resolution and normalizer. Developer art acceptance remains pending.

Pazo geometry replaces its single dark arch with two adjacent arches separated
by a stone pier, backed by closed wall geometry. Both stair footings gain rounded
landings and curved outer baluster outlines. Existing ramp collision and routes
remain. `game/tests/test_lourizan_exterior.gd` now traverses both stair flights.
Native captures were inspected at 1280×720 and 844×390. See ignored
`build/verification/lucas-pazo/pazo-start-1280.png`,
`pazo-terrace-1280.png`, `lucas-walking-1280.png`, and
`lucas-dialogue-1280.png`; final 844×390 files are `build/verification/home-scan/
lourizan-start.png` and `lourizan-terrace.png` from the command below.

`/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --fixed-fps
60 --script res://tests/test_street_character.gd` passed 156 checks; dialogue
passed 81; exterior traversal passed 41; place support 20, bag travel 36, camera
clearance 10 and location travel 117 passed. Full command:
`PATH=/private/tmp/lourizan-author313/bin:$PATH make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed **985 checks**,
documentation, format/lint, import and Web HTML/WASM/PCK export. Full log:
`build/verification/lucas-pazo/final-check.log`. The existing gdtoolkit
`pkg_resources` deprecation warning remains; no runtime errors remain in the final
log. Native walkthrough also passed 41 exterior checks at each of 1280×720 and
844×390; command: `Godot --path game --max-fps 60 --resolution WIDTHxHEIGHT
--script res://tests/test_lourizan_exterior.gd -- --capture`. No browser, physical
phone check was performed. Production deployment of `df1d4e6da33a208e95660f54078e0fcbeb1f94d5` succeeded through [GitHub Actions run 37546400548](https://github.com/Riquinos-Soft/le-josss-dreamscape/actions/runs/37546400548); its deploy job published the same-run tested export and verified `/release.txt` equals the commit SHA. Direct local DNS lookup for the sslip.io endpoint failed, so endpoint verification is sourced from the passing CI deploy step.

The plan's shared index/spec/development records are updated in a documentation
commit after the Pazo code commit `a4e2320`. Five Lucas candidate files (three PNGs and two
that were untracked before work began remain untouched and unstaged.

## Historical planning handoff — Lucas and Pazo, 2026-10-07

Goal: execute [Plan 014](plans/014-lucas-atlas-and-pazo-refinement.md) on an
available economical model. Base before planning: `e6c835b` on `main`. Five
pre-existing untracked Lucas assets/helpers are inventoried in the plan and
were not modified or committed. Runtime still uses v02; pending v03 images are
256×512 walk and 256×128 idle (`sips -g pixelWidth -g pixelHeight`). Helper source
inspection found cardinal duplication in idle and two repeated walk poses.
Image quality/provenance has not been visually verified in this planning pass.

Completed: bounded sequential packages, edit ownership, validation commands,
reference/acceptance contracts. Latest user requirement covers BOTH Joss and Lucas:
clear walking and dedicated standing poses with extended legs. This supersedes
the previous first-walk-frame idle shortcut and its pixel-equality test.
Superseded by the implementation record above. This planning-only checkpoint
made no runtime changes or deployment.
Documentation validation: `python3 tools/check_docs.py` and `git diff --check`
both passed (0 documentation errors; no whitespace errors). Historical runtime
counts below do not validate the planned changes.

## Retro clarity and stable character motion — 2026-10-06

Follow-up: Joss's former idle atlas did not match the walk atlas, so stopping
could replace his correctly proportioned moving head with a different silhouette.
Each idle direction now uses its matching first walk frame. The character test
compares idle and walk pixel data for all eight directions; validation evidence
is `Godot --headless --path game --max-fps 60 --script
res://tests/test_street_character.gd`: **148 checks, zero failures**.
`make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` then passed
**936 checks**, formatting, lint, import and the Web HTML/WASM/PCK export.

[Spec 015](specs/015-retro-character-clarity.md) delivers the first restyle step
before mobile review. Production preserves rendered detail instead of sampling
the world into 180 rows. Original sprite/material art remains, with linear
sampling for both characters. No new textures or heavier render target: the old
mosaic already ran over the full-resolution render. Travel retains the setting.

Joss and Lucas share `player/directional_animation.gd`: a five-degree angular
margin prevents direction chatter and turning preserves frame/progress. Joss
uses separate movement thresholds for starting/stopping animation. Existing
physics/camera interpolation is retained. The gdtoolkit `pkg_resources`
deprecation warning remains.

`PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
passed **928 checks**, lint/import and Web HTML/WASM/PCK export. Evidence:
`build/verification/restyle/full-check.log`. Native `--max-fps 60 --script
res://tests/test_street_character.gd` passed 140 checks (`native-movement.log`).
`res://tests/capture_character_presentation.gd` produced matching before/after
720p and 844x390 views and 12 walking frames, inspected for face detail, contours,
ground contact and UI. Desktop capture is not a physical mobile performance test;
full browser gameplay remains unverified.

Reviewed Evermore/facade references and eight sampled frames of the developer's
on-site video. [Timestamped notes](../references/lourizan-video-2026-10-06.md)
identify the double arch, glazed volumes, stairs and paving for the next pass.
The one-off AVFoundation extraction emitted SDK warnings for deprecated synchronous
reading calls; extraction succeeded. No video or external reference image ships
with the game. Next: deploy, developer tests mobile walking/turning/talk, then
refine the facade from the new reference.

## Lucas garden patrol and character art — 2026-10-06

[Spec 014](specs/014-lucas-garden-patrol.md) and
[Plan 013](plans/013-lucas-garden-patrol.md) replace Lucas's high-detail static
four-view sprite with original compact pixel art at Joss's apparent scale: eight
directions and two walking frames each. Lucas now follows a short, bounded loop on
the open Lourizán garden paving, pauses at each point and remains collidable. The
dialogue freezes him in place, then resumes the same route after a short pause.
The bag still rejects placement at his live position.

The focused native dialogue test passes **49 checks** covering several waypoints,
bounds, walk/idle states, freeze, no jump on close, resume and the existing
four-page conversation. Placement support (**20**), bag travel (**36**) and
location travel (**111**) checks pass. Native walking, approach and dialogue
captures were inspected under `build/verification/lucas-patrol/`. The full
`make check` passed **917 checks, zero failures** and produced HTML/WASM/PCK for
Web. Its log and export evidence are in
`build/verification/lucas-patrol/full-check.log`. The generated sheet's prompt,
provenance and atlas layout are recorded beside its PNG. Browser conversation,
physical mobile gameplay and developer visual acceptance remain separate.

## Eight-slot bag and travelling objects — 2026-10-06

[Spec 012](specs/012-eight-slot-bag.md) and [Plan 011](plans/011-eight-slot-bag.md)
are implemented. Pickup now stores the exact item instance in the first of eight
stable slots without starting placement. A right-side original pixel backpack,
plus B/P and touch actions, opens a 4×2 bag. Selecting an occupied slot closes the
modal and starts the existing rotate/validate/confirm flow; cancellation preserves
the same instance and slot. The initial street object is now the original amber
Birra Dreamscape with a teal dream label, matching icon, small physical collider
and readable pickup halo.

The session controller now manages several world representations and records them
by location ID as `{item, global transform}` before a successful travel commit.
Street, Casa and Lourizán bind only their active collision bodies as placement
supports. Returning restores the same references and poses; an initialized empty
location stays empty. Failed destination loading does not change source records,
bag ownership or world nodes. No reload persistence was added.

Native evidence under `build/verification/bag/` includes the normal/compact bag
and two placed Pazo bottles. Focused checks cover full bag rejection, input modal
isolation, multi-object overlap, Casa edges, the Pazo terrace, Lucas collision and
the full round trip. Final `make check` passed **902 checks, zero failures** and
produced the Web release HTML/WASM/PCK. Final suite and Web export log:
`build/verification/bag/full-check.log`. Generated prompts/provenance live beside
`game/assets/art/items/birra_dreamscape_icon_v01.png` and
`game/assets/art/ui/bag_icon_v01.png`. Developer art review, browser playthrough
and physical mobile validation remain separate.

## Lucas Maconheiro guide dialogue — 2026-10-06

[Spec 013](specs/013-lourizan-guide-dialogue.md) and
[Plan 012](plans/012-lourizan-guide.md) are implemented. At that milestone,
Lourizán contained one stationary Lucas Maconheiro, an original four-direction pixel character with an
olive field jacket, satchel, tied-back hair and beard. Within 2 m and clear line
of sight, `E · Hablar` appears; desktop or touch opens a four-page Spanish account
of the Pazo's history based on the linked Turismo de Galicia source. The balloon
tracks Lucas's projected head, remains screen-clamped, and uses explicit
Continue/Finish controls. Movement, items and travel remain locked until close.
Focus loss, respawn and travel clean up the modal, and a return to Lourizán
creates exactly one fresh guide.

Original runtime sprite:
`game/assets/art/characters/lucas_maconheiro_idle_v01.png`. Its adjacent JSON
records the built-in image generator, complete prompt and grid layout. Final
native captures were inspected for grounding, route clearance, scale and dialogue
bounds in `build/verification/lucas/lucas-approach.png` and
`lucas-dialogue.png`.

`make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed docs,
format/lint, import, **786 checks with zero failures**, and Web release export.
Log: `build/verification/lucas/full-check.log`. Final native Compatibility run
passed **34 checks with zero failures**; log:
`build/verification/lucas/dialogue-native-final.log`. The pinned gdtoolkit
`pkg_resources` warning remains. Manual browser conversation, physical mobile
gameplay and developer visual/copy acceptance are pending.

## Historical: bag and Lucas planning handoff — 2026-10-06

Planning-only delivery from clean baseline `2a059ce`: drafted
[Spec 012](specs/012-eight-slot-bag.md)/[Plan 011](plans/011-eight-slot-bag.md) for
an eight-slot bag, Dreamscape beer and session-preserved objects across travel;
[Spec 013](specs/013-lourizan-guide-dialogue.md)/[Plan 012](plans/012-lourizan-guide.md)
for Lucas Maconheiro, a hippie forest worker with overhead paged historical dialogue.
The explicit naming/appearance correction is included. NPC history is original
paraphrase of the linked Turismo de Galicia article, inspected during planning.

At that planning point, the current inventory, item identity/representation, placement validation,
travel teardown and touch routing. Plans address singular world-item/null access,
source/destination collision isolation, ownership rollback, modal input and touch
click-through. Each package names context, allowed paths, contracts, tests and
handoff. Seven bag packages and six NPC packages were unstarted. Both sets were
subsequently completed as recorded above.
No model was spawned/switched and no runtime behavior or art asset changed in
that planning delivery.

Validation: `python3 tools/check_docs.py` and `git diff --check`; documentation
only, so gameplay tests/export were not repeated. Specs remain draft, preserving
implementation and developer acceptance as future evidence. Indexes and roadmap
link the two candidate features. A later launch of a plan authorizes that plan's
implementation without repeating settled product questions.

## Reusable botanical kit and ground — 2026-10-06

[Spec 011](specs/011-botanical-assets.md): original generated transparent atlas for
cedar, metasequoia, magnolia and camellia, with measured UV regions and trunk
baselines. Five reusable scenes (including the existing fern artwork), simple
large-tree trunk collision and metre-sized billboards live in
`game/world/vegetation/`. Atlas metadata records sources, generation and regions.
Lourizán uses mixed species around its perimeter, six camellias in the beds and
24 ferns along the garden edge. The garden is interpreted, not surveyed planting.

Reusable ground materials add fixed gravel aggregate, moss margins, leaf litter
and grass variation without coplanar overlays or animated noise. Current zoom,
controller and travel behavior are unchanged. The asset README documents reuse.

`PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
passed documentation, format/lint, import, **752 checks**, and Web export.
Log: `build/verification/botanical/check.log`. Native production route command:
`Godot --path game --max-fps 60 --script res://tests/test_location_travel.gd -- --capture`;
logs `build/verification/botanical/native.log` and `native-final.log` (111 checks,
zero failures in each); captures in
`build/verification/lourizan/`, including `lourizan-botanical-garden.png`.
Inspected the final garden view: new silhouettes and ground detail are visible;
nearby canopies reveal Joss using the existing wall-opacity shader.
Known tooling warning: pinned gdtoolkit `pkg_resources` deprecation. Browser and
final developer visual acceptance remain separate from export/native checks.

## Camera clipping and Lourizán garden correction — 2026-10-06

Supersedes the wide Pazo framing below. All places now share maximum camera size
13.5, head focus 0.9 and pixel height 180. Orthographic obstruction changes zoom
without moving the eye into walls; fixed heading, 60 m eye offset and 200 m far
plane keep the clipping volume behind the scene. Clearance holds for 0.18 seconds
through brief corner gaps. Perspective behavior retains its original approach.
Wall reveal starts at a physical distance rather than a fraction of camera distance.

Photo reference: https://www.galiciamaxica.eu/galicia/pontevedra/comarca-de-pontevedra/pontevedra-c/pazolourizan/.
Inspected the facade/foliage photo. Pazo woodland increases from 8 to 36 trees,
with varied sizes and layered perimeter planting; small climbing leaf clusters
soften the central terrace. Placement is an interpretation, not a botanical survey.
Routes remain clear. No downloaded photo ships as game art.

Verification commands: `PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
and native `Godot --path game --max-fps 60 --script res://tests/test_location_travel.gd -- --capture`.
Evidence: `build/verification/camera-garden/`; screenshots in
`build/verification/lourizan/`. Tests cover close-wall clipping stability, fixed
heading, bounded zoom, corner gaps and consistent Pazo framing after travel.
Full suite: 750 checks, zero failures; Web export passes. Native travel passed
109 checks and native camera clearance passed 10; inspected the arrival screenshot.
Browser gameplay is not manually verified; this is not a claim of exhaustive
flicker elimination.
The existing gdtoolkit `pkg_resources` deprecation remains.

## Historical: authored Lourizán reconstruction and standing workflow — 2026-10-06

Supersedes the rejected filtered scan in `a252591`. [Spec 010](specs/010-camera-scale-and-lourizan-art.md)
now uses batched authored palace geometry: glazed wings, slate mansards, central
clock, balustraded terrace, paired walkable stairs and formal planted forecourt.
Simple collision replaces captured collision. The source GLB stays in the repo
as an offline reference, excluded from Web export. Shared player, map and items
remain; the Pazo has wider elevated framing and a 360-line pixel presentation.
Street/home scale and presentation are preserved. Estimated dimensions and
simplified ornament/layout require developer review, not survey claims.

The permanent [place workflow](place-authoring.md), `AGENTS.md` and
`.cursor/rules/real-place-authoring.mdc` require scans primarily as spatial
references, photographic landmark study, coherent authored geometry, traversal
and gameplay-camera visual inspection for all new places.

Verification: `PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
passed docs, formatter/linter, import, **740 checks with zero failures** and Web
release export. Log: `build/verification/lourizan-rebuild/final-check.log`.
Native commands use the same executable with `--path game --max-fps 60 --script
res://tests/test_location_travel.gd -- --capture` and
`res://tests/test_lourizan_exterior.gd -- --capture`. Captures/evidence are under
`build/verification/lourizan/`, `build/verification/home-scan/` and
`build/verification/lourizan-rebuild/`. The pinned gdtoolkit `pkg_resources`
deprecation remains; no Godot runtime error was reported by the full check.
Browser gameplay and final developer art acceptance are separate pending checks.

## Historical: rejected initial Lourizán art — 2026-10-06

[Spec 010](specs/010-camera-scale-and-lourizan-art.md) restores physical camera
clearance in all three locations; orthographic size now responds as the camera
approaches solid geometry and eases back out. The street, home and Pazo locations
are provisionally enlarged as complete spaces (1.45, 1.30 and 1.20), leaving the
shared 1.8 m player unchanged. Lourizán now uses a reduced stone/plant palette,
authored court paving, reused pixel plants and a noncolliding ground backdrop.
The source scan still provides its recognizable silhouette. These factors need a
real measurement before calling them surveyed scale.

`PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed: docs, format/lint,
import, **731 checks with zero failures**, and release Web export. Log:
`build/verification/lourizan/spec010-check.log`. Native Compatibility captures
passed 103 travel checks and 23 standalone Pazo checks; inspected the street,
home and Pazo views in `build/verification/lourizan/` and
`build/verification/home-scan/lourizan-start.png`. The pinned gdtoolkit still
reports its `pkg_resources` deprecation warning. Browser gameplay, physical
mobile controls and the developer's final art approval remain unverified.

## Deployment queue and map guidance — 2026-10-05

Investigation found two independent causes. GitHub's public status reported a major Actions outage while push run `37370450215` remained queued before its Godot job; the live `/release.txt` stayed at `5d69bb0`. A separate manual `workflow_dispatch` run `37371913850` on the same commit completed lint and Godot/Web export, but its deploy job was skipped by the workflow's `push`-only condition. The workflow now permits a manual dispatch on `main` to deploy the same tested artifact after both gates, while PRs and other branches remain excluded. Verify a fresh dispatch and the live release SHA before calling production updated.

The local UX issue was also real: the street exit sits about 30 m from spawn and the near-exit button overlapped the existing top-left HUD. The map now shows a persistent direction/distance guide in the upper right; near the exit it switches to an unobscured `M · Abrir mapa` button. `test_location_travel.gd` checks the guide, prompt location and travel behavior. Native screenshots `build/verification/lourizan/street-production.png` and `street-map-exit.png` were inspected. The latest local Web export rendered the guide in Chrome. `make check` passed with **725 checks, zero failures**; log: `build/verification/lourizan/map-guide-check.log`. Chrome validation here covers boot and the visible guide, not a manual full route.

## Local Chrome Web smoke test — 2026-10-05

Opened the latest `build/web` export at `http://127.0.0.1:8000/` in Chrome and inspected the rendered production street: pixel environment, Joss sprite and HUD appeared correctly. The game's console produced no errors; several warnings originated from an installed Chrome extension (`chrome-extension://nkbihfbeogaeaoehlefnkodbefgpgknn`), not the game. This is a browser boot/visual smoke check, not a complete route playthrough or mobile validation. The local tab was left open for developer review. The public `/release.txt` still returned `5d69bb0` while GitHub Actions was queued during a reported Actions service degradation.

## Map touch interaction — 2026-10-05

The integrated travel test now injects screen-touch events at the marked exit and map buttons. The Map action appears only at the exit, opens the modal, allows selection of Casa and confirms the trip; touch movement resumes afterward. This is a headless simulated-touch check, not physical Android/iOS or browser acceptance. `test_location_travel.gd` now passes **99 checks**. `PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed: **721 checks, zero failures**, documentation/lint/import and Web release export. Log: `build/verification/lourizan/touch-route-check.log`. GitHub Actions remained queued while its public status reported degraded Actions performance; the live `/release.txt` still returned `5d69bb0` at the time of observation.

## Integrated physical route — 2026-10-05

The integration test now uses normal player movement for the first street approach to its marked map exit, the captured Pazo paving to its exit, and the captured home path to its exit. Later repeat cycles still position the player at an exit to focus on map state. `PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed: **715 checks, zero failures**, docs/lint/import and Web release export. Native Compatibility run passed **93 location-travel checks** with no reported runtime warnings or errors. Logs: ignored `build/verification/lourizan/route-check.log` and `route-native.log`. The public deployment for push `d3c8f18` was still queued in GitHub Actions when this check ran; browser gameplay of the new build remains unverified.

## Production street and Lourizán integration — 2026-10-05

Fetched `origin/main` at `5d69bb0` and reconciled the local capture/travel work with the actual pixel-art production street. The current local default scene is `world/dreamscape.tscn`, hosting the existing Jacobo Risa scene, Joss sprite, orthographic camera, 180-row world pixel pass, touch HUD and item loop. A marked southern street edge opens a three-destination map; the captured home and Lourizán use the same player and renderer. The physical home-to-bar route remains pending real layout references. Earlier entries below describe historical branch states and are superseded where they identify a different main scene.

- `PATH=/private/tmp/lourizan-author313/bin:$PATH make lint`: docs 0 errors, formatter clean, linter clean. The pinned gdtoolkit emits its existing `pkg_resources` deprecation warning.
- `make test GODOT=/Applications/Godot.app/Contents/MacOS/Godot`: 694 checks, 0 failures, including touch, items, scans, production street and 72 map/travel checks over three round trips. Log: `build/verification/lourizan/production-final-check.log`.
- Native `Godot --path game --max-fps 60 --script res://tests/test_location_travel.gd -- --capture`: 72 checks, 0 failures. Inspected captures: `build/verification/lourizan/street-production.png`, `travel-map.png`, `lourizan-pixel-pass.png`, `home-pixel-pass.png`. Street matches the production pixel treatment; Pazo is recognizably captured and screen-pixelated, but remains visibly photogrammetric rather than authored pixel art. Native log: `production-native.log`.
- `make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot`: passed, HTML/WASM/PCK present. Log: `build/verification/lourizan/production-final-check.log`. Browser gameplay, physical touch and sustained performance are not yet verified. The linked public site is unchanged because no push or deployment was requested.
- A clean `git archive HEAD` extraction ran `make check` successfully: documentation/lint passed, 694 checks passed, and Web release HTML/WASM/PCK exported. Log: `build/verification/lourizan/clean-checkout.log`. This verifies tracked files do not depend on the current workspace's Godot cache.
- Test harness teleports to each marked exit to isolate map behavior; separate street and Pazo tests exercise walking. A manual end-to-end walk to/from exits is still required for acceptance. The capture only covers Pazo's current paved/facade section; no wider estate or interior is represented.

## Lourizán capture playable — 2026-10-05

The public Scaniverse Draco/JPEG inputs were decoded offline to `game/assets/lourizan/exterior.glb` with `tools/prepare_lourizan_scan.py` (Python 3.13 and pinned authoring dependencies). 264,177 visible triangles and UV-mapped photographic appearance retained, 55,000-triangle collision, 4096px JPEG. GLB output is 12,982,644 bytes. Initial export had an invalid GLB header and failed Godot import; corrected, reimported and inspected. An initial UV orientation test rendered scrambled texture; V-flip corrected it. An early native walk exposed small captured paving gaps; an invisible support box below the verified 8m paving route resolves them. The limited capture still has gaps elsewhere.

`PATH=/private/tmp/lourizan-author313/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passed: **202 checks, zero failures**, import and Web release export. Native rendered `test_lourizan_exterior.gd -- --capture` passed all 13 new checks; inspected screenshot in `docs/images/lourizan-gameplay.png`. Logs: ignored `build/verification/lourizan/phase1-check.log` and `native-route.log`. Total nine-file Web build is **96,961,627 bytes (92.47 MiB)** because export includes both location assets even before travel is wired. Spec 002's 64MiB temporary single-capture ceiling no longer describes this two-location bundle; measure browser memory/loading before accepting a new budget. Browser gameplay of Lourizán remains unverified.


## Lourizán and travel planning — 2026-10-05

Prepared Spec 003 for the supplied brief: real Lourizán location, explicit map opening at exits, destination selection and reversible Casa/Lourizán travel. Seven bounded phases (0–6) include evidence intake, visible location, traversal, session composition, map, travel and Web acceptance, plus a reusable implementation prompt. Received Scaniverse and Google Photos share links. Web reader could not access either; direct public-page downloads succeeded. Inspected scan metadata/preview and video thumbnail; downloaded the advertised Draco mesh (853,382 bytes) and JPEG (8,389,733 bytes), recording hashes in assets/source/lourizan/source-report.json. The advertised MP4 URL returned HTTP 500; full video review and mesh decoding remain pending. No gameplay implementation or new runtime verification is claimed; reviewed Markdown diff and local links only. Next action: decode/import the captured mesh and obtain a playable video to resolve wider path coverage. Existing baseline is commit `2825626` and its recorded 189 checks.


## Connected microzone: first stair module — 2026-09-30

Goal: extend the approved captured exterior into the real home/street/bar route. Completed: reusable `game/world/modules/stair_flight.tscn` (visible steps, continuous incline collision, side rails), and an F6-inspectable `game/tests/fixtures/three_floor_stairs.tscn` with two flights/three landings using the existing player/camera. Dimensions are provisional; this fixture is not the house layout. Production scene remains the approved scan.

- `PATH=/private/tmp/dreamscape-clean-lint/bin:$PATH make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`: passed; **189 checks, zero failures**, lint and release Web export succeeded. New 16 checks cover descent from the upper landing through three heights, ascent back, grounded landings and side-rail collision through normal input. No runtime controller changes.
- `/Applications/Godot.app/Contents/MacOS/Godot --path game --max-fps 60 --script res://tests/test_connected_stairs.gd -- --capture`: passed. Inspected rendered screenshot `build/verification/home-scan/04-stair-module.png`; steps, landing and character are legible. The native automated route is not browser validation.
- Logs: `build/verification/home-scan/connected-stairs-check.log` and `connected-stairs-native.log`; both exited 0 without reported warnings/errors. Web payload: 66,323,491 bytes (63.25 MiB), below the provisional 64 MiB ceiling. Test fixtures remain excluded by `tests/*`.
- Next action: obtain entrance/stairwell identification, rough floor layouts, bar direction/distance and one known scale measurement. Then align building interiors and open the captured facade. The requested complete house-to-bar route remains unimplemented; no guessed extension was inserted into the approved scan.


Current state: the main scene is the developer's captured home exterior (`world/home_exterior.tscn`), following the fidelity-first clarification on 2026-09-24. The original courtyard and item loop remain available and pass their regressions. Earlier manual browser acceptance applies to that courtyard, not to the new scan. See [Spec 002](specs/008-real-home-microzone.md).

## Captured exterior verification — 2026-09-24

- Prepared the supplied GLB offline in Blender 5.2.1: all 249,260 visible triangles retained; one 4096px photographic JPEG; separate 49,852-triangle static collision. Runtime GLB is 11,685,040 bytes. Source hash/settings are in `assets/source/home_scan/preparation.json`.
- `make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` passes with the pinned lint tools on PATH. Headless tests run at fixed 60 simulation FPS: direction 13, keyboard 32, item lifecycle 63, courtyard 30, captured exterior 30, scan movement 5; **173 checks, zero failures**. The new route walks 20 metres along the captured path and back through normal movement inputs. Step fixtures cover a 20cm rise, descent, tall-wall rejection and stopping before unsupported ground.
- Native Compatibility validation at `--max-fps 60` passes all 30 exterior checks. Representative 1280×720 frames were inspected; the player, actual photographic surroundings and controls are visible. The screenshot in `docs/images/home-exterior-gameplay.png` is a game capture, not concept art.
- Web release export succeeds with unchanged single-threaded/Compatibility preset. Nine-file payload: **66,316,695 bytes (63.24 MiB)**; PCK **26,467,256 bytes**. This fits Spec 002's provisional 64MiB fidelity-prototype ceiling and exceeds the old 40MiB primitive-courtyard target. No sustained frame-time or browser-memory benchmark is claimed.
- New scan gameplay has not been manually accepted in Chrome or Safari. Computer-use access was unavailable because permission was not granted; no UI automation or browser pass is claimed. Local HTTP checks and export do not replace that playtest.
- Evidence: ignored `build/verification/home-scan/check.log`, `route.log`, `movement.log`, `native-final.log`, and numbered PNGs. Native command: `Godot --path game --max-fps 60 --script res://tests/test_home_exterior.gd -- --capture` (use the installed executable path on macOS). Tests do not ship in the Web PCK.

Validation caveats: initial sandboxed Blender/Godot attempts failed on environment access; authorized native runs succeeded. An accelerated native `--fixed-fps` test warned that Jolt's job system exceeded its job capacity. Another capture waited indefinitely for a draw signal from an occluded window. The capture driver now requests a draw directly and native validation runs at normal capped speed; the final native log contains neither warning nor runtime error. The pinned gdtoolkit dependency still emits its existing `pkg_resources` deprecation warning; lint succeeds. Failed test routes and an initial step-edge collision issue were corrected before the recorded passing runs.

## Manual gameplay report — 2026-09-24

Tester: the developer. In response to the proposed Chrome/Safari checklist, they reported having completed it and that everything works in principle. The checklist covered three pickup/place/rotate round trips, keyboard/right-mouse movement during placement, invalid targets, cancellation, tab switching, resizing, and comfort/readability. No issue was reported; this is a brief overall report, not a per-check result or automated browser run.

Browser/OS versions, exact viewports, tested build identifier, console output, and measured timings were not supplied. Do not reuse historical versions as the versions tested today or infer the absence of console warnings. The report is sufficient to move the workflow beyond the initial gameplay playtest; it does not close every AC9/AC10 evidence requirement or the art/performance criteria. No new tests or export were run for this documentation update.

The sections below retain earlier environment and verification evidence. Their pending browser statements describe those earlier runs and are superseded by this report.

## Local inspection — 2026-09-07

- Repository: only `.git/` initially, `main` with no commits, no remotes, and no existing project instructions found in the checked ancestor locations.
- macOS 26.5.1, arm64. MacBook Air / 16 GB is user-provided information; sandbox restrictions prevented independently reading RAM with `sysctl`.
- Git 2.50.1 (Apple Git-155), `/usr/bin/git`.
- Godot CLI: **`4.7.2.stable.official.ed1daf0bf`**, standard non-.NET editor at `/Applications/Godot.app/Contents/MacOS/Godot`. Universal Mach-O includes arm64 and x86_64. Native renderer identifies `Apple - Apple M5`. The app was present on reinspection for this task; it was not found during the earlier foundation session.
- Export templates now installed at `~/Library/Application Support/Godot/export_templates/4.7.2.stable/`: `version.txt`, `web_nothreads_debug.zip`, and `web_nothreads_release.zip`. The version marker reads `4.7.2.stable`. These are all templates required for this preset; other platforms, threaded builds, and extensions are not installed.
- Blender 5.2.1 LTS, build `9e2066aef7ef`, at `/Applications/Blender.app/Contents/MacOS/Blender`. Not on PATH. `--version` exited successfully but printed a USD architecture/cache-line warning; actual authoring and GLB export remain untested.
- Python 3.9.6 and Homebrew 6.0.21 are available. Python is sufficient for a local static server; no package installation is needed for that.
- Apple Command Line Tools selected at `/Library/Developer/CommandLineTools`. Full Xcode was not found in `/Applications`; native iOS setup is deferred.
- Chrome **152.0.7977.77**, Safari **26.5**, read from installed app metadata. Browser rendering and consoles remain unverified because automation access failed.

The Godot editor and required Web templates are available. No package ecosystem, .NET, mobile SDK, addons, backend, or reconstruction dependencies were added. Chrome/Safari baseline acceptance is complete by developer report.

## Pinned toolchain and installation verification

Use the standard **4.7.2.stable.official.ed1daf0bf** editor and matching **4.7.2.stable** templates. Do not silently upgrade mid-spec. The [official download page](https://godotengine.org/download/macos/) links the standard macOS Universal build used here.

A fresh official editor archive was downloaded and passed ZIP integrity checks. Its executable SHA-256 exactly matches the installed executable: `c7cccbf8fb143e34e02fd6521e09be2c2b974f0d5db080b19071c9c570718ccf`. No replacement was necessary. Both copies produce the signature-verification warning recorded below.

The full official template archive repeatedly failed to download. The required version marker and two Web template ZIPs were extracted using HTTP byte ranges from that archive. Member CRCs, sizes, version, and nested ZIP integrity were verified before installation. Template SHA-256 values, measured locally rather than independently published signatures:

- Debug: `08962aefef811b603541d7951ac67ef00413aad2d978855183c28adee98f626a`.
- Release: `d3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0`.

Use the same Compatibility rendering baseline in the macOS editor and Web export. A desktop preview is useful for iteration but cannot certify browser behavior.

## Reproduce from the repository root

The project and preset named `Web` now exist:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
mkdir -p build/web build/verification
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
/Applications/Godot.app/Contents/MacOS/Godot --path game
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --export-release Web ../build/web/index.html
python3 -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

Then open `http://127.0.0.1:8000/`. Use explicit IPv4: this machine previously resolved `localhost` to an unrelated IPv6 service that returned 404. If the server is no longer running, use the command above. Stop it with Ctrl+C when finished. Do not start a second server on the same address/port. Local HTTP is for development; choose an HTTPS static host later. Never open the export through `file://`.

Install the pinned development linter with `python3 -m pip install -r requirements-dev.txt`.
The repository `Makefile` provides the checks used by CI: `make lint`, `make test`,
and `make export-web`. On macOS, pass the installed editor explicitly with
`GODOT='/Applications/Godot.app/Contents/MacOS/Godot'` when running Godot targets.
GitHub Actions runs the same checks on pushes and pull requests and retains the Web
build as a seven-day artifact.

Verification used the same commands with absolute project/output paths and `--log-file` paths under `build/verification/`. Normal native run added `--quit-after 600 --print-fps`. Godot interprets the relative export output path from `game/`, not the shell's working directory. No PATH/alias changes are required.

Commit `export_presets.cfg`, source assets, import-setting sidecars, and generated UID sidecars when present; ignore `.godot/`, export credentials, and `build/`. No commits were made by this task.

## Project configuration and structure

- `game/project.godot`: `res://world/courtyard.tscn` as main scene, `gl_compatibility` including mobile override, 1280×720 viewport, `canvas_items` stretching, physics interpolation, and WASD/arrow-key InputMap actions.
- `game/world/courtyard.tscn`: floor, walls, obstacles, player, camera, environment/light, and `ItemLoop`, which adds the prototype world item and HUD. Primitive geometry only.
- `game/player/`: small controller, pure direction helper, player scene, and dedicated camera rig/script. One unit = one meter; prototype height 1.8 m and speed 4 m/s. See [scale and implementation details](architecture.md).
- `game/world/smoke_test.tscn`: `World` root, environment, floor and block meshes, one shadowless directional light, and static elevated perspective camera. Two solid-color materials, no textures on geometry, shaders, post-processing, physics bodies, player, or gameplay systems.
- `game/export_presets.cfg`: `Web`, all resources with `tests/*` excluded; `variant/thread_support=false`, `variant/extensions_support=false`, PWA disabled. This includes preloaded scripts that the former scene-only allowlist omitted. Audio-worklet files are standard exporter output, not an implemented audio system.
- Generated `icon.svg`, import sidecar, `.editorconfig`, `.gitattributes`, and `.gitignore` appeared during the task and were preserved. A concurrent/default project configuration briefly replaced the main scene and renderer; the requested settings were reapplied. Other generated defaults are not new architectural decisions.
- `build/web/`: ignored HTML, JS, WASM, PCK, splash/icon PNGs, and two standard audio-worklet JS files. No service worker.
- `build/web-smoke-baseline/`: preserved original static Web build, copied before exporting movement.
- `build/verification/`: ignored import/export/native logs and rendered evidence.

The approved camera direction is preserved. Browser baseline acceptance and explicit owner approval now authorize the implemented single-item lifecycle.

## Original static baseline results

- **Native: passed.** Renderer reports `OpenGL API 4.1 Metal - 90.5 - Compatibility - Using Device: Apple - Apple M5`. Normal 600-frame run exited 0; logged FPS samples were 120. No runtime errors/warnings in successful runs. Separate 120-frame movie and one-frame PNG capture completed; the rendered PNG was visually inspected and shows an orange block on a teal floor against a dark background. This is not a sustained performance benchmark.
- **Import/export: passed.** Unsandboxed import and release Web export exited 0 without reported errors/warnings. HTML confirms threads disabled and no extensions.
- **Local HTTP: passed.** `index.html` and `index.wasm` return HTTP 200; WASM is served as `application/wasm`. No COOP/COEP headers or compression configured. HTTP checks do not verify WebGL execution.
- **Chrome: pending.** Automation failed before navigation with `Cannot find module .../browser/26.820.71523/scripts/browser-service.mjs .../trusted-worker.js`, including after retry. The installed skill package is newer. No plugin internals or browser settings were altered. This is an automation failure, not an observed game failure; console output is unavailable.
- **Safari: pending.** Computer-use connection returned `Sky Computer Use native pipe startup failed`. No page rendering or console output observed.
- **Payload:** 39,858,651 bytes / 38.01 MiB total uncompressed; `index.wasm` 39,514,754 bytes; `index.pck` 9,216 bytes. Independent per-file gzip estimate: 10,229,354 bytes / 9.76 MiB. This is not measured compressed transfer; the local Python server sends uncompressed responses.

Ignored local evidence: `build/verification/import.log`, `export.log`, `native-realtime.log`, `native.log`, `native.avi`, `native-frame.log`, and `native-frame00000000.png`. Movie recording also produced silent audio tracks by default. No browser screenshot or console log exists yet.

## Movement validation

Keyboard follow-up: the developer reported that the browser rendered the scene but the character did not move. Two input hardening changes were made first: all eight bindings now accept every device, and the controller no longer depends on a Web-sensitive focus-in notification. These were valid fixes, but the continued browser failure exposed the decisive export defect: the scene-only export omitted the preloaded `movement_direction.gd`. The courtyard could render while `player.gd` failed to parse, leaving an inert character. The Web preset now exports all project resources while excluding tests. An isolated PCK launch from outside the project proves the dependency is packaged and reports no script errors. The developer then confirmed movement works in Chrome. Direction (8), keyboard mapping (32), and courtyard integration (30) checks all pass. Current PCK SHA-256: `b615329e31d1599cec3bc4eb9cc157261095fcce561585e87f5015ac03428fa5`.

Use `http://127.0.0.1:8000/` on this machine: `localhost:8000` can resolve to Docker's IPv6 listener and return a Uvicorn `{"detail":"Not Found"}` response, while the game server listens on IPv4. Reload the game after rebuilding to fetch updated bindings.

The engine sanity check retained Godot; the brief comparison against Unity 6, PlayCanvas, Babylon.js, Bevy, and Defold is recorded with sources in [ADR 001](adr/001-engine-and-web-baseline.md). No migration or new ADR.

- Eight pure movement-direction checks passed. Thirty courtyard integration checks passed headless and with native rendering enabled. These exercise the actual scene's movement/geometry/focus wiring; they do not substitute for a human browser playtest.
- Native start framing was visually inspected. A separate native run of the exported PCK exited 0, confirming packaged script/scene dependencies can load. This does not run WebAssembly or verify a browser.
- Successful native/import/test/export logs contain no runtime errors/warnings. An unsupported `Input.release_pressed_events()` call was caught during development and removed; focus handling now releases only the four named movement actions.
- Export succeeded with unchanged renderer/thread/extension/PWA configuration. Current total **39,835,186 bytes (37.99 MiB)** versus the original **39,858,651 bytes (38.01 MiB)**. PCK is 35,168 bytes. The small total variation is insignificant.
- Chrome movement is developer-verified manually. The full Chrome checklist (console, reload/resize, and focus recovery) and Safari remain unverified; automation tooling was not repaired.

Run the meaningful automated checks from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_movement_direction.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_keyboard_input.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_courtyard.gd
```

Omit `--headless` from the second command to repeat the automated movement route with native rendering. The test exits itself and returns nonzero on an assertion failure. Tests use Godot's input actions/focus notifications; actual OS/browser key delivery and browser focus recovery still need the manual check below.

Evidence is under ignored `build/verification/movement/`: `direction-tests.log`, `courtyard-tests.log`, `native-movement.log`, `native-frame.log`, `export-pack-native.log`, `export.log`, and `start00000001.png`. No sustained performance benchmark or mobile validation was performed. Source scan confirms no ADR 003 classes or item/placement code were introduced.

## Exact manual browser test

Run separately in Chrome and Safari. The standard server command above exposes the movement build at `http://localhost:8000`. To also check the preserved static baseline, serve it separately:

```sh
python3 -m http.server 8001 --bind 127.0.0.1 --directory build/web-smoke-baseline
```

1. Open `http://localhost:8001` for the original static baseline: orange block, teal floor, lit faces, dark background, elevated camera, no movement. Then open `http://localhost:8000` for the new courtyard and visible capsule player. Wait for each splash to disappear; neither should show a blank canvas/error overlay.
2. Reload and confirm the same scene. Resize the window and verify rendering continues with the scene in view. Switch tabs and return; confirm rendering recovers.
3. Inspect the console during initial load and reload. Chrome: View → Developer → JavaScript Console (Option+Command+J). Safari: Settings → Advanced → enable “Show features for web developers” if necessary, then Develop → Show JavaScript Console (Option+Command+C). Record exact warnings/errors.
4. In Network, confirm HTML, JS, WASM, and PCK load successfully; WASM should have `application/wasm`. No cross-origin-isolation or SharedArrayBuffer requirement should block startup.
5. In the movement build, click the canvas if necessary, use WASD and arrows to walk into each boundary and both obstacles, release input, try diagonals, and check the camera follows with the character visible. No jumping, orbit, or mouse capture is expected. Switch tabs while moving, release the key elsewhere, and return: movement must not remain stuck. Repeat at a smaller viewport.
6. Record browser/macOS versions, rendering/reload/resize/tab-return/input results, and console messages here. A browser failure blocks acceptance and must be investigated before item/inventory/placement work.

Successful developer manual verification of these checks in both Chrome and Safari is sufficient for browser acceptance when automation is unavailable. Record the date, tester, versions, rendering/reload/resize/tab-return results, and console messages (or explicitly none), clearly labeling them as developer-reported manual results. Do not require automation repair or automated screenshots as an additional gate. A reported runtime failure still needs investigation.

Chrome's stale plugin runtime path and Safari's computer-use startup failure were tooling/control failures. The developer has now accepted the baseline manually in both browsers. The new item loop needs its own playtest below; no automation repair is required.

## Single-item loop validation and manual test

Run `--script res://tests/test_item_lifecycle.gd` using the Godot commands above, headless or natively. The 61 checks exercise the actual coordinator, instance references, and courtyard geometry; all pass in both modes. Existing direction (8), keyboard (32), and courtyard (30) checks pass: 131 total. Native rendered test output is `build/verification/item-native.log`. The same 61 checks also pass against the final exported PCK from `/private/tmp`, with only the external test driver supplied: `build/verification/item-export-native.log`. This prevents source files from masking missing packaged dependencies. Export log is `build/verification/export.log`. Native frame inspection confirms the initial item/HUD layout at 1280×720.

Final Web payload: **39,894,588 bytes (38.05 MiB)**, counting all nine exported files; PCK **45,152 bytes**. Compared with the recorded 38.03 MiB movement baseline (39,873,004 bytes), growth is **21,584 bytes (21.08 KiB, 0.054%)**. Compared with the immediately preceding repaired movement export, growth is 9,984 bytes. An earlier 37.99 MiB figure counted only HTML/JS/WASM/PCK and omitted icons/worklets; it was not the complete payload. Renderer, threads, extensions, PWA, and WASM remain unchanged; no optimization is warranted for this difference.

Reproduce the isolated packaged lifecycle test (from a directory outside the Godot project):

```sh
cd /private/tmp
/Applications/Godot.app/Contents/MacOS/Godot --main-pack /Users/josefanjul/www/le-josss-dreamscape/build/web/index.pck --script /Users/josefanjul/www/le-josss-dreamscape/game/tests/test_item_lifecycle.gd
```

Check log text as well as process status: Godot may exit 0 on a startup script error. This runs packaged game logic natively, not WebAssembly in a browser.

An early script type-inference error and an Euler-angle test assertion were corrected. The old south-wall route hit the newly collidable item, so the route now avoids it. Some sandboxed test runs print a macOS certificate-access error; native authorized validation and isolated package startup are clean. No game/runtime or export warnings remain in those successful runs. Automated browser tooling was not retried; no browser gameplay pass is claimed.

Current controls are shown in the HUD: WASD/arrows or holding right mouse walks, E picks up within 2 m, P or Place starts preview, mouse aims, Q/E rotates by 90°, left click confirms, Escape cancels. Movement remains active while placing. Green/red indicates validity. The instance stays held until a valid confirm. Floor targeting is deliberately limited to the authored flat courtyard; overlap/ray checks are not an arbitrary-surface placement system.

Developer playtest in Chrome and Safari at `http://127.0.0.1:8000/`:

1. Reload the new export; approach the purple striped block, press E, and verify inventory shows Dream block #1.
2. Enter placement with the button and separately with P. Opening it must not immediately confirm. Aim nearby, rotate with Q/E, and confirm on green. Verify the pose and pick it up again; repeat three times with #1 unchanged.
3. Aim at player, obstacles, walls, and distant floor: red preview must reject confirmation. Escape must retain the item and remove the preview. UI clicks must not confirm a world placement.
4. Walk away/return to a placed block. Check tab-out recovery, resizing to 800×600, and console messages. Reload restores one authored item and empty inventory.
5. Report pickup reach, aiming, rotation, and UI feel before choosing any next feature. The original baseline is accepted; this checklist concerns newly introduced gameplay only.

## Warnings and setup errors

- **Unresolved signature verification:** `codesign --verify --deep --strict --verbose=2` reports `invalid signature (code or signature have been modified)` for arm64 on both the pre-existing app and freshly extracted official download. Their executable hashes match. Cause undetermined; successful CLI/native execution does not resolve it. No re-signing, quarantine removal, or security-setting changes made.
- **Resolved sandbox restrictions:** sandboxed import could not read system CA certificates or save editor settings; an authorized unsandboxed retry succeeded. Sandbox also prevented binding/accessing localhost; authorized unsandboxed server/checks succeeded.
- **Resolved configuration error:** native attempts initially reported `no main scene defined` after the project file changed to generated defaults. Reapplying `run/main_scene` resolved it.
- **Resolved transport failures:** HTTP/2 cancellation, incomplete transfer, and HTTP 504 interrupted full downloads. Bounded range downloads completed, with ZIP integrity/CRC checks. One-off download helpers and partial archives remain under `/private/tmp/dreamscape-godot-a2TBhO/`, outside the repository.
- **Unresolved browser access:** Chrome runtime and Safari computer-use failures above prevent automated browser acceptance in this session.

## Web and mobile risks

Godot's [Web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) defines the current constraints: WebAssembly and WebGL 2.0, Compatibility rendering, and no Godot 4 C# Web export. Single-threaded exports simplify hosting; threaded builds need cross-origin isolation headers. Pointer capture and audio activation require user gestures. Safari needs explicit testing. Serve exports over HTTP locally/HTTPS remotely, with correct WebAssembly MIME type and compression; opening `index.html` as a file is insufficient.

Project responses: test exported builds early; keep CPU work small; keep input actions separate from physical keys; defer audio effects and offline caching. The constrained third-person camera does not need pointer capture. Do not mistake a successful desktop run for browser/mobile readiness.

The measured 38.01 MiB baseline leaves little room under the provisional 40 MiB uncompressed ceiling. Revisit the budget with evidence as content arrives and measure compression on the eventual host. No custom engine build is warranted during this baseline.

Low triangle counts alone do not guarantee performance. Draw calls, transparent overdraw, shaders, resolution, and memory also matter; see [3D performance guidance](https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html). Start with opaque materials and a limited palette. High-DPI displays can inflate pixel work; budget 3D resolution separately from UI sharpness. A fanless laptop and phones need sustained-load tests, not just a cold-start FPS reading.

Touch input, safe areas, orientation, smaller UI, app suspension, and thermal throttling need explicit native/mobile-browser testing later. InputMap actions and UI anchors reduce future changes but do not solve touch camera design. Browser memory behavior on an iPhone cannot be extrapolated from a 16 GB Mac. Pick real baseline devices before promising supported models.

Native [Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) requires the documented JDK/Android SDK setup. Native [iOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html) requires macOS and Xcode plus appropriate signing/provisioning for the distribution method. Recheck version requirements when those milestones begin; do not install these toolchains now.
