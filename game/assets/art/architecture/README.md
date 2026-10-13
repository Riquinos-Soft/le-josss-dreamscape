# Lourizan pixel architectural ornaments

Original SVG pixel drawings authored on integer grids, 12–96 pixels across.
These are canonical source/runtime files; Godot rasterizes at their declared size,
then the facade samples nearest. No external photograph is embedded or traced.

Reference: supplied 2026-10-06 video, especially 00:40 (paired vaulted entrance,
concentric stone mouldings, central pier, hanging ivy), 00:53 (stairs, sculpted
balusters and figures), 00:13 (gallery glazing, mansard dormers), and 00:26 (clock).
See `references/lourizan-video-2026-10-06.md` in the repository. The official
Turismo de Galicia Pazo listing was consulted on 2026-10-13 for context:
https://www.turismo.gal/recurso/-/detalle/19667/pazo-de-lourizan?ctre=36&langId=es_ES&tp=9
The recent supplied video, not an assumed date of online photos, is the visual
reference. Ornaments are stylized, not measured conservation reproductions.

Arches and glazing sit on facade planes; balusters and statues face the fixed
isometric composition. Alpha scissor writes depth, avoiding blended-layer sorting.
One shared material/batch per ornament keeps repeated rails inexpensive. Structural
stairs, building masses and collision are retained. No fullscreen pixel filter.
