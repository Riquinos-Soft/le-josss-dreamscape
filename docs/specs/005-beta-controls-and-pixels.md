# Spec 005 — Simplified touch placement and pixel comparison

Status: implemented
Updated: 2026-09-26
Language: en

Acceptance: implementation and emulated-browser checks are complete; physical
Android/iOS testing and developer art acceptance remain pending.
Beta 01 is a comparison reference, not the final asset standard.

## Objective and scope

Simplify touch controls and increase overall pixel size, especially the hedges
along the road, as requested by the developer. Refine available-action presentation
without changing desktop controls or the existing placement guarantees.

## Requirements

- With no held item, show Pick up only for an unobstructed item within reach.
  With an item in inventory, show one Place button.
- Place starts a preview 1.3 m in front of the character. It follows movement
  and facing until the preview is dragged.
- During placement show only Rotate (90 degrees, one direction) and Confirm.
  Hide Confirm for an invalid target, keeping Rotate in its fixed position.
  Do not show duplicate rotation, Place or Cancel buttons in this state.
- Tapping the ground does not move the object. Dragging from the preview moves it;
  releasing retains that world position even if the camera moves.
- Preserve reach, collision, sloped-floor support and identity. Unsupported
  placement is red and cannot be confirmed. The preview remains visible outside
  the path, so it can be dragged back without requiring a Cancel button.
- Preserve simultaneous joystick input, focus-loss handling and portrait blocking.
- Sample the world at approximately 180 rows, enlarged with nearest sampling in
  whole blocks of at least two pixels. Keep the HUD sharp. The captured scan
  palette uses eight levels per channel, with vegetation greens grouped into four
  tones; asphalt grain is coarser. Later street art hides the raw scan, so these
  scan-shader settings are historical rather than the visible foliage palette.
- Comparison: `references/beta-01/before-mobile.png` comes from the previous
  deployment; `after-mobile.png` uses the same camera and dimensions after the
  adjustment. Record the published commit and settings for reproducibility.

The original implementation interpretation, recorded after asking and receiving
no answer, retained Place and removed Cancel. Desktop controls were unchanged.

## Available-action refinement

Do not show pickup instructions when pickup is unavailable. Hidden action regions
must not accept touches. Buttons use vector icons, lavender borders, a green
confirmation accent, shadows and pressed feedback while retaining touch target
sizes and sharp labels. Preserve the original Beta 01 tag as the reference before
this refinement.

## Non-goals

No final cross-project art standard, new gameplay system, infrastructure change
or replacement of desktop input.

## Acceptance criteria

Test touch input in both courtyard and street, the complete item lifecycle,
invalid positions, recovery of available actions and stable button placement.
Inspect native/Web captures, export and verify the public URL when publication
is authorized. Physical-device testing is a separate acceptance step.

## Validation

See [plan 005](../plans/005-beta-controls-and-pixels.md) for Beta 01 and
[plan 006](../plans/006-contextual-actions.md) for the later available-action
refinement. Do not equate an export or browser emulation with physical Android
or iOS acceptance.
