# Plan 016 — Persistent vertical rebuild

## Plan header

- Objective/spec: execute [Spec 020](../specs/020-persistent-online-vertical.md)
  through independently reviewable playable increments.
- Design references: [place authoring](../place-authoring.md), ADRs 001–004 linked
  from Spec 020; existing Joss and Jacobo Risa are art references, not automatic
  approvals of every current implementation. No new Bible content was fetched.
- Original planning base: `ab91b89`, main. P2a base: `931fcc4`; P2b base: `adc6f6d`.
  Production art/device acceptance remains open.
- Status: P0 complete; P1 contracts reviewed, 2026-10-14. P2 implementation complete; visual/gameplay review is next.
  Physical target: iPhone 16 Pro + Chrome; hands-on validation remains pending.
  Developer explicitly authorized
  starting the refactor and pushing completed increments. V2 now has a locally verified account entry/character checkpoint slice; production
  activation awaits administrator access. See [baseline inventory](../refactor-baseline.md).
- Settled: Godot 4.7.2 Compatibility, Web first, metres, stable item identity,
  same repository, small scenes, a street sample before Pazo migration.
- Settled by P1: [ADR 006](../adr/006-v2-character-and-scene-contract.md) defines
  scene/appearance contracts; [ADR 007](../adr/007-authoritative-persistent-vertical.md)
  defines service, authority, identity and recovery boundaries. Review was explicitly
  authorized after the Spec 003 escalation; no external reviewer/model switch claimed.
- Remaining: D2 physical-device acceptance and D4 operational launch decisions.
  Neither blocks the isolated P2 laboratory; they block later acceptance/release.
- Single integrator: current executing session; no workers assigned. Economical
  execution resumes after contract review. No model availability or cost assumed.
- Non-goals: speculative frameworks, engine migration, mass art regeneration,
  new game features beyond Spec 020, or an unbounded legacy cleanup.
- Updated priority (developer correction, 2026-10-14): login/register → existing
  character resume or first character creation → play. Defer P3 authoring; execute
  P4 and the P5 movement-checkpoint slice using the existing validation location.
  The original order below is superseded for this entry/resume increment.
- Original order: P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8 → P9.
  No parallel agent work authorized. Each package is split further if its first
  working increment cannot be reviewed independently.
- Integrator-owned shared files: indexes, roadmap, development log, architecture
  documentation, project entry point, exports and deployment configuration.

## Common package contract

### Active correction packages — reviewed 2026-10-17

This sequence supersedes P2's pending visual review and the temporary public
laboratory entry. Base: `63bd5bd`, with the existing uncommitted Lourizán/account
correction listed in the development checkpoint. ADR 006's canonical-pose review
is complete. One executor/integrator works serially; no delegation is authorized.
No new architecture, identity schema or art direction decision remains open.

**C1 — Lossless canonical character, locally verified 2026-10-18.**

195 appearance checks, 120 HTML/Godot RGBA composition matches, 382 native real-clock
checks and Web export pass. Eight static sheets inspected. Developer/physical-device
acceptance and full browser flow remain separate; see development evidence.

- Read ADR 006's correction, the canonical character README, the catalog/presenter,
  `preview.js`, `test_v2_appearance.gd` and the parts source README. Do not reopen
  unrelated world/backend contracts.
- Allowed: `assets/source/characters/parts/`, runtime character derivatives and
  catalog, HTML preview and its shared catalog metadata, appearance tests and
  capture tools. Preserve the canonical Joss/Lucas sources and account schema.
- First deliver a complete down-facing idle + four walk row with default and
  alternate choices. Extract source pixels into aligned layers with explicit
  material masks; preserve detailed shading and exact default reconstruction.
  Author compatible hair/face alternatives. Inspect motion before expanding to
  all eight rows. Replace the rejected procedural master after the derivative is
  reproducible; do not leave two competing current pipelines.
- Keep all existing IDs and options. Use one palette/mask specification for Godot
  and HTML. Do not silently fall back, remove controls or rewrite saved appearance.
- Replace only the obsolete translated-head checks. Retain rejection/cache/phase
  checks, add exact reconstruction against the independent original images,
  material isolation, variant-mask alignment and actual JS/Godot pixel parity.
- Run the appearance test, native matched-scale comparisons of all eight
  directions and start/turn/stop sequences, and account Web export. Compare the
  editor to gameplay. Record warnings and visual limitations separately from
  passing counts. Do not commit the candidate as finished on static sheets alone.

**C2 — Native route diagnosis, intermittent warning still open.**

Two updated default native runs passed 50 checks without warnings. A temporary
single-worker diagnostic also passed 50 but emitted the Jolt maximum-job warning;
it did not establish a cause and was removed. No permanent physics setting changed.
Keep this limitation for release review; see development evidence.

- Allowed: the existing `game/tests/test_account_location.gd`, ignored diagnostic
  drivers/logs and the directly implicated runtime code if a cause is demonstrated.
- Reproduce the stall with only one native Godot process; capture process stacks
  and route progress before termination. Distinguish a blocked physics job from a
  missing render callback or test wait. Do not infer the cause from the warning.
- Make the smallest evidence-supported correction. Re-run the affected route
  natively and headless, both stair directions, arrival, day/night and compact
  dimensions; confirm errors/warnings and no orphan test process. Engine change
  or global physics/thread tuning is outside this package without new evidence.

**C3 — Account-world integration locally verified; OVH rollout pending.**

Expanded developer authorization restores the original NPCs, street/Pazo/salon and
Scandale, excluding Casa. Local backend, full Godot suite, HTTP/WebSocket travel/
dialogue/resume, native capture, Web export and Chrome desktop/responsive checks
pass. Production is unchanged; rollout remains subject to C2 and acceptance.

- Own the inherited account place/migration/UI/authority/CI/nginx files already
  listed in the development checkpoint. Keep the durable character ID, appearance
  and existing Lourizán positions. Relocate only old laboratory saves once.
- Run account tests and the real HTTP/WSS persistence round trip after integration,
  including existing-character edit/resume, session fencing and reconnect. Export
  the final Web build, inspect the entry/editor/world route at desktop and compact
  size. The laboratory route is inaccessible; fullscreen play has no upper bar.
- Deploy only the final verified assets and matching preview metadata with the
  authorized account-world change, using the existing OVH procedure and a fresh
  database backup. Verify readiness, migration and resume without overwriting the
  developer's saved appearance or active browser edits. Preserve rollback assets.
- Record production checks honestly; physical iPhone acceptance remains separate.
  Mail configuration/public signup remains a separate pending sender dependency.

Each working package receives its own local atomic commit. No additional model
request is needed for this reviewed implementation sequence. Follow the current
user Git instructions; the historical push authorization below is not an automatic
push of this correction.

Each package uses its stated input, edit boundary, output and gate below. Before
starting, inspect current branch/status and record inherited work. Read only the
listed relevant subsystem and its tests. Proposed `game/v2/` and `backend/` paths
are ownership boundaries to confirm in P1, not directories to populate in advance.
Preserve runtime/data compatibility and do not move files merely to make them look
clean. Legacy data classes may be reused when their behavior passes the new gate.

Implement one working increment, inspect it, record evidence, and commit it with
a concise conventional message. Log commands/results and remaining issues under
`build/verification/v2/Pn/` and summarize in `docs/development.md`. Meaningful
tests target gameplay, identity and recovery failures. Native rendering, Web export
and device play are separate evidence. Never mark art accepted from a test count.

At every package handoff record base SHA, changed paths, completed acceptance
criteria, actual commands/results, capture/log paths, warnings, next unresolved
step and measured cost/time only when available. The integrator reviews the diff,
checks scope, updates Spec 020 and this plan, and commits the working package.
The subsequent 2026-10-14 request authorizes pushing completed refactor increments;
it does not authorize unreviewed service provisioning or replacing production with
an incomplete V2 scene.

## P0 — Baseline and dependency inventory

- Status: done, 2026-10-14; owner: integrator. Dependency: none.
- Output: [baseline and migration inventory](../refactor-baseline.md); native
  captures/reference scan under `build/verification/v2/P0/`. Runtime comparison
  base is `753e31c`; subsequent surf increment is `14d2be5`.
- Context: current entry point and direct dependencies, export/deploy setup,
  current asset manifests, Specs 012/018/019 and ADRs 002/003.
- Allowed: reference inventory, ignored captures and planning/evidence docs.
- Steps: record deployed SHA and reproducible build; inventory each subsystem as
  retain/adapt/replace/retire with concrete callers/assets; capture the route and
  known failures. Assess collision, movement, input and item boundaries from code,
  not from the assumption that the entire repo is unusable.
- Output/gate: a finite migration checklist, baseline screenshots/performance and
  list of genuinely unused files. Deletion follows P9; no blanket archive or purge.

## P1 — Settle the visual and online contracts

- Status: contracts complete, physical target selected (iPhone 16 Pro + Chrome); owner: integrator.
  Dependency: P0 complete. Developer authorized this review and confirmed the
  bounded product defaults on 2026-10-14.
- Output: ADRs 006/007; offline `tools/preview_v2_contract.gd` calibration at
  1280×720/844×390, evidence `build/verification/v2/P1/`. No service or database
  implementation. Art sample is calibration, not final user art acceptance.
- Allowed: contract documents, narrowly scoped disposable art/protocol experiments
  and new ADRs only for consequential decisions; no production service rollout.
- Steps: compare a small in-game art sample; decide logical pixel/camera/pose and
  import rules. Review ADR 004's headless server, WSS and account boundary against
  Web restrictions. Specify ownership, commands/results, durable IDs, transactions,
  reconnect and save cadence before creating service code.
- Output: concrete reviewed art/scene/data/network/auth contracts, a validation
  device and measured-load target, and the multiplayer quest-item policy.
- Gate: D1–D3 resolved for the next increment, with reasons and failure cases.
  Independent art preparation can proceed while operational D4 is settled.
  Confirmed correctness target: two simultaneous clients, one character/account,
  personal quest beer. This is not an MMO capacity commitment. Device details and
  measured operating capacity remain open; no production schema/provider deployed.

## P2 — A character and collision laboratory

- Status: review; owner: executor/integrator. Dependency: ADR 006 delivered.
- P2a completed: isolated collision route, intent controller, keyboard/touch adapter
  and provisional Joss presenter; 17 headless/native checks, captures and Web export.
  P2b implemented: shared-pose parts, two configurations and a patrolling NPC,
  appearance/cache/rejection checks (203), expanded input/collision checks (19),
  eight native pose sheets and a bounded Chrome render/switch/input/resize/reload check.
  Separate laboratory Web export is reproducible with `tools/export_v2_laboratory.py`.
  P2c: the same 19 collision/input assertions pass in Chrome WebAssembly at desktop
  and 844×390 for both appearances; the laboratory includes a repeatable route button.
  CI now publishes an isolated `/v2/` HTTPS preview alongside the root game for
  physical review; both V2 tests are part of its deployment gates.
  Physical target is iPhone 16 Pro + Chrome. Developer art/manual movement review,
  sustained performance and physical-device acceptance remain pending; P3 stays gated.
- Allowed: `game/v2/characters/`, `game/v2/validation/`, directly related tests;
  original character source art outside `game/` and normalized derivatives inside.
- Input/output: one body/pose format → configurable face, hair, skin and clothes
  with stable idle/walk identity in eight directions. Prove two appearances and
  one NPC configuration without generating separate full-character animations.
- Steps: make a room with walls, corner, doorway, stair and ledge; establish movement
  against explicit colliders before decoration. Use the same controller for both
  keyboard/touch and later local prediction/server validation where compatible.
- Gate: grounded feet, straight idle legs, consistent head/body proportions,
  smooth direction changes and no penetration or stair catches. Capture actual
  gameplay scale in native/Web. Performance and art are reviewed before expansion.

### P2 first working increment

- Minimum context: ADR 006, `player/movement_direction.gd`, current
  `player/player.gd` and `player/directional_animation.gd`, canonical atlas README.
- Start with an isolated scene under `game/v2/validation/`, not the production
  entry point. Build explicit floor/wall/corner/door/stair/ledge collision and
  compose an actor, input adapter, appearance presenter and camera as defined.
- Use Joss only as a temporary reference while preparing the shared pose template.
  Then compose two configurations from compatible skin/face/hair/clothing parts
  and reuse one as an NPC. Do not generate another complete character atlas per style.
- Configuration changes rebuild presentation, not physics. Unknown IDs must have
  explicit errors; compare all eight idle/walk directions and feet at actual scale.
- Output includes source/anchor notes, normalized runtime parts, idle/walk captures,
  route evidence and native/Web limitations. Keep schema/account/network/service
  files untouched in this increment. Do not start P3 until the sample is reviewed.

## P3 — First authored Jacobo Risa section

- Status: planned; owner: executor/integrator. Dependency: P2.
- Allowed: `game/v2/world/modules/`, `game/v2/world/jacobo_risa/`, place sources,
  normalized art and related traversal tests. Preserve current release entry point.
- Steps: use real references to author one floor/wall/stair/door family with shared
  dimensions, anchors and collision. Integrate the character, one NPC and object.
  Add restrained day/night presentation coherent with the approved art sample.
- Output/gate: short playable section with a clear route, occlusion, grounded
  placement and matching collision. Inspect before repeating modules. Validate
  stairs up/down, edges and doorway with real controls and compact landscape.

## P4 — Registration and persistent character creation

- Status: local test slice implemented; production activation pending.
  Owner: executor/integrator. Dependency: P1 service contracts, P2.
  Developer explicitly prioritized account entry/resume over P3 on 2026-10-14,
  then selected a single `test:test` account with public registration disabled.
  Login/creation/preview, PostgreSQL ownership, session/ticket lifecycle and the
  safe movement checkpoint portion of P5 are implemented and tested locally.
  The world is still the P2 fixture; P6 shared-player replication is not implemented.
  See `backend/README.md` and `deploy/ovh/ACCOUNTS.md`.
- Allowed: selected account service under `backend/`, reviewed database migrations,
  `game/v2/account/`, `game/v2/character_creation/`, and service integration tests.
- Steps: isolated local/staging database; register/login/logout/recovery flow;
  create one owned character using P2 parts with name validation and idle/walk
  preview. Persist and retrieve configuration through authenticated endpoints.
- Output/gate: account → character → street; repeat login in a fresh client restores
  appearance. Duplicate creation, expired sessions and unauthorized character access
  fail safely. No passwords/secrets in repository or Godot export. No guessed
  production credentials or unrelated database reuse. Public release waits on D4.

## P5 — Durable item and progress slice

- Status: planned; owner: executor/integrator. Dependency: P4.
- Allowed: reviewed gameplay persistence service/server modules, schema migrations,
  `game/v2/items/`, `game/v2/inventory/`, bounded mission state and integration tests.
- Steps: implement stable item IDs and exactly one committed holder; eight-slot bag,
  validated pickup/place, currency and one mission state. Save safe character
  location and define acknowledgement/checkpoint semantics for movement.
- Output/gate: reload, fresh login and process restart recover committed inventory,
  placement and progress. Simulate response loss after commit and a repeated request;
  reward and item transfer occur once. A failed load never overwrites state with an
  empty profile. Exercise migrations against persisted fixtures.

## P6 — Two-player shared street

- Status: planned; owner: executor/integrator. Dependency: P5.
- Allowed: reviewed headless/authority implementation, `game/v2/network/`, shared
  movement/interaction contract, staging configuration and multi-client tests.
- Steps: authenticate game connection; join one shared zone; replicate appearance
  and movement with bounded interpolation/prediction chosen in P1. Validate actions
  on the authority using the same collision layout and item rules. Add reconnect,
  stale-command rejection and explicit connection feedback.
- Output/gate: two independent browser clients see each other; racing for a common
  object produces one holder; invalid movement/foreign inventory access are rejected.
  Disconnect during transfer, reconnect and restart the server without duplication.
  Two clients establish correctness, not a production capacity promise.

## P7 — Migrate the recognizable game loop

- Status: planned; owner: executor/integrator. Dependency: P6.
- Allowed: `game/v2/dialogue/`, `game/v2/travel/`, `game/v2/quests/`, relevant assets,
  adapter code only where needed and route-level tests.
- Steps: retain Lucas's dialogue content and 20-coin beer task; apply the D3 policy
  so one player consuming beer cannot permanently deny another player's mission.
  Port contextual bag/dialogue/touch interactions and reconnectable place transitions.
  Preserve Specs 021/022 companion travel and surf diversion; durable surf rewards
  require authority validation rather than accepting an arbitrary client coin total.
- Gate: accept → collect → deliver across login/reload; exactly one reward per
  eligible character; replay and concurrent requests are safe. Scene replacement
  never becomes the owner of persistent item or quest data.

## P8 — Rebuild Pazo and salon with the validated kit

- Status: planned; owner: executor/integrator. Dependency: P7.
- Allowed: V2 Pazo/salon place scenes, authored modules, art and place/route tests.
- Steps: references → measured/estimated layout → collision walkthrough → approved
  gallery/arch sample → stairs/mansards → vegetation → salon. Integrate NPC presets,
  day/night, lanterns and permanent salon illumination through settled contracts.
- Gate: full street/Pazo/mission/salon route passes in Web and physical mobile;
  geometry, appearance, gameplay and persistent state agree for both clients.
  No further map expansion before this route is accepted.

## P9 — Cutover, restore drill and targeted cleanup

- Status: planned; owner: integrator/operator. Dependency: P8 and D4.
- Allowed: release configuration, reviewed migrations, explicitly enumerated
  obsolete files, documentation and resource references.
- Steps: measure representative load on the shared VPS; verify backup restoration
  into an isolated DB, account recovery, schema compatibility and rollback. Deploy
  a reviewable staging candidate, then request production action if not already
  authorized. Preserve the old release reference before retiring runtime entry.
- Output/gate: exact replacement/retirement manifest, rollback procedure, successful
  Web/mobile route and recovery evidence. Remove only files proven unused by the
  new accepted route and remaining reference/authoring workflows; report removals.
  Existing session-only progress has no durable historical account record to
  import. Never pretend that absent server saves can be migrated.

## Next action

Implement P2's isolated character/collision laboratory under ADR 006. P1 review
is recorded in ADRs 006/007; do not reopen those decisions for routine execution.
Physical target is iPhone 16 Pro + Chrome; physical results remain pending.
D4 recovery provider/retention/offsite objectives remain explicit launch gates.
Authorization for accounts/online/persistence is already recorded; no new product
approval is needed to execute these bounded packages.
