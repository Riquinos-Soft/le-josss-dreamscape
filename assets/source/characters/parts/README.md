# Canonical human appearance parts

The editable master is [author_parts.gd](author_parts.gd), using the unchanged
canonical Joss walk/idle atlases and [material_masks.png](material_masks.png).
This replaces the rejected simplified procedural body under ADR 006's correction.
No new body, head template or walk cycle is drawn. Default composition preserves
all visible source RGBA and alpha in all 40 poses; RGB in fully transparent pixels
may be padded by texture import and is not visible.

Run from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --script assets/source/characters/parts/author_parts.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import --quit
```

Runtime derivatives live in `game/v2/characters/parts/`, 320×512: five 64px cells
per row (idle, walk0–3), eight rows in the original direction order. The mask's red
byte labels 0=unchanged, 1=skin, 2=hair, 3=upper clothing, 4=lower clothing, 5=shoes.
It is an explicit offline source asset; no runtime hue or rectangle classification
occurs. Material layers copy the source pixels and their alpha losslessly. The
complete base retains facial detail, backpack, outlines and unlabelled pixels.

Short hair uses the original pixels. The tied accessory is a small code-authored
pixel cluster attached to each original head pose; freckles only touch labelled
facial skin and are absent in rear views. Their code remains editable in the
master. These variants retain the original body and per-phase motion. Default
parts are copied rather than repeatedly alpha-blended, preserving the original
partially transparent idle legs.

`palettes.json` in the runtime directory is the single palette specification used
by Godot and the HTML preview. Default palette IDs are a no-op. Other choices map
source luminance `(54R+183G+19B)` to the target RGB using the part's documented
anchor: `floor(light * channel / (256 * anchor))`, clamped at 255. Alpha is retained.
`poses.json` records the canonical head bounds and baseline for each cell; it is
metadata, not a synthetic translation template. Appearance IDs/schema stay v1.

Verification:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/test_v2_appearance.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script ../tools/export_appearance_fixture.gd
node tools/test_appearance_preview.cjs
/Applications/Godot.app/Contents/MacOS/Godot --path game --fixed-fps 60 --script ../tools/capture_character_motion.gd
```

The parity check compares the actual HTML composition functions against Godot RGBA
outputs for default, alternate and blond/navy/olive appearances, all 40 poses.
It proves pixel-function parity with the same decoded inputs; browser PNG decoding
and the full account UI still require browser validation. Native captures compare
unchanged Joss, restored default and alternate at 0.0375m/pixel, camera size13.5.
Technical checks and inspected comparisons do not claim developer art acceptance
or physical iPhone acceptance.
