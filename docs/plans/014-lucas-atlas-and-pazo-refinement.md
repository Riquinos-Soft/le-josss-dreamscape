# Plan 014 — Lucas atlas and Pazo refinement

- Status: implemented; developer visual and physical mobile acceptance pending. Updated 2026-10-07.
- Objective: integrate coherent Lucas art and proper walking/standing poses for Joss and Lucas and refine the recognizable Pazo facade
  and paired stairs without disturbing the playable route.
- Governing specs: [014](../specs/014-lucas-garden-patrol.md),
  [010](../specs/010-camera-scale-and-lourizan-art.md),
  [015](../specs/015-retro-character-clarity.md).
- Authorization: on 2026-10-07 the developer requested continuing Lucas/Pazo work
  and preparing this plan for a lower-cost model. This delivery is planning only.
  Proceeding is authorized; prior mobile acceptance is not inferred.
- Design references: [place authoring](../place-authoring.md),
  [on-site video notes](../../references/lourizan-video-2026-10-06.md), and the
  exact character/landmark requirements in Specs 014/010/015. The Notion Game Bible
  was not retrieved for this planning pass; no new product decisions depend on it.
- Base: `main`, `bb80e9db45431eb08dc8be2f51367dab5de2a39d`; implementation commits
  `3451cb8` (L1) and `a4e2320` (P1/P2). The five pre-existing
  untracked candidates remain outside these commits.
- Executor: this Codex session completed the authorized work. Actual token/cost
  breakdown is unavailable; no savings claim is made. The built-in image generator
  produced two original standing sheets; no provider was installed.
- Single integrator: that executing session, responsible for review and commits.
- Order: L1 → P1 → P2 → V1; completed sequentially with no delegated agents.
- Settled contracts: Godot 4.7.2 standard, Compatibility/Web, metre units, existing
  place scales/camera, continuous presentation, shared directional animation,
  local patrol, existing dialogue and item identity.
- Non-goals: new NPC systems, extra dialogue, interiors, estate expansion,
  persistence, global asset pipeline, renderer changes, automatic push/deployment.
- Shared files reserved for integrator: specs, indexes, roadmap, development log,
  Makefile and this plan. No changes to Makefile are expected.

## Starting state and pre-existing files

The following untracked files predate this plan. Preserve them; inspect before
using and stage only justified deliverables. A clean checkout will not contain them.

- `game/assets/art/characters/lucas_maconheiro_idle_cardinals_v01.png`
- `game/assets/art/characters/lucas_maconheiro_idle_directions_v03.png`
- `game/assets/art/characters/lucas_maconheiro_walk_v03.png`
- `tools/expand_idle_directions.gd`
- `tools/normalize_two_frame_walk.gd`

Runtime still references `lucas_maconheiro_animations_v02.tres`, which reads
313×313 cells from the v02 sheet. The v03 walk image is 256×512 (4×8 cells of
64×64); the v03 idle image is 256×128. Their visual quality/provenance is not yet
verified. The idle helper explicitly duplicates cardinal poses into diagonal
slots, so an eight-name resource alone cannot establish eight correct poses.
The walk helper repeats two poses across four columns and normalizes to a
48-pixel body height with a baseline at cell y=60. Neither helper was executed
in planning. Existing v02 JSON filtering notes predate Spec 015.

## Common execution and evidence contract

Read AGENTS.md and [Spec 003](../specs/003-agent-workflow.md), then only the
package's minimum context. Before running any unfamiliar helper, read it.
Use `git status --short --branch` and inspect the scoped diff before edits/commit.
For every package, record actual commands, results, warnings and evidence in
[development](../development.md); screenshots/logs belong under ignored
`build/verification/lucas-pazo/`. Record unavailable references and measurements
honestly. Do not fabricate provenance or substitute a guessed measurement.

Focused test command (replace TEST with the listed filename):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --fixed-fps 60 --script res://tests/TEST.gd
```

For rendered route checks omit `--headless`, use `--max-fps 60` instead of
`--fixed-fps 60`, and inspect screenshots/output. Check logs for script errors
as well as process status. Run relevant focused tests during each package, then
`make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot` before each working
runtime commit: docs, lint, import, regression tests and Web export. Do not repeat
unchanged checks in V1 without a reason. The existing gdtoolkit deprecation warning
must remain reported if present. No gameplay suite is needed for this plan alone.

Deliver each package with: actual base SHA, changed files, observable result,
command/result/log paths, inspected captures, limitations, retries and cost if
available (otherwise unavailable). Mark review first; the integrator inspects
criteria and diff, then creates one local conventional commit per working unit.
Update package/spec status and next step. Never stage unrelated pending files.

## Package L1 — Coherent walking and standing for Joss and Lucas

- Status: done; commit `3451cb8`. Owner: Codex integrator. Dependencies: none.
- Minimum context: Spec 014 R1–R5; Spec 015 R1–R3; the starting-state files above;
  `game/npcs/lourizan_guide.gd`, its scene, v02 SpriteFrames/JSON;
  `game/player/directional_animation.gd`; `game/tests/test_lourizan_dialogue.gd`;
  `game/assets/art/characters/char_joss_animations_v01.tres`, its source PNG/JSON
  files and `game/tests/test_street_character.gd`.
- Allowed edits: Lucas PNG/JSON/import/SpriteFrames files under
  `game/assets/art/characters/`; `game/npcs/lourizan_guide.tscn`;
  the two pending helpers; `game/tests/test_lourizan_dialogue.gd`;
  a focused capture driver `game/tests/capture_lucas_pazo.gd` and its UID.
- Also allowed: Joss PNG/JSON/import/SpriteFrames assets under the same character
  directory and `game/tests/test_street_character.gd`. Preserve Joss scene scale.
- Do not edit shared animation, NPC patrol logic, session, dialogue text,
  camera or placement behavior. A need outside these boundaries goes to integrator.

### Steps and input/output contract

1. Inspect the candidate sheets visually, including each direction/pose and
   transparency; compare to v02 and Joss at actual gameplay size. Locate existing
   generation/source evidence. If source provenance is unavailable, document the
   gap and do not invent it or commission replacement art automatically.
2. Use the v03 walk only if it preserves Lucas's appearance and distinct eight
   directions. If a candidate is defective, normalize the known v02 source using
   the inspected local helper and re-inspect; do not promote defective art.
3. Produce `lucas_maconheiro_animations_v03.tres` with existing animation names:
   down, up, left, right, down_left, down_right, up_left, up_right, each with
   `idle_`/`walk_` prefixes. Preserve effective two-pose cadence; duplicating poses
   into four cells must not halve/double the visible stepping rate.
4. For BOTH characters, author/select a true standing pose for each of eight
   directions: legs extended naturally, feet planted, no frozen stride or lifted
   foot. Preserve head/body proportions, outfit, facing and foot pivot through
   start/stop. This explicitly supersedes Spec 015 R5's first-walk-frame shortcut.
   Do not reuse cardinal poses for diagonals. Inspect existing idle art first;
   if it cannot meet this criterion, use the available image-editing skill/tools
   for a bounded original sprite correction, then normalize and record provenance.
   Do not install a provider or silently substitute an unsuitable walk frame.
   Keep unused experiments unstaged.
5. Wire only Lucas's scene. Adjust its sprite pixel size/local offset to the new
   cells so apparent human height and foot contact match the existing character;
   retain collision, head marker, filtering and shared animation behavior.
6. Add truthful adjacent v03 JSON provenance/layout notes. Extend the dialogue
   test only for meaningful direction, foot alignment and idle/walk continuity
   regressions; preserve patrol freeze/resume coverage. Replace Joss's current
   idle-equals-walk pixel assertion, which enforces the superseded shortcut, with
   state/facing and grounding checks. Visual inspection must establish straight
   legs and consistent proportions; pixel equality cannot prove these criteria.
7. Verify both characters show alternating steps without sliding, rapid facing
   flicker or foot drift. Inspect start → walk → turn → stop in all eight
   directions, wall stop, Lucas waypoint pauses and dialogue pauses.
   Run dialogue, street-character, place-support and bag-travel tests. Capture all
   eight idle/walk directions beside Joss, then patrol/talk/resume at 1280×720 and
   844×390 using the real camera. Run common gate and commit.

### Acceptance / escalation

- [ ] Both characters: eight appropriate standing directions, legs naturally
  extended, grounded feet, stable proportions, no frozen stride or head jump.
- [ ] Both characters: visible alternating steps, stable turns and clean return
  to standing on release, obstruction and NPC pauses.
- [ ] Patrol, four dialogue pages, freeze/resume and live placement rejection work.
- [ ] Native evidence inspected; Web export passes; mobile acceptance remains open.

If available art tools/source cannot yield acceptable poses, report failed poses and
continue independent reference preparation; do not hide the failure. Request Astra
only if resolution requires changing the shared animation format/pipeline or
cross-project scale/rendering standards. Local resource fixes remain routine.

## Package P1 — Recognizable facade landmarks

- Status: done with P2, commit `a4e2320`. Owner: Codex integrator.
- Minimum context: Spec 010; place-authoring workflow; video notes; existing
  `game/world/lourizan_exterior.gd` (build_palace, roof, window, batching helpers);
  `game/world/locations/lourizan.tscn`, `lourizan_preview.tscn`;
  `game/tests/test_lourizan_exterior.gd`.
- Allowed edits: `game/world/lourizan_exterior.gd`,
  `game/tests/capture_lucas_pazo.gd`, `references/lourizan-video-2026-10-06.md`.
- Preserve stairs/route collision in this package, shader, botanical kit and shared
  camera. Integrator owns documentation updates.

### Steps and contract

1. Inspect available video frames `build/verification/restyle/site-0.png` through
   `site-7.png`, local source video identified in the notes, and offline GLB layout.
   Record measured versus inferred spans. Use existing photographic references
   where available; request missing input only for geometry it actually blocks.
2. Capture baseline arrival, central terrace, side pavilion and stair approach
   using the gameplay camera. Map six landmarks: paired arches, projecting glazed
   bays, vertical gallery divisions, slate mansards, clock pavilion, raised terrace.
3. Replace the single central dark arch with two adjacent authored arches and a
   supporting pier; keep recesses closed to gameplay. Refine projecting bays and
   coherent gallery divisions, mansard/dormer silhouettes and clock proportions.
4. Reuse local mesh/material batching and small building helpers. Preserve metre
   units, current place scale and travel points. Do not claim surveyed dimensions.
5. Compare the same views at 1280×720 and 844×390. Document which video timestamp
   supports each correction. Run exterior, camera-clearance and location-travel
   tests, common gate, then commit.

### Acceptance / escalation

- [ ] Paired arches and other facade landmarks recognizable in gameplay captures.
- [ ] Existing route and terrace remain accessible; no invented interior entrance.
- [ ] Existing architecture batching bound in exterior test retained; no arbitrary
  increase of limits to conceal a regression.

Request Astra only if evidence requires changing shared camera/place calibration,
rendering or batching architecture. Ornament proportions and local meshes are
routine implementation choices. Missing spatial evidence is recorded as an
estimate or blocks only the affected detail.

## Package P2 — Paired stairs and connected landings

- Status: done with P1, commit `a4e2320`. Owner: Codex integrator.
- Minimum context: P1 evidence; video timestamps 00:26, 00:53, 01:19, 01:32;
  `build_stairs`, `balustrade`, `statue`, `build_garden` in the exterior script;
  exterior test and `game/tests/test_place_support.gd`.
- Allowed edits: exterior script; exterior/place-support tests; capture driver;
  reference notes. No player physics, shared camera or item-loop edits.

### Steps and contract

1. Refine paired stair outlines and rounded lower landings from the references;
   join terrace/upper path visibly, keeping existing arrival/exit/patrol corridors.
2. Match simple continuous collision to walkable surfaces. Refine balusters and
   statue placement, large paving slabs and restrained stone colour variation
   using existing materials. Do not add a separate floor patch or raw scan overlay.
3. Walk both flights up/down with the real controller, and follow the forecourt,
   terrace and exit routes. Update test waypoints only to follow actual intended
   surfaces; preserve grounded/reachability assertions. Cover both flights.
4. Check bag placement on changed landings and live Lucas collision. Inspect
   native views at both sizes; run exterior, place-support, bag-travel, dialogue,
   camera-clearance and location-travel checks plus common gate, then commit.

### Acceptance / escalation

- [ ] Both stairs and landings read as coherent volumes and are traversable.
- [ ] No floating feet, fall-through, snagged route or blocked NPC/travel corridor.
- [ ] Visual contact matches collision; placement and camera behavior preserved.

Request Astra only if the geometry demonstrably demands a new movement/collision
system or conflicts with accepted scale contracts. Use local ramps/meshes first.

## Package V1 — Final acceptance handoff

- Status: implemented and deployed; developer visual and mobile acceptance pending.
- Owner: integrator. Allowed edits: this plan, governing specs/indexes, roadmap,
  development log. Minimum context: package evidence and final scoped diff.
- Review final integrated native arrival → Lucas conversation → both stairs →
  item placement → travel away/return. Reuse final gate evidence if code unchanged.
- Record commit SHAs, exact checks/warnings and remaining visual limits. Mark
  implemented only when technical criteria pass; developer visual acceptance,
  physical mobile and actual Chrome/Safari gameplay remain separate.
- Supply a short mobile checklist: walk/turn/stop, talk/resume, climb/descend each
  flight, place/pick up, travel back. Do not claim browser validation from export; browser gameplay remains pending.
- Keep commits local. The developer explicitly requested push and production deployment after implementation;
  CI run 37546400548 deployed and verified commit `df1d4e6`.
- No Astra decision expected; report concrete unmet criteria instead of expanding
  scope. Stop when this bounded delivery is complete.


## Execution results — 2026-10-07

L1 is committed as `3451cb8`; Joss uses dedicated eight-direction standing art
with straight legs and planted feet, and Lucas uses a new eight-direction idle
atlas alongside the existing two-pose v02 walk. Runtime walk presentation is
not replaced by the incomplete v03 candidate. Dialogue/street tests assert idle
and stride differ and the feet baseline is y=60. Original source images remain in
the local generated-images directory; committed JSON records prompts and layout.
Developer review is pending.

P1/P2 are committed as `a4e2320`; they replace the single central arch with two closed-backed arches and a pier,
and add rounded lower stair landings/curved baluster outlines. Collision ramps,
metre scale, routes and architecture batching stay in place. The exterior test now
walks up and down both stair flights. Native captures at 1280×720 and 844×390
were inspected: `build/verification/lucas-pazo/pazo-terrace-1280.png` and `build/verification/lucas-pazo/pazo-terrace-844.png`. Character
captures: `build/verification/lucas-pazo/lucas-walking-1280.png` and
`lucas-dialogue-1280.png`. This is native visual inspection, not browser or phone
acceptance.

Final command: `PATH=/private/tmp/lourizan-author313/bin:$PATH make check
GODOT=/Applications/Godot.app/Contents/MacOS/Godot`; 985 checks passed, docs,
format/lint, imports and Web export passed. Log: `build/verification/lucas-pazo/final-check.log`.
The gdtoolkit `pkg_resources` deprecation warning remains. Native route command:
`Godot --path game --max-fps 60 --resolution 1280x720 --script
res://tests/test_lourizan_exterior.gd -- --capture`; same command passed at
844×390. Both reported 41 checks, zero failures.
