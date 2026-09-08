# ADR 002 — Reconstruction and authoring stay outside the game

Status: accepted foundation direction; no reconstruction integration authorized for Spec 001.

## Context

Future environments may originate in video, photographs, reconstruction tools, Blender, or hand-built geometry. Source captures and reconstruction dependencies can be large and should not determine gameplay architecture.

## Decision

Keep captures, reconstruction output, and Blender authoring outside `game/`. Only reviewed runtime assets enter `game/assets/`, using glTF 2.0/GLB for 3D exchange. Keep behavior and collision decisions in Godot wrapper scenes rather than reconstruction metadata or imported mesh names.

Future conceptual process: capture → offline reconstruction experiment → Blender cleanup/retopology/simplification/stylization → validated GLB → Godot scene. Reconstruction output is not assumed to be a usable game mesh. Experiments own their environments under `tools/` only when introduced; the game must import/run without them.

## Alternatives and consequences

Direct `.blend` import speeds artist iteration but makes Godot import depend on a Blender installation. Godot recommends glTF and supports both approaches; see [available 3D formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html). Explicit GLB export adds a manual step and potential source/export drift; track source and export settings together when real assets arrive.

Keep raw data out of Git by default and choose external storage or Git LFS only when actual asset sizes justify it. Ignored data is not backed up by Git. Runtime meshes must meet the game's budgets regardless of source. A future reconstruction tool can be replaced without changing player, inventory, or crafting code.
