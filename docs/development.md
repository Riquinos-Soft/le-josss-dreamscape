# Development setup and verified baseline

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
[Plan 012](plans/012-lourizan-guide.md) are implemented. Lourizán now contains one
stationary Lucas Maconheiro, an original four-direction pixel character with an
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
