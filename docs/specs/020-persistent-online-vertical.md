# Spec 020 — Persistent online vertical rebuild

Status: draft
Updated: 2026-10-13
Language: en

Authorization: developer requested a controlled rebuild plan on 2026-10-13,
explicitly adding registration, character creation, online play and persistence.
This authorizes these features as product scope. Infrastructure provisioning,
provider selection and production replacement are not implied by writing the plan.
Acceptance: planning only; no V2 runtime, accounts, online server or persistent
gameplay has been implemented. Draft status reflects unresolved technical decisions,
not a request to reauthorize the already requested product scope.

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

Documentation-only preparation based on clean `ab91b89`, whose CI/deployment
previously completed successfully in run 38393362916. Read Spec 003, ADRs 003/004,
the existing art/roadmap contracts and current runtime entry point. No backend,
load, account, new art or migration validation is claimed. Run documentation and
whitespace checks for this change; runtime acceptance is future work.

## Open questions

- D1 — Integrator/Astra architectural review: finalize pixel/pose contract and
  scene composition; confirm authoritative server/WSS approach; choose account
  service/authentication method and durable save/transaction boundaries. These
  consequential choices block dependent implementation under Spec 003.
- D2 — Developer product choice during D1: expected concurrent players and target
  device; whether one character per account is sufficient initially. Proposed
  bounded default: one character and two-client acceptance, with capacity measured
  separately. These defaults are recommendations, not scale commitments.
- D3 — Developer/integrator before shared quest migration: the current single beer
  instance cannot be consumed once globally and satisfy every account. Decide
  quest-specific instancing versus shared replenishment, and who may move each
  category of placed object. Test shared ownership with a separate common object.
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
- [Current bag](012-eight-slot-bag.md), [beer loop](018-residents-and-beer-errand.md)
  and [pixel environments](019-coherent-pixel-environment.md)
