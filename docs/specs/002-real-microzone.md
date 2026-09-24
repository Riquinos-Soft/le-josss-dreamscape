# Spec 002 — Home to bar

Status: active priority, authorized by the developer on 2026-09-24. Build a walkable blockout first; recognition of the actual house/street requires developer confirmation. Spec 001 remains the regression scene.

## Scope and acceptance

- Start on the second floor (third storey) of the house. Walk through all three floors via stairs, leave through a door, follow the street past parking, enter the bar, and return home. No debug teleport or scene change in this route.
- Reuse the existing visible player, camera-relative keyboard/right-mouse movement, collisions and instance-preserving item loop. Test the courtyard as well as the new map.
- House has simple rooms, furniture, windows and doors; bar has a working entrance, counter, tables and chairs. Exterior has garden, adjoining sister's house, pavement, road, parking and visual boundaries.
- Interiors and exterior share one scene/physics space; see ADR 004. Hide roofs/upper-storey visuals for readability while preserving collision.
- Keep 1 unit = 1 metre, Compatibility rendering and the existing single-threaded Web preset. Run lint, existing tests, a full-route test, native visual inspection and Web export. Record browser acceptance separately.
- Deliver a representative game capture. Flat materials and reused primitives are sufficient; final pixel art, reconstruction accuracy and sustained performance acceptance remain later work.

## Source and provisional layout

Source: developer's `Scaniverse 2026-09-09 151237.glb`, inspected locally in Blender 5.2.1. One mesh, 196,205 vertices, 249,260 triangles, one embedded 8192×8192 JPEG, 20,600,632 bytes. Bounds are about 22.91×45.05 m horizontally and 11.85 m vertically; real scale has not been independently calibrated. Raw scan stays outside the game and Git.

Visible reference features: pale masonry, a central house, elongated garden, paths, boundary walls and a terracotta terrace. The developer identifies the central house as their sister's and their own house as adjacent beyond the garden. Uncaptured roofs, interior room plans, the road to the bar and the bar itself need confirmation. Use explicitly provisional metre-scale modules for these rather than claiming an accurate reconstruction. A request for direction/distance, parking position and floor layouts is pending.

## Small, visible steps

1. Add the new map and street/garden blockout; preserve the courtyard.
2. Add a three-storey house, room partitions and two stair flights.
3. Verify the stairs and floor-aware mouse steering; add roof/floor cutaways.
4. Connect house entrance, pavement, parking and bar entrance physically.
5. Furnish the bar and house with reused simple modules; add doors and location hints.
6. Carry/place the same item through the route; verify no courtyard regression.
7. Run the full route, inspect native frames, export Web and capture the result.

## Authoring decision

Fastest now: inspect the supplied scan in Blender, then author fixed primitive modules directly as Godot scenes. A small offline scene-building script makes repeated box, stair and prop authoring reproducible; it is not procedural world generation. Later, replace reviewed visual children with simplified Blender/GLB assets, preserving gameplay collision and scene ownership.

Photos/video and a marked map can refine silhouettes and layout. OpenStreetMap would help street alignment once a location is supplied, but cannot supply the home's interior; it adds no immediate value without that location. New photogrammetry, Gaussian splats, NeRF, AI reconstruction or LingBot-Map add setup/cleanup for already available exterior evidence and cannot establish unseen floor plans. Defer them unless a concrete missing reference justifies an offline experiment. No reconstruction dependency enters runtime.

Visual direction: World of Anterra × Ultima Online × recognizable reality × dreams. Use its [official game presentation](https://store.steampowered.com/app/2402470/World_of_Anterra/) as a composition/density/legibility reference, not an asset source. Keep one light, a limited palette and crisp UI. Evaluate reduced 3D resolution after route readability works; no expensive shader is needed.
