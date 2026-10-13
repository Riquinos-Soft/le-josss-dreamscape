# Canonical character presentation

Only currently used assets live here. Use stable names; Git stores old versions.
No numbered drafts or unused atlas alternatives belong in the runtime tree.

- `joss.tres`: Joss presentation, `joss_walk.png` and `joss_idle.png`.
- `lucas.tres`: Lucas presentation, `lucas_walk.png` and `lucas_idle.png`.
- `ines.tres`, `brais.tres`, `narci.tres`: stationary resident presentation,
  using the three cells in `residents.png` in that order Inés, Brais, Narci.

Each cell is 64x64; characters use the existing maximum 48px body scale, feet baseline
at y=60 and 0.0375m per pixel. The directional atlases have four columns and eight
rows, ordered down, up, left, right, down_left, down_right, up_left, up_right.
Idle always reads column zero of its matching row. Joss walks with four frames;
Lucas walks with four frames. Every direction has its own standing pose.

Joss walking is the visual authority. The idle pipeline retains the first walk
frame's exact head/torso pixels above y=43; only the lower body uses generated
straight-leg art. This avoids separate heads or proportions at rest. Static
residents use the same compact, large-head vocabulary and planted stance.

## Sources and reproducibility

The only retained source masters and prompts are in
[assets/source/characters](../../../../assets/source/characters/README.md).
Run Godot with absolute input/output paths:

1. `tools/normalize_walk.gd` normalizes the Joss walking master.
2. `tools/normalize_walk.gd` also normalizes the Lucas walking master; disconnected
   neighboring-row spill is excluded before scaling.
3. `tools/normalize_generated_idle.gd` normalizes each standing master into an
   ignored build intermediate; `tools/prepare_character_idle.gd` combines it with
   the canonical walk atlas to produce the runtime standing atlas.
4. `tools/normalize_resident_atlas.gd` normalizes the resident master.

## Future appearance configuration

These atlases are transitional art, not a dynamic customization system. NPC names,
dialogue and behavior remain independent of SpriteFrames resources. The requested
next spec will define composition from face, hair, clothing and body style and
how it replaces these presentation resources. Do not add unused configuration
fields or a generator until that contract is settled.
