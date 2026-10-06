# Spec 015 — Retro character clarity and stable walking

Status: implemented
Updated: 2026-10-07
Language: en

Authorization: developer requested Secret of Evermore-inspired restyling,
starting with a small character/readability and walking-stability release,
deployment, then their mobile playtest before further art work.

## Authorized follow-up — 2026-10-07

The developer authorized continuing Lucas and Pazo improvements and requested
a bounded plan for an economical executor. [Plan 014](../plans/014-lucas-atlas-and-pazo-refinement.md)
is ready; implementation has not started. Earlier validation applies to the
previous release only. Mobile and developer visual acceptance remain pending;
the new request authorizes proceeding without treating that acceptance as passed.

The developer further required BOTH Joss and Lucas to walk correctly and adopt
a standing shape with extended legs when stopped. This supersedes R5's
requirement to reuse the first walk frame: retain proportions and facing, but
use dedicated standing art for all eight directions, with planted feet and no
frozen stride. Preserve stable direction transitions and walk-cycle phase.

Follow-up acceptance: inspect eight-direction start/walk/turn/stop sequences
for both characters at 1280×720 and 844×390; verify wall stops and Lucas
waypoint/dialogue pauses use standing poses. Replace the old pixel-equality
regression with applicable state/grounding checks and visual evidence. Run
focused tests/full gate/Web export. Next: Plan L1; art acceptance remains pending.


## Objective and scope

Recover the detail already authored in Joss and Lucas and reduce shimmering and
direction flicker while walking. Establish the presentation direction for later
original character art and a more faithful Lourizán facade. This first release
changes rendering and animation behavior; facade remodeling follows mobile review.

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
  The idle and first walk pose share the same normalized atlas frame, preventing
  an unrelated head proportion from appearing at rest.

## Non-goals

No full character redraw, facade reconstruction, new renderer, postprocessing
stack, gameplay feature or physical-device acceptance inferred from desktop tests.

## Acceptance criteria

- AC1 — Compare the same native scene at 1280x720 and 844x390 with old and new
  presentation; inspect faces, outlines and details while retaining readable UI.
- AC2 — Automated movement covers eight directions, noisy analog sector edges,
  deliberate turns, uninterrupted phase, wall stop and respawn. Lucas dialogue
  and patrol regressions pass.
- AC3 — Existing tests and Web export pass; deploy and verify the public release.
  Developer plays on a physical mobile before the next visual pass.

## Steps and next action

1. Capture the old and new presentation, implement continuous sampling and stable
   directional animation, then inspect a short native walk.
2. Run focused checks and full gate, document, commit and deploy.
3. Await mobile feedback. Next art milestone: facade proportions, glazed bays,
   mansard profiles, central clock and paired curved stairs from photographs.

## Validation

Godot 4.7.2 Compatibility: `make check` passed 928 checks and Web release export.
The character test also passed 140 checks natively at 60 FPS. Native A/B captures
at 1280x720 and 844x390 plus walking frames were inspected. Logs and images are in
`build/verification/restyle/`; commands are in [development](../development.md).
No full browser gameplay or physical mobile performance pass is claimed.

Follow-up: the idle atlas had a different Joss drawing from the walk atlas, making
his head change proportion when movement stopped. Idle now uses each direction's
first walk frame and a focused regression check compares their pixel data. The
follow-up validation is recorded in [development](../development.md).

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
