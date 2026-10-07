# residents source

Built-in image_gen edit, 2026-10-07. Transparent source: `residents.png`.
Reference identities came from commit 45af87e. Current canonical walking references
are `joss_walk.png` and `lucas_walk.png`; superseded portraits remain in Git history.

Prompt:

Redraw first reference three stationary NPCs with EXACTLY the compact big-headed 16-bit RPG proportions and chunky pixel detail of Joss in the second reference. First image identities left to right: Inés auburn bun teal coat botanical notebook; Brais grey hair moustache burgundy jacket cream waistcoat; Alba dark bob ochre jacket plum scarf shoulder bag. Each body 48 effective pixels high, head about 17 pixels high and 22 wide, compact torso, short straight parallel legs boots together. Do NOT keep the current long slender realistic body proportions. Preserve distinct identity, faces, colors and outfit. Transparent THREE columns ONE row. Full bodies at equal height and same baseline, front three-quarter facing. No labels, ground or cast shadows. Crisp dark outline, restrained clustered shading exactly matching the Joss walking art vocabulary.

Runtime preparation: normalize into 64px cells, 48px body/feet y=60.
For Joss and Lucas, `tools/prepare_character_idle.gd` retains the canonical
walking head/torso above row 43 and fits the generated standing lower body.
This guarantees identical identity pixels at the idle/walk boundary.
