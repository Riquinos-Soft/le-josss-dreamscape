# Plan 015 — Terra palace pixel polish

## Plan header

- Objective: make the Pazo facade read as intentional, consistent pixel art at
  gameplay scale while preserving its real architectural identity.
- Governing specs: [019](../specs/019-coherent-pixel-environment.md) and
  [010](../specs/010-camera-scale-and-lourizan-art.md).
- Design authority: [place-authoring](../place-authoring.md), especially Current
  pixel environment contract; Jacobo Risa and Joss at the actual gameplay camera.
  No new Game Bible decisions or external Bible review are claimed.
- Base: `759833c`, main, clean working tree before execution.
- Status: implemented, 2026-10-13. The developer authorized uninterrupted execution
  and production push. Developer visual acceptance remains pending.
- Scope assumption: “house” means the Pazo building discussed in this thread.
  If the developer means the separate Casa location, replace this plan's reference
  and file contracts before starting; do not silently modify Spec 008.
- Executor: the current implementation session. Terra was requested but is not
  exposed in this session's callable model list, so no Terra selection or cost claim
  is made. The package boundaries and validation cadence were retained.
- Integrator: the single executing session. Work serially on the current branch;
  no subagents, parallel waves or simultaneous writers.
- Settled: existing renderer/camera/scale, nearest sampling, authored pixel clusters,
  original artwork, existing routes and collision. No architectural decision open.
- Non-goals: characters, missions, interiors, new locations, sky, lighting systems,
  global pixel filters, provider installation, new engine or asset framework.
- Order: P0 → P1 → P2 → P3 → P4 → P5 → P6. One package at a time.
- Integrator-owned records: this plan, Spec 019, `docs/development.md` and indexes.

## Shared execution contract

### Minimum context

Read this plan and only the current package's files. Reuse reference findings:
`references/lourizan-video-2026-10-06.md` and its original local video. Existing
sample frames in `build/verification/restyle/` are conveniences, not durable inputs;
extract missing frames from the video if needed. Report missing video rather than
inventing details. Read `game/assets/art/architecture/README.md` for current art.

### Cadence and output

1. Read the package, current commit and working-tree status. Record inherited changes.
2. Capture the relevant current gameplay view before editing. List at most three
   concrete defects, with the corresponding reference frame.
3. Change one architectural family. First prove one module in the game before
   applying it repeatedly. Do not regenerate the entire palace in one attempt.
4. Inspect the same view after editing at 1280x720 and 844x390, at 13:00 and 01:00.
   Include Joss, preserve the shipping camera, and inspect at native size. Zoomed
   asset previews are supporting evidence, not acceptance by themselves.
5. Correct local failures; after two unsuccessful targeted iterations, document
   the remaining defect and diagnosis before spending another generation attempt.
   This is a retry checkpoint, not an invented token or time budget.
6. Review the diff, run authorized checks, then make one working atomic commit.
   Record evidence, actual result and next package. Do not call art accepted merely
   because import/export passes. Do not push without an explicit user instruction.
7. Present the phase result briefly. Technical passes may proceed sequentially
  after execution is authorized. The developer explicitly authorized completing the
  phases without pausing; P1 was reviewed by the executor before repetition. Do not
  claim that as developer art acceptance.

Evidence: `build/verification/terra-palace/P0/` through `P6/`, ignored logs/captures.
Keep source art in canonical unversioned files. Git stores history; no v02/v03 copies.
Use existing SVGs for integer-grid drawing; use the imagegen skill if raster art is
needed. Do not use generated perspective sheets as uninspected runtime atlases.

### Common visual gate

- Large silhouette, medium construction, then small accents: detail must reinforce
  the first two. Deliberate clusters; no random stone noise, scattered single pixels,
  smooth vector-looking contours, blurred edges or spherical decorative substitutes.
- Use the existing warm stone, muted pink plaster, slate and dark green palette.
  Avoid introducing a separate palette for every ornament. Judge pixel density
  beside Joss and Jacobo Risa; do not set a new global resolution or camera scale.
- Highlights describe the same light direction; deep recesses read as recesses.
  Materials remain recognizable in the existing night grade.
- Repetition varies only where the reference supports it. Keep authored trim widths,
  pane divisions and dark outlines consistent across neighboring modules.
- No facade plane z-fighting, floating pieces, flicker or obstructed player routes.

## Package P0 — Baseline and reference mapping

- Status: done. Owner: current implementation session. Dependency: none.
- Allowed: ignored capture scripts/evidence; this plan's reference notes via integrator.
- Read: reference video notes, exterior script and current facade assets.
- Output: fixed arrival, double-arch, stair, gallery and roof overview capture setups;
  a short mapping of landmarks to video frames and current defects.
- Steps: use 00:13 galleries, 00:26 clock/landing, 00:40 paired vaults,
  00:53 stairs and 01:19 weathering. Mark proportions as estimated unless measured.
- Gate: the next phase has a named shot, source frame and bounded defect list.
  No runtime code or art change in P0.

## Package P1 — One convincing gallery bay

- Status: done. Owner: current implementation session. Dependency: P0.
- Allowed: `game/assets/art/architecture/lourizan-window.svg`, and only `window()`
  in `game/world/lourizan_exterior.gd` if placement adjustments are required.
- Inputs: existing window dimensions, facade anchors, video 00:13/01:19.
- Output: a single reference bay with readable sill, frame, mullions, reflection
  clusters and recess. Inspect in situ before replacing repetitions.
- Gate: face proportions match the reference; panes remain distinct at 844x390;
  no thin shimmering bars or glossy 3D appearance. Developer accepts the sample
  as the style target before P2–P5. If rejected, revise this sample only.

## Package P2 — Paired arches and stone relief

- Status: done. Owner: current implementation session. Dependency: P1 executor review.
- Allowed: `lourizan-arches.svg` under the architecture directory; only the arch
  ornament placement in `build_palace()` if needed.
- Inputs: video 00:40, existing 4.15x3.26 facade module and solid terrace contract.
- Steps: draw substantial central pier, coherent archivolt bands, keystones and
  capitals; make the inner vault depth readable without a flat black doorway.
- Gate: both arches read at gameplay scale and belong to the gallery's palette;
  preserve closed-backed/non-traversable semantics and terrace collision.

## Package P3 — Stair rails and sculpture silhouettes

- Status: done. Owner: current implementation session. Dependency: P2.
- Allowed: `lourizan-baluster.svg`, `lourizan-statue.svg`; `carved_post()`,
  `balustrade()`, decorative portions of `build_stairs()` and `statue()` only.
- Inputs: video 00:26/00:53, unchanged step heights and collision ramps.
- Steps: resolve baluster profile and continuous rail connections; improve one
  statue's drapery silhouette, then distribute it with deliberate orientation.
- Gate: no forked/crossed cutout appearance, detached rail endpoints or mannequin
  look. Both stairs and landings remain clear; feet/pedestals visibly meet surfaces.
- Do not change ramp points, passage transforms or create new collision.

## Package P4 — Clock, dormers and mansard readability

- Status: done. Owner: current implementation session. Dependency: P3.
- Allowed: `lourizan-clock.svg`, `lourizan-dormer.svg`; decorative roof/clock
  placement in `build_palace()` and `roof()` only, preserving structural footprint.
- Inputs: video 00:13/00:26, existing skyline and P1 palette.
- Steps: distinguish the actual clock from round glazed dormers; simplify slate
  clusters and cornice edges so roof masses remain legible at normal zoom.
- Gate: no repeated clock-face substitutes for windows; clock pavilion and flanking
  mansards are recognizable in the overview and coherent in close gameplay shots.

## Package P5 — Integrate the facade

- Status: done. Owner: current implementation session. Dependency: P4.
- Allowed: completed architecture SVGs, decorative placement in exterior script,
  `lourizan_architecture.gdshader` only if a documented material mismatch remains.
- Steps: align trim widths and color ramps; remove duplicate/overlapping decorative
  planes; soften repetitive ivy edges only where they hide the architecture.
  Inspect facade ends and joins, not just the attractive central view.
- Gate: one coherent building beside Joss; no isolated high-resolution decoration;
  source/runtime asset ownership remains clear and draw-call batching is retained.
- Do not compensate for problems by changing camera, global postprocess, backdrop,
  NPC assets, botanical atlas, gameplay scale or navigation.

## Package P6 — Route and release readiness

- Status: done. Owner/integrator: current implementation session. Dependency: P5.
- Allowed: evidence and documentation; localized corrections return to their owner
  package and are recorded before final acceptance.
- Inspect arrival → paired arches → both stairs → gallery → salon threshold → exit,
  using the real controller, day/night and compact landscape. Check lantern/rail
  overlap and orientation overlay without changing their behavior.
- Commands, when execution includes verification authorization:
  `python3 tools/check_docs.py`; `gdformat --check game`; `gdlint game`;
  `make import GODOT=/Applications/Godot.app/Contents/MacOS/Godot`;
  `make export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot`.
  Reuse existing relevant stair/place tests only when tests are authorized; do not
  add tests that merely restate geometry. Read unfamiliar scripts before running.
- Inspect logs, not just return codes. Record the existing gdtoolkit deprecation
  warning. Never claim a physical mobile/browser review from native captures.
- Gate: compare P0 and P6 at identical views; record achieved criteria and remaining
  defects. Developer art acceptance and production release are separate events.

## Escalation and handoff

Routine art adjustments, imports and syntax fixes remain with Terra. Stop only the
portion requiring a renderer change, new global asset standard, camera/scale change
or cross-system redesign; use Spec 003's evidenced Astra decision report. Continue
independent settled work. Do not switch models or invent provider availability.

Every phase delivery records:

```text
Package / base SHA / commit SHA:
Observed defect and reference timestamp:
Changed files and visible result:
Commands actually run / results / evidence paths:
Before-and-after captures at identical camera:
Limitations, retries and actual cost (unavailable if not exposed):
Acceptance: technical review / developer art review:
Next bounded phase:
```

## Execution record — 2026-10-13

P0 captured the existing arrival and terrace images. The observed defects were
uniform glazing, generic sculptural relief and arches whose recess was too flat.
The supplied video remains the reference: galleries 00:13/01:19, clock 00:26,
paired vaults 00:40 and stairs 00:53.

P1 redraws the single canonical gallery bay before its existing repetitions are
instantiated: unequal reflection clusters, deep muted panes, wider cream mullions
and a stepped sill/cornice. P2 redraws the paired vaults with continuous stepped
archivolts, capitals, a central pier and separate dark recess planes. P3 redraws
the baluster and draped figure silhouettes. P4 redraws the clock and dormer so
they do not share the same circular motif. P5 keeps the shared warm-stone/slate
palette and leaves geometry, routes, collision, camera, backdrop and lighting
untouched.

P6 evidence: `build/verification/terra-palace/`. Native captures at 1280x720 and
844x390 include arrival, terrace and stairs at 13:00/01:00. `test_lourizan_exterior`
passed 41 checks, `test_location_travel` passed 119 checks; formatting, lint,
documentation validation, import and Web export passed. The existing gdtoolkit
`pkg_resources` deprecation warning remains. No physical browser/mobile review is
claimed. The remaining decision is developer visual acceptance of the new Pazo art.
