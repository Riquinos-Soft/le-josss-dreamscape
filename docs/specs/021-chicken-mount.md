# Spec 021 — Jacobo Risa chicken mount

Status: implemented
Updated: 2026-10-14
Language: en

Authorization: developer requested a rideable chicken in the lower-left end of
Jacobo Risa, mounting/dismounting on approach, 80% faster movement and a push.
Acceptance: native mounted/parked/travel captures and Web export completed;
developer visual, regression suite and physical-device review remain pending.

## Objective

Let the player ride a large pixel-art chicken along Jacobo Risa.

## Scope

One local mount, its directional sprites, proximity interaction and touch action.
This is a bounded addition to the current release before Spec 020 preparation.

## Non-goals

Mount inventory, combat, breeding, persistence, online replication or new places.

## Requirements

- R1 — Place the chicken on accessible ground near the lower-left end of the
  street. Use coherent pixel art with an identifiable comb, beak and saddle.
- R2 — Within 2.2 metres, F or the contextual touch button mounts the chicken.
  The mounted player can use the same action to dismount. Block this interaction
  during modals, travel, portrait blocking and item placement.
- R3 — Mounted speed is exactly base speed × 1.8, without accumulating bonuses.
  Keep keyboard, mouse and touch steering and the existing collision controller.
- R4 — The chicken animates along the movement direction; the rider preserves
  identity and does not run while seated. Idle feet stop moving.
- R5 — Dismount on the current grounded player footprint and leave the chicken
  nearby on validated ground. If no safe parking offset exists, use that footprint.
  After first mounting the chicken, successful travel carries it to the destination;
  mounted travel preserves both riding and its bonus. Failed travel changes neither.
  Salon passages also carry it. Respawn restores walking and brings the chicken to
  the player's spawn. Initial startup still places it in Jacobo Risa.
- R6 — No session save is introduced. Reload restores the chicken's initial spot.

## Acceptance criteria

- AC1 — Reachable parked chicken and consistent idle/walk/rider composition:
  native gameplay-camera captures and developer art review.
- AC2 — Proximity, bonus, repeat interaction, safe dismount and modal restrictions:
  automated runtime checks.
- AC3 — Touch mounting/dismounting, respawn and travel cleanup: automated runtime
  checks; physical-device validation remains separate.
- AC4 — Related regression tests, import and Web export complete; record warnings.

## Validation

Godot 4.7.2 Compatibility on macOS: import, native scene captures at 1280×720 and
844×390 with touch controls, and Web export completed. Captures show the parked
chicken, rider at rest/in motion, dismount and arrival in the Pazo still mounted
with multiplier 1.8. Four view directions inspected; chicken rear diagonals reuse
the rear view. No automated gameplay suite was added/run locally and no physical
mobile/browser validation is claimed. AC1 has native evidence; developer art
acceptance and the automated checks in AC2–AC4 remain open.

Commands, limitations and evidence: [development](../development.md).

Next: developer art/mobile review and requested gameplay regression validation.

## Open questions

None blocking this bounded implementation.

## References

- [Character presentation](015-retro-character-clarity.md)
- [Pixel environment contract](019-coherent-pixel-environment.md)
- [Mobile controls](004-mobile-touch.md)
- [V2 rebuild](020-persistent-online-vertical.md)
- [Place authoring](../place-authoring.md)
