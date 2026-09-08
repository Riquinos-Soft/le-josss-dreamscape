# Repository and vertical-slice architecture

Status: the developer has accepted the browser baseline in Chrome and Safari. The approved single-item lifecycle is implemented; its new browser gameplay checks remain pending. The original static smoke-test scene is preserved.

## World scale

One Godot world unit is one meter. Ground plane is XZ, +Y is up, and authored forward is -Z. Player root represents the feet; the prototype is 1.8 m tall with a 0.35 m capsule radius. Movement speed uses meters/second and gravity meters/second squared. Use unit scale on physics bodies and set mesh/collision dimensions explicitly.

Blender authoring uses Metric, Unit Scale 1.0, and meter-sized dimensions with transforms checked/applied before glTF export. Let the glTF exporter handle Blender/Godot axis conversion; do not manually swap axes a second time. Validate scale with a known one-meter reference after import. Reconstruction outputs may have uncertain scale: calibrate against a known real-world measurement offline before treating geometry as meters. No scale-conversion tooling is needed now.

## Repository layout

- `game/`: Godot project root; `res://` resolves here. Contains `project.godot` and the Web export preset.
- `game/world/`: playable `courtyard.tscn` and preserved static `smoke_test.tscn`.
- `game/player/`: player scene/controller, pure movement-direction helper, and dedicated camera rig. No interaction probe implemented yet.
- `game/items/`: constant item definition, runtime instance, procedural world representation, and courtyard-local pickup/placement coordination.
- `game/inventory/`: a holder of item instances, independent of scene nodes; not a dictionary of type counts as the authoritative state.
- HUD: a few procedural Control nodes owned by `ItemLoop`; no separate UI directory/framework is needed yet.
- `game/assets/`: approved runtime GLB, textures, materials, and eventual audio.
- `game/tests/`: direction, keyboard, courtyard, and item lifecycle checks.
- `docs/`: setup, architecture, specs, and the few ADRs that matter.
- `assets/`: authoring source; ignored `captures/` and `work/` for local raw data and experiments.
- `tools/`: offline helper scripts only when repeated work warrants them.
- `references/`: curated links, provenance, and art notes, not bulk captures.
- `build/`: ignored export output, outside Godot's import root.

Create gameplay subdirectories when they gain content. Keep scenes and their scripts together by feature instead of separate global scripts/scenes trees. The only significant refinement of the requested layout is the distinction between root authoring assets and `game/assets/`: Godot needs its runtime inputs inside `res://`, while raw captures should stay outside it.

## Implemented movement layer

`Courtyard` owns `Geometry` (floor, walls, obstacles), `Player`, `CameraRig`, environment/light, and `ItemLoop`. The latter adds one `WorldItem`, or a mesh-only `PlacementPreview` during placement, and its own CanvasLayer HUD. All geometry is primitive.

`Player` uses `CharacterBody3D`, a capsule collision shape, and a separate visual root with a capsule mesh/facing marker. Named InputMap actions map physical WASD and arrow keys. `Input.get_vector` and the direction helper cap diagonal magnitude; horizontal velocity is assigned at 4 m/s and stops on release. Gravity and a 0.2 m floor snap keep the player grounded. Focus-out clears the four movement actions. Only the visual rotates toward travel; the body/camera basis does not rotate with it.

The player receives an exported `movement_orientation: Node3D`, currently assigned to the camera. The pure helper projects its basis onto XZ, including a straight-down-view fallback. A different future camera can supply a different orientation node; no fixed global angle, current-camera lookup, or camera framework is embedded in the controller.

The camera rig is a sibling of the player, targets its interpolated position at 0.9 m height, and follows with delta-based exponential smoothing. Its local camera offset is (9, 12, 12) m, perspective FOV 45 degrees, fixed heading/elevation, and no orbit input. Physics interpolation is enabled for the player; the render-updated rig opts out to avoid double interpolation. Low walls and obstacles support visible character framing; generalized camera obstruction handling is not implemented.

## Single-item implementation

`items/item_loop.gd` coordinates pickup, inventory, floor preview, validity, and the small HUD directly. `inventory/inventory.gd` owns one data reference; its removal method requires the expected instance. `items/item_instance.gd` contains only session ID and definition. `items/item_definition.gd` provides immutable constants for this one prototype (type, display name, dimensions); a Resource asset/catalog would add no value yet. `items/world_item.gd` constructs a static collision box and striped rectangular mesh, retaining the instance reference. A recreated world node receives the original data object.

Pickup is limited to 2 m with a ray against courtyard geometry. Placement targets the mouse ray's intersection with the y=0 plane, within 2 m horizontally. A rotated footprint must remain inside the 20×16 m courtyard; a physics overlap query rejects geometry/player/items while excluding the supporting floor. A player-to-target ray prevents placement through obstacles. Preview is green/red and non-colliding. Q/E rotates yaw by 90°; movement pauses until confirm/cancel. Layer 1 is courtyard geometry, 2 player, 4 item; the player collides with geometry and the placed item.

This validity policy assumes this authored flat floor and box-shaped prototype. It is not suitable for holes, uneven floors, shelves, or arbitrary supporting surfaces. The tiny top stripe is visual only. The item remains static after placement. No location metadata, serialization, catalog, or general interaction framework exists.

## Composition direction

One slice root owns the world, player, inventory, and HUD, connects local signals, and coordinates item transfers. No autoload or registry is needed for one scene/session. Reloading/restarting resets state; within a runtime session, placed items stay where confirmed.

- Player: `CharacterBody3D`, a simple collision shape, visible placeholder character, and a small interaction probe. Movement uses named InputMap actions and physics updates, projected onto the ground using the camera's forward/right directions. Rotate the character visual independently of the camera framing.
- Camera: slightly elevated third-person 3/4 view, with constrained follow behavior and a stable initial heading. Keep the character visible and frame the surrounding architecture. No free orbit, mouse-look, or cursor capture in Spec 001. A small camera rig in the player feature is enough; do not build a camera framework.
- World: static collision and meshes. Visual meshes do not define gameplay behavior. Use simple hand-authored collision shapes for this slice.
- World item: mesh and simple collision with a small local interaction script, referencing the actual item instance. Player-to-item reach/obstruction checks prevent collection through walls. Recreated world nodes represent the same instance after placement.
- Inventory: a small GDScript `RefCounted` holder, limited to one non-stackable item for this demonstration. It holds the item instance, not a scene node or a replacement counter. Capacity/transfer validation can be tested without rendering.
- Placement: one small script coordinates a non-interactive preview on the courtyard floor, yaw rotation, validity checks, confirm, and cancel. Keep it local to the slice; it is not a general furniture or building system.
- HUD: `Control` nodes under a `CanvasLayer`, showing the held item's name, Drop/Place action, and placement validity/controls. Emits requests; does not own or clone item state. No inventory grid or recipe menu.

## Minimal item boundary

The durable rule is in [ADR 003](adr/003-item-identity-and-world-representation.md): definitions describe kinds of objects; instances represent actual objects; world nodes and inventory are contexts for the same instance.

- **ItemDefinition:** shared type ID, display name, and reference to its simple visual. One small definition is enough. A Godot Resource is a reasonable authoring choice; do not build a catalog/database system. Shared definition data must not hold per-object mutable state.
- **ItemInstance:** plain GDScript `RefCounted` data with an instance ID and definition reference. ID remains stable through this session's transfers and differs from a Godot node's instance ID. A slice-local incrementing ID is sufficient; no global UUID service. Only one non-stackable object, implicitly quantity one. No owner, durability, custom property bag, or history fields yet.
- **WorldItem:** the scene representation of an instance, with a world transform and interaction/collision. Visual or preview nodes are not the object identity. Transform belongs to the world representation for now, not to shared item data.
- **Inventory:** a holder of instances, with one slot for this test. Counts may be derived for display; counts cannot replace identity. Other containers are future holders, not a base-class hierarchy to implement now.

An item has exactly one committed location: world or inventory. Do not duplicate authoritative location fields across models. Future ownership means who owns an item, not which holder currently contains it; neither player ownership nor cross-world location metadata is required yet.

Pickup validates reach, obstruction, capacity, and an in-progress guard before a synchronous transfer of the same instance to inventory. Disable world interaction immediately on success, then remove the world representation. Failure leaves the original untouched; repeated input cannot duplicate it.

Drop and place are one operation in Spec 001. Entering placement leaves the real instance in inventory and displays a non-colliding, non-pickable preview. Aim at floor within reach, rotate around the vertical axis, and validate the footprint. Confirm revalidates and transfers the instance to a new world representation at the preview pose. Complete synchronously; if creation or validation fails, leave inventory unchanged and remove any partial representation. Cancel removes only the preview. Do not add a second physics-toss path.

Use a clearly asymmetric block as the item so yaw changes are visible. Proposed limits: flat courtyard floor only, free horizontal position within reach, 90-degree yaw increments, no overlap with walls/player, no stacking, surface attachment, snapping grid, gravity simulation, or arbitrary three-axis rotation. These constraints keep the slice small; they do not define the long-term placement rules. Repositioning in the slice is pickup followed by placement.

Crafting is deferred from Spec 001. When added later, crafted output should be an item instance usable by this same placement path. Ingredient consumption/output creation rules belong to that later spec; no crafting implementation or tests now.

No ECS, event bus, generic entity framework, database repositories, event sourcing, save format, speculative networking layer, or complex inheritance. Direct references and local signals are enough. Test identity conservation and failed/cancelled transfers; test geometry and interaction in the actual scene.

## Reality, objects, and future housing

Recognizable reality and a home world anchor anomalies, dreams, alternate times, parallel universes, distant places, and impossible interiors. These places should feel connected: objects and consequences may return with the player. A home can eventually become a physical collection of everyday belongings and artifacts discovered elsewhere. Persistent, freely arranged housing is a product pillar, not a technical deliverable for this slice.

A future world area can start as an independent Godot scene or controlled space. A scene transition may stand for sleep, temporal displacement, another version of a location, distant travel, or an impossible doorway. A small transition coordinator can later carry selected player/item data between those scenes. Decide which data survives a scene replacement and which transitions permit transfer when that feature is actually built; do not assume scene unloading will preserve nodes. Different area rules can initially be local behavior rather than a universal rules engine.

Do not introduce RealityManager, UniverseRegistry, TimelineService, MultiverseGraph, or any transition code in Spec 001. A session-local ID is not a durable cross-save identity solution. Keeping object data independent of its world node provides a useful boundary without solving serialization, networking authority, or persistence now.

Later item requirements may include durable identity, owner, current world/reality, container/location, world position/rotation, quantity for stacks, condition, crafted/custom properties, and provenance. Place those fields where the actual feature requires them; do not add placeholders today. Provenance might explain how a radio from an alternate 1980s city reached a present-day house, but no history tracking is planned now.

Housing may later build on placement for moving/rotating objects on floors, tables, shelves, and containers; storage/trading and leaving objects in persistent locations remain future work. No housing scenes, placement-slot catalogs, persistence backend, accounts, or servers. The current model does not promise multiplayer readiness.

Stylized low-poly, pixel-influenced visuals support the preference for rich interaction over costly graphical detail. This is a direction for future tradeoffs, not permission to add simulation or optimize speculative workloads. Offline reconstruction still produces reviewed, stylized assets through ADR 002; it never dictates item or reality behavior.

## Final camera direction

The product uses a visible third-person character and slightly elevated 3/4 framing, closer to a modern 3D adventure/RPG than first-person survival. Movement is camera-relative. Initial camera behavior stays constrained/simple so environments and architecture remain readable. Exact distance, elevation, projection, and follow tuning can be playtested without changing this direction.

First-person and fixed cinematic dream cameras may be considered later, outside Spec 001. The static baseline camera is only a rendering test; the block is geometry, not a player implementation. This product decision lives here and in the spec; it does not require another technical ADR.

## Remaining reversible design choices for Spec 001

- **Placement controls:** recommend cursor-to-floor targeting, Q/E yaw rotation during placement, click to confirm, Escape to cancel. Keep movement inactive during the preview for a stable reach origin. Exact key bindings and angles are tuning choices; identity-preserving return to the world is required.
- **Dream quality:** recommend one authored visual impossibility at the edge of an ordinary courtyard. Dynamic reality blending, streaming, and procedural generation can wait.

The three durable technical decisions are the engine/Web baseline, offline asset boundary, and item identity/world-representation boundary. The old count-only inventory and inventory-only crafting output proposals are superseded. The scene-root composition, camera direction, engine settings, and asset boundary remain compatible and unchanged in principle. Narrative choices, filenames, and placement-key tuning do not need ADRs.
