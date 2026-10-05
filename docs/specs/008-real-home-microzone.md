# Spec 008 — Connected real home microzone

Status: in-progress
Updated: 2026-10-05
Language: en

## Objective

Build a recognizable, walkable connection from the developer's real three-storey home through the nearby street and parking to a bar interior, using consistent metre-scale geometry. The supplied home Scaniverse capture is the approved exterior anchor. The older invented blockout was rejected and is not shipped.

## Scope and limits

The approved home exterior is playable as `world/home_exterior.tscn` and available as `world/locations/home.tscn`. A reusable stair flight and three-level fixture have been verified. The real entrance, floor layout, bar position and appearance are not established by the capture. Do not present invented geometry as the real location. This route is pending more user references.

The current production entry point is the pixel-art Jacobo Risa street, governed by [Spec 002](002-street-trial.md). This captured home exterior remains a separate playable scene until its placement within a connected map is grounded in references. The [Lourizán travel slice](009-lourizan-and-map-travel.md) is a distinct current milestone.

## Acceptance

- AC1: Home exterior retains the supplied silhouette, proportions and visible landmarks. Verify by native inspection against the capture.
- AC2: The player can traverse all three home floors and stairs without clipping. Verify with a normal-input route test and visual inspection once layout references arrive.
- AC3: A physical, continuous route leads through street and parking to an accessible bar interior and back. Verify complete round trip in a clean checkout.
- AC4: Existing player, item and Web regressions remain green. Verify `make check`.

## Validation and next input

Historical capture and stair checks are recorded in [development evidence](../development.md). AC2–AC3 remain open. Needed references: marked house entrance and stairwell, rough floor plans, direction and distance to bar, street/parking photos or video and one known measurement. Source and preparation are recorded in [home scan assets](../../assets/source/home_scan/README.md). No backend, runtime reconstruction or final pixel treatment is in scope.
