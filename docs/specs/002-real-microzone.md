# Spec 002 — Faithful home exterior first

Status: implemented as the current playable scene; developer playtest and capture completion remain pending. The developer corrected the initial home-to-bar blockout on 2026-09-24: first reproduce the actual house exterior from the supplied GLB, as faithfully as practical; expand toward the street/bar with later scans, video or photos. Pixel-art styling and invented room plans are deferred. This supersedes the earlier provisional generic microzone.

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

## Next unresolved work

1. Developer playtest of the captured exterior and confirmation of the house identification/view.
2. Add missing exterior coverage and a real scale reference supplied by the developer.
3. Reconstruct/clean only observed surfaces, then extend the real street and bar from new evidence.
4. Interior floors and connected house-to-bar traversal remain the later product goal; use new plans/photos to make them recognizable before revisiting ADR 004.

The rejected generic blockout is preserved only in ignored local `build/experiments/provisional-microzone/`. It is not part of a clean checkout or a game export. World of Anterra and Ultima Online remain long-term interaction/art references; fidelity to this real location takes priority in the current deliverable.

## Verification

173 automated checks pass, including the unchanged courtyard regressions. The captured path round trip also passes natively with inspected screenshots. Web release exports at 63.24 MiB. See [commands, evidence and limitations](../development.md#captured-exterior-verification--2026-09-24).
