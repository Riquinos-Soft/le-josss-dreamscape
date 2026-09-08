# Development setup and verified baseline

Current state: the developer has accepted the Web baseline manually in Chrome and Safari and authorized the first ADR 003 implementation. The single-item pickup/inventory/placement loop is implemented. Native automated checks and Web export pass; browser acceptance of this new gameplay remains pending. Original static scene/export are preserved. Historical pending-baseline entries below are superseded by this developer report (2026-09-07); no new browser versions or console transcripts were supplied.

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

Controls are shown in the HUD: WASD/arrows walk, E picks up within 2 m, P or Place starts preview, mouse aims, Q/E rotates by 90°, left click confirms, Escape cancels. Movement pauses while placing. Green/red indicates validity. The instance stays held until a valid confirm. Floor targeting is deliberately limited to the authored flat courtyard; overlap/ray checks are not an arbitrary-surface placement system.

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
