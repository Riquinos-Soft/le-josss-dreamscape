# Spec 010 — Camera clearance, place scale and Lourizán pixel art

Status: implemented
Updated: 2026-10-06
Language: en

## Objective

Make the existing connected game easier to read and closer to the established
Jacobo Risa art direction. Restore the camera's close-in response to nearby
occluding world geometry. Give the captured Lourizán exterior an authored pixel
palette and recognizable scene detail. Increase provisional place scale so Joss
looks proportionate beside the street and home, without changing his 1.8 m body.

## Scope and non-goals

- Keep one shared player, orthographic camera, pixel pass and map travel. In the
  street, home and Lourizán, query solid world geometry between the player and
  desired camera position; draw the camera in promptly and ease it back out. In
  orthographic mode adjust camera size too, so the response is visible. Preserve
  movement direction and mouse aiming.
- Recalibrate unmeasured captures as complete locations, scaling their visible
  geometry, collision, arrivals, exits and authored landmarks together. Keep
  `1 Godot unit = 1 metre` after calibration; Joss remains 1.8 m. Do not stretch
  just the sprite or shrink the physics capsule. Treat these factors as visual
  estimates until the developer provides a measured span.
- Lourizán's source scan remains an offline reference and geometric silhouette.
  Replace its photo color at runtime with nearest-sampled, reduced-palette
  stone, paving and vegetation shading, and add a small set of authored pixel
  accents from reusable project art. Do not claim an unscanned estate or rooms.
- Keep Web Compatibility rendering, existing physical item behavior and map
  transitions. No new streaming, reconstruction runtime or asset system.

## Requirements

- The camera response must depend on solid collision, return without popping,
  and reset after a location change or respawn. The wall fade remains intact.
- The location scale factors apply to the entire authored place, including
  collision and travel points; the shared player and movement speed stay fixed.
- The Pazo art stays limited to captured geometry and a nonwalkable backdrop.
  The floor decoration must not create a traversable route beyond collision.

## Acceptance criteria

- AC1: A wall or solid bank between Joss and the camera moves the camera closer;
  removing the obstruction smoothly restores the previous framing. Joss stays
  visible, and orthographic framing visibly changes. Respawn and travel reset
  stale camera proximity. Verify the camera clearance test and a native capture.
- AC2: Street and home are visibly roomier relative to the same Joss sprite. Street
  route, garage apron, item pickup/placement, home path, map exits and return
  trips remain physically walkable and grounded. Lourizán's paving still works.
  Verify the street, home, Lourizán, item and travel route tests.
- AC3: Native captures of the Lourizán facade and paving show a coherent coarse
  pixel palette and authored accents instead of the raw photograph. The facade
  silhouette and paths remain recognizable. The production street look remains.
  Verify paired native screenshots and developer art review.
- AC4: Relevant movement, street, home, Lourizán, item and travel tests pass; native
  rendering is inspected; Web export succeeds. Push and verify the public release
  SHA after the complete working change.

## Small steps

1. Restore and verify camera obstruction behavior in the shared rig.
2. Recalibrate one location at a time and update its route checks.
3. Apply the Lourizán palette and add a few reusable details; inspect captures.
4. Run full local checks and Web export, commit working units, push and verify
   the production workflow and live release.

The source captures have no measured dimensions yet. Geometry scale is a
provisional art calibration, not a surveyed real-world measurement.

Implementation uses provisional factors of 1.45 for Jacobo Risa, 1.30 for Casa
and 1.20 for Lourizán. The full location geometry and physical route points move
together; the player remains 1.8 m. Lourizán has a drawn stone court over its
captured support and a noncolliding ground backdrop. Its building shape remains
the scan, now painted with coarse stone and plant colors. Further hand-authored
facade detail and measured calibration await visual review and new references.

## Validation and references

Run `make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`, native
`test_location_travel.gd -- --capture` and `test_camera_clearance.gd`, inspect
the ignored captures in `build/verification/lourizan/`, then verify the Actions
run and production `/release.txt`. Record results in [development](../development.md).
This work follows [Spec 002](002-street-trial.md), [Spec 009](009-lourizan-and-map-travel.md),
[ADR 002](../adr/002-offline-asset-boundary.md) and the captured source notes in
`assets/source/home_scan/` and `assets/source/lourizan/`.

Local result on 2026-10-06: 731 automated checks and zero failures, formatter,
linter, docs checks, project import and Web release export passed. Native
Compatibility rendering passed 103 integrated travel checks and 23 standalone
Lourizán checks. Inspected `street-production.png`, `home-pixel-pass.png`,
`lourizan-pixel-pass.png` and `home-scan/lourizan-start.png`. The known
`pkg_resources` deprecation warning from pinned gdtoolkit remains. Browser and
developer art acceptance are separate from these checks.

## Open questions

The developer can provide one measured street or building span to replace the
provisional scale factors. This does not block this visual iteration. Final Pazo
palette acceptance requires developer review of the deployed image.
