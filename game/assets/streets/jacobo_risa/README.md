# Calle Jacobo Risa M — geometry trial

Source: [Scaniverse scan shared by the developer](https://scaniverse.com/scan/2nt4wpvsrhi6zfza), credited there to `@J0ss` and listed as unlisted. Retrieved 2026-09-25. Its [Draco mesh](https://scaniverse.com/api/media/2nt4wpvsrhi6zfza/mesh.drc) has 277,829 triangles and roughly 73 m of length. The original `mesh.drc` and photo atlases stay in ignored `assets/work/scaniverse-2nt4wpvsrhi6zfza/` for local authoring; this repository contains the reviewed game export only.

Permission recorded for this prototype: the developer supplied the scan link and requested its integration. No separate public-distribution license was supplied.

`street.glb` has 34,970 triangles and 31,206 vertices, converted offline with
`tools/scaniverse_street/convert.cjs` (Draco 1.5.7, meshoptimizer 1.2.0,
jpeg-js 0.4.4). Colors are sampled from the original 8192x8192 photo atlas into
linear vertex RGB before simplification, preserving captured surface identity
without shipping the large photograph. UVs are also retained. Coordinates stay
in the scan's meter-scale frame and +Y is up. The wrapper owns variable-width
collision, the accessible garage apron, and two clean pixel-art garage faces.
World units have not been independently calibrated against an on-site measurement.

From the repository root, install the pinned offline dependencies with
`npm ci --prefix tools/scaniverse_street`, then run
`node tools/scaniverse_street/convert.cjs`. Inputs must be present in the local
ignored work directory. For comparison only, append an explicit ignored output
path and `--reference` to export the unsimplified mesh with its original atlas.
Do not put that heavy comparison GLB in the runtime project.

This is source geometry for evaluating contours and scale, not a finished Dreamscape environment. Future authored road, walls, vegetation, and props can each have an editable `.blend` source under root `assets/source/` and a reviewed `.glb` under `game/assets/`. The scan remains a spatial reference rather than the final texture or collision design.
