# Spec 024 — Optional third-person camera prototype

Status: implemented
Updated: 2026-11-05
Language: en

Authorization: developer requested a reversible account-world camera experiment,
C toggle, mouse orbit, zoom, smoothing and SpringArm3D. Initially one independent
PR without release; subsequently the developer explicitly authorized conflict
resolution, merging both camera/signup PRs and production deployment.
Username signup remains a separate bounded increment.

## Objective

Explore the existing Pazo from behind canonical Joss without replacing the
orthographic default or altering the server-authoritative simulation/protocol.

## Scope

Only V2 account-client camera, its input coordination and view-relative sprite
presentation. Reuse the original orthographic camera rig unchanged; optional
perspective rig with SpringArm3D, smooth follow/orbit, bounded pitch/distance,
right-button drag and wheel zoom. C toggles back with the original view intact.

## Non-goals

No new assets, renderer/engine migration, first-person controls, character models,
world rebuild, networking/persistence changes or camera preference persistence.
Legacy right-mouse steering belongs to the V1 player, not the V2 input adapter;
leave it untouched. Unfinished account inventory/mount restoration is outside
this branch, not silently included or claimed complete.

## Design fit

Reference `player/camera_rig.tscn`, account `session.gd`, canonical Joss/Lucas
40-pose nearest-sampled billboards and existing Pazo/Speakers/salon. Retain metre
scale, 0.0375 sprite pixel size, 1.05m foot offset, continuous eight-direction
walking, Compatibility/daylight/pixel grade and existing controls in default mode.
Compare both modes at identical Pazo arrival, stair/terrace, garden/NPC and salon.
Orbit must update standing/moving local, remote and NPC poses in the active view.

## Requirements

- R1: orthographic default on every load; C switches only during admitted gameplay.
  Perspective starts behind the last world-space facing; mouse drag orbits without
  moving Joss. Scroll adjusts bounded distance. No pointer lock; release/focus loss
  and modal state clear drag/input, preventing accidental movement or stuck orbit.
- R2: keep the original orthographic Camera3D/rig untouched and create one optional
  perspective Camera3D on the SpringArm3D. Switch the session's active camera and
  all input/presenter/NPC consumers together; preserve original projection,
  clipping/size/follow behavior when returning. Actor/saves untouched.
- R3: keyboard and existing touch stick use the active camera basis; same bounded
  world-space intent reaches the authority. Left-click/UI/touch controls are not
  repurposed. Mobile can retain the original orthographic experience; hardware C
  may opt in, with no required new touch gesture.
- R4: collision arm excludes Joss and collides with authored world geometry;
  short-space camera must not cross palace/salon walls. Clamp pitch and zoom to
  keep sprites readable. Preserve default pipeline/assets; document any inherent
  billboard/environment limitations exposed by lower angles rather than invent art.
- R5: reuse the existing foliage wall-fade uniforms only while perspective is
  active; restore authored settings on return. Scale passage signs with distance
  in perspective so they remain readable rather than filling the view. Hide only
  the local billboard when the collision arm compresses below 1.4m, restoring it
  with clearance/default view. Single-pose residents retain their original art;
  never request missing directions or synthesize replacement assets.

## Acceptance criteria

- AC1: toggle roundtrip restores exact original camera and canonical resources;
  repeat toggles, travel, reconnect and focus/modal changes leave input coherent.
- AC2: real input/orbit/zoom clamps, smoothing and SpringArm obstruction/recovery
  tests pass; camera-relative keyboard/touch and eight-way/idle reorientation pass.
- AC3: inspect native exterior, stairs, garden, NPCs and salon in both modes;
  record clipping/visibility/pixel readability and screenshots/known limitations.
- AC4: relevant/full Godot regression, online presence and travel roundtrip plus
  account Web export pass. Actual browser review when practical, physical phone
  acceptance separately recorded. No claim of permanent art acceptance.

## Validation

Native comparison completed: 61 focused checks pass, including C roundtrip,
real mouse/touch/keyboard input, clamps, follow, SpringArm solid obstruction and
recovery, modal/focus/reconnect/travel, sprite directions and original foliage/sign
restoration. All 26 Godot suites and real two-account HTTP/WebSocket/PostgreSQL
presence/travel route pass. Account Web export passes. Perspective NPC fallback
for the authored single-front-pose residents was found in actual Web review and
covered by a new regression. Final Web review/evidence recorded in development.

Inspected the Pazo forecourt, both camera views on the terrace/stair approach,
garden/NPCs and salon, including compressed camera near its solid wall. Canonical
art remains crisp at default distance. Reused foliage reveal and capped passage
labels address the observed obstruction/readability issues. Existing cutaway
salon walls/open roof and billboard foliage reveal the original orthographic
composition under reverse orbit; no geometry or assets were recreated. These are
experimental limits, not acceptance of a permanent perspective art direction.
Physical iPhone review and developer visual acceptance remain open.

Production checkpoint: PR3 merged at `a99a512` and final CI/deployment passes.
Actual HTTPS game C → right-drag orbit → C was visually inspected with no captured
runtime errors. Default orthographic and saved character resume remain intact.
Production evidence/backup are recorded in development. This is deployment,
not permanent perspective art acceptance or a physical-device review.

## Open questions

None blocking the bounded experiment. Visual developer acceptance remains open.

## References

[Design contract](../design-contract.md), [Spec020](020-persistent-online-vertical.md),
[Spec009](009-lourizan-and-map-travel.md),
[ADR006](../adr/006-v2-character-and-scene-contract.md),
[ADR007](../adr/007-authoritative-persistent-vertical.md),
[SpringArm3D](https://docs.godotengine.org/en/stable/classes/class_springarm3d.html).
