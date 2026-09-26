# Plan 007 — Street video decor correction

Scope: spec 002; retain existing camera, movement, collision and pixel scale.
Integrator: current session. No parallel file owners or new architecture.

- V01: inspect the supplied video, record visible roadside features and map them
  against the existing scan cross sections. Mark uncertain placement explicitly.
- A01: generate two tree silhouettes, fern and bramble in one transparent atlas;
  save source and prompt, normalize into bounded palette-limited cells. Keep
  existing hedges available. Inspect silhouettes and in-game scale.
- G01: dress only the outer banks with varied plants and the observed tree area;
  construct the lateral fence with coarse bars, preserving all road/garage access.
  Reuse continuous occlusion and shared materials. No new collision system.
- G02: add sparse asphalt patches, fine cracks and aggregate at fixed world
  coordinates. Keep dark base, contrast modest, concrete apron distinct.
- V02: run street traversal and placement tests, inspect native spawn/fence/
  garage views, export Web, lint and create one coherent local commit.

Art remains a draft for developer review. Video availability and actual
verification results must be recorded before claiming fidelity or completion.

## Result — 2026-09-25

V01/A01/G01/G02/V02 implemented. The shared viewer was still processing; the
original download worked. Inspected contact sheets spanning the entire 120s
clip plus individual frames at 55, 70, 80, 90 and 100s. Saved the contact sheets
under `references/street-video-00-60.jpg` and `street-video-60-120.jpg`.

Observed: wild fern banks, ivy/brambles, wire mesh and tree canopy before the
garage, dry leaves along the road edge, worn asphalt. Fence occupies the east
bank sections 5–9; three trees follow it and one stands opposite the garage.
These placements interpret the footage against the scan; they are not a new
metric survey. Other surroundings visible beyond the scan remain out of scope.

Four additional sprites use a shared 128x128 atlas. Tree roots/plant bases are
anchored in billboard coordinates, avoiding camera-tilt displacement. Fence uses
physical mesh holes plus continuous occlusion, never stippled fade. Asphalt has
irregular wear, restrained aggregate, sparse cracks and leaf/moss edge accents.

Validation: 166 street traversal and 33 placement checks pass. Native Compatibility
captures inspected at spawn, fence and garage; Web release export succeeds.
The machine's WASAPI device failed on the initial native launch; subsequent
visual captures used the explicit Dummy audio driver. No audio validation or
manual Safari acceptance is claimed. Art acceptance remains with the developer.
