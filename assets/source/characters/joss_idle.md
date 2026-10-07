# joss_idle source

Built-in image_gen edit, 2026-10-07. Transparent source: `joss_idle.png`.
Reference identities came from commit 45af87e. Current canonical walking references
are `joss_walk.png` and `lucas_walk.png`; superseded portraits remain in Git history.

Prompt:

Edit this original game sprite sheet to create standing poses. Preserve exactly Joss's large head, face, hair silhouette, blue clothes, backpack, brown shoes, black outline and chunky low resolution pixel style from the reference walk sheet. Output a transparent 4 columns by 8 rows sprite atlas with the SAME directional row order: front, back, left profile, right profile, front-left, front-right, back-left, back-right. Each row repeats the SAME STANDING pose in four columns. Change only walking stance to straight legs together side by side, both boots on a common baseline; no bent knees, no stride. Arms relaxed. Head occupies same fraction of height as the reference, no smaller head or taller realistic body. EXACT facing per row including four distinct diagonals. No labels, no shadows, no ground. This is standing art for the very same walking character, not a redesign.

Runtime preparation: normalize into 64px cells, 48px body/feet y=60.
For Joss and Lucas, `tools/prepare_character_idle.gd` retains the canonical
walking head/torso above row 43 and fits the generated standing lower body.
This guarantees identical identity pixels at the idle/walk boundary.
