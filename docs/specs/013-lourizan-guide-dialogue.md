# Spec 013 — Lourizán guide and paged dialogue

Status: draft
Updated: 2026-10-06
Language: en

Authorization: developer requested a spec and stepwise plan on 2026-10-06.
This delivery is planning only; implementation starts when its plan is launched.
Acceptance: no NPC/dialogue implementation yet.

## Objective

Meet one stationary garden guide in Lourizán and hear a short history of the pazo
through a classic pixel RPG speech balloon, advancing one paragraph at a time.

## Requirements

- R1 — One fictional `Lucas Maconheiro`, named explicitly by the developer, with a
  hippie forest-worker appearance: olive/earth-tone field clothes, worn boots,
  long or tied-back hair, optional beard, a practical shoulder satchel and a small
  handmade accessory. Relaxed, friendly posture and an approachable speaking tone.
  Keep him readable at the current pixel scale. He is a present-day fictional
  guide, not Montero Ríos. Original pixel sprite, standing idle,
  approximately human scale, a simple physical collider and a 2 m interaction
  radius. No autonomous movement. Place on supported forecourt ground near the
  arrival route, clear of map exit, stairs, beds and path bottlenecks. Candidate
  coordinate `(10, 0, -3) * place_scale` must be verified visually and physically.
- R2 — In range with clear line of sight, show `E · Hablar` and a small talk marker
  above the guide. E or a touch `Hablar` button begins. Being behind a wall, outside
  reach, busy travelling, in placement mode or in another modal must block talk.
- R3 — Display a pixel-framed speech balloon anchored above the NPC's head, with
  a tail pointing toward the speaker, speaker name and one paragraph. Use original
  art inspired by older RPGs; do not copy Final Fantasy graphics. Dark readable
  panel, cream text, accent border, clear `Continuar` button/indicator. Keep text
  sharp and independent of the world pixel pass. No bottom-only dialogue box.
- R4 — Project the NPC head to screen each frame while open, clamp the bubble to
  a viewport safe rectangle and keep the pointer connected to the projected
  speaker. Avoid HUD/touch conflicts. Reflow for 1280×720 and 844×390; do not shrink
  text below readability or crop buttons. If a paragraph needs more space, split
  its display into continuation pages rather than losing text.
- R5 — Show the full paragraph immediately. Each fresh E/Enter/Space press or
  `Continuar` click/tap advances one page. Opening input must not skip page one;
  held keys, key-repeat and emulated touch/mouse pairs must not skip pages. Last
  button reads `Terminar`; final activation closes the conversation. Escape or
  visible close control ends early; starting again begins at paragraph one.
  There is no auto-advance, typewriter, branching, choice tree or voice in v1.
- R6 — During dialogue, lock movement, pickup, bag and travel, reset held steering
  and touch gestures, and consume UI events. Restore controls after closing;
  no movement resumes until a fresh input. Keep simulation running. On focus loss,
  close safely; if NPC/location is freed or player respawns, close and release
  the lock without accessing freed nodes. Closing must not unlock a different modal.
- R7 — Re-entering Lourizán creates exactly one guide. No session NPC state is
  required; conversations replay from the start. Outside Lourizán no guide prompt
  or balloon remains. With Spec 012 installed, talk has priority over pickup when
  both are reachable; while placing, E rotates only. Use the same exclusion
  contract as [Spec 012](012-eight-slot-bag.md).

## Content and historical basis

Initial Spanish copy below is original paraphrase of the tourism authority's
[Paseo romántico por el Pazo de Lourizán](https://blog.turismo.gal/paseo-romantico-por-el-pazo-de-lourizan/),
published in December 2018 and inspected on 2026-10-06. Its historical chronology,
Montero Ríos connection, imperial stairs and garden species support these pages.
Avoid current opening hours, ownership/access claims and exact estate area, which
need fresh verification. The speaker is fictional; historical statements are not.

1. `Bienvenido a Lourizán. Antes de este palacio hubo aquí una granja del siglo XV. El palomar es uno de los recuerdos que quedan de aquella etapa.`
2. `Este lugar fue residencia de verano de Eugenio Montero Ríos, político y jurista gallego. Entre finales del siglo XIX y comienzos del XX impulsó el palacio, el invernadero y los jardines.`
3. `Fíjate en la escalinata imperial y en las estatuas que la acompañan. En el jardín conviven robles y castaños con cedros, magnolios y camelias.`
4. `En 1943, la finca se destinó a la enseñanza y la investigación forestal. Por eso la historia de Lourizán también está ligada al estudio y al cuidado de los árboles.`

Keep this dialogue as local data with speaker, ordered paragraph array and source
URL in developer metadata. Do not put implementation notes or source disclaimers
in the player's speech balloon. Preserve accents. More lore requires an explicit
content extension, not speculative generated history.

## Minimal implementation contract

Add a focused `game/npcs/lourizan_guide.tscn` and script, local dialogue data
`game/dialogue/lourizan_history.gd` (or `.tres` with a tiny Resource), and a
`dialogue_bubble.tscn`/script exposing `open(speaker, anchor, paragraphs)`,
`advance()` and `close()` with a `closed` signal. NPC selection is one explicit
nearby candidate, not a generalized NPC framework. Keep the UI in the session
so location unload cleanup is explicit. Compose the NPC only in Lourizán.

The existing `dreamscape.gd` owns travel/input gating; extend it with direct talk
predicates and a reference to the active guide. Reuse player `set_input_locked`
and touch reset. The existing touch handler consumes screen input before Control
GUI handling, so explicitly pass dialogue/button events to the UI and test touch
emulation rather than assuming GUI clicks reach it.

## Non-goals

No AI dialogue, LLM runtime, backend, quests, rewards, reputation, walking AI,
schedules, combat, navigation mesh, historical impersonation or saved dialogue state.
The guide and bag can be implemented independently and integrated sequentially.

## Acceptance criteria

- AC1: Approach the guide normally, start talk, advance through all four paragraphs
  once per action, and resume movement. Opening cannot skip the first paragraph.
- AC2: Out-of-reach/through-wall attempts fail; pickup, bag, map and rotation do not
  trigger during dialogue. Closing/focus loss/respawn/unload clears stale controls.
- AC3: Bubble remains above/pointing to the NPC, within bounds, with no lost text
  at both target viewport sizes. Inspect native screenshots and simulated touch.
- AC4: Travel away and back produces one guide and no duplicate signal handlers;
  replay starts at page one. Existing item and travel tests continue to pass.
- AC5: Copy matches the four approved-for-implementation paragraphs, has no added
  unsupported history, and original NPC/bubble art reads in the production style.
- AC6: Tests and Web export pass; browser and physical device evidence is reported
  distinctly. Developer visual/copy acceptance remains pending after implementation.

## Validation and open questions

Documentation-only work now. [Plan 012](../plans/012-lourizan-guide.md) specifies
implementation packages and commands. No blocking question; exact sprite and
bubble styling are routine choices within this spec. The settled character
direction is Lucas Maconheiro, a hippie forest worker;
minor costume details remain routine art choices. Developer visual review may
adjust them later.

## References

[Spec 009](009-lourizan-and-map-travel.md), [Spec 005](005-beta-controls-and-pixels.md),
[Spec 012](012-eight-slot-bag.md), [agent workflow](003-agent-workflow.md).
External Notion Game Bible was not accessed; do not invent quotations or page IDs.
