# Chicken mount source

Generated 2026-10-14 with the built-in imagegen tool, transparent output.
Canonical master: `chicken.png` (1254×1254). No commercial sprite was imported.
Runtime: `game/assets/art/characters/chicken.png`, prepared from repository root:

```sh
godot --headless --script tools/normalize_chicken.gd
```

The offline derivative crops the generated row bands, ignores disconnected
neighbor spill, uses one scale per row, thresholds alpha and nearest-resamples
into grounded 64px cells. Original master remains outside the runtime import tree.

## Generation prompt

Use case: stylized-concept. Asset type: transparent pixel-art game mount animation
sprite sheet. Create a giant ridable CHICKEN, charming cream-white domestic hen
with bright red comb and wattles, short golden beak, stout orange bird legs,
rounded body, dark brown leather saddle on back, no rider. Fantasy bird mount but
distinctly domestic chicken. Style: deliberate 16-bit RPG pixel art, dark brown
outline, crisp square pixels, restrained warm earthy palette, readable clusters,
no smooth shading. Exact layout: 3 columns by 4 rows on a square transparent
canvas, twelve complete sprites total, evenly spaced equal cells, same chicken
size, aligned feet. Row1 faces DOWN toward viewer, row2 faces LEFT profile, row3
faces UP away from viewer, row4 faces DOWN-LEFT three-quarter. Every row column1
is standing idle feet together, column2 walking left foot forward, column3 walking
right foot forward. Identical face, proportions, saddle, body position across
columns, only legs and slight wing motion change. Full bird uncropped within each
cell with clear transparent gutters. Each bird designed at roughly 64x64 logical
pixels. Strictly transparent background, no shadows on ground, no labels, no grid
lines, no text, no scenery.
