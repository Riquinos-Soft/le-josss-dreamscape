# Reusable botanical kit

Instance `cedar.tscn`, `metasequoia.tscn`, `magnolia.tscn`, `camellia.tscn` or
`fern.tscn` in any place. Place the origin at ground level and use uniform scale.
Nominal sprite heights: 10, 14, 8, 3 and 0.85 metres respectively; artwork occupies
its transparent inset, so these are presentation sizes, not measured specimens.
Large trees include a simple trunk collision; camellias/ferns are decorative.
Keep large canopies outside narrow player corridors. Billboard direction uses
the actual camera and nearest sampling. Large canopies reveal the tracked player
using the shared wall-opacity shader, keeping dense planting readable. The fern reuses the existing woodland atlas.

The original `lourizan_botanical_v01.png` atlas contains cedar/metasequoia on the
upper row and magnolia/camellia on the lower row. Metadata and references are next
to the image. These are stylized botanical interpretations, not exact historic trees.

`grass.tres` and `gravel.tres` share a fixed, metre-scale ground shader with coarse
color variation, aggregate, moss edges and leaf litter. When reusing gravel,
duplicate its material and set `path_center_x` and `path_half_width` to the mesh's
local coordinates. Avoid coplanar decoration layers. No animation or screen-space
noise is used; keep existing terrain collision.
