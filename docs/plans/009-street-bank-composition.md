# Plan 009 — Street bank composition

Spec: [002](../specs/002-street-trial.md). Base: `2d77cbd`; initially clean tree.
Owner/integrator: current Codex session, sequential execution.
Status: done for implementation; developer art acceptance remains pending.
Updated: 2026-09-26.

## Scope and contract

Replace the narrow stone caps with visual grassy terrain extending 3.5–4.9 m
outside the surveyed road. Adjacent panels share endpoint widths and heights.
Reuse existing sprites in seeded, irregular groups with clearings. Preserve
the street floor, boundaries, garage opening, camera, pixel scale and smooth fade.
The banks are scenery, not an expansion of walkable space. No new raster assets,
interactions, architectural decisions, persistent state or collision layers.

## Tasks and evidence

- T01 — Author the ground shader and bank mesh: complete. Shared material,
  coarse grass/soil palette, dark outer edge; no additional texture dependency.
- T02 — Compose vegetation: complete. Seeded size/spacing, fewer repeated
  roadside plants and small outer fern/bramble clusters; existing trees retained.
- V01 — Validate: complete. 166 traversal and 33 placement checks pass. Native
  Compatibility captures inspected at route points 5, 7, 9, 11 and 12 (1280x720,
  Dummy audio driver). Release Web export and lint pass; gdtoolkit retains its
  existing `pkg_resources` deprecation warning. No physical mobile/Safari test.

Ignored evidence: `build/verification/banks-{native,traversal,item,export}.log`
and `woodland_*.png`. No repeated gameplay test is needed for later document-only
normalization. Final art review is separate from technical completion.
