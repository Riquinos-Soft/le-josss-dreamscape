# Plan 016 — Persistent vertical rebuild

## Plan header

- Objective/spec: execute [Spec 020](../specs/020-persistent-online-vertical.md)
  through independently reviewable playable increments.
- Design references: [place authoring](../place-authoring.md), ADRs 001–004 linked
  from Spec 020; existing Joss and Jacobo Risa are art references, not automatic
  approvals of every current implementation. No new Bible content was fetched.
- Base: `ab91b89`, main, clean working tree. Previous deploy succeeded; production
  art/device acceptance remains open. This change adds planning documents only.
- Status: planned, 2026-10-13. Product expansion authorized in the user's request;
  no backend/runtime execution or service connection is claimed.
- Settled: Godot 4.7.2 Compatibility, Web first, metres, stable item identity,
  same repository, small scenes, a street sample before Pazo migration.
- Unresolved: D1–D4 in Spec 020. Request Astra for the consequential decisions
  before implementing those contracts, as required by Spec 003. Preparation and
  inventory can proceed without reopening existing engine decisions.
- Single integrator: current executing session; no workers assigned. Economical
  execution resumes after contract review. No model availability or cost assumed.
- Non-goals: speculative frameworks, engine migration, mass art regeneration,
  new game features beyond Spec 020, or an unbounded legacy cleanup.
- Order: P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8 → P9.
  No parallel agent work authorized. Each package is split further if its first
  working increment cannot be reviewed independently.
- Integrator-owned shared files: indexes, roadmap, development log, architecture
  documentation, project entry point, exports and deployment configuration.

## Common package contract

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
No automatic production push is authorized by this planning request.

## P0 — Baseline and dependency inventory

- Status: ready for preparation; owner: integrator. Dependency: none.
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

- Status: planned; owner: integrator with Astra review per Spec 003. Dependency: P0.
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
  No provider, numeric capacity or database schema is treated as chosen by this plan.

## P2 — A character and collision laboratory

- Status: planned; owner: executor/integrator. Dependency: P1 visual contract.
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

- Status: planned; owner: executor/integrator. Dependency: P1 service contracts, P3.
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

Begin P0's bounded inventory. Before implementing P1's unresolved architecture,
request Astra review as specified by repository Spec 003. User authorization for
accounts/online/persistence is already recorded; do not ask to approve that scope
again. Select providers and release operations only after their concrete decisions
and environments are known.
