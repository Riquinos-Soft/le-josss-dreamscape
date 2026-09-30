# Home exterior capture

Source and permission: supplied by the project owner for use in Le Joss's Dreamscape, originally exported from Scaniverse. No third-party asset pack or external upload was used. This does not assign a new public license to the capture or project.

Original local source: `~/Documents/Dreamscape/Scaniverse 2026-09-09 151237.glb`. It remains external and unmodified. The committed runtime derivative is `game/assets/home_scan/exterior.glb`; `preparation.json` records source hash, Blender version, counts and texture settings.

Preparation is offline:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background \
  --python tools/prepare_home_scan.py -- \
  '/Users/josefanjul/Documents/Dreamscape/Scaniverse 2026-09-09 151237.glb'
```

The visible mesh is not decimated, leveled, scaled, stylized or supplemented with invented architecture. Its 249,260 triangles preserve the captured surface. Blender deduplicates coincident vertices during import. The image is resized from 8192 to 4096px and exported as JPEG quality 90; this is the deliberate visual fidelity tradeoff for the first Web build.

A copy of the geometry is decimated to 20% (49,852 triangles) and named `CapturedGround-colonly`. Godot's scene importer converts it to static collision, not another visible building. Normal export is disabled to avoid per-face vertex splitting; photographic shading is supplied by the scene wrapper. Keep the generated `.glb.import` alongside the runtime asset for reproducible import.

Only runtime derivatives are versioned. The external original and ignored experiment directories are not backed up by Git. Source units are treated as metres but have not been checked against a known physical measurement. Uncaptured roofs, walls and interiors remain incomplete.
