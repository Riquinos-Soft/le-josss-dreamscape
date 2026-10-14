# Spec 022 — Lucas surf arcade

Status: implemented
Updated: 2026-10-14
Language: en

Authorization: developer requested a random “¿Surf?” invitation from Maconheiro,
an affirmative choice transporting the player to a beach surfing/coin minigame.
Acceptance: native invitation/arcade/result/return presentation completed. Existing
push authorization covers this work; full gameplay and physical-device review remain open.

## Objective

Add a short repeatable arcade diversion offered by Lucas, with collected coins
credited to the existing session balance on return.

## Scope

A local pixel-style beach arcade, two dialogue choices, keyboard/touch steering,
coin collection, obstacles and return to the unchanged world position.

## Non-goals

Online competition, persistent scores, a real-place beach reconstruction, new
account services or a general minigame framework. Spec 020 remains separate.

## Requirements

- R1 — Preserve first beer-task dialogue and delivery priority. Other conversations
  have a 25% surf invitation chance, without consecutive invitations. Only Lucas
  offers it. Show “¿Surf?” with explicit “Sí, ¡vamos!” / “Ahora no” choices.
- R2 — Decline/close keeps the player in the world. Accept opens the beach arcade,
  suspending world input/simulation, bag, travel and mount interactions.
- R3 — Surf automatically along the sea. Steer left/right using A/D, arrows,
  on-screen buttons or dragging on the water. Collect coins while avoiding rocks.
  One run lasts 45 seconds or three collisions, with a grace interval after hits.
- R4 — Show remaining time, hearts and collected coins. End/leave shows a result
  and explicit return action. Returning credits collected coins exactly once to
  the session balance, restores the same world position, mount state and controls.
- R5 — Focus loss pauses the run with explicit resume. Portrait orientation keeps
  the existing rotation blocker above the arcade and pauses elapsed gameplay.
- R6 — Reuse Joss's canonical identity; author the ocean, board, beach and effects
  as crisp code-native pixel clusters. No external beach assets or provider needed.

## Acceptance criteria

- AC1 — Invitation eligibility and accept/decline integrate without replacing the
  beer errand or other NPC dialogue; inspect code and native UI.
- AC2 — Native arcade renders controls, beach, surfer, coins, rocks and results;
  collect/collision/timer/return semantics need gameplay validation.
- AC3 — Entry and return preserve world/mount state and credit a run once;
  orientation/focus controls and physical mobile need separate validation.
- AC4 — Import, lint and Web export complete with warnings recorded.

## Validation

Godot 4.7.2 Compatibility native capture at 844×390 with touch controls shows a
random invitation, acceptance, beach instructions, nine collected coins, result
and return to Lourizán with balance nine and busy=false. The capture deliberately
ends the run early; it does not establish the full timer/collision/focus/portrait
acceptance. Import and targeted lint pass. No gameplay tests were added/run locally
and no physical-device/browser validation is claimed. Web export result and
commands are recorded in [development](../development.md).

Next: developer gameplay review, including complete rounds and mobile controls.

## Open questions

None for this local arcade. Durable rewards and online authority remain subject
to Spec 020's reviewed contracts.

## References

- [Lucas beer loop](018-residents-and-beer-errand.md)
- [Chicken mount](021-chicken-mount.md)
- [Persistent online vertical](020-persistent-online-vertical.md)
- [Pixel direction](../place-authoring.md)
