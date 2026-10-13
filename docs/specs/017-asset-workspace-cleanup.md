# Spec 017 — Asset workspace cleanup

Status: implemented
Updated: 2026-10-13
Language: en

Authorization: developer requested an explanation and cleanup of root assets,
runtime assets and useless duplicates on 2026-10-13.
Acceptance: inventory, cleanup, documentation, import and Web export complete.

## Objective

Make the source/runtime boundary clear and remove obsolete or redundant assets.

## Scope

Asset directories, their provenance notes, preparation paths and import settings.
Keep original art masters needed to reproduce normalized sprites. Retain the
Lourizan scan as an offline reference as required by Spec 010.

## Non-goals

No art redesign, gameplay changes, appearance generator or deletion of user
captures, historical verification evidence or development caches.

## Requirements

- R1 — Root `assets/source/` contains offline masters and reference scans;
  `game/assets/` contains resources imported by the game.
- R2 — Remove unused assets and duplicate extracted image files only after
  checking scene/script references and embedded GLB data.
- R3 — Preserve provenance and reproducible preparation commands. Update paths
  when an offline reference moves out of the Godot project.

## Acceptance criteria

- AC1 — Document every deletion/move and its dependency evidence.
- AC2 — Import and Web export succeed; the home scan still has its texture.
- AC3 — Documentation links and Git whitespace checks pass. No new gameplay
  acceptance is inferred from an asset cleanup.

## Validation

Tracked-file SHA-256 inventory found no identical complete files. GLB inspection
found extracted JPEGs identical to embedded image data. Removed the unused
Lourizan JPEG (4,440,259 bytes), its import settings and an unused shrub SVG/import.
Moved the unchanged 12,982,644-byte Lourizan GLB outside Godot and updated its
preparation script. The home JPEG remains: the active imported emission material
references it at 4096x4096. Source masters remain distinct from runtime atlases.

Godot 4.7.2 import and `make export-web` succeeded; documentation and whitespace
checks passed. Evidence: `build/verification/asset-cleanup/`. An initial import
reported a stale UID during an abandoned home-import experiment; the original
home configuration was restored and the final import/export have no warnings or
errors. No gameplay changes, gameplay test suite or physical-device review.
Next action: none for this cleanup; configurable characters remain separate.

## Open questions

None. Keep both source and runtime directories because their contents serve
different purposes; avoid duplicating editable SVGs already usable by Godot.

## References

- [Asset workspace](../../assets/README.md)
- [Offline Lourizan reference requirement](010-camera-scale-and-lourizan-art.md)
- [Character asset contract](../../game/assets/art/characters/README.md)
