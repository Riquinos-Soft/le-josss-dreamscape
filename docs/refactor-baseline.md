# V2 baseline and migration inventory

Updated: 2026-10-14. Plan 016 P0, integrator-owned.
Scope: reference inventory and migration boundaries; no runtime replacement.

## Release and reproducibility

- Original palace comparison: `ab91b89`, deployed successfully in run 38393362916.
- Current captured reference: `753e31c`, including the travelling chicken;
  CI/import/tests/export/deployment succeeded in run 38487188852.
- Subsequent bounded addition: `14d2be5`, Lucas surf arcade. Its native evidence
  is separate under `build/verification/surf/`; P0 world captures precede it.
  CI and deployment succeeded in run 38487990020.
- Entry: `game/project.godot` → `world/dreamscape.tscn`. Godot 4.7.2 standard,
  GDScript, Compatibility, Jolt, metres, single-threaded Web export.
- Rebuild: `make import export-web GODOT=/Applications/Godot.app/Contents/MacOS/Godot`.
  Release references remain in Git; do not overwrite them or copy the whole repo.
- Deployment: `.github/workflows/ci.yml` builds/tests before publishing through
  `deploy/ovh/receive-release.py`. `release.txt` identifies the deployed commit.
  P0 changes neither deployment permissions nor the production entry point.

## Concrete dependency inventory

### 1. Session composition — replace during P3/P7

`world/dreamscape.tscn` owns Street, LocationSlot, ItemWorld, TravelMap,
DialogueBubble and BagUI. `world/dreamscape.gd` also creates day/night, background,
lamps and the chicken, stores currency/beer flags, binds NPCs and coordinates
travel/input locks. It grew from 554 lines at the captured baseline to 608 with
surf; length alone is not a defect, but these are distinct migration boundaries.

Street remains loaded while Pazo/home are active because player, camera, item loop,
touch HUD and presentation are children of Street. V2's player/session must be
independent from any particular place. Keep this release intact until the isolated
V2 route can replace those callers together. Do not move files as a substitute
for separating responsibility.

### 2. Movement and collision — retain helper, adapt controller in P2

`player/movement_direction.gd` is a pure camera-relative direction helper.
`player/player.gd` owns a CharacterBody3D: keyboard/touch/right-mouse intent,
gravity, floor support, step assistance, respawn and the mount multiplier.
`player/player.tscn` defines the capsule, floor snap and collision layers.
Keep these explicit semantics and units; isolate input acquisition from movement
before sharing simulation with authority. Do not introduce an ECS/controller bus.

Street collision comes from authored CROSS_SECTIONS, not the noisy rendered scan;
`jacobo_risa_street.gd` applies provisional scale 1.45. Pazo creates static bodies
alongside authored geometry at scale 1.2. Home uses imported collision and scale
1.3. The existing `world/modules/stair_flight.tscn` is a useful laboratory reference,
not a measured real-home module. P2 must prove wall slide, corner, door, stairs
and ledge before selecting a module for P3. No new collision failure was reproduced
by P0's static captures; historical complaints remain requirements, not evidence
that every collider is broken.

### 3. Character identity — retain reference, replace baked appearance in P2/P4

`street_character.gd` reads resolved velocity; `directional_animation.gd` provides
eight-way hysteresis and preserves walking phase. Preserve those behaviors.
`assets/art/characters/joss.tres` and `lucas.tres` load canonical 64px atlases.
Humans currently use maximum 48px body height, baseline y=60 and 0.0375m/pixel.
Idle processing retains walking head/torso pixels and substitutes straight legs.
Residents use baked appearances. These atlases cannot implement independent face,
hair and clothes changes; retain them as visual references until layered parts
have demonstrated the same identity in every pose. Keep source masters and
normalization tools outside `game/` as specified by ADR 002.

### 4. Camera and touch — adapt in P2/P3

`camera_rig.gd` has fixed heading, interpolated follow, floor clearance and
orthographic size 13.5 for the live places. The scene's perspective defaults also
serve old fixtures; do not confuse those defaults with production framing.
`touch_controls.gd` directly accesses sibling Player/ItemLoop and handles joystick,
contextual actions, bag hit regions, portrait pause and input reset. Preserve the
player-facing behavior while replacing its Street-relative dependencies.
Bag (layer 15), dialogue (20), surf (40) and portrait blocker (100) have deliberate
ordering; new scenes must preserve modal ownership and focus recovery.

### 5. Items and bag — retain invariants, adapt storage in P5

`item_instance.gd` separates identity from representation; `inventory.gd` holds
eight exact item references and rejects duplicate references. `world_item.gd`
holds the original instance. These boundaries already satisfy ADR 003 and should
survive. Current IDs increment within one session and are not durable IDs.

`item_loop.gd` combines support/ray/overlap checks, preview, input/HUD, local
transfers and location snapshots. World records retain actual RefCounted instances
and Transform3D values in memory; reload loses them. `street_item_loop.gd` adds
street placement settling and Spanish HUD. V2 must split authoritative transfers
from local preview/UI, preserving reach/support and one-holder invariants. An
inventory redraw or scene recreation must never allocate a new durable item.

### 6. NPC/dialogue/beer task — retain content, adapt behavior in P7

`lourizan_guide.gd` is shared by the guide/residents. Its local AnimatableBody3D
patrol directly updates position; it is not a general navigation solution.
`smoking_pause.gd` is presentation. `lourizan_history.gd` contains the ten dialogue
variants. `dialogue_bubble.gd` owns pages and the new explicit yes/no choice.

The session root owns beer-started/completed and coins. Delivery removes the
matching beer then adds 20 locally. Preserve the story/reward and once-only rule;
P5/P7 must replace local mutation with one durable authority transaction. One
globally consumed beer would prevent later players completing the task, so D3
must settle quest availability separately from shared-object contention.

### 7. Travel, companion and surf — adapt in P7

`travel_map.gd` and `travel/exit.tscn` expose destinations. The session loads an
incoming scene and validates its arrival ground before committing item/place
state. Preserve failed-travel rollback, safe arrival and modal cleanup.
`lourizan_passage.gd` invokes explicit salon/terrace markers.

`chicken_mount.gd` now carries a recruited hen through successful travel and salon
passages, retains mounted state, and applies exactly 1.8× speed. Its source/runtime
atlas is intentional. Preserve this new parity item in V2; do not create a second
physics controller or infer a breeding/ownership system.

`minigames/surf_arcade.gd` is a bounded Control scene with one finished reward;
the session suspends the world and adds collected coins on return. Keep it separate
from the shared street simulation. Durable/online surf rewards need authority
validation in P7; never accept an unrestricted client-supplied coin total online.
No ranking, multiplayer surf or minigame framework is authorized by that parity.

### 8. Place art, lighting and backgrounds — adapt/replace in P3/P8

`jacobo_risa_street.gd` builds walkway/garage; `street_decor.gd` uses current foliage,
woodland and stone SVG assets. `lourizan_exterior.gd` batches authored geometry
and loads seven SVG ornament names dynamically. Five vegetation scenes are also
loaded dynamically by kind. `lourizan_salon.gd` builds furniture and light.

`daylight.gd` grades the world and `dream_castles.gd` background from the same local
clock. `pixel_lantern.gd` provides screen-space pools; these do not cast physical
shadows. Preserve day/night consistency, HUD readability and constant salon light.
P0 terrace capture shows very fine window/baluster detail alongside much coarser
character/foliage clusters; the salon retains primitive furniture silhouettes.
Those are concrete art-density issues for the sample, not permission to repaint
all locations before P2/P3 establish a coherent replacement.

### 9. Accounts, online and durable state — implement after P1 review

There are no account, network authority or gameplay persistence modules to migrate.
`deploy/ovh/compose.yaml` describes an isolated PostgreSQL service and static host;
`backup.sh`/timer describe operational backups. Neither establishes player saves,
account recovery or a game server. P0 did not connect to the DB or inspect secrets.
Retain ADR 004's deployment separation. Resolve auth/authority/transaction/recovery
contracts before introducing the first service, schema or dependency.

## Actual retirement candidates

Full-path resource scan was followed by inspection of dynamic loaders and importer
dependencies. SHA-256 grouping found no identical complete tracked artwork files.
The absence of byte duplicates does not establish visual equivalence or quality.

- `game/world/vegetation/gravel.tres`: no runtime/test/preparation caller found.
  Pazo uses `grass.tres` and its own paving material; plant loading constructs
  `.tscn` paths, not this material. Candidate for P9 retirement, 293 bytes, not
  deleted during this inventory.
- `game/world/smoke_test.tscn`: no live scene caller, but explicitly preserved as
  the original static baseline in game/README. Historical reference, not trash.
- `courtyard.tscn`, `home_exterior.tscn`, `lourizan_preview.tscn`: current automated
  fixture callers exist; keep until replacement tests no longer need them.
- Seven `lourizan-*.svg` and all five plant scenes: dynamic runtime callers exist;
  retain. Brais is used by the salon, despite not appearing in the exterior scene.
- Home JPEG: imported GLB material dependency, already established by Spec 017;
  not an unused duplicate to remove. Offline masters differ from runtime images.
- Remaining `_v01`/`_v02` environment filenames have active callers. Naming cleanup
  can be atomic during migration, but a suffix is not evidence of dead content.

## Native/export evidence and limitations

Evidence directory: `build/verification/v2/P0/` (ignored local artifacts).
`inventory.py`/`inventory.log` record reference candidates, hashes and payload.
`capture.gd`/`native.log` record eight reference views: Pazo arrival day/night,
terrace, salon night, street arrival day/night, lower end and compact touch.
The run uses scripted travel/positioning, not manual keyboard/mobile traversal.

On Apple M5, native Compatibility at 1280×720 (compact 844×390), each settled
view sampled 120 rendered frames after warm-up with a 60fps cap. Observed throughput
was about 60fps; frame counts reported 42–69 draw calls and 196–315 objects in
desktop views, 67 calls/194 objects in the compact view. Static engine allocation
was approximately 81–89 MB; this excludes full GPU/process/browser memory.
The raw process-time monitor fluctuates and is not a sustained CPU budget. The
initial unwarmed log is retained as invalid timing evidence, superseded by
`native.log`. No thermal, network, physical-device or browser performance claim.

Baseline Web output: 76,901,473 bytes across nine files (~73.34 MiB uncompressed),
including 39,514,754-byte WASM and 34,518,456-byte PCK. This supersedes much older
38 MiB payload figures; it is not a compressed network-transfer measurement.
Export currently includes all resources except tests, so retained legacy fixtures
may still be packaged. Narrow export roots only after dynamic resource coverage.

## Finite migration checklist and handoff

- [x] Preserve release SHA, successful build/deploy evidence and current entry.
- [x] Identify actual callers for movement, items, camera, art, UI and lifecycle.
- [x] Capture comparable native routes/day/night and record limited render metrics.
- [x] Separate a proven unused material from dynamic/import/fixture dependencies.
- [ ] P1: close visual/pose and authority/account/transaction contracts, including
  D2 device/load and D3 shared quest policy. No service rollout in this package.
- [ ] P2/P3: isolated character/collision laboratory and one authored street module;
  preserve current entry, then demonstrate appearance variants and reliable routes.
- [ ] P4/P5: real account → configurable character → acknowledged durable item state.
- [ ] P6/P7: two authenticated clients, contention/reconnect, migrated beer/travel,
  companion and bounded surf reward parity.
- [ ] P8: Pazo/salon migration using the proven kit, with real-place references.
- [ ] P9: restore/cutover/rollback drill, explicit retirement list, targeted cleanup.

P0 completes only Spec 020 AC1's inventory/build reference, not V2 runtime or art
acceptance. Next unresolved step is P1. The developer authorized continuation on
2026-10-14 after the Spec 003 review request; no external reviewer or model switch
is asserted by this document. Keep operational D4 choices open until concrete
recovery/release requirements are available.

## References

- [Spec 020](specs/020-persistent-online-vertical.md)
- [Plan 016](plans/016-persistent-vertical-rebuild.md)
- [Source/runtime cleanup evidence](specs/017-asset-workspace-cleanup.md)
- [Asset boundary](adr/002-offline-asset-boundary.md)
- [Item identity](adr/003-item-identity-and-world-representation.md)
- [Hosting direction](adr/004-hosting-and-persistent-server-direction.md)
