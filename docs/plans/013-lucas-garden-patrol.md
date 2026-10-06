# Plan 013 — Lucas garden patrol

Governing spec: [014](../specs/014-lucas-garden-patrol.md).
Status: active, 2026-10-06. Authorized by the developer.
Base: `4cf46dd`. Execute sequentially on the current branch.

## L1 — Match the protagonist's visual language

Status: done.

Create an original low-resolution Lucas sheet with eight directions and a compact
walk cycle. Replace the static `Sprite3D` with `AnimatedSprite3D`, preserving the
feet pivot, collider and prompt/head anchors. Add asset prompt/provenance metadata.

Verify import, exact animation names, nearest filtering, scale and a native
arrival capture. Commit one working visual unit.

## L2 — Add a safe local patrol

Status: done; L1 complete.

Add a deterministic waypoint loop and pauses on the open central paving. Face the
actual movement direction. Stop on dialogue open, resume after close, and keep
range, line of sight, collision, item placement and travel teardown correct.

Extend the focused Lourizán dialogue test with movement bounds, pause/resume and
animation assertions. Do not introduce navigation, schedules or shared NPC APIs.
Commit one working behavior unit.

## L3 — Validate and deploy

Status: ready; L2 complete.

Run focused dialogue, bag placement and travel tests; capture Lucas walking and
talking natively. Run `make check` with Godot 4.7.2 and inspect warnings, then
record exact results in the spec, plan and `docs/development.md`. Push `main`,
watch CI and verify the public `release.txt` matches the deployed commit.

## Handoff

L1 result commit: `9dc22e1`. The visual sheet was inspected in a native arrival
capture. L2 focused checks: 46 Lourizán dialogue checks, 20 placement-support
checks, 36 bag-travel checks and 111 location-travel checks, all with zero
failures. Native walking, approach and dialogue captures were inspected.

Next action: L3. Expected evidence directory:
`build/verification/lucas-patrol/`. Remaining manual acceptance after delivery:
developer visual review, full browser conversation and physical mobile gameplay.
