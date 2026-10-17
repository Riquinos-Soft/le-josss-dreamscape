# Game-wide design and consistency contract

Updated: 2026-10-17. This applies to every player-facing change: characters,
animation, places, objects, menus, account screens, interactions and deployment.
The developer requested this standing rule after rejecting the V2 character
style and the public test-room entry. It is a delivery requirement, not a new
engine, art generator or approval system.

## Reference hierarchy

Use the latest explicit developer direction, then this contract and the relevant
spec/ADR. Treat proposed work and unaccepted experiments as proposals. If an older
contract conflicts with current direction, record and resolve that conflict before
implementing the affected part; do not silently pick another visual style.

Concrete references:

- Character silhouette, detail and walking: [canonical Joss/Lucas assets](../game/assets/art/characters/README.md),
  especially [Joss walking](../game/assets/art/characters/joss_walk.png),
  [Joss standing](../game/assets/art/characters/joss_idle.png) and
  [Lucas walking](../game/assets/art/characters/lucas_walk.png).
  Preserve the recognizable face/body proportions, pixel shading, eight directions,
  walk cadence, planted stance and phase continuity. The developer explicitly
  rejected the simplified V2 parts on 2026-10-17; they are not the new reference.
- Environment language: Jacobo Risa, [Spec 019](specs/019-coherent-pixel-environment.md)
  and [place authoring](place-authoring.md). Match authored clusters, nearest
  sampling, restrained colors, character-relative density and the shared day/night
  grade. Existing locations are references with their recorded acceptance limits,
  not blanket approval of every asset.
- Product: [project vision](../README.md) and [Spec 020](specs/020-persistent-online-vertical.md).
  Login/creation/personalization leads into the authored world. Public players do
  not enter technical laboratories. No permanent upper character/logout bar in
  play, per the current developer request. Necessary connection errors may appear
  temporarily and must remain actionable.

## Before implementing a visible change

In the active spec, record a short design fit statement:

1. The exact existing scene/asset/interaction used as the reference.
2. What the feature changes and which identity, motion, scale and interaction
   behaviors it preserves.
3. Whether existing art/components can be reused. Prefer that to a replacement.
4. The concrete comparison that will demonstrate the result in gameplay.

Do not introduce a new drawing style, body template, camera scale, walk cycle,
UI language or prototype destination as a side effect of adding a feature.
Customization must preserve the established design and walking in both the editor
and the world; configurable options do not justify a simpler substitute character.

## Delivery checks

Inspect the actual game, not only an isolated texture or a successful export.
Record comparison evidence and limitations in [development](development.md):

- Characters: compare reference/candidate in all eight idle/walk directions and
  start, stop and turn transitions, at the same camera scale. Check head/torso
  identity, foot contact, cadence and direction changes; still screenshots alone
  do not validate walking. Preview and gameplay must show the same result.
- Environments/objects: inspect arrival and the real walkable approach alongside
  the reference character, including occlusion/collision and day/night when relevant.
- UI: inspect the complete player flow at desktop and target mobile dimensions.
  Labels, spacing and controls must serve the game experience, with technical
  diagnostics kept out of normal play.
- Production: inspect the real entry route. A test destination or placeholder
  accessible from the login flow is a product defect, even if automated tests pass.

Tests, native rendering, Web export and browser checks are evidence for their
specific claims; none grants visual acceptance. Do not declare a rejected candidate
fixed or deploy it merely because it passes technical tests. First address the
reported mismatch and inspect the comparison. Deliberate style changes require
explicit developer direction; ordinary fixes within the established reference do
not require repeated permission. If comparison is unavailable, state that limit
and keep the visible result unaccepted.

## Current checkpoint

The production character editor exists, but its simplified V2 art is rejected.
Restoring the earlier design/walk while retaining coherent customization is open.
The Lourizán replacement and removal of the upper play bar remain local; native
validation is intermittent. The shared animation review is now closed in ADR 006:
preserve the original per-phase pixels and derive compatible layers/masks, rather
than enforce a new fixed-head walk. Implementation and visual checks remain. Do
not describe these corrections as deployed. Registration/mail setup remains separate.
See the active spec and development log for the next unresolved step. Update this
checkpoint when it is superseded; do not turn this contract into a second roadmap.
