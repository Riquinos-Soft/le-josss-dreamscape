# Spec 002 — Scanned street and first pixel art pass

Status: traversal and fall recovery implemented and covered by automated physics
tests. The first pixel treatment is implemented and inspected natively. Browser
gameplay acceptance and the developer's art review remain pending; this spec is
not complete. Spec 001 remains the separate courtyard milestone.

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

Implementation: a 2.7 m wide sloping strip follows 15 surveyed points in the scan,
with side and end collision barriers. The scan itself is decoration. The player
records its instance spawn on ready and recovers below world Y=-8 m, resetting
velocity/interpolation and notifying the camera. Mouse steering uses the player's
current elevation. Procedural stone/paving materials and a nearest-sampled world
pass (3 px at 720p) establish initial pixel detail; the HUD renders afterward.
These procedural materials are not yet baked Blender texture assets.

Validation on Windows, Godot 4.7.2 Compatibility: all 261 headless checks pass
(123 street, 138 existing). Street tests cover both directions, every side join,
end caps and repeated falls. Native captures are under ignored
`build/verification/street_{spawn,south_end,north_end}.png`; final endpoint
material checks are `street_final_0.png` and `street_final_14.png`. Both courtyard and
independent street release Web exports succeed. HTTP 200 is verified locally;
this does not count as browser gameplay acceptance. The street payload is about
39.43 MiB. Lint passes, with the existing gdtoolkit `pkg_resources` deprecation
warning. An uncapped fixed-FPS test run produced a Jolt job-capacity warning;
the normal-timing headless run passed without that warning.

The developer also supplied
https://chatgpt.com/s/m_6ab5dfffd56c8191b75db5733b9caf0f for visual and contextual
interaction-menu references. Its images were not accessible through the page
reader; do not claim to have reviewed them. Proximity prompts and location menus
are a direction to refine from those references, not implemented acceptance here.

Editable Blender assets, reusable props and authored pixel textures remain the
production direction under ADR 002. This trial does not require a new asset
framework, full character, interaction-menu system or a new architectural ADR.
