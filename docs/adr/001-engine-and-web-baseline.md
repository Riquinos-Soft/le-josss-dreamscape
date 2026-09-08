# ADR 001 — Godot 4, GDScript, Compatibility, single-threaded Web

Status: accepted. Engine/template version pinned and native smoke test verified on 2026-09-07; browser rendering acceptance remains pending.

## Context

The browser is the first shipping target. Development is on Apple Silicon, and future mobile support must remain plausible. The project needs a small 3D workflow with minimal dependencies.

## Decision

Use standard Godot **4.7.2.stable.official.ed1daf0bf**, with **4.7.2.stable** export templates and GDScript for future scripts. Put the project in `game/`. Use Compatibility rendering from day one and begin with single-threaded Web export, without extensions. No scripts are necessary for the static baseline.

The checked-in preset explicitly sets `variant/thread_support=false` and `variant/extensions_support=false`; generated HTML confirms `GODOT_THREADS_ENABLED = false`. Only the required single-threaded Web debug/release templates are installed. PWA support is disabled. Native rendering and Web export/local serving passed; Chrome/Safari rendering could not be verified through the available automation. See [verified results and warnings](../development.md). The product owner subsequently authorized courtyard/player/camera work while manual browser acceptance is pending. Browser acceptance still gates all item/inventory/placement implementation.

## Alternatives and consequences

Forward+/Mobile provide different rendering capabilities but are not the current Web rendering path. C# conflicts with the current Godot 4 Web export capability. Threaded Web builds can improve CPU/audio behavior but complicate hosting. These constraints are documented in [Godot's Web export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

Accept a simpler rendering/CPU baseline in return for a direct browser path. Establish visual identity through art direction before post-processing. There is no demonstrated reason to change engines. Revisit threading only for a measured bottleneck, and reconsider engine suitability only if the minimal export cannot meet agreed platform needs.

## Short engine sanity check — 2026-09-07

Keep Godot 4.7.2. This is a workflow assessment, not a comparative benchmark. The known tradeoffs remain browser validation, engine payload, and eventual object/physics budgets. None of the following alternatives offers a demonstrated overall advantage sufficient to replace the baseline:

- **Unity 6:** credible Web/native mobile/Apple Silicon support and extensive 3D tooling. Its larger editor/build/package workflow is a poor trade for this small GDScript-based project without a specific missing capability. See [platform requirements](https://docs.unity3d.com/6000.0/Documentation/Manual/system-requirements.html).
- **PlayCanvas:** attractive browser-first iteration, visual editor, and GLB workflow. Its documented mobile app route adds a wrapper rather than our desired direct native engine export workflow. A stronger candidate for a predominantly browser-only product. See [mobile publishing](https://developer.playcanvas.com/user-manual/editor/publishing/mobile/) and [model pipeline](https://developer.playcanvas.com/user-manual/assets/models/building/).
- **Babylon.js:** strong web 3D/glTF tooling; native deployment is possible through Babylon Native/React Native. It would require assembling more game authoring and app infrastructure than our current scene-based workflow. See [Babylon Native](https://www.babylonjs.com/native/) and [native mobile integration](https://www.babylonjs.com/reactnative/).
- **Bevy:** Rust/ECS is attractive for data-oriented simulation, with Web and mobile paths and glTF examples. That architecture/compiled-language workflow is a substantial change for fast solo scene iteration, without measured simulation pressure to justify it. See [Bevy introduction](https://bevy.org/learn/quick-start/introduction/), [platform examples](https://github.com/bevyengine/bevy/blob/main/examples/README.md), and [glTF example](https://bevy.org/examples/gltf/load-gltf/).
- **Defold:** a serious lightweight Lua alternative with HTML5, native mobile, Apple Silicon, and glTF support; it is not disqualified as a 2D-only engine. Its footprint is appealing, but no demonstrated advantage in this project's 3D authoring/interaction workflow outweighs switching. See [platform FAQ](https://defold.com/faq/faq/) and [3D models](https://defold.com/manuals/model/).

Stylized geometry and Blender/glTF are compatible with this choice; future reconstructed geometry must be simplified offline regardless of engine. On a 16 GB Air, prioritize the already-working editor and small iteration loop over a speculative simulation rewrite. Numerous cheap objects need deliberate activation/render/physics budgets in any engine; an item need not be an always-simulated rigid body. Persistent identity, housing state, and future multiplayer authority are game architecture responsibilities, not reasons to migrate today. This check makes no native-mobile, MMO-scale, or browser-performance guarantee.
