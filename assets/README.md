# Asset authoring workspace

Root `assets/` is for authoring inputs, not Godot runtime resources. Create `source/` for intentional Blender/art source files when needed. Put reviewed exports in `game/assets/`.

`captures/` and `work/` are ignored local scratch locations for future raw photos/video and reconstruction work. They do not exist yet and Git will not back them up; choose storage and backup arrangements before gathering important captures. Do not download models or reconstruction datasets for Spec 001.

When introducing a real asset, record its source, permission/license, authoring-tool version, and export settings beside the source. Use meters, apply/check transforms, and verify orientation, materials, triangle counts, texture sizes, and a sensible origin in Godot. Treat imported visuals as children of game-authored scenes so re-exporting does not overwrite behavior. Use deliberately simplified collision.

For reusable Dreamscape pieces, keep an editable `.blend` source per character or modular prop in `assets/source/`, and a reviewed `.glb` export in `game/assets/`. A street can then be composed from separate road, wall, facade, vegetation, and decor models. The current capsule player is a scale and control placeholder; a future character model can replace its visual child without rewriting movement or camera behavior. The [pixel RPG reference](../references/dreamscape-pixel-rpg-reference.png) guides silhouette, palette, lighting, and restrained texture resolution rather than serving as a texture atlas.

Budgets live in [Spec 001](../docs/specs/001-vertical-slice.md). Versioning large binary sources and capture privacy/rights should be resolved when that work enters scope, not through a pipeline built in advance.
