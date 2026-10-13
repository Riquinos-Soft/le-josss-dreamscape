# Runtime assets

Godot's project root is `game/`; files here are addressed as `res://assets/...`.
Keep resources used by scenes/scripts here. Offline art masters and reference-only
scans belong in [the source workspace](../../assets/README.md).

- `art/`: normalized sprites and directly editable SVG artwork.
- `branding/`: boot splash used by the project settings.
- `home_scan/`: playable home geometry with its JPEG embedded in the GLB.
- `streets/`: playable street geometry and provenance.

Track `.import` files: they define reproducible import settings, not duplicate
art. Godot stores generated imports in ignored `game/.godot/`; Web build output
lives in ignored `build/web/`. Neither cache is a source master.

The home GLB importer extracts its embedded JPEG as `exterior_texture.jpg`.
Retain both the GLB and extracted texture: the current imported material depends
on that image. This is an intentional importer dependency, not an unused asset.
The Lourizan scan is an offline reference under `assets/source/lourizan/`; it
does not belong in the Godot project or export.
