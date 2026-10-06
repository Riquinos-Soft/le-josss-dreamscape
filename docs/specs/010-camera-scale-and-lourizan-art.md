# Spec 010 — Camera clearance, place scale and Lourizán pixel art

Status: implemented
Updated: 2026-10-07
Language: en

## Authorized follow-up — 2026-10-07

The developer authorized continuing Lucas and Pazo improvements and requested
a bounded plan for an economical executor. [Plan 014](../plans/014-lucas-atlas-and-pazo-refinement.md)
is ready; implementation has not started. Earlier validation applies to the
previous release only. Mobile and developer visual acceptance remain pending;
the new request authorizes proceeding without treating that acceptance as passed.

Current follow-up: paired central arches, projecting glazed bays and gallery
divisions, mansards/clock, then curved stair outlines and connected landings from
the supplied video. Preserve current scale/camera, playable routes and batching.
Acceptance: Plan P1/P2 reference-matched gameplay captures, both stair traversals,
placement/travel/camera regressions and Web export. Dimensions remain estimates
unless measured. Plan 014 P1/P2 completed in commit `a4e2320`. The closed-backed double
arch and rounded landings are visually inspected in native captures; both stairs
pass traversal checks. Full validation and evidence are in [development](../development.md).
Browser gameplay, mobile acceptance and developer visual review remain pending.


## Objective and correction

Restore obstruction-aware framing, improve provisional place scale and rebuild
Lourizán as recognizable authored architecture in the established pixel style.
The developer rejected the initial filtered scan in `a252591`. That art pass is
superseded; retain its accepted shared camera and scale work.

## Implementation

- Shared camera queries solid geometry from the player's head toward the desired
  eye, draws in promptly, eases back out and adjusts orthographic size. An elevated
  composition still checks the actual player sight line. Travel resets proximity.
- Complete-place scale factors remain 1.45 for Jacobo Risa, 1.30 for Casa and 1.20
  for Lourizán. Geometry, collision and travel points scale together; the player
  stays 1.8 m and movement speed is unchanged. These are provisional calibrations,
  not surveyed measurements; one runtime unit remains one metre.
- Lourizán now has authored glazed wings, paired mansard pavilions, central clock,
  raised balustraded terrace, paired stairs, statues and a planted forecourt.
  Geometry is batched by material. Simple collision follows visible surfaces;
  both staircases have continuous ramp collision beneath visible steps.
- Keep the shared player, map travel, items and Compatibility renderer. All locations use the same maximum 13.5 orthographic size, head focus and
  180-line pixel presentation. No runtime reconstruction or streaming.
- Retain the original GLB as an offline proportion/layout reference, without a
  scene dependency, and exclude it from Web export. No undocumented interiors.
- Apply [the place-authoring workflow](../place-authoring.md) to future locations.

## References and limits

Inspected the facade photograph at
https://www.guiategalicia.com/el-pazo-de-lourizan-y-sus-jardines-historicos/;
also consulted https://www.viajeroscallejeros.com/que-ver-en-pontevedra/.
Photos inform original geometry; they are not redistributed as game textures.
The reconstruction simplifies ornament, garden layout and dimensions. It is a
recognizable first exterior, not a surveyed full estate or an interior model.

## Acceptance and verification

- AC1: Camera clearance responds to solid walls and resets after travel; preserve
  movement direction, aiming and existing wall fade. Camera regression test.
- AC2: Existing street/home routes, physical item loop, map exits and return trips
  remain functional with the same player. Full regression suite.
- AC3: Native arrival view shows the authored landmarks; walk the forecourt and
  climb/descend the terrace with normal controls. Pazo traversal and screenshots.
  Final art acceptance remains with the developer.
- AC4: Documentation, format/lint, import, automated tests and Web export pass;
  push the authorized change and verify deployment SHA. Evidence and commands in
  [development](../development.md).

## Follow-up — camera stability and garden, 2026-10-06

Implemented: use the same maximum orthographic size (13.5) and head focus in all
locations. Orthographic obstruction response changes zoom without pushing the
near plane into walls; hold clearance briefly at corners to avoid oscillation.
Test close obstacles, release and framing across travel. Enrich garden woodland
and climbing vegetation from photographed references, preserving clear paths.
Reference: https://www.galiciamaxica.eu/galicia/pontevedra/comarca-de-pontevedra/pontevedra-c/pazolourizan/
Native walkthrough captures, camera regression tests and Web export are recorded
in development. The woodland is an interpreted perimeter, not a surveyed tree inventory.

## Current scope and next step

Implementation complete; final verification/deployment recorded in development.
Next: developer visual review of the deployed reconstruction and a measured span
for scale calibration. Do not expand the estate or invent rooms in this pass.

Related: [Spec 002](002-street-trial.md),
[Spec 009](009-lourizan-and-map-travel.md),
[ADR 002](../adr/002-offline-asset-boundary.md).
