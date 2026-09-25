# Spec 002 — Scanned street and first pixel art pass

Status: traversal and fall recovery implemented and covered by automated physics
tests. The first pixel treatment is implemented and inspected natively. Browser
gameplay acceptance and the developer's art review remain pending; this spec is
not complete. Spec 001 remains the separate courtyard milestone.

## Scope

Design authority: [Game Bible](https://app.notion.com/p/3e678dc87e92819582a7e84c00e6678e),
especially its art, asset, character and development pages, read on 2026-09-25.
The street remains a bounded experiment inside this repository, not a replacement
for the Bible's longer-term Casa → Bar slice or an approval of its pending standards.

Fidelity correction requested after the first art review: preserve the original
dark asphalt, variable road edges, pale garage facade and its accessible entrance
apron. The cobblestone replacement and fixed-width corridor were not accepted.
Use the original scan's appearance and dimensions as evidence; atmosphere and
pixel treatment must not replace recognizable materials or block side entrances.
Add a controller traversal check from the road to the garage door and back.

Second art correction: reduce the raw 3D reconstruction look with an orthographic
street camera, a pixel sprite character and flatter color treatment. Keep the
original materials recognizable. Scanned walls that cover the character must
become locally transparent using continuous alpha blending with soft edges, without
pixel stippling or changes to collision. This supersedes the rejected dotted effect.
Check both the unobstructed view and a character behind the garage wall natively.
Joss must display all eight movement directions, including four genuine diagonal
views, and preserve the last orientation when idle. Each direction now needs an
actual looping walk animation; static facing sprites are insufficient. Animate
resolved displacement, stop when blocked, and reset presentation on respawn.

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

Implementation: 17 variable-width cross sections follow the scanned road edges,
junction and garage apron, with side/end barriers. The source texture is sampled
into vertex colors offline. Two garage faces use clean geometry and pixel artwork
at the surveyed footprint; small vegetation accents are sprites. The remaining
scan is still draft art, not a finished RPG environment. The player
records its instance spawn on ready and recovers below world Y=-8 m, resetting
velocity/interpolation and notifying the camera. Mouse steering uses the player's
current elevation. Dark asphalt replaces invented cobbles. An orthographic camera,
flat palette and nearest-sampled world pass (2 px at 720p) accompany Joss's sprites;
the HUD renders afterward. Occluding scan/garage walls use continuous local alpha
with an opaque depth prepass, without changing collision. These assets are not Blender sources.

Trial-only normalization: Joss has a 48px body in a 64x64 frame, feet pivot (32,60),
1.8m visual height, 0.0375m per sprite pixel. Original generated source, exact prompt,
normalization script and JSON metadata are retained. Eight idle directions are
retained alongside eight walk clips: four frames each, 8 FPS, 32 walk cells.
The initial six-frame proposal was reduced after inspecting repeated poses.
Row-wide scaling preserves proportions; actual opaque soles align to y60.
No global tile standard or approved master palette is implied.

Previous validation on Windows, Godot 4.7.2 Compatibility: all 302 headless checks pass
(164 street, 138 existing). Street tests cover both ends, variable-width boundaries,
the garage route and return, repeated falls, eight directional choices and common
sprite height/feet pivots. Native rendering inspected the garage and the same
occluded character with/without wall fade: ignored `build/verification/` files
`street_final_15.png`, `street_final_16.png`, `street_wall_solid_final.png`.
Both courtyard and independent street release Web exports succeed without
reported runtime/export errors. Street payload: 41,454,538 bytes (39.53 MiB).
HTTP 200 and opening Chrome are verified; browser gameplay/Safari are not claimed.
Lint/format pass with the existing gdtoolkit `pkg_resources` deprecation warning.

The public image previews of the shared plaza and Joss character sheet were
recovered from their pages' image metadata after the text-only reader failed.
Both are saved in `references/` and visually inspected. Proximity prompts and
location menus remain a direction to refine, not implemented acceptance here.

Editable Blender assets, reusable props and authored pixel textures remain the
production direction under ADR 002. This trial does not require a new asset
framework, full character, interaction-menu system or a new architectural ADR.

## Walk and smooth occlusion correction — 2026-09-25

`street_character.gd` isolates AnimatedSprite3D presentation from movement.
Eight idle and eight walk clips use camera-relative resolved velocity. The
character test covers all directions under two camera headings, sector edges,
cycle progress, idle preservation, wall blocking and respawn (135 checks).
Native occlusion capture shows a continuous soft cutaway, with no pixel pattern.
Final art and manual browser acceptance remain pending.

## Movable trial object

The developer requested one movable object and a push after completion. Reuse
the existing single-instance block pickup/inventory/placement loop in the street.
Place it within reach of spawn without blocking the walking route. E picks up,
P starts placement, mouse aims, Q/E rotates, click confirms and Escape cancels.
Use the actual authored sloping floor: the complete footprint must be supported,
within reach, unobstructed and clear of the player. Reject edges and empty space;
preserve identity across repeated moves and keep cancellation lossless. This is
repositioning, not rigid-body pushing, and introduces no new inventory system.

Final validation of this correction: 472 checks pass (135 character, 33 street
item, 166 street traversal, 138 existing). Native captures show the block before
and after placement, the soft wall cutaway and all four walk frames advancing
in the actual scene. Both release Web exports succeed; street payload is
41,568,582 bytes (39.64 MiB). Preview responds HTTP 200 on port 8001. No manual
Chrome/Safari gameplay acceptance is claimed. Format/lint pass; gdtoolkit still
emits its pre-existing pkg_resources deprecation warning.
