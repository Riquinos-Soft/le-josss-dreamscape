# Spec 014 — Lucas garden patrol and character art

Status: implemented
Updated: 2026-10-07
Language: en

Authorization: the developer requested a visual upgrade that makes Lucas read
like the protagonist and asked for him to walk around the palace gardens. The
same request authorizes implementation, testing, push and deployment after the
travelling bag release.

## Authorized follow-up — 2026-10-07

The developer authorized continuing Lucas and Pazo improvements and requested
a bounded plan for an economical executor. [Plan 014](../plans/014-lucas-atlas-and-pazo-refinement.md)
is ready; implementation is complete in commit `3451cb8`. Lucas now uses the v04
standing sheet with the existing v02 walk; eight idle directions have planted
feet and are distinct from the walking frames. Focused and full suite results are
in [development](../development.md). Earlier validation applies to the previous
release only; developer art review remains pending. Mobile and developer visual acceptance remain pending;
the new request authorizes proceeding without treating that acceptance as passed.

Current follow-up: inspect/integrate the pending Lucas atlas, with real
eight-direction standing poses (legs extended and feet planted) and readable
alternating walking steps. Preserve patrol, dialogue freeze/resume and collision.
Acceptance: Plan L1 native eight-direction start/walk/turn/stop captures, dialogue
and placement regressions, full gate and Web export. Next: execute L1.

## Asset scale correction — 2026-10-07

The production review found the previous walk resource using 64px regions from a
313px-cell sheet, which rendered clipped artwork. Runtime now pairs the olive
Lucas idle atlas with a normalized 4x8 walk atlas: 64px cells, two poses per
direction, 48px character height and feet baseline y=60. Automated checks cover
all directions, source identity, pose distinction, silhouette height and pivot.
Native walk and dialogue captures, the full test gate and Web export are recorded
in [development](../development.md). This verifies the native view; production
browser and physical-device acceptance remain unclaimed.

Spec 015 governs current filtering and continuous presentation, superseding the
historical nearest-filter/world-pixel-pass sentence in R2.


## Objective

Make Lucas Maconheiro feel like a living inhabitant of Lourizán: a readable
eight-direction pixel character at Joss's apparent scale who takes a short,
safe walk through the palace forecourt and remains fully usable as the existing
history guide.

## Requirements

- R1 — Replace the oversized high-detail four-view sheet with original Lucas art
  using the same low-resolution silhouette, pixel density, foot pivot and apparent
  human scale as Joss. Preserve his tied-back dark hair, beard, olive field jacket,
  ochre shirt, brown trousers, boots and canvas satchel.
- R2 — Lucas exposes eight directional idle/walk states. His facing follows his
  actual horizontal motion and his walk has visible stepping rather than sliding.
  Nearest-neighbour filtering and the existing world pixel pass remain active.
- R3 — Lucas patrols a short ordered loop on the open central garden paving at a
  relaxed speed, pauses briefly at waypoints and never enters the palace stairs,
  exit trigger, parterres or vegetation. The route is authored locally in metres.
- R4 — Approaching Lucas still shows `E · Hablar` using his current moving
  position. Opening dialogue stops him immediately and keeps him stationary for
  the entire conversation. Closing resumes from the same patrol state after a
  short pause; no teleport or route reset occurs.
- R5 — Lucas remains a collidable placement/NPC obstacle. Travel away frees him;
  returning creates exactly one fresh guide and one patrol. Do not add navmeshes,
  schedules, generic NPC AI, persistence, quests or runtime pathfinding.

## Acceptance criteria

- AC1: Native capture shows Lucas and Joss at compatible scale and pixel detail;
  all eight direction names exist and moving Lucas uses a walk state.
- AC2: An automated route observes Lucas leave his start, reach multiple points,
  pause and remain inside the declared safe patrol bounds without blocking travel.
- AC3: Starting a conversation freezes Lucas; every existing dialogue page/input
  check still passes; closing allows patrol to continue without a position jump.
- AC4: Item placement rejects Lucas at his live position and existing bag, travel,
  camera and movement regressions pass.
- AC5: `make check` and Web export pass. Native screenshots are inspected;
  browser and physical-device gameplay are reported separately.

## Implementation boundary

Keep the focused place-owned `lourizan_guide` scene. A tiny deterministic waypoint
loop in its script is enough. The session directly tells the active guide when a
conversation opens or closes. Reuse Joss's eight-sector naming and a local
`SpriteFrames` resource; do not create an NPC manager or navigation layer.

## Validation and open questions

Implemented through [Plan 013](../plans/013-lucas-garden-patrol.md). The focused
native test covers eight animation directions, movement to multiple garden
waypoints, bounds, pauses, conversation freeze/resume, live collision, replay and
travel. The placement, bag and location-travel tests remain green. Native
walking, approach and dialogue captures were inspected under ignored
`build/verification/lucas-patrol/`.

The final `make check` passed 917 checks with zero failures and produced the Web
release. Its log and export evidence are recorded in
`build/verification/lucas-patrol/full-check.log`. Developer art acceptance,
browser conversation gameplay and physical mobile gameplay remain separate.
There is no blocking product or architecture question.

## References

[Spec 013](013-lourizan-guide-dialogue.md),
[Spec 010](010-camera-scale-and-lourizan-art.md),
[Plan 013](../plans/013-lucas-garden-patrol.md), and
[ADR 002](../adr/002-offline-asset-boundary.md).
