# Godot project location

Open `project.godot` with standard Godot **4.7.2.stable.official.ed1daf0bf** and press F5 for `world/home_exterior.tscn`: the actual developer-supplied Scaniverse exterior, with its captured geometry and photographic texture. Walk with WASD/arrows or hold the right mouse button to steer toward the cursor; keyboard input takes precedence. The player starts on the captured paved path. Small steps and unsupported edges are handled locally; incomplete scan regions are not reconstructed or made into invented interiors.

The original `world/courtyard.tscn` remains a separate regression/playtest scene (open it and press F6). There, approach the purple block and press E to pick it up; P or Place starts placement, Q/E rotates, left click confirms, Escape cancels. The item/inventory implementation is unchanged. The captured-exterior scene currently focuses on walking and does not instantiate the courtyard's flat-floor item coordinator.

Scale: one unit is one meter; character height 1.8 m, speed 4 m/s, courtyard interior 20×16 m. `world/smoke_test.tscn` remains the unchanged original static scene; its old export is preserved locally in `build/web-smoke-baseline/`.

`export_presets.cfg` contains the `Web` release preset for the project, using Compatibility rendering with thread and extension support disabled. All runtime assets are included, so a clean checkout needs Godot and its templates, not Blender or the original external scan. See [reproducible commands, tests, and manual browser reports](../docs/development.md).

Keep all shipped resources inside this directory. Keep original captures, Blender source, tooling, and exports outside it. See [the proposed layout](../docs/architecture.md).
