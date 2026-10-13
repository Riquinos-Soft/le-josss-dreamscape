# Offline asset workspace

This directory is outside Godot's `res://` root and is never exported with the
game. It contains inputs and provenance used to prepare the runtime resources in
[`game/assets/`](../game/assets/README.md).

- `source/characters/`: original generated masters, prompts and normalization
  instructions. These are larger than and different from the runtime atlases.
- `source/ai/`: vegetation masters and their preparation instructions.
- `source/home_scan/`: provenance and preparation report; the original capture
  remains at the owner's external path documented there.
- `source/lourizan/`: offline scan reference, provenance and preparation report.
  The playable Pazo uses authored geometry, not this scan.

Keep one current source per artifact and one runtime derivative when conversion
is required. Do not copy an SVG or other directly usable source here merely to
mirror `game/assets/`. Git retains superseded variants. A source master and its
cropped, scaled or palette-reduced derivative are not redundant copies.

`captures/` and `work/` are ignored scratch locations, not Git backups. Preserve
important originals separately. Record source permissions and preparation steps
beside each intentional source; keep runtime import settings beside the export.
