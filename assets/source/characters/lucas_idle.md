# lucas_idle source

Built-in image_gen edit, 2026-10-07. Transparent source: `lucas_idle.png`.
Reference identities came from commit 45af87e. Current canonical walking references
are `joss_walk.png` and `lucas_walk.png`; superseded portraits remain in Git history.

Prompt:

Edit first reference (Lucas walking atlas) into Lucas standing atlas. Second reference Joss is ONLY the common pixel style/body proportions reference. Preserve Lucas's own dark hair tied back, beard, olive jacket, ochre shirt, brown trousers, boots and satchel. Same large-head compact RPG proportions as Joss walking, NEVER blue clothes or Joss face. Transparent 4 columns by 8 rows; rows EXACTLY front, back, left profile, right profile, front-left, front-right, back-left, back-right. Four IDENTICAL standing cells per row. Both legs fully straight and parallel together, planted boots on same baseline, relaxed arms. Preserve facing, head outline and clothes from Lucas's matching walking direction. No labels, shadow or ground.

Runtime preparation: normalize into 64px cells, 48px body/feet y=60.
For Joss and Lucas, `tools/prepare_character_idle.gd` retains the canonical
walking head/torso above row 43 and fits the generated standing lower body.
This guarantees identical identity pixels at the idle/walk boundary.
