# Spec 015 — Retro character clarity and stable walking

Status: implemented
Updated: 2026-10-13
Language: en

Authorization: developer requested Secret of Evermore-inspired restyling,
starting with a small character/readability and walking-stability release,
deployment, then their mobile playtest before further art work.

## Current refactor — 2026-10-07

Authorized by the developer: remove obsolete character asset versions, use stable
unversioned names, and harmonize idle/walk silhouettes with Joss's existing walk
art. The runtime Joss idle resource incorrectly slices a 4x8 sheet as 4x2; fix
its actual eight-facing mapping. Retain directional state, frame cadence and
planted straight-leg standing poses. The current walking head and torso are the
canonical identity reference; idle must preserve their pixels and proportions.
Static residents must use the same compact, large-head style.

Keep only the active runtime atlases, animation resources and reproducible source
masters. Git retains historical assets; the working tree must not accumulate
obsolete variants. Verify exact idle row mapping, distinct direction imagery,
matching head/torso at rest, movement transitions and NPC conversations. Next:
developer visual review of the normalized comparison and canonical assets.

Future direction supplied by the developer: a separate spec will define character
style configurations (face, hair, clothing, proportions) and dynamic appearance
composition. Current SpriteFrames remain replaceable presentation resources,
independent of NPC identity/dialogue. Do not add unused customization fields or
claim that baked sprites already implement configurable appearance. The current
atlases are transitional art references for that next spec.

## Historical iterations

Earlier releases alternated between first-walk-frame idle and independently
generated standing art. They passed movement-state checks but failed developer
visual review: head/body proportions changed and directional atlas addressing
was wrong. The current refactor supersedes those visual acceptance claims;
older evidence in development notes applies only to those earlier commits.

## Objective and scope

Recover the detail already authored in Joss and Lucas and reduce shimmering and
direction flicker while walking. Establish the presentation direction for later
original character art and a more faithful Lourizán facade. This first release
now confines changes to character assets, addressing and visual consistency.

## Requirements

- R1 — Stop crushing characters and architectural details through the historical
  180-row screen mosaic. Retain the original pixel sprites and world materials,
  use gentle character sampling and continuous screen coordinates in production.
  Keep the old mosaic as an offline comparison setting only. Travel must retain
  the same presentation in every location; do not change world scale or zoom.
- R2 — Analog input near an eight-direction boundary must not alternate poses
  every frame. Use a small angular dead band and preserve walk-cycle phase across
  direction changes for Joss and Lucas. Start/stop, wall collisions and respawn
  still resolve from actual movement.
- R3 — Share the small directional-animation rule between both characters so new
  characters can use it. Preserve existing camera/physics interpolation.
- R4 — Record Evermore and real-facade references and a staged art direction:
  readable expressive sprites, restrained earthy colours, coherent shading,
  original textures and geometry. No copied commercial assets.
- R5 — Stopping after movement must retain Joss's exact directional silhouette.
  Idle preserves the first walk frame's visible head and torso pixels above y=43,
  with separately prepared straight-leg standing art below. Every directional
  animation must address its own actual atlas row.

## Non-goals

No facade reconstruction, new renderer, gameplay feature or runtime appearance
generator. Face/hair/clothing configuration is reserved for the requested next
spec. Physical-device and developer visual acceptance remain separate.

## Acceptance criteria

- AC1 — Inspect all eight walk/idle direction pairs and the resident lineup,
  plus the native gameplay composition. Idle retains walking head/torso identity
  and uses straight standing legs. Developer visual acceptance remains pending.
- AC2 — Automated movement covers eight directions, noisy analog sector edges,
  deliberate turns, uninterrupted phase, wall stop and respawn. Lucas dialogue
  and patrol regressions pass.
- AC3 — Existing tests and Web export pass. The canonical refactor shipped
  in the successful `a5a0285` deployment. Later Lucas/resident art is in Spec 018.
- AC4 — Keep only active character atlases/resources with stable unversioned
  names and retained source provenance. Record configurable appearance as the
  next spec without implementing a generator in this cleanup.

## Validation and next action

Godot 4.7.2 Compatibility: the full `make check` passed 1138 checks with zero
failures and produced the Web export. The character test has 172 checks covering
real movement, all eight facings, correct idle row addressing and exact visible
head/torso retention; Lucas has corresponding checks in the 184-check dialogue
suite. The scene test now checks the real runtime resources rather than an unused
legacy sheet. It compares each idle silhouette height to its corresponding walk
frame; the canonical walk has a per-frame maximum of 48px, not 48px for every pose.

Native 1280x720 dialogue run passed 184 checks and its capture was inspected.
The eight-direction walk/idle comparison and resident lineup were also inspected;
paths and commands are recorded in [development](../development.md). An inventory
audit found five used runtime PNGs and five used SpriteFrames resources, no
version suffixes or unreferenced character variants. Old assets remain in Git.
The existing gdtoolkit deprecation warning remains. Next: developer visual review
and the separate configurable appearance specification.

## References and open questions

Inspected [Evermore town screenshot](https://postgamecontent.com/post/158795276820/squareenix-misfits-secret-of-evermore)
and [Lourizán facade photograph](https://cufa.es/areas-de-trabajo/colocacion_pizarra_pontevedra_costa).
Use these as composition and style references, not runtime textures.
The developer then supplied a 105.7-second on-site video. Eight sampled frames
and timestamped [observations](../../references/lourizan-video-2026-10-06.md)
now provide the primary reference for the next facade pass.
[Spec 005](005-beta-controls-and-pixels.md)'s 180-row comparison and Spec 010's
180-row setting are superseded for current production by R1. Follow
[place authoring](../place-authoring.md) for later locations. No blocking question;
final visual acceptance belongs to the developer's requested mobile review.
