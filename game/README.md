# Godot project location

Open `project.godot` with standard Godot **4.7.2.stable.official.ed1daf0bf** and run the default `world/dreamscape.tscn` (F5). At the marked southern street edge, press M or Map, choose Casa or Lourizán and confirm; each marked exit returns to the map. The courtyard remains separately runnable. Walk with WASD/arrows or hold the right mouse button to steer toward the cursor; keyboard input takes precedence when both are active. Approach the purple block and press E to pick it up; P or the Place button starts placement. Movement remains available while placing. Aim with the mouse, rotate with Q/E, confirm with left click, cancel with Escape. Green/red preview indicates valid/invalid placement. One instance retains its identity through inventory and replacement; restart resets it. No crafting or persistence.

Scale: one unit is one meter; character height 1.8 m, speed 4 m/s, courtyard interior 20×16 m. `world/smoke_test.tscn` remains the unchanged original static scene; its old export is preserved locally in `build/web-smoke-baseline/`.

Mobile browser: turn the phone horizontally. Use the left joystick to walk and
the right button to pick up, then start placement. The preview appears in front
of you until you drag it elsewhere; release to leave it at that world position.
During placement only Rotate and Confirm appear. Another finger can keep walking. Portrait
pauses the game behind a rotate-device message. Losing focus or rotating clears
touch input. Native testing can force the mobile UI with `-- --touch`.

`export_presets.cfg` contains the `Web` release preset for the courtyard and dependencies, using Compatibility rendering with thread and extension support disabled. See [reproducible commands, tests, and pending browser checks](../docs/development.md).

Keep all shipped resources inside this directory. Keep original captures, Blender source, tooling, and exports outside it. See [the proposed layout](../docs/architecture.md).

The separate geometry trial for Calle Jacobo Risa M opens with `godot --path game res://world/jacobo_risa_street.tscn` from the repository root, or by running that scene in the editor. The default scene wraps that same production street and adds map travel to Lourizán. The standalone trial uses the scan's simplified mesh and collision, a neutral study material, and the existing player/camera; see [asset provenance](assets/streets/jacobo_risa/README.md).
