# Spec 002 — Scanned street and first pixel art pass

Status: implementation in progress. The independent scan scene exists; its initial
spawn test passes, but continuous traversal, fall recovery and the pixel art pass
are not yet accepted. Spec 001 remains the separate courtyard milestone.

## Scope

Use the developer's Scaniverse capture as the visual basis of an independent
street trial. Preserve recognizable contours and decoration while providing a
continuous, deliberately authored walking surface. Do not make scan holes or
reconstruction noise into gameplay obstacles. Keep the courtyard as the main scene.

The player must reach the scanned gateway/portal area without jumping. This
does not introduce portal travel or another world. Normal movement must stay
inside the supported street; an exceptional fall returns the player to the
original spawn transform of the current scene instance, with velocity cleared.
No checkpoint, persistence or inventory reset is implied.

The first art pass follows `references/dreamscape-pixel-rpg-reference.png`:
readable pixel detail, violet shadows, warm highlights and clear silhouettes.
Preserve readable UI independently of reduced world resolution. This is an
initial treatment, not a claim of matching the finished reference illustration.

## Acceptance

- Walk from spawn to the gateway area and back using the actual character
  controller, including the route's slopes and joins; no blocking scan fragments.
- Normal walking against both sides and ends cannot leave the supported surface.
- Force an exceptional fall: recover at this instance's original spawn, clear
  falling velocity and restore camera framing. Repeat after moving elsewhere.
- Keyboard and mouse steering remain usable on the elevated street.
- Native visual inspection demonstrates the first pixel treatment; HUD is legible.
- Relevant movement, courtyard and street tests pass; release Web export succeeds.
  Record browser gameplay separately from export or HTTP checks.

## References and deferred work

The developer also supplied
https://chatgpt.com/s/m_6ab5dfffd56c8191b75db5733b9caf0f for visual and contextual
interaction-menu references. Its images were not accessible through the page
reader; do not claim to have reviewed them. Proximity prompts and location menus
are a direction to refine from those references, not implemented acceptance here.

Editable Blender assets, reusable props and authored pixel textures remain the
production direction under ADR 002. This trial does not require a new asset
framework, full character, interaction-menu system or a new architectural ADR.
