# Spec 019 — Coherent pixel environment art

Status: implemented
Updated: 2026-10-13
Language: en

Authorization: developer requested a more compatible castle background, stronger
pixel art for the Pazo/trees/environment, and Jacobo Risa as the reference for all
new art going forward. The follow-up also authorizes synchronized day/night
colors for the location and backdrop.
Acceptance: implemented, native day/night captures inspected and Web export passed.
Developer visual/physical-device acceptance remains pending.

## Objective

Make the Pazo and distant scenery belong to the same pixel RPG as Jacobo Risa.

## Scope

Replace detailed botanical and castle artwork, normalize to low-resolution
runtime textures, and apply discrete material shading/pixel clusters to authored
architecture, paving and garden ground. Record the new-art convention.

## Non-goals

No location expansion, changed collision/routes, new rendering backend, character
redesign, blurred UI or full-screen pixel filter over every object.

## Architectural follow-up — 2026-10-13

Developer rejected the initial primitive-looking arches and architectural details.
Re-author these as explicit low-resolution drawn ornaments, using the supplied
2026-10-06 palace video (00:40 vaults, 00:53 stairs) as the primary reference.
Preserve structural geometry, routes and collision. This follow-up is implemented; developer visual acceptance is still pending.
Initial material-only work is historical, not visual acceptance.

## Requirements

- R1 — Jacobo Risa's restrained earth palette, visible color clusters and crisp
  nearest sampling govern new world artwork. Avoid photoreal leaf/stone detail.
- R2 — Retain four recognizable botanical silhouettes and their grounded origins;
  tree placement and trunk collision remain unchanged.
- R3 — The illustrated floating castles use muted sage/slate/stone colors and
  atmospheric depth compatible with the garden rather than bright purple nebulae.
- R4 — Preserve Pazo landmarks, stairs/gallery silhouette and walkable geometry;
  quantize material patterns and shade bands in local space to avoid crawling.

- R5 — Use local device time for a smooth daily palette cycle shared by the
  world and background. Keep HUD colors unchanged and night traversal legible.
  It follows device time on Web and native, without networking or saved state.

## Acceptance criteria

- AC1 — Inspect native arrival, terrace and boundary composition at desktop and
  compact landscape sizes; developer visual acceptance remains separate.
- AC2 — Import and Web export succeed. Maintain source/provenance and only the
  current runtime derivative. No gameplay changes are intended.
- AC3 — Update roadmap and standing art guidance so future work uses this direction.

## Validation

Generated with built-in imagegen using the existing botanical silhouettes and
Jacobo Risa atlas as references. Runtime foliage is a 256x256 atlas (128px cells);
the backdrop is 480x270. Source masters/prompts remain outside the Godot project.
Godot 4.7.2 native captures at 1280x720 and 844x390 show day/night arrival and map
boundaries; compact terrace composition was also inspected. Daylight uses local
device time, with 13:00 and 01:00 overrides used only in the offline capture script.
UI remains ungraded. Import, lint/format, docs/whitespace checks and Web export
passed. The existing gdtoolkit deprecation warning remains. No full gameplay test
suite or physical mobile/browser review is claimed. Evidence lives under
`build/verification/pixel-environment/`. Next: developer visual review of the architectural follow-up below.

## Open questions

None blocking. Developer must review the visual result before marking accepted.

## References

- [Place authoring](../place-authoring.md)
- [Street art](002-street-trial.md)
- [Pazo](010-camera-scale-and-lourizan-art.md)
- [Botanical kit](011-botanical-assets.md)
- [Dream scenery](016-lourizan-galleries-and-salon.md)

## Architectural follow-up validation

Original integer-grid SVG ornaments replace primitive archivolts, window bars,
round balusters, mannequin statues, clock/dormer circles and spherical ivy.
Continuous stair handrails were added. Seven shared ornament materials batch the
repeated geometry; alpha scissor preserves depth without alpha sorting. Stone
noise was removed and directional contrast reduced. Structural collision/routes
remain unchanged. Sources and reference timestamps are documented alongside the
canonical artwork in `game/assets/art/architecture/README.md`.

Godot native arrival/terrace/boundary captures at 13:00 and 01:00 were inspected.
Import, Web export, formatting, lint and documentation checks are recorded in
`build/verification/palace-pixel/`. No full gameplay suite or browser/device review
is claimed. Next step: developer visual acceptance, especially the stair rail and
vault composition. This is a stylized reconstruction, not a measured replica.
