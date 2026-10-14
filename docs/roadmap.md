# Roadmap and current checkpoint

Updated: 2026-10-14. This is the entry point for current priorities. Spec numbers
are identifiers, not execution order. Proposed work below is not implementation
authorization. Older roadmap wording is retained in Git history.

## 1. Current priority: controlled persistent online rebuild

The developer requested the V2 refactor plan, including registration, character
creation, online play and durable progress. [Spec 020](specs/020-persistent-online-vertical.md)
records authorized product scope and unresolved architecture;
[Plan 016](plans/016-persistent-vertical-rebuild.md) is the execution sequence.
This steering supersedes further open-ended V1 art polishing as the main priority.
P0 is complete: [baseline and migration inventory](refactor-baseline.md).
P1 technical contracts are reviewed in [ADR 006](adr/006-v2-character-and-scene-contract.md)
and [ADR 007](adr/007-authoritative-persistent-vertical.md). P2a collision laboratory is implemented.
An isolated V2 collision laboratory exists; no backend has been implemented.

Order: baseline inventory → art/authority/data contracts → modular character and
collision laboratory → small Jacobo Risa section → registration/character creation
→ durable inventory/progress → two-player street → migrated beer/travel loop
→ Pazo/salon → restore drill, cutover and proven-unused-file cleanup.

Next: P2b shared-pose character parts and configurable appearances in the laboratory. Keep the live
entry point intact. One character/account, two-client first validation and personal
quest beer are developer-confirmed. The physical phone/browser remains requested;
mail/backup/retention launch choices stay open in D4. No service rollout during P2.

## 2. Legacy release and comparison route

Explicit bounded follow-up: [Spec 021](specs/021-chicken-mount.md) adds the requested
chicken mount and travel companionship before returning to Plan 016 P0. Native
presentation and Web export completed; mobile/art acceptance remains open.
The developer subsequently requested [Spec 022](specs/022-lucas-surf-arcade.md):
Lucas randomly offers a local beach coin arcade. It is implemented with native
presentation evidence; complete-round and physical-device acceptance remain open.

Recorded implementation/deployment baseline: `ab91b89`, pushed to main. Its
[CI/deployment run](https://github.com/Riquinos-Soft/le-josss-dreamscape/actions/runs/38393362916)
was confirmed successful earlier in this session. Preserve it as the V2 comparison
and rollback reference; successful deployment does not imply art acceptance.
Updated P0 capture reference `753e31c` also passed CI and deployment in run
38487188852. Surf is the subsequent `14d2be5` increment with separate native evidence.

Authorized follow-up implemented: [Spec 019](specs/019-coherent-pixel-environment.md)
unifies Pazo/background pixel art and local day/night color. Use it as the current
reference for the route checkpoint below.

A sequential Pazo pixel-art pass is recorded in [Plan 015](plans/015-terra-palace-pixel-polish.md).
It was executed after explicit developer authorization and awaits visual acceptance.
It assumes the recent “house” request refers to the Pazo, not the separate Casa location.

Current playable scope is [Spec 018](specs/018-residents-and-beer-errand.md), plus remaining
visual/device acceptance of [015](specs/015-retro-character-clarity.md) and
[016](specs/016-lourizan-galleries-and-salon.md). Implementation is complete;
developer acceptance is open. Spec 019 implementation is complete; its art/device review joins this checkpoint.

Review one route on the deployed build:

1. Start at Lourizan; inspect Joss, Lucas and residents standing/walking.
2. Speak to Lucas and receive the beer errand.
3. Travel to Jacobo Risa, collect the beer into the bag and return.
4. Deliver it: beer leaves the bag, balance becomes 20; repeat conversation must
   not pay again. Travel must retain the balance; reload resets the session.
5. Enter/leave the salon, inspect furniture for flicker, then inspect the castle
   illustration outside the map. Check touch bag/dialogue/map controls.

Exit: deployed build confirmed, route reviewed on physical mobile, and concrete
blocking defects resolved. Native checks/export already exist; they do not replace
this review. Current screenshots report issues, not blanket acceptance.

Configurable character appearance is now part of Spec 020 and Plan 016 P2/P4,
including registration and character creation. It is no longer a separate proposed
next feature. Prove one compatible body/pose format before expanding the roster.

## 3. Waiting for input: Casa to Bar

[Spec 008](specs/008-real-home-microzone.md) is partially implemented: the captured
home exterior exists. The connected route, real interior and bar do not. It is
waiting for entrance/stair/floor references, street-to-bar layout and a measured
span. Its lifecycle remains in-progress because scope is incomplete; it is not
an active execution task. Resume only with the required references and priority.

## 4. Implemented baseline, not a feature queue

- Foundations and controls: Specs 001–007. Web engine, movement, item identity,
  touch, boot screen and deployment. Individual acceptance limits stay in specs.
- Places/travel: 009–011. Map travel, authored Pazo/camera and botanical kit.
- Inventory/NPCs: 012–014. Eight-slot bag, dialogue and local Lucas patrol.
- Presentation: 015–017. Canonical character resources, salon/illustrated dream
  backdrop and source/runtime asset cleanup.
- Current gameplay loop: 018. Revised residents, Narci, Lucas smoking/walk and
  the session-only 20-coin beer errand.

These are implemented, not universally accepted. Hosting preparation does not
mean persistence or multiplayer. The beer errand does not imply a quest framework,
shops or durable currency.

## 5. Unscheduled ideas

Further contextual interactions, impossible events, more authored places,
housing, containers, trading, crafting and combat beyond the V2 vertical.
No date, order or implementation authorization is assigned. Do not turn this list
into parallel work. The original Casa/Bar vision remains; repeated Pazo art work
must not silently replace it as the overall product goal.

## Where each kind of information lives

- This roadmap: current checkpoint, proposed next feature, waiting input, backlog.
- [Spec registry](specs/README.md): scope and acceptance status; IDs stay stable.
- [Plan registry](plans/README.md): bounded execution breakdowns and historical
  work records, not another competing priority list.
- [Development](development.md): commands, evidence, known limitations and release
  snapshots. Older entries are historical when superseded by newer records.

Recommended cadence: complete/review the current checkpoint, agree the next
bounded spec, implement it, record verification and deployment, then review before
starting another feature. Developer steering can change priorities explicitly.
