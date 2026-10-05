# Plan 010 — Lourizán map travel

Governing spec: [009](../specs/009-lourizan-and-map-travel.md). Status: in progress, 2026-10-05. The developer authorized implementation with Sol Medium. Integrate on current branch; keep local commits and do not push automatically. Use the current production street and its pixel pass as the visual/runtime baseline.

## Phase 1 — Capture and provenance (done)

Decode the supplied Scaniverse Draco mesh offline, prepare the runtime GLB and record source hashes and known coverage. Inspect UV direction and geometry in Godot. The linked video is excluded per developer instruction. Evidence: `assets/source/lourizan/`, `tools/prepare_lourizan_scan.py`, `game/assets/lourizan/` and `test_lourizan_exterior.gd`.

## Phase 2 — Production integration (done)

Use `world/jacobo_risa_street.tscn` as the initial scene inside `world/dreamscape.tscn`. Keep its player, sprite, orthographic camera, world pixel pass and touch HUD. The marked street exit, captured home and Pazo scenes, map selection, cancel/error recovery and return are implemented. `test_location_travel.gd` passes 72 checks; native captures of street, map and Pazo were inspected. The Pazo is screen-pixelated but still shows photographic scan texture; an authored art treatment is a later visual pass.

## Phase 3 — Route and device acceptance (in progress)

The first street-to-map, captured Pazo paving-to-exit and home-to-exit walks pass under normal player movement in the integrated native test. Verify the exported Web in Chrome/Safari and landscape touch on a physical device when available. Record actual screenshots, performance, UI readability and collision gaps. Do not claim browser/device acceptance from an export alone.

## Phase 4 — Wider Pazo mapping (awaiting references)

For each new photo/video/scan: mark its observed landmarks and connection to the current paved zone, extend collision and art only where supported, then repeat the route test. Add interior or estate paths only after coverage establishes them. Keep reconstruction offline.

## Next executor handoff

Read [Spec 009](../specs/009-lourizan-and-map-travel.md), `game/world/dreamscape.gd`, `game/world/jacobo_risa_street.tscn`, `game/player/touch_controls.gd` and recent `docs/development.md` entries. Run `python tools/check_docs.py`, `make test` and `make export-web` after changes. Current unresolved step: Phase 3 full manual route and real browser/touch acceptance. Keep warnings visible in `build/verification/`.
