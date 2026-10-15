# Spec 023 — Bar Scandale and bartender jokes

Status: implemented
Updated: 2026-10-15
Language: en

Authorization: developer requested a new Bar Scandale location on 2026-10-15,
providing five interior photographs, a blond bartender NPC and random very dark jokes.
Acceptance: native route, automated checks and Web export pass; developer art and
physical-device acceptance remain open.

## Objective

Add a recognizable, walkable pixel-art Bar Scandale and a fictional blond bartender
who tells randomly selected Spanish dark-humor jokes when approached.

## Scope

Add a destination to the existing playable travel map and use its keyboard/touch
conversation flow. Reuse the current character pose and pixel environment contracts.
The account-first slice from Spec 020 is retained; this request authorizes a bounded
new location in the playable world, not unimplemented persistent travel or economy.

## Non-goals

No purchase system, alcohol mechanics, new quests, fabricated real-person biography,
photo textures, online joke generator or changes to account deployment credentials.

## Requirements

- R1 — Travel to "Bar Scandale" and return through a visible exit, keeping the
  player, bag identities, camera and existing destinations functional.
- R2 — Author the narrow room, reddish floor, wooden return bar, suspended metal
  bottle/glass rack, crowded poster walls, blue television and pink disco ball
  from the supplied photos. Dimensions are estimates; no scan was provided.
- R3 — A blond, blue-shirted bartender remains behind the counter and is reachable
  for dialogue from the customer aisle. Counter/wall collisions match the scene;
  conversation works across the countertop but not through walls or at a distance.
- R4 — Each conversation selects one original Spanish dark joke, avoiding immediate
  repetition. Text is fictional NPC dialogue, not attributed to the photographed
  person's real views. No network call or influence on Lucas's quest/rewards.
- R5 — Use crisp pixel clusters and earthy materials; preserve indoor warmth,
  shared world/background day-night grading and unaffected HUD colors.

## Acceptance criteria

- AC1 — Native controller route enters, approaches the bartender, talks, and exits.
- AC2 — Map travel, collision obstruction, range and joke repeat behavior pass tests.
- AC3 — Inspect native arrival/dialogue views and compact framing; Web export passes.
  Record physical-device and developer art review separately.

## Validation

Reference inspection: all five supplied images are HEIF data with `.png` filenames;
converted into ignored `build/verification/scandale/references/` only for inspection.
No scan available; use photo-derived estimated layout with an open camera cutaway.
Godot 4.7.2: 125 Scandale checks pass headless and natively, including actual
controller travel, counter collision and keyboard/touch dialogue. Native arrival,
dialogue day/night and compact-map captures were inspected. Web export passes.
Appearance (203), travel (119) and backend (12) regression checks pass.
See [development evidence](../development.md) for commands, warnings and limitations.
No Chrome/Safari or physical iPhone validation is claimed for this increment.

## Open questions

None blocking this bounded implementation. Final visual likeness awaits developer review.

## References

- [Place authoring](../place-authoring.md)
- [Pixel environments](019-coherent-pixel-environment.md)
- [Character contract](../adr/006-v2-character-and-scene-contract.md)
- [Account-first work](020-persistent-online-vertical.md)
