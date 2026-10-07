# Spec 016 — Lourizán galleries, residents and dream salon

Status: implemented
Updated: 2026-10-07
Language: en

Authorization: the developer requested a substantial video-led Pazo improvement,
more NPCs, a luxurious interior area and push/deployment on 2026-10-07.
Acceptance: authored expansion implemented and native route/camera checked;
developer art and physical-device review remain open.

## Objective

Make Lourizán more recognizable and rewarding to explore: detailed glazed galleries
and stonework outside, three additional inhabitants and a walkable dream salon.

## Scope

Extend the existing authored exterior using the developer video. Add three distinct
stationary, collidable fictional NPCs (botanist, visitor and salon host) with local
Spanish dialogue through the existing bubble and nearest reachable speaker choice.
Keep Lucas's patrol and ten conversations. The salon is a finite authored room
inside the same loaded location, connected to the terrace by paired walking portals.
Its invented layout is documented and named `Salón de los sueños` in the game.
This explicitly extends the old exterior-only boundary in Spec 009 and Plan 014.

## Non-goals

No claim to reconstruct undocumented real interiors, estate-wide expansion,
NPC manager, navigation system, persistence, multiplayer or renderer change.

## Requirements

- R1 — Express the video's tall continuous glazed bays, pale frames, pink/ochre
  facade panels, slate roofs, cornices, balustrades and monumental stair statues.
  Preserve the paired arches and traversable stairs. Existing dimensions remain
  estimates from reference; do not claim measured architectural accuracy.
- R2 — Give the forecourt coherent large stone slabs, restrained weathering and
  planted seating edges. Keep arrival, patrol, exit and stair paths unobstructed.
- R3 — Add three visually distinct NPCs at human scale. Choose the nearest speaker
  with line of sight, expose the correct name and retain modal input exclusion.
  Freeze the selected speaker until dialogue closes; travel frees all residents.
- R4 — A visible terrace entrance leads to a luxurious traversable salon and a
  visible salon exit returns to the terrace without looping or changing inventory.
  Reset steering and camera on passage; block passage during active modals.
- R5 — The salon contains patterned marble, a carpet, paneled walls, gold trim,
  tall windows/curtains, chandelier, seating and display furniture. Use a cutaway
  presentation to keep the player visible. Match collision to solid furniture;
  preserve item identity and existing floor placement within the location.
- R7 — Surround the playable map with non-colliding floating castle islands,
  purple starry void and warm windows inspired by the existing cover. Preserve
  safe boundaries and avoid blocking the palace camera composition.
- R6 — Keep Web/Compatibility and the existing unit, camera and sprite contracts.
  Batch static architecture by material; no runtime external asset services.

## Acceptance criteria

- AC1 — Inspect native arrival, terrace and salon captures at desktop and compact
  landscape sizes against video frames; record the limitations separately.
- AC2 — Walk both stairs and both portal directions with the real player controller;
  verify grounded arrival, no immediate return, no stuck steering and reachable exit.
- AC3 — Talk to each added NPC using the existing keyboard/touch actions, verify
  correct speaker/content and modal locks, and preserve Lucas's existing regressions.
- AC4 — Bag, travel, collision and item support regressions pass; verify salon floor
  placement and furniture obstruction. Full checks and Web export pass before push.

## Validation

Godot 4.7.2 native Compatibility route passed 25 checks at both 1280x720 and
844x390. Captures under `build/verification/home-scan/pazo-*.png` were inspected
for galleries, readable salon furniture/route, doorway labels and floating
castles. Full `make check` and Web export passed; evidence and limitations are
recorded in [development](../development.md). The furniture is simplified authored
geometry and the interior is fictional. No physical iOS/Android or browser
acceptance is claimed. Next: production CI/deployment and developer art review.

## Open questions

No blocking decision. The salon is an explicitly fictional dream interpretation;
the video does not document a real interior. Developer visual acceptance remains open.

## References

[Place authoring](../place-authoring.md), [video reference](../../references/lourizan-video-2026-10-06.md),
[Spec 009](009-lourizan-and-map-travel.md), [Spec 012](012-eight-slot-bag.md),
[Spec 013](013-lourizan-guide-dialogue.md), [Spec 014](014-lucas-garden-patrol.md),
[Spec 015](015-retro-character-clarity.md).
