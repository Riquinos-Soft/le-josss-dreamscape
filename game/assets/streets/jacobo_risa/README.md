# Calle Jacobo Risa M — geometry trial

Source: [Scaniverse scan shared by the developer](https://scaniverse.com/scan/2nt4wpvsrhi6zfza), credited there to `@J0ss` and listed as unlisted. Retrieved 2026-09-25. Its [Draco mesh](https://scaniverse.com/api/media/2nt4wpvsrhi6zfza/mesh.drc) has 277,829 triangles and roughly 73 m of length. The original `mesh.drc` and photo atlases stay in ignored `assets/work/scaniverse-2nt4wpvsrhi6zfza/` for local authoring; this repository contains the reviewed game export only.

Permission recorded for this prototype: the developer supplied the scan link and requested its integration. No separate public-distribution license was supplied.

`street.glb` is a 34,921-triangle, 34,211-vertex geometry study made with `tools/scaniverse_street/convert.cjs` using Draco 1.5.7 and meshoptimizer 1.2.0. It retains UVs but uses a neutral material; the photographic atlas is intentionally absent from the game asset. Coordinates are kept in the scan's meter-scale frame and +Y is up. The playable wrapper and collision are in `world/jacobo_risa_street.tscn`, outside the imported file.

This is source geometry for evaluating contours and scale, not a finished Dreamscape environment. Future authored road, walls, vegetation, and props can each have an editable `.blend` source under root `assets/source/` and a reviewed `.glb` under `game/assets/`. The scan remains a spatial reference rather than the final texture or collision design.
