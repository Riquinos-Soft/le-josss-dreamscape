# Spec 009 — Lourizán and map travel

Status: implemented
Updated: 2026-10-13
Language: en

## Current status

Travel implementation is complete; developer/browser acceptance remains open.
The original scan-based Pazo art below is historical: Spec 010 replaced it with
[authored architecture](010-camera-scale-and-lourizan-art.md), Spec 016 added the
[fictional salon](016-lourizan-galleries-and-salon.md), and Spec 017 moved the scan
outside runtime. These successors supersede the original scan-only art scope and
AC2's captured-paving requirement. Current route acceptance is consolidated in
[the roadmap](../roadmap.md); no new travel system is pending implementation.

## Original objective

Add a first walkable Pazo de Lourizán location from the developer's Scaniverse mesh. At a marked edge, the player opens a map, chooses a destination and travels among the production Calle Jacobo Risa scene, the captured home exterior and Lourizán. Keep the existing sprite, orthographic camera, screen pixel pass, movement and touch controls.

## Scope and non-goals

The captured façade and paved approach form the initial Pazo location. The linked video was withdrawn by the developer. This scan does not establish the whole estate, interior or distant paths. Home-to-bar construction remains [Spec 008](008-real-home-microzone.md). No streaming, backend, persistence, pixel redraw of the scan or invented estate expansion is authorized by this slice.

## Requirements

- A fresh session starts in Lourizán. The production street and home scan remain available as map destinations. The same player, camera, sprite, world pixel pass, item scene and touch controls survive travel.
- A marked edge opens the map via M, prompt button or mobile Map action. The map cannot open elsewhere. Selection requires confirmation; Escape/Back cancels in place.
- On desktop, an on-screen direction/distance guide identifies the exit and offers M.
  Developer follow-up, 2026-10-13: hide that guide and keyboard M prompt on mobile;
  the existing touch Map action remains available at the exit.
- During the map and loading, movement stops. Travel returns the same player instance to a grounded arrival outside the exit, resets velocity and camera position, and updates fall recovery.
- A missing or invalid destination leaves the origin playable and shows an error.
- Captured geometry and simplified collision stay in offline-prepared assets; Godot runs from a clean checkout without reconstruction tools. One unit is one metre provisionally until a real dimension is supplied.

## Acceptance

- AC1: A fresh session opens in Lourizán with the guide active; the street remains reachable from its marked exit and retains its authored item. Verify native startup and location/item tests.
- AC2: Lourizán loads and the paved captured section is walkable with collision. Verify native capture and route test.
- AC3: Map cancel, three street ↔ Lourizán round trips, one home round trip and missing-target recovery pass. Verify `test_location_travel.gd` plus visual playthrough.
- AC4: Existing tests, docs checks and Web release export pass from a clean checkout. Browser gameplay remains a separate acceptance step.

## Phases and handoff

The executable sequence, file boundaries, checks and next visual milestones are in [Plan 010](../plans/010-lourizan-map-travel.md). Read the current spec status and the relevant phase before working. Keep each phase small and commit one working unit. Sol Medium or a cheaper implementation model can handle remaining local tasks; escalate only a consequential unresolved architectural decision.

## References and open questions

[Scaniverse source and preparation](../../assets/source/lourizan/README.md); [production street spec](002-street-trial.md); [development evidence](../development.md). Open: a measured dimension for scan calibration, more captures of the wider estate, and developer visual acceptance of the Pazo's pixel treatment. None block the current captured-paving traversal.

## Inactive exit marker correction — 2026-10-13

The street exit marker and label must be hidden when another location is active.
Retain the accessible exit marker at the active place; disable monitoring and
visuals together. The ghost marker over the Pazo backdrop was the inactive street
exit, not an additional destination.
