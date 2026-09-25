# Joss diagonal source and eight-direction runtime sheet

Generated with built-in imagegen on 2026-09-25, using the original four-direction
Joss source as reference. Status: draft. The user explicitly requested all eight
orientations. New 45-degree drawings complement the original four cardinal views.

Normalize and combine without changing the original cardinal pixels:

```sh
godot --headless --path game --script ../tools/normalize_character.gd -- /absolute/repo/assets/source/ai/char_joss_idle_diagonals_v01.png /absolute/repo/game/assets/art/characters/char_joss_idle_directions_v02.png /absolute/repo/game/assets/art/characters/char_joss_idle_directions_v01.png
```

Runtime: 256x128 PNG, four columns and two rows of 64x64. Row one is down, up,
left, right; row two is down_left, down_right, up_left, up_right. Each body is
48px high with feet pivot (32,60). Eight-direction metadata accompanies the PNG.
Nearest normalization and alpha cleanup are deterministic; generated originals
remain intact. These are idle orientations, not walking animation frames.

## Exact generation prompt

Asset type: supplementary four diagonal idle sprites for the SAME Joss pixel RPG character in the reference. Preserve exact design, adult chibi proportions, palette, short tousled dark brown hair, small dark moustache/chin stubble, warm skin, turquoise hoodie with pale drawstrings, brown leather backpack, charcoal jeans and grey-white sneakers. Generate a transparent square PNG with exactly FOUR full-body standing idle sprites in a regular 2x2 grid of equal cells. TOP LEFT: front three-quarter view facing DOWN-LEFT (southwest), both front of hoodie and LEFT profile visible. TOP RIGHT: front three-quarter view facing DOWN-RIGHT (southeast), both front of hoodie and RIGHT profile visible. BOTTOM LEFT: rear three-quarter view facing UP-LEFT (northwest), BACKPACK dominates but left side and a sliver of left cheek visible. BOTTOM RIGHT: rear three-quarter view facing UP-RIGHT (northeast), BACKPACK dominates but right side and a sliver of right cheek visible. Each must be a real 45-degree diagonal view, NOT a straight front, straight back or side view. Match reference scale exactly: body approximately 75% of cell height, fixed feet baseline 90%, centered horizontally. Crisp deliberate 2D pixel clusters, limited palette, purple shadows/warm highlights, no smooth 3D. Genuinely transparent background including between sprites, no floor or cast shadow, no text, labels, border, arrows or sheet decoration. Equal nonoverlapping cells with generous transparent margins, consistent body height, feet intact. This sheet supplements the original four cardinal sprites; do not recreate those cardinal views.
