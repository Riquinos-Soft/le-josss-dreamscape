# Spec 001 — Vertical slice

Status: Chrome and Safari Web baseline accepted manually by the developer. The approved single-item lifecycle is implemented and passes automated native checks. New browser gameplay acceptance, subjective feel, and remaining art/performance criteria are pending; the full spec is not marked complete.

## Objective

Prove physical world item → pickup → inventory → drop/place → rotate → confirm → physical world item again, then pick it up once more. The same object must survive the change of context. A player should finish this loop within two minutes without developer assistance in a real Web export.

This is the smallest foundation for a materially interactive world; it does not implement housing or travel between realities. Crafting is secondary and deferred from Spec 001 so placement and identity are not sacrificed to keep the milestone small.

## Scope

One small enclosed courtyard, one visible primitive player, one camera, static collision, one non-stackable physical item of one type, a one-slot inventory, one placement preview, and one HUD. No external assets are required. Use an asymmetric block/primitive prop so its rotation is observable; its final name and appearance are not product decisions.

Final camera direction: third-person with a visible player character, slightly elevated 3/4 framing, camera-relative movement, and initially constrained/simple follow behavior. Frame the environment and architecture as a modern 3D adventure/RPG world. No first-person default or free orbit. Other dream/cinematic cameras are outside this spec.

Implemented controls: WASD/arrows for camera-relative movement, or hold right mouse to steer toward the cursor; keyboard takes precedence when both are active. E picks up, and P or the HUD Place button enters placement. Mouse aims at the floor, Q/E rotates 90°, left click confirms, and Escape cancels. E rotates only during placement. HUD consumes its clicks so entering placement does not confirm. Movement remains active during placement; the mouse stays free. No jumping, sprinting, crouching, animation, or alternate cameras.

Pickup transfers the actual instance into the empty inventory. Drop and placement are a single controlled operation, not separate systems or a physics throw. Keep the instance in inventory while its preview is positioned on the courtyard floor within a proposed 2 m player reach. Validity includes the whole object footprint on the floor, an unobstructed player-to-target path, and no overlap with the player or walls. No placement on vertical surfaces, tables, shelves, outside the courtyard, or in mid-air. No grid snapping, stacking, free three-axis rotation, or rigid-body simulation.

Confirmation transfers the same instance back to the world at the preview's position/yaw. The preview is not a second pickable object. Invalid confirmation changes nothing and keeps placement active; cancellation removes the preview and keeps the item in inventory. Re-pickup/replacement is the slice's way to move an already placed object. Position/rotation last for this runtime session only; restart/reload resets the authored scene and empty inventory.

Art pass: a recognizable courtyard that becomes visually impossible toward one edge, using a limited palette, simple geometry, and one surreal prop such as a floating doorway. The surreal prop is decoration, not a portal or second interactable. No photorealism, CRT shader stack, or dynamic world transformation is required.

## Acceptance criteria

- AC1 — A clean checkout opens in the documented Godot version, imports without missing resources, and runs the slice from the main scene. No Blender or reconstruction tool is needed to run it.
- AC2 — Movement is camera-relative, consistent across frame rates, does not accelerate diagonally, and collides with the floor and enclosing walls. The player cannot leave the courtyard during normal movement. The player character stays visible in an elevated 3/4 view throughout the test route; the camera follows with constrained behavior and preserves readable architecture framing without free orbit or pointer capture.
- AC3 — Start with one world item and empty inventory. Within the proposed 2 m reach, an unobstructed item shows a pickup prompt. Picking it up removes the interactive world representation and places that same instance in inventory. Out-of-range or wall-obstructed pickup changes nothing. Repeated input cannot duplicate the item. HUD shows the held item and enables Drop/Place only when occupied.
- AC4 — Drop/Place produces one clearly identifiable, non-pickable preview while the real instance remains in inventory. The cursor selects floor position within reach; Q/E visibly rotates the asymmetric preview in 90-degree yaw increments. The HUD indicates valid/invalid placement and confirm/cancel controls. Preview has no collision or gameplay interaction.
- AC5 — Confirming a valid pose empties inventory and creates one interactive world representation with the same instance ID and definition at the preview position/yaw. It can be picked up and placed again. Complete three round trips, including a rotated placement, without loss, duplicate objects, or identity changes. The confirmed pose matches the preview.
- AC6 — Confirming outside reach, behind a wall, off the floor, in mid-air, or with a footprint overlapping the player/walls leaves inventory and committed world state unchanged. It keeps placement active with an invalid indication. Escape cancels and removes the preview without losing the item. Repeated confirm/pickup and a failed transfer cannot create duplicates or drop the only reference to the instance; confirmation rechecks current validity.
- AC7 — Walk away and return to a confirmed placement during the same runtime: the item remains at its position/yaw and can be picked up. Browser reload or scene restart restores the authored start state. No save files, local-storage persistence, backend, or server state are introduced.
- AC8 — Small headless tests verify stable identity through transfers, single committed location, occupied-inventory rejection, failed/cancelled placement with unchanged state, and repeated-confirm/repeated-pickup rejection. Exit nonzero on failure. Verify geometry, preview pose, rotation, and input routing manually in the scene; do not reimplement rendering/physics to test built-in behavior.
- AC9 — Complete movement and AC3–AC7 in a native run and a single-threaded release Web export served over localhost in Chrome and Safari. Record exact engine/browser/OS versions, results, and console warnings/errors. Successful developer manual verification is sufficient when automation is unavailable; export/HTTP success alone is not. This full-loop check is distinct from accepting the earlier static baseline.
- AC10 — Browser focus loss does not leave movement or rotation stuck. HUD clicks do not pick up/confirm world actions. Entering placement does not confirm on the same click; E has only its active mode's meaning. HUD and placement status remain readable/clickable at 1280×720 and 800×600 CSS viewports with a free cursor.
- AC11 — The courtyard pairs a recognizable setting with one decorative impossible feature and a coherent stylized palette. The movable prop has a readable silhouette/orientation; UI stays crisp if 3D resolution is reduced. Art review does not require a portal, dream transition, or advanced rendering.
- AC12 — Record release payload, frame timing, visible geometry/draw calls, and available memory measurements against the budgets below. Resolve a missed budget by simplifying or explicitly revising it with evidence before marking the spec done. Interaction quality takes priority over expensive graphical detail, without adding speculative optimization systems.

## Initial budgets and measurement

These are conservative project targets, not claimed Godot/platform limits. Revisit after the first empty Web export establishes engine overhead.

- Target 60 FPS on this MacBook Air: 95th-percentile frame interval ≤20 ms during a repeatable 60-second courtyard walk after warm-up, at a documented 1280×720 browser viewport, device pixel ratio, and 3D render resolution capped at 1280×720. Repeat after ten minutes to expose sustained-load slowdown.
- First art pass: ≤50,000 visible triangles, ≤100 draw calls in the most populated view, one directional light, and at most one shadow-casting light. Start without shadows and add them only after profiling.
- Most textures 64–256 px; 512 px maximum per dimension for this slice. Use a small shared palette/material set, and tune filtering/mipmaps per asset to avoid distracting shimmer. Keep total decoded runtime textures ≤32 MiB, including mipmaps; file compression is not runtime memory.
- Game content payload ≤5 MiB uncompressed; total exported files ≤40 MiB uncompressed including engine. Record compressed transfer size separately when tested on a compressed static host. Do not promise a download time without specifying bandwidth and cache state.
- Target ≤256 MiB game/engine memory where measurable. Record browser process memory separately because it includes browser overhead; mark unavailable metrics honestly instead of equating Godot monitors with total memory.
- Eventual mobile target: sustained 30 FPS on an agreed physical Android device first, then iPhone. Devices are not selected or validated in this milestone; this is a planning target, not a mobile-support claim.

Avoid expensive full-screen effects, dense transparency, large textures, and reconstructed meshes in this milestone. Profile before adding LOD infrastructure or custom engine builds.

## Explicit exclusions

Crafting/recipes (deferred), stacking/splitting quantities, multi-slot inventory, containers, trading, ownership rules, durability, custom-property systems, provenance/history, housing, furniture interfaces, arbitrary surface placement, and physics tossing. Also multiplayer, accounts, backend, databases, cloud infrastructure, disk/browser saves, servers, NPC AI, procedural generation, real-world maps, LingBot integration, combat, quests, interiors as a system, fishing, and item equipment/use. No reality/dream transitions, timeline management, serialization, native mobile export, or touch controls. Future support remains separate work.

## Small implementation sequence

1. **Browser baseline — accepted:** developer reports successful manual acceptance in Chrome and Safari.
2. **Movement/collision/camera — implemented:** existing controls and constrained camera preserved.
3. **One item and pickup — implemented:** one definition, one runtime instance, one world representation, one-slot inventory, reach/obstruction check, and HUD.
4. **Return to world — implemented:** floor preview, 90° yaw, confirm/cancel, validity checks, and identity-preserving placement. Automated native tests cover three round trips and rejected operations.
5. **Next: developer playtest of this loop:** perform new Chrome/Safari gameplay checks and review how pickup/placement feels before choosing further work. AC9–AC12 remain incomplete. No art expansion or further feature is authorized by this implementation.

Each step is a small reviewable change or a few atomic commits. No CI service is necessary now; preserve reproducible local commands so automation can reuse them later.

## Verification record

Latest status (2026-09-08): the developer explicitly accepted the manual Web baseline in both Chrome and Safari and authorized ADR 003 implementation. This supersedes earlier pending-baseline entries below. No new browser versions or console transcripts were supplied; acceptance is developer-reported, not automated. The new item loop has not yet been accepted in browsers.

### Single-item lifecycle

- One purple striped block (0.8×0.5×0.45 m), ID 1 for this authored session, empty inventory at start. The same reference, session ID, and definition survive replacement. World representation is static; preview has no collision or instance ownership.
- 61 item checks pass headless and in native Compatibility rendering: three round trips, identity/reference checks, one committed world representation, repeated actions, occupied slot, cancellation, invalid confirmation, range/obstruction, player/obstacle/wall overlap, pose, and midair rejection.
- Existing direction (8), keyboard (32), and courtyard (30) checks pass. The south-wall test route was moved around the new physical block. Native start-frame inspection confirms visible item, orientation stripe, prompt, and control instructions.
- Web export succeeds; all 61 lifecycle checks also pass natively against the isolated final PCK outside the source project. All-resource export with tests excluded is preserved. Complete payload: 39,894,588 bytes (38.05 MiB), +21,584 bytes versus the recorded 38.03 MiB baseline. See development documentation for logs and measurement correction.
- Native automated loop is verified; manual browser item-loop behavior, GUI click routing, smaller viewport usability, and subjective placement feel await developer testing. Baseline acceptance does not certify these new behaviors.
- Art and sustained performance criteria are not claimed. No crafting, extra item type, persistence, container hierarchy, or housing was added.

Historical baseline verification on 2026-09-07 (pending entries superseded above):

- Standard Godot `4.7.2.stable.official.ed1daf0bf`; matching `4.7.2.stable` single-threaded Web debug/release templates installed.
- Static `World` scene: camera, environment, directional light, floor, and block only. No player, collision system, gameplay scripts, UI, inventory, or crafting.
- Native Compatibility rendering passed: a 600-frame normal run exited 0 without runtime errors, and a rendered frame was visually inspected. This is not the sustained performance test in AC12.
- Web release export exited 0 without reported export errors. Threads and extensions disabled. Local HTTP checks returned 200, including `application/wasm` for WebAssembly.
- Export payload: 39,858,651 bytes (38.01 MiB), of which `index.pck` is 9,216 bytes. Within the provisional 40 MiB total, but with little headroom. Gzip estimate: 10,229,354 bytes; local server is not compressing responses.
- Chrome 152.0.7977.77: rendering/console verification pending; browser automation cannot initialize because of a missing runtime file.
- Safari 26.5: rendering/console verification pending; computer-use connection failed to start. Exact manual checks and installation warnings are in [development setup](../development.md).

The static smoke scene is unchanged and its original local export is preserved in `build/web-smoke-baseline/`. Step 1 still awaits Chrome/Safari acceptance; no developer manual report has been received. The owner explicitly allowed movement work to proceed, without authorizing ADR 003 implementation.

### Movement-layer verification

- Scale established before implementation: 1 unit = 1 m, +Y up, XZ ground, -Z authored forward. Prototype capsule height 1.8 m/radius 0.35 m; 20×16 m courtyard interior. Blender/glTF/reconstruction scale guidance is in architecture documentation.
- Main scene is now `world/courtyard.tscn`: floor, four low walls, two differently sized obstacles, visible player, fixed-heading elevated camera, environment, and one shadowless light. No art/content systems or interaction objects.
- WASD/arrow keys, camera-relative ground movement at 4 m/s, capped diagonals, immediate horizontal stop, gravity/floor snap. The orientation comes from an assigned Node3D, not a fixed global camera angle. Character visual rotates independently.
- Dedicated camera follows interpolated player position with exponential smoothing, (9, 12, 12) m offset, 45-degree perspective FOV, no orbit or mouse capture. Native start-frame visual inspection passed; this does not certify framing for every possible future environment.
- Eight pure direction checks passed, including alternative heading, pitch, overhead view, diagonal cap, and analog magnitude. Thirty integration checks passed both headless and with native rendering: configured speed, camera-relative travel, stop, four boundaries, two obstacles, grounding, and focus notifications. Focus notifications were simulated through Godot; browser focus behavior is still unverified.
- Native rendered run and native execution of exported PCK exited 0, without errors/warnings. One unsupported input-reset API call found during development was replaced with releases of the four movement actions; subsequent tests passed.
- Web release export exited 0. Compatibility, no threads/extensions/PWA unchanged. New build: **39,873,004 bytes (38.03 MiB)** versus 39,858,651 bytes (38.01 MiB), an increase of **14,353 bytes (14.02 KiB, about 0.036%)**. WASM is byte-identical; PCK is 23,568 bytes. No optimization needed for this difference.
- Chrome movement now has a developer-reported manual pass. Full Chrome console/reload/resize/focus checks and all Safari checks remain pending; no automation repair was attempted.

AC1/AC2 are exercised for this movement layer locally, not a complete slice or independently verified clean checkout. Browser coverage of AC2 remains pending; AC3–AC12 remain incomplete. Step 2 is implemented; Steps 3–5 have not begun. No item/inventory/placement/crafting code exists.

Browser keyboard follow-up: bindings restricted to device 16 were corrected to all devices, and a Web-sensitive focus-in gate was removed. When movement still failed, an isolated exported-PCK run revealed the root packaging defect: the scene-only allowlist omitted the controller's preloaded movement-direction script, so the visible player had no working script. The preset now exports all project resources except tests. The isolated package loads without script errors, all automated checks pass, and the developer confirmed Chrome movement manually. Safari and the remaining browser checklist are still pending.
