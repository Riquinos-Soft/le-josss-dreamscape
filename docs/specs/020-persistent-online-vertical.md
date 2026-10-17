# Spec 020 — Persistent online vertical rebuild

Status: in-progress
Updated: 2026-10-17
Language: en

Authorization: developer requested a controlled rebuild plan on 2026-10-13,
explicitly adding registration, character creation, online play and persistence.
This authorizes these features as product scope. Infrastructure provisioning,
provider selection and production replacement are not implied by writing the plan.
The developer subsequently authorized beginning execution and pushing increments
on 2026-10-14. Acceptance: P0 inventory/build reference and P2 laboratory implementation
complete; the account-entry/character-checkpoint test slice is deployed on OVH,
with HTTPS/WSS creation, movement, logout/resume and restart recovery verified. Inventory, quests
and multiplayer replication remain unimplemented. P1 technical contracts
are now reviewed in ADRs 006/007; P2 awaits visual/gameplay review. The physical target is iPhone 16 Pro + Chrome; physical
acceptance and D4 launch choices remain open. See [baseline inventory](../refactor-baseline.md).

## Current priority — developer clarification, 2026-10-14

The developer corrected the sequence: arrival must show login/registration; an
existing account resumes its owned character at its last committed position, while
a first-time account creates one named character with modest Ultima Online-style
appearance choices and a preview. Account and character data must live in the
database. Prioritize this entry/resume vertical before further street authoring.
P3 is deferred; P4 and the movement-checkpoint portion of P5 may use the existing
validation location while the authored street remains pending. This is not
authorization to claim the laboratory is the finished world. Preserve the accepted
Django/PostgreSQL and headless-Godot authority contracts. The developer subsequently specified exactly one initial `test:test` account.
That initial restriction was superseded on 2026-10-17: the developer explicitly
authorized public self-registration and configuring outgoing mail. The existing
email/password, verification and recovery contract remains in force. No custom
domain or SMTP service is currently configured; sender/provider setup and the D4
recovery arrangements remain the next unresolved launch steps. Until those work,
production registration remains disabled rather than creating unusable accounts.
First verified login opens the character creator. On 2026-10-17 the developer
reported that the existing test character skipped creation and went directly to
the validation room. The bounded correction shows the owned character's name and
appearance editor before entering on return visits, with a continue-without-changes
action. Saving must preserve character identity, ownership, place and position;
validate the same appearance choices as creation and fence older game sessions.
An in-game return to this screen must acknowledge the movement save before leaving.
This correction is deployed. Fifteen account tests and the local real HTTP/WSS
round trip pass; production Chrome loaded the editor and preview. Full physical
phone acceptance remains open. Public signup still awaits working outgoing mail.

## Current correction — remove the public test room, 2026-10-17

2026-10-18 scope update: the developer explicitly requested restoring the detailed
Joss character, original NPCs and map travel to all existing authored destinations
except Casa. Include Calle Jacobo Risa, Pazo de Lourizán (including its salon) and
Bar Scandale. Reuse their existing art, speakers/dialogue and marked exits. Casa
must not be selectable or reachable through a forged destination request. This
supersedes the earlier deferral of NPC/travel migration for this correction.
Account play must retain identity and save both destination and position; a separate
legacy preview is not completion of the account-world restoration. Keep server
authority over movement and travel; do not trust client-submitted coordinates.

The developer explicitly rejected entering the validation room and requested its
removal from public play, together with the upper character/logout bar. This
supersedes the temporary laboratory destination and the in-game personalization
button described above. Use the existing authored Lourizán exterior as the bounded
account destination, with the same visible geometry/collision on client and trusted
authority. Preserve one owned character and its appearance; relocate only existing
`laboratory_v1` saves to Lourizán's safe arrival through an additive data migration.
Subsequent Lourizán saves must resume without relocation. Reuse the existing scene,
camera, background and day/night components instead of importing the legacy world
root or inventing new art. Travel/NPC/economy migration remains separate.

Play must fill the page without a permanent top bar, character label or logout
button. Show a reconnect notice only while connecting or after a connection error;
hide it when play is connected. Keep character personalization at account entry.
Stop publishing the laboratory preview route/export. Collision fixtures may remain
internal automated test inputs; they are not player destinations. Current status:
in progress. Seventeen backend tests, the local HTTP/WSS round trip, headless
25-check route and account Web export pass. One native route run passed 25 checks,
but repeated native runs intermittently stall with a Jolt job-system warning.
The V2 character design/walk has also been explicitly rejected. Next: resolve the
canonical-animation/shared-pose conflict and native stall before OVH rollout.
The developer authorized the requested review on 2026-10-17. The decision is now
closed in [ADR 006](../adr/006-v2-character-and-scene-contract.md): derive lossless
layers and explicit material masks from the original per-phase Joss pixels;
preserve existing appearance IDs, actor, direction helper and cadence. Replace
the incorrect fixed-head oracle with exact default reconstruction of the canonical
poses and matching editor/game compositions. The canonical character implementation is locally verified (195 appearance
checks, 120 HTML/Godot composition matches, 382 native motion checks and account
Web export); developer art acceptance and full account-world browser checks remain.
Full NPC/map integration is pending; keep the prepared runtime correction local until the character
correction and native failure investigation pass. Plan 016 records the bounded
execution sequence. No further architecture approval is needed for that sequence.

### Design fit for the character correction

- Exact reference: `game/assets/art/characters/joss_walk.png`, `joss_idle.png`
  and `joss.tres`; Lucas is the second style reference.
- Preserve original silhouette, clusters, per-phase motion, eight directions,
  8 fps walk, idle/walk0 upper-body identity, grounding and turn/stop continuity.
  Personalization changes only authored material masks and compatible overlays.
- Reuse the existing presenter, actor, direction helper and cache. Keep saved
  appearance IDs and all offered choices; no new identity or animation system.
- Compare reference/default/alternate in motion at the same gameplay camera and
  in the editor, all eight directions. Default composition must exactly reproduce
  the original pixels. Compare HTML and Godot output pixels as well as appearance.

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
  session restores the same durable character in the personalization screen.
  Saving a new name/appearance preserves identity, ownership, place and position;
  continuing without changes does not modify state. Returning from play to edit
  waits for the save acknowledgement. Invalid input and cross-account access are
  rejected without partial creation or state leakage.
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

Current entry/resume slice: login-first HTML entry, database-backed one-character
creation with P2 part preview, single-use game tickets, headless Godot intent
simulation and safe position checkpoints are implemented. Twelve PostgreSQL account
tests pass, as does a real HTTP/WebSocket round trip covering fresh login, movement,
logout acknowledgement, replay rejection, duplicate session fencing and authority
restart. A local dump was restored into a separate database and compared for ID,
name, appearance and position. Chrome exercised first creation, entry, logout and
return login, including compact layout. These are local tests, not production or
physical iPhone acceptance. Current location remains the P2 validation room.
Production follow-up on 2026-10-17: account services are active. Public HTTPS/WSS
checks passed first character creation, movement, acknowledged logout, fresh-session
resume, Secure/HttpOnly sessions and service-restart recovery. The character used
for the shared test account is named Joss. Fifteen local PostgreSQL tests now pass,
including registration → verification → first creation → fresh-session resume and
isolation from the test account. Email in those tests uses an in-memory sink; real
mail delivery and public registration remain unverified. Next: configure the
operator-selected sender, verify actual delivery/recovery and resolve D4 launch
choices before enabling registration; then physical iPhone review and authored
world migration. See the current deployment record in [development](../development.md).
No legacy progress migration is claimed.

Historical P2 validation follows:

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
and runs its two tests before deploying. Run 38576229271 deployed `fc009d2`;
the public preview loaded and its route passed 19/19 in desktop Chrome.
Preview publication is not art/mobile
acceptance or a V2 production cutover. The later account-first clarification above
supersedes the former P2-review/P3-first sequence. Reproduction and warnings are in
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
