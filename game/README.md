# Godot project location

Open `project.godot` with standard Godot **4.7.2.stable.official.ed1daf0bf** and run `world/courtyard.tscn` (F5). Walk with WASD/arrows. Approach the purple block and press E to pick it up; P or the Place button starts placement. Aim with the mouse, rotate with Q/E, confirm with left click, cancel with Escape. Green/red preview indicates valid/invalid placement. Movement pauses during placement. One instance retains its identity through inventory and replacement; restart resets it. No crafting or persistence.

Scale: one unit is one meter; character height 1.8 m, speed 4 m/s, courtyard interior 20×16 m. `world/smoke_test.tscn` remains the unchanged original static scene; its old export is preserved locally in `build/web-smoke-baseline/`.

`export_presets.cfg` contains the `Web` release preset for the courtyard and dependencies, using Compatibility rendering with thread and extension support disabled. See [reproducible commands, tests, and pending browser checks](../docs/development.md).

Keep all shipped resources inside this directory. Keep original captures, Blender source, tooling, and exports outside it. See [the proposed layout](../docs/architecture.md).
