# Joss directional sprite source

Status: draft, generated with the built-in imagegen tool on 2026-09-25 using the
developer's `references/joss-pixel-character-reference.png`. Original output is
retained alongside this file. Runtime derivative is
`game/assets/art/characters/char_joss_idle_directions_v01.png`, with its JSON
contract beside it. Generation returned 1280x1280 rather than the requested 512.

Normalize reproducibly with Godot 4.7.2, from the repository root:

```sh
godot --headless --path game --script ../tools/normalize_character.gd -- /absolute/repo/assets/source/ai/char_joss_idle_directions_v01.png /absolute/repo/game/assets/art/characters/char_joss_idle_directions_v01.png
```

The normalizer removes sub-50% alpha fringe, measures each silhouette, resizes
with nearest sampling to exactly 48 px body height, and aligns all four frames
at feet pivot (32,60) in 64x64 cells. Original alpha/source is retained in this
directory; the runtime uses crisp cutout alpha. Palette and silhouettes still
need the developer's art review before becoming approved assets.

## Exact generation prompt

Use case: identity-preserve / game sprite asset. Reference image: supplied Joss character sheet, use its small directional sprites and exact character design as the visual reference, not its decorative presentation. Generate ONE production-ready transparent PNG sprite sheet for a pixel RPG, square 512x512 image, exactly four equal 256x256 cells in a 2x2 grid. TOP LEFT: front facing viewer. TOP RIGHT: back facing away. BOTTOM LEFT: left-facing profile. BOTTOM RIGHT: right-facing profile. Same adult man Joss in all four: short tousled dark brown hair, small dark moustache and light chin stubble, warm skin, TURQUOISE hoodie with pale drawstrings, BROWN leather backpack/straps, dark charcoal jeans, grey-white sneakers. Match the cute but adult pixel RPG proportions in the reference small sprites, detailed readable clustered pixel shading, restrained purple shadows and warm amber highlights. Full body idle neutral standing pose in every cell, identical scale, fixed feet baseline at 90% of each cell height, horizontally centered, transparent generous margin; each figure occupies around 75% of the cell height. Genuine transparent background with alpha, including between all figures; no floor, no cast shadow, NO text, no labels, no borders, no poster graphics, no extra characters or props. Crisp deliberately pixelated 2D hand-drawn game art, no smooth 3D, no antialiased vector style. This is a game asset to be split into four equal rectangles without manual realignment. Save the generated image as the final asset.
