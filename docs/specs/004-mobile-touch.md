# Spec 004 — Landscape mobile browser controls

Status: implemented
Updated: 2026-09-26
Language: en

Acceptance: native and browser-emulated checks are recorded in
[plan 004](../plans/004-mobile-touch.md). Physical Android/iOS testing is pending.
[Spec 005](005-beta-controls-and-pixels.md) supersedes the initial button layout
and placement aiming behavior; the remaining guarantees are retained.

## Objective

Make the published prototype playable without a keyboard, gamepad or mouse.

## Scope and requirements

Controls are mounted in both the courtyard and `jacobo_risa_street.tscn`, now the
initial public scene. Street aiming uses its sloped floor and skips vertical
faces of walls that the camera makes transparent. Player-to-target reach,
support and obstruction checks remain mandatory. Hide the street keyboard HUD
in touch mode.

- A left analog joystick moves relative to the camera. A finger keeps ownership
  outside its circle. Release, cancellation, focus loss, resize and respawn clear
  input to prevent stuck movement.
- A second finger can pick up, begin placement, aim, rotate 90 degrees and
  confirm. The initial touch-to-aim and cancel controls are superseded by
  [Spec 005](005-beta-controls-and-pixels.md). Preserve object identity and
  placement validation. Mouse emulation must not leak UI touches into world
  aiming or confirmation.
- Show controls only on touch screens; `--touch` enables local test mode.
  Desktop keyboard/mouse behavior remains unchanged.
- In portrait orientation, cover the game with a rotate-device message and
  pause simulation. Returning to landscape resumes without pending movement.
  Do not depend on browser orientation lock being available.
- Use large targets and margins within the existing expanded viewport.

## Non-goals

No engine, camera, renderer, persistence or service changes. Browser emulation
does not substitute for testing physical Chrome Android and Safari iOS devices.

## Acceptance criteria

- Verify actual movement, multitouch, the item loop, cancellation of input,
  focus changes and portrait/landscape transitions.
- Run existing regressions, native rendering and a Web export.
- Publish the tested export through the OVH receiver when authorized and verify
  the public `/release.txt`.

## Validation

Implementation and emulated-browser results are recorded in
[plan 004](../plans/004-mobile-touch.md). Later refinements are covered by
[Spec 005](005-beta-controls-and-pixels.md). Physical-device acceptance remains open.
