# Spec 020 — Persistent online vertical rebuild

Status: in-progress
Updated: 2026-10-14
Language: en

Authorization: developer requested a controlled rebuild plan on 2026-10-13,
explicitly adding registration, character creation, online play and persistence.
This authorizes these features as product scope. Infrastructure provisioning,
provider selection and production replacement are not implied by writing the plan.
The developer subsequently authorized beginning execution and pushing increments
on 2026-10-14. Acceptance: P0 inventory/build reference and P2 laboratory implementation
complete; accounts, online server and persistent gameplay remain unimplemented. P1 technical contracts
are now reviewed in ADRs 006/007; P2 awaits visual/gameplay review. The physical target is iPhone 16 Pro + Chrome; physical
acceptance and D4 launch choices remain open. See [baseline inventory](../refactor-baseline.md).

## Objective

Build one small, coherent pixel-art playable route with reliable movement and
collisions, configurable characters and durable online progress. Prove it before
rebuilding every existing location. Preserve the current playable release as a
comparison and recovery reference while replacing components deliberately.

## Scope

First reconstruct a short representative Jacobo Risa section with floor, corner,
wall, stairs, entrance, one NPC and one movable object. Add registration/login,
character creation and reconnectable persistent play there. Then migrate the
Lucas beer loop across Jacobo Risa and the Pazo, including the existing salon.
Use the same repository and Godot baseline. Package work through
[Plan 016](../plans/016-persistent-vertical-rebuild.md).

## Non-goals

No engine migration, MMO-scale promise, combat, trading, housing, procedural world
generation, chat or social systems in this vertical. No remote AI generation at
runtime is required for character creation. No mass deletion by filename, automatic
migration of invented legacy accounts, or blanket replacement of existing systems
before the new route is usable.

## Requirements

- R1 — Record the deployed legacy commit and preserve its reproducible build.
  Develop the V2 slice in an isolated scene/module area; retain the production
  entry point until the V2 release gate passes. Review old files by actual use:
  retain, adapt, replace or retire, with dependency evidence for retirement.
- R2 — Settle an art contract with a real in-game sample: logical resolution,
  pixel density, camera/scale relationship, palette, shading, animation layout and
  export rules. Jacobo Risa and Joss remain reference targets. Author silhouette
  and color clusters; reducing a photograph or adding a mosaic is insufficient.
  Keep masters/references outside runtime and one named current runtime derivative.
- R3 — A scene module owns its visible structure, matching collision and connection
  markers. Movement must work along walls, corners, stairs, doors and elevated
  edges with keyboard and touch. Rendering changes must not change collision or
  player speed. Keep one metre per Godot unit and audit imported/scaled geometry.
- R4 — Player and NPC appearances use compatible configurable parts and one pose
  contract. Face, hair, skin and clothing choices retain identity/proportions in
  every idle/walk direction. Standing legs are straight and side by side.
  Animation uses motion state; a changed appearance must not alter physics.
- R5 — A newcomer can register, sign in and create a character with a name and
  appearance preview. Invalid/duplicate submissions show actionable feedback.
  Return visits restore the existing character. Account/session lifecycle includes
  logout, expiry and recovery. Exact authentication method remains a D1 decision.
- R6 — Durable state includes account-to-character ownership, appearance, safe
  location/position, item instance identity and location, bag contents, currency
  and mission progress/completion. Reload, logout/login and server restart must
  restore committed state. Local browser storage alone is not durable authority.
- R7 — The online vertical has one shared zone demonstrated by two independent
  authenticated clients. Players see each other's movement and appearance.
  Server-side authority validates movement and interactions, item ownership,
  reach/capacity, quest prerequisites and rewards. A client submits intentions;
  it cannot declare a balance, arbitrary item ownership or quest completion.
- R8 — Pickup/place and delivery/reward are atomic durable operations. Concurrent
  pickup attempts yield one holder; retries or reconnects cannot duplicate an
  item, create extra coins or lose a confirmed transfer. Temporary placement
  previews are local presentation and never committed item instances.
- R9 — Define reconnect, disconnect, duplicate login and save acknowledgement
  behavior before networking code. A broken connection visibly stops authoritative
  actions. Reconnect loads server truth, including transactions completed before
  the connection dropped. No silent fresh game on load/DB failure.
- R10 — Durable storage follows ADR 004's isolated PostgreSQL direction; only
  trusted services access it. Review its proposed headless Godot/WSS/account-service
  split before adopting it. Use TLS, restricted credentials, validated sessions,
  input bounds and login throttling. Define recovery, migrations and offsite
  backups; demonstrate restoration before releasing durable user progress.
- R11 — Port the eight-slot bag, contextual dialogue, map travel and beer delivery
  as small scene/domain components with explicit responsibilities. Use the existing
  item identity invariant. Character/quest/item data must survive recreation of
  visual scenes. Do not import the current world root wholesale into V2.
- R12 — Rebuild the Pazo only after the small street sample passes art, collision,
  persistence and two-client gates. Preserve defining real landmarks and valid
  routes. Day/night, permanent salon light and touch orientation behavior must
  remain part of the parity route. Reuse validated source references.
- R13 — Retire superseded files only after reference/import/export review and
  replacement parity. Git retains history; mark historical specs rather than
  renumbering or deleting their evidence. Measure native/Web/mobile performance
  against an agreed device and concurrent-player target before expansion.

## Acceptance criteria

- AC1 — Reference inventory maps every migrated subsystem to retained/replaced
  files; the recorded old release can still be built before cutover.
- AC2 — One character and one architectural sample satisfy the recorded art
  contract in identical desktop/compact gameplay views, both idle and moving,
  day/night. Developer art acceptance is recorded separately from import success.
- AC3 — Real controller traversal of floor, both stair directions, wall slides,
  narrow doorway and exposed edge has reproducible native/Web evidence. Collision
  probes and regression tests cover failures rather than scene-node counts alone.
- AC4 — Register → create character → play → logout → login in a fresh browser
  session restores the same durable character. Invalid input and cross-account
  access are rejected without partial creation or state leakage.
- AC5 — Two authenticated browser clients share the zone; simultaneous pickup,
  stale actions, invalid movement and repeated delivery do not corrupt ownership
  or rewards. Record latency/reconnect conditions and actual player count.
- AC6 — Pick up/place an item and deliver the beer, then reload/reconnect/restart
  the server. Committed item state and the once-only 20-coin reward are conserved.
  Inject failure between request and response and verify a retry is safe.
- AC7 — A staged schema migration and backup restore preserve durable identities
  and progress. Record the recovery point/time objectives and demonstrated result;
  do not claim restoration from the existence of a backup file alone.
- AC8 — Complete the two-place parity route in Web and physical landscape mobile,
  including bag, dialogue, travel, salon light and portrait overlay. Compare visual
  and collision behavior to the agreed V2 sample, not only to the legacy build.
- AC9 — Release checklist names deployment, database migration and rollback
  actions; application rollback is compatible with the deployed schema. Remove
  obsolete resources only after imports, references and Web export pass.

## Validation

P2 current: shared-pose body/face/hair/clothing parts, two configurable appearances,
NPC reuse and the isolated collision route are implemented. Appearance (203) and
collision/input (19) checks pass headless/natively; eight pose sheets and production/
laboratory Web exports completed. Bounded Chrome render, appearance switch, keyboard,
resize and reload were executed successfully. P2c also runs the shared 19-case
collision/input route inside Chrome WebAssembly at desktop and 844×390, with
19/19 passing for both appearances. Developer art/manual traversal, sustained
performance and physical-device acceptance remain open. The developer confirmed
iPhone 16 Pro + Chrome as the physical target.
Production follow-up: developer reported the new work was unavailable in production.
CI now exports the isolated laboratory to `/v2/` alongside the existing root game,
and runs its two tests before deploying. Preview publication is not art/mobile
acceptance or a V2 production cutover. Next is P2 review; P3 stays gated. Reproduction and warnings are in
[development](../development.md).

P1 completed: ADRs 006/007 settle the scene/pose, service, authority and transaction
contracts. Developer confirmed one character/account, two-client correctness and
personal quest beer. Native calibration script renders current Joss/Lucas against
one authored floor/wall sample at 1280×720 and 844×390. This proves only calibration
visibility; it does not prove layered appearance, collision, Web accounts or online
play. Evidence/command: [development](../development.md). P2 implementation follows this contract; final sample review remains pending.

P0: Plan 016 inventory completed against deployed `753e31c`, with explicit addition
inventory for surf `14d2be5`. Eight native reference views, bounded render samples,
resource/caller/hash review and Web payload recorded in
[the baseline](../refactor-baseline.md). AC1 inventory/build-reference portion
complete; no gameplay/backend/account/migration validation inferred. Next: P1.

Historical planning record (superseded as current progress):

Documentation-only preparation based on clean `ab91b89`, whose CI/deployment
previously completed successfully in run 38393362916. Read Spec 003, ADRs 003/004,
the existing art/roadmap contracts and current runtime entry point. No backend,
load, account, new art or migration validation is claimed. Run documentation and
whitespace checks for this change; runtime acceptance is future work.

## Decisions and remaining questions

- D1 — Resolved for implementation by [ADR 006](../adr/006-v2-character-and-scene-contract.md)
  and [ADR 007](../adr/007-authoritative-persistent-vertical.md), following the
  authorized review. P2 must demonstrate composable art; P4–P6 must demonstrate
  the account/authority/recovery contracts. A document is not runtime acceptance.
- D2 — Developer confirmed one character/account and two simultaneous clients for
  first correctness validation on 2026-10-14. Physical target is iPhone 16 Pro +
  Chrome, confirmed in the subsequent continuation on 2026-10-14. Physical play results, OS/browser
  versions and a sustained performance budget remain pending. Target selection is
  resolved; physical acceptance is still open and does not block local P2 work.
  Capacity is measured separately in P6/P9.
- D3 — Developer confirmed personal quest beer; ordinary objects remain shared.
  ADR 007 specifies private quest representation, single reward and common-object
  contention. No trading or unrestricted client reward submission.
- D4 — Developer/operator before external account launch: recovery method, account
  deletion/data retention, offsite backup destination and recovery objectives.
  No provider purchases, production migrations or customer-data resets are implied.

## References

- [Execution plan](../plans/016-persistent-vertical-rebuild.md)
- [Roadmap](../roadmap.md)
- [Model/decision workflow](003-agent-workflow.md)
- [Place and pixel authoring](../place-authoring.md)
- [Engine baseline](../adr/001-engine-and-web-baseline.md)
- [Offline asset boundary](../adr/002-offline-asset-boundary.md)
- [Item identity](../adr/003-item-identity-and-world-representation.md)
- [Hosting and proposed persistent server](../adr/004-hosting-and-persistent-server-direction.md)
- [V2 scene/appearance contract](../adr/006-v2-character-and-scene-contract.md)
- [V2 authority/persistence contract](../adr/007-authoritative-persistent-vertical.md)
- [Current bag](012-eight-slot-bag.md), [beer loop](018-residents-and-beer-errand.md)
  and [pixel environments](019-coherent-pixel-environment.md)
