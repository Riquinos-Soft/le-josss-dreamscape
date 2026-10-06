# Spec 010 — Camera clearance, place scale and Lourizán pixel art

Status: implemented
Updated: 2026-10-06
Language: en

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
- Keep the shared player, map travel, items and Compatibility renderer. The Pazo
  uses wider elevated framing and a 360-line pixel pass; other locations keep
  their established 180-line presentation. No runtime reconstruction or streaming.
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

## Current scope and next step

Implementation complete; final verification/deployment recorded in development.
Next: developer visual review of the deployed reconstruction and a measured span
for scale calibration. Do not expand the estate or invent rooms in this pass.

Related: [Spec 002](002-street-trial.md),
[Spec 009](009-lourizan-and-map-travel.md),
[ADR 002](../adr/002-offline-asset-boundary.md).
