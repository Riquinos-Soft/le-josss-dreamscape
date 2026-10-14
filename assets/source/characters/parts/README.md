# Shared human pose parts

Original, code-authored pixel masters for ADR 006 / Plan 016 P2b. The editable
master is [author_parts.gd](author_parts.gd); it draws opaque integer rectangles
and scan-converted polygons, with no generated whole-character atlas, external
image input, smoothing or rescaling. Joss is the proportion reference, not a claim
that this new sample has developer art approval. The sample uses deliberate small
clusters, an earthy palette and a compact large head; visual review remains open.

From the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --script assets/source/characters/parts/author_parts.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import --quit
```

Output: `game/v2/characters/parts/`, one stable derivative per compatible part.
Every atlas is 320×512: five 64×64 cells per row (straight-leg idle, four walking
phases), eight rows (down, up, left, right, down_left, down_right, up_left, up_right).
Maximum extent is 48px. Feet touch y=59 (baseline y=60, exclusive). Head, neck,
pelvis and foot anchors for every cell are recorded in `poses.json` alongside the
parts. The foot anchor is fixed; the torso/head translate by one pixel in alternate
walking phases. Direction-specific head positions, nose, facial omissions, arm and
leg offsets are authored directly; asymmetric freckles are never blindly mirrored.

Parts: skin/body, plain/freckled face, short/tied rear/front hair, shirt, trousers
and boots. The master uses four indexed opaque swatches (`211e25`, `555555`,
`aaaaaa`, `ffffff`); the runtime catalog maps these to permitted outline/shadow/
base/light palettes. Transparent pixels remain transparent. This makes skin,
hair and clothes independently configurable without storing rendered images.

The rear hair moves behind the body in front/side views and over the shirt in
rear views. Facial detail is transparent in all three rear-facing rows. The head
region remains pixel-identical between idle and walking after the anchor offset.
Idle legs stay straight; walking alternates raised feet and translated arms, with
side-view strides using explicit horizontal offsets.

Runtime imports are lossless, without mipmaps. The presenter uses nearest sampling,
0.0375m/pixel and 1.05m sprite centre above the actor origin. This puts the pixel
baseline at the actor's foot plane. Actor physics remains a separate 1.8m capsule.

Inspect all eight direction sheets with:
`Godot --path game --script ../tools/capture_v2_appearance.gd` (absolute engine path
as above). Captures go to ignored `build/verification/v2/P2b/`; each sheet shows
all five poses for both appearances and the matching NPC at the contracted scale.
Final art, browser interaction and physical-device acceptance remain separate gates.
