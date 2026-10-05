# Spec 002 — Connected real microzone

Status: captured exterior implemented and positively received by the developer. On 2026-09-30 the connected three-storey home → street → parking → bar → home route became the immediate priority again. Preserve the approved scan as the real-world anchor; simple modular interiors are authorized, but their locations and layout still require the developer's references. The previous rejected invented map is historical.


Priority update (2026-10-05): the next planned location and travel milestone is [Spec 003 — Lourizán and map travel](003-lourizan-and-travel.md). This house-to-bar scope remains pending its references; the approved house exterior becomes the first travel destination.

## Current increment and acceptance

Implemented one reusable metre-scale stair flight; verified the existing player can descend and ascend two flights through three elevations. Default module dimensions (2.8 m rise, 5.6 m run, 1.4 m clear width) are provisional authoring dimensions, not measurements of the real house. The isolated test fixture is an authoring check, not a second game or the real house.

Next steps: identify the actual entrance and stairwell; align three floors and stairs; open the captured facade; connect street and parking; place the bar and accessible interior; verify the complete round trip and camera cutaways; add reusable props and capture gameplay. Each stage must remain visually inspectable.

The full route is **not complete**. Pending input: house entrance location, approximate floor layouts/stairwell, direction and distance to the bar, street/parking references and one known dimension for scale. Ask for these before placing guessed buildings into the approved map.

Scene composition: retain `home_exterior.tscn` as the playable root; add `buildings/home.tscn`, `buildings/bar.tscn` and street/parking children as their placement becomes grounded in references. Reusable static modules live in `world/modules/`; imported meshes remain in `assets/`. One player and physics world span interiors/exteriors. Local roof/floor cutaways are required for the elevated camera. No scene streaming or runtime reconstruction.

Pipeline: existing GLB → offline Blender cleanup/splitting and simple measured additions → GLB/static modular scenes → Godot collision/doors/cutaways. Photos, video and a rough plan fill unseen spaces. Maps can provide street outlines once a location is supplied, but cannot establish interiors. Further AI reconstruction, splats/NeRF and LingBot evaluation are deferred until new source data exposes a concrete need; none is required to author stairs or rooms.

Runtime constraints found: captured geometry is one mesh, so door openings/cutaways require offline splitting; camera shortening alone is unsuitable beneath ceilings; courtyard item placement is tied to one flat floor. Preserve its identity model and existing tests; adapt surface targeting only when item placement in this microzone is in scope.

## Immediate deliverable

- Main scene displays the actual captured buildings, garden, walls, paths and photographic appearance, preserving spatial relationships and visible geometry.
- Use the existing character, camera-relative WASD/arrows and held-right-mouse steering. Start on captured ground and allow walking along the exterior.
- Physical collision follows the scan. Small surface steps may be assisted; prevent walking off unsupported scan edges. Missing regions remain visibly incomplete.
- Preserve 1 unit = 1 metre and the scan's original scale; its real dimensions remain uncalibrated until a known measurement is provided.
- Keep the original courtyard, item implementation and tests. This scene does not instantiate the courtyard-specific placement system, whose flat-plane assumptions do not apply to rough scan terrain.
- Native inspection, captured-path movement tests, existing regressions, Web export and a representative in-game screenshot are required. Browser acceptance of the new scan is separate from the earlier courtyard acceptance.

## Source and fidelity

Developer source: `~/Documents/Dreamscape/Scaniverse 2026-09-09 151237.glb`, SHA-256 `eaaa968f8f22fb965cd10887ea714f3558c01bd9e43cfc2bf9d3743aa04c1afd`.

The capture contains 249,260 visual triangles and an 8192×8192 photographic texture. Its bounds are approximately 22.91×45.05 m horizontally and 11.85 m vertically in source units. Blender merges a few coincident vertices on import; triangle geometry and UV appearance remain unchanged. The developer identifies the central building as their sister's house and their own house as adjacent beyond the garden. Capture holes, incomplete facades/roofs and unobserved interiors cannot establish the missing real geometry.

The prepared runtime GLB retains all visual triangles and reduces the JPEG to 4096px at quality 90. A distinct 49,852-triangle collision mesh is decimated offline; it is never rendered. Full-resolution source remains external. See [asset preparation](../../assets/source/home_scan/README.md) and its machine-readable report.

## Pipeline and boundaries

Actual capture → offline Blender import/texture preparation/collision simplification → versioned runtime GLB → Godot wrapper scene. `tools/prepare_home_scan.py` reproduces preparation when the source and Blender are available. Running or exporting the committed game does not require either. No reconstruction, AI service or map dependency exists at runtime.

This fidelity prototype explicitly supersedes Spec 001's 50k visual-triangle/40MiB payload targets for this scene. Preserve captured shape at 249,260 visual triangles; use a provisional 64MiB uncompressed Web payload ceiling and record actual size. The earlier 256MiB memory and sustained-FPS goals are not claimed until measured. No generalized optimization or streaming system is introduced.

## Reference boundary

The rejected generic blockout is preserved only in ignored local `build/experiments/provisional-microzone/`. It is not part of a clean checkout or game export. World of Anterra and Ultima Online guide legibility and atmosphere; styling follows the connected traversal milestone.

## Verification

189 automated checks pass, including the unchanged courtyard regressions and 16 new stair checks. Captured-path and two-flight round trips pass natively with inspected screenshots. Web release exports at 63.25 MiB. See [commands, evidence and remaining work](../development.md#connected-microzone-first-stair-module--2026-09-30).
