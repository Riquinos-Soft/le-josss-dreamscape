# Spec 009 — Lourizán and map travel

Status: in-progress
Updated: 2026-10-05
Language: en

## Objective

Add a first walkable Pazo de Lourizán location from the developer's Scaniverse mesh. At a marked edge, the player opens a map, chooses a destination and travels among the production Calle Jacobo Risa scene, the captured home exterior and Lourizán. Keep the existing sprite, orthographic camera, screen pixel pass, movement and touch controls.

## Scope and non-goals

The captured façade and paved approach form the initial Pazo location. The linked video was withdrawn by the developer. This scan does not establish the whole estate, interior or distant paths. Home-to-bar construction remains [Spec 008](008-real-home-microzone.md). No streaming, backend, persistence, pixel redraw of the scan or invented estate expansion is authorized by this slice.

## Requirements

- The production street remains the initial location; the home scan and Lourizán are map destinations. Its existing player, camera, sprite, world pixel pass, item scene and touch controls survive travel.
- A marked edge opens the map via M, prompt button or mobile Map action. The map cannot open elsewhere. Selection requires confirmation; Escape/Back cancels in place.
- During the map and loading, movement stops. Travel returns the same player instance to a grounded arrival outside the exit, resets velocity and camera position, and updates fall recovery.
- A missing or invalid destination leaves the origin playable and shows an error.
- Captured geometry and simplified collision stay in offline-prepared assets; Godot runs from a clean checkout without reconstruction tools. One unit is one metre provisionally until a real dimension is supplied.

## Acceptance

- AC1: The production street still opens with its pixel art, sprite, camera and item interaction. Verify native capture and street tests.
- AC2: Lourizán loads and the paved captured section is walkable with collision. Verify native capture and route test.
- AC3: Map cancel, three street ↔ Lourizán round trips, one home round trip and missing-target recovery pass. Verify `test_location_travel.gd` plus visual playthrough.
- AC4: Existing tests, docs checks and Web release export pass from a clean checkout. Browser gameplay remains a separate acceptance step.

## Phases and handoff

The executable sequence, file boundaries, checks and next visual milestones are in [Plan 010](../plans/010-lourizan-map-travel.md). Read the current spec status and the relevant phase before working. Keep each phase small and commit one working unit. Sol Medium or a cheaper implementation model can handle remaining local tasks; escalate only a consequential unresolved architectural decision.

## References and open questions

[Scaniverse source and preparation](../../assets/source/lourizan/README.md); [production street spec](002-street-trial.md); [development evidence](../development.md). Open: a measured dimension for scan calibration, more captures of the wider estate, and developer visual acceptance of the Pazo's pixel treatment. None block the current captured-paving traversal.
