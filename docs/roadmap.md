# Roadmap and current checkpoint

Updated: 2026-10-13. This is the entry point for current priorities. Spec numbers
are identifiers, not execution order. Proposed work below is not implementation
authorization. Older roadmap wording is retained in Git history.

## 1. Current checkpoint: finish the existing playable loop

Implementation baseline: `b9a3ede`, pushed to main. Its CI/deployment run is
[38328916165](https://github.com/Riquinos-Soft/le-josss-dreamscape/actions/runs/38328916165).
CI and deployment completed successfully on 2026-10-13. Production baseline is
`b9a3ede`. A successful deployment does not imply developer gameplay acceptance.

Current scope is [Spec 018](specs/018-residents-and-beer-errand.md), plus remaining
visual/device acceptance of [015](specs/015-retro-character-clarity.md) and
[016](specs/016-lourizan-galleries-and-salon.md). Implementation is complete;
developer acceptance is open. No additional feature is currently in implementation.

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

## 2. Proposed next feature: configurable character appearance

Requested by the developer; not yet specified or authorized for implementation.
After the current checkpoint, draft one bounded spec for face, hair, clothing and
shared body proportions for Joss/NPCs. Decide composition and authoring strategy,
then prove one character can change appearance without changing gait/identity.
Define that acceptance before extending the NPC roster or regenerating more
independent full-body atlases. Do not reserve an ID until drafting begins.

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
housing, containers, trading, crafting, combat, persistent/shared worlds.
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
