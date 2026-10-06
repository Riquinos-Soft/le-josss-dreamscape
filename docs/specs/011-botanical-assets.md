# Spec 011 — Reusable botanical assets and garden ground

Status: implemented
Updated: 2026-10-06
Language: en

## Scope

Authorized by the developer: invent reusable assets inspired by species at the
Montero Ríos estate and enrich the current ground. Add original cedar,
metasequoia, magnolia and camellia sprites, reusable plant scenes, fern understory
and shared ground materials for grass and gravel. Preserve the existing map,
player, camera limits and walking routes. No new gameplay systems.

## References

- https://blog.turismo.gal/paseo-romantico-por-el-pazo-de-lourizan/
- https://lourizan.xunta.gal/es/jardin-botanico/curiosidades-sobre-jardin
- https://www.turismo.gal/que-facer/ruta-da-camelia/camelias-durmindo-en-pazos?langId=es_ES

These support species choice, not exact tree positions. Assets are stylized
original interpretations. Reuse them by instancing species scenes with uniform
scale; retain documented metre dimensions, source and atlas layout.

## Acceptance

Distinct tree silhouettes, flowering camellias and fern understory appear in
Lourizán. Ground has restrained gravel, moss, grass variation and leaf litter,
without coplanar overlays or noise animation. Existing walking/stair/travel
checks pass; native captures are inspected and Web export succeeds. Record
commands, evidence and remaining visual acceptance in development.

## Next step

Implementation complete. Original alpha atlas and five reusable species scenes
are in `game/world/vegetation/` and `game/assets/art/vegetation/`. Full check and
Web export passed (752 checks). Native garden captures and developer visual
acceptance are tracked in development; refine art only after reviewing these.
