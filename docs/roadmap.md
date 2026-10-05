# General roadmap proposal

Status: draft for developer discussion. Updated: 2026-09-26.
This is an ordering proposal, not authorization for all listed work, a release
promise or a new architectural decision. Final priorities will be agreed next.

## Established direction and current baseline

An explorable home world grounded in recognizable places, classic pixel RPG
presentation, material object interaction and eventual journeys into the
impossible. The current public street is a bounded art/playability experiment,
not the complete Casa → Bar slice described by the Game Bible.

Implemented foundations: Godot Compatibility/Web, movement, session-local item
identity and placement, eight-direction Joss walking, bounded street traversal,
fall recovery, smooth occlusion, touch controls and static Web deployment.
VPS/database preparation does not mean multiplayer or persistence is implemented.
Developer art acceptance, full gameplay checks on physical mobile/Safari, and
sustained performance/download measurements remain open.

## Proposed sequence and exit criteria

| Stage | Outcome | Exit criteria and dependencies | Authority |
| --- | --- | --- | --- |
| Now: street composition | A coherent test street with grounded vegetation, readable route and clear garage access | Bank implementation verified; developer visual review remains pending | Existing [Spec 002](specs/002-street-trial.md), [plan 009](plans/009-street-bank-composition.md) |
| Next: settle the presentation | Consistent character/environment pixel scale and readable occlusion/UI | Review one agreed route; physical mobile/Safari input and visibility checks; measure load/FPS before promising budgets | Continue 002/004/005; request Astra only if changing a cross-project standard |
| Then: one contextual interaction | Approach a recognizable garage/fence location, see an Observe prompt and read a short response | Correct proximity/input behavior, no clash with pickup/placement, works on desktop and touch | Proposed; agree a bounded spec before implementation |
| Then: Casa → Bar playable slice | A small purposeful route using the accepted art and interaction vocabulary | Agree locations, boundaries and player objective from the Bible; deliver one complete route before expanding | Proposed; read current Bible and define a new spec/plan |
| Later: reusable place/prop library | A few reusable plants, fences, surfaces and movable props supporting that slice | Consistent pivots, dimensions, palette, source/provenance and Web import; Blender only where an editable 3D source adds value | Proposed production work, not a generic asset framework |
| Later: first impossible event | One readable anomaly connecting the familiar world to Dreamscape | Agree a minimal experience and state boundaries; no generalized multiverse system | Proposed feature and spec |
| Future: durable/shared world | Accounts, authoritative interaction and persistence, if selected as the next product milestone | Player/load targets, save/reconnect rules, recovery/offsite backups and end-to-end validation agreed first | [ADR 004](adr/004-hosting-and-persistent-server-direction.md) is a proposed runtime boundary; Astra review and implementation spec required |

Housing, containers, trading, crafting, quests and combat remain future candidates.
Their order is not fixed, and this roadmap does not authorize their infrastructure.

## Decisions to settle together next

1. Is the street the ongoing test map or will the next feature be built in the
   Casa → Bar slice? Avoid polishing a test map indefinitely without playable goals.
2. After visual review, prioritize the first contextual interaction or more
   environmental fidelity; choose one observable milestone.
3. Select physical Android/iOS devices and define the next release acceptance
   route and measurements. Do not invent devices, dates or performance results.
4. Decide when persistence/shared play should displace single-player slice work.
   Hosting readiness alone is not a reason to start it.

## Maintenance

Keep this document in English. After a developer decision, update the stage,
link the approved spec and a bounded execution plan, and record actual evidence.
Use the [spec registry](specs/README.md) to allocate IDs only when a distinct
deliverable is ready to specify. Do not reserve speculative specs for every row.
