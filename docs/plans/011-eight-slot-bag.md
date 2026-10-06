# Plan 011 — Eight-slot bag

Governing spec: [012](../specs/012-eight-slot-bag.md).
Status: done, 2026-10-06. Implementation authorized and completed.
Actual planning base: `2a059ce`; implementation base: `78e5485`.
Design references: developer's bag/beer brief; ADR 003 ownership; Spec 009 travel;
Spec 005 touch/UI. External Notion Bible was not supplied or reinterpreted.
Observable objective: beer pickup → bag → travel → placement → return and recover.
Settled choices: eight stable slots, select-to-place, session-only location records,
original beer, no stacking or persistence. No unresolved architectural decision.
Non-goals: those in Spec 012. All packages execute sequentially B1 → B7.
Recommend doing the shorter NPC plan first; this plan also works independently.
If the NPC was implemented first, inspect its completed modal/input contracts
rather than rebuilding them. Shared files are reserved to the integrator.

## Execution rules and verification commands

Use Sol 5.6 Medium, as requested; the developer selects the model. No agent was
spawned or model availability asserted by this planning delivery. One sequential
executor is also the integrator. Run only the next unblocked package, commit a
working unit, update this plan and `docs/development.md`, then continue when the
execution prompt authorizes it. Do not reread the entire repo between packages.

All packages are planned until this plan is launched; the first package then
becomes ready. No parallel writes are authorized. The current executor owns the
listed package files; `dreamscape.gd`, `touch_controls.gd`, Makefile, tests and
spec/plan indexes are integrated serially. Read actual current state before each
package: later commits may have moved paths. Preserve unrelated local changes.
Common documentation edits to this plan/spec and development evidence are allowed
for every package. Any other file requires a recorded reason and scope check,
not an automatic permission question for a routine dependency correction.

Commands below run from repo root with the configured gdtoolkit on PATH:

```sh
git status --short
git rev-parse HEAD
python3 tools/check_docs.py
make lint
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --fixed-fps 60 --script res://tests/TEST.gd
/Applications/Godot.app/Contents/MacOS/Godot --path game --max-fps 60 --script res://tests/TEST.gd -- --capture
make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot
```

Replace `TEST.gd` with each package's named test. Use installed `godot` elsewhere.
On the inspected Mac, the lint environment was `/private/tmp/lourizan-author313/bin`;
check it still exists before using it, otherwise follow documented development
setup. Never assume a temp path is portable. Read logs for `SCRIPT ERROR`/shader
errors as well as exit status. Evidence goes under ignored `build/verification/`.
Run focused tests for each change; full check at the final package. Do not repeat
unchanged gates after a documentation-only handoff. Browser/mobile acceptance
requires actual execution; native captures and Web export do not establish it.

The settled spec contracts are sufficient for routine work. Only request Astra
for an unresolved conflict with ADR identity/ownership, a newly required durable
save system, or a shared input change that cannot preserve the stated contracts.
Provide reproduction and two options under Spec 003. Syntax, test migration,
asset pivots and local GUI fixes stay with the executor.

For each package record: actual base and result commit, changed files, observable
outcome, commands/results/log paths, screenshot where applicable, limitations and
next package. Integrator reviews the diff and required evidence before marking
it done; no user art acceptance is implied. Commit atomically with a conventional
message. Follow current session push authorization; implementation instructions
alone do not create a new blanket deployment authorization.

## B1 — Replace one-slot storage with eight stable slots

Status: done. Owner: the session executor/integrator.
Dependencies: developer starts this plan. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 R1/R5 and ADR 003; inventory.gd, item_instance.gd, item_loop.gd; rg all inventory callers.
Allowed edits: game/inventory/inventory.gd; game/items/item_loop.gd; game/items/street_item_loop.gd; dependent inventory call sites in game/player/touch_controls.gd and game/tests/test_item_lifecycle.gd; new game/tests/test_bag_inventory.gd; Makefile. All other feature work is outside this package.

Contract: Implement the spec API, changed notification and explicit selected-slot reference. Keep default slot zero temporarily for the old placement command until B3 replaces the UI. Pickup never starts preview.

Steps:

1. Search `.item`, `put`, `take` call sites; record the migration list.
2. Implement first-free insertion, expected-reference removal, stable empty slots and duplicate rejection.
3. Migrate callers to explicit slot access; preserve the existing single-world-object loop until B4. Add capacity and failed-transfer cases.

Checks and evidence: Run test_bag_inventory.gd, test_item_lifecycle.gd and test_touch_controls.gd. The inventory test covers eight distinct references, ninth rejection, holes, nulls, wrong expected item and repeated removal. Log under bag/B1.

Acceptance: Old loop still runs; eight entries can be stored without aliasing or compaction. No broken intermediate commit. Visual bag follows in B3.

## B2 — Author the beer definition and matching art

Status: done. Owner: the session executor/integrator.
Dependencies: B1. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 R9; item_definition.gd, world_item.gd; current art metadata convention.
Allowed edits: game/items/item_definition.gd; game/items/world_item.gd; game/items/item_loop.gd; game/items/street_item_loop.gd; game/assets/art/items/; item fixture tests. All other feature work is outside this package.

Contract: Definition supplies per-type dimensions, icon and world visual. Production initial item becomes Birra Dreamscape; block can remain a test definition. Preview has matching silhouette and pivot.

Steps:

1. Create original beer bottle and slot icon; use imagegen skill if raster generation helps, keep source/prompt/provenance.
2. Replace fixed Definition.SIZE/.25 assumptions in affected validators with the selected definition dimensions.
3. Keep beer grounded and make orientation visible on its label; inspect world and inventory-size render.

Checks and evidence: Run item lifecycle and street item tests; native street capture at normal camera size. Verify footprint/height tests against definition, not visual bounding guesswork.

Acceptance: Recognizable small beer on street, matching icon, preview and collider; no block label remains in production.

## B3 — Build the visible bag and select-to-place flow

Status: done. Owner: the session executor/integrator.
Dependencies: B1 and B2. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 R2–R5/shared input; touch_controls.gd input consumption; dreamscape.gd open_map/close_map.
Allowed edits: game/inventory/bag_ui.gd and .tscn; game/assets/art/ui/; game/items/item_loop.gd and street_item_loop.gd; game/world/dreamscape.gd; game/player/touch_controls.gd; game/project.godot if action binding is needed; new game/tests/test_bag_ui.gd; Makefile. All other feature work is outside this package.

Contract: Right-side icon, B/P open 4×2 grid. Slot selection closes bag and starts preview for that reference. Bag is modal; placement allows existing movement. Fresh press required for confirm.

Steps:

1. Create reusable pixel bag UI showing empty and occupied slots, item name and occupancy.
2. Wire updates to inventory.changed and remove the old production Place shortcut behavior.
3. Coordinate input/modal gating with map and any existing dialogue. Explicitly route touch events around the touch handler that currently consumes them.
4. Implement cancel, empty/full feedback, keyboard focus and no-click-through guards.

Checks and evidence: Run test_bag_ui.gd with real GUI key/mouse/simulated touch events, plus touch/item regressions. Native screenshots at 1280×720 and 844×390; evidence bag/B3.

Acceptance: Pickup stores silently with short feedback; clicking a slot only opens preview. Bag never moves player or confirms placement. All eight slots and close control remain visible.

## B4 — Support several placed objects in the active zone

Status: done. Owner: the session executor/integrator.
Dependencies: B3. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 minimal controller contract; current world_item and can_pickup paths; dreamscape.gd set_street_active.
Allowed edits: game/items/item_loop.gd; game/items/street_item_loop.gd; game/world/dreamscape.gd; game/player/touch_controls.gd; affected item/street/travel tests. All other feature work is outside this package.

Contract: Replace singular world_item ownership with a collection and nearest reachable candidate; selected inventory slot remains the owner until confirmed. Use a session monotonic ID allocator for initial/test-created items.

Steps:

1. Remove all singular/null world_item assumptions, including startup collision-layer access and inactive-street toggles.
2. Implement deterministic candidate selection and atomic transfer for multiple world nodes.
3. Seed multiple instances only in tests; production still starts with one beer. Preserve all eight carried identities over repeated placement/pickup.

Checks and evidence: Run bag inventory/UI, item lifecycle, street item and location travel tests. Cover pickup of nearest reachable item, full bag, repeated confirm and overlap between two placed items.

Acceptance: Eight objects can be manipulated one at a time with no replacement/loss of previously placed objects. Travelling with zero world nodes does not crash.

## B5 — Retain placed objects across scene unloads

Status: done. Owner: the session executor/integrator.
Dependencies: B4. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 R7–R8; dreamscape.gd travel_to/load_destination and rollback; ADR 003.
Allowed edits: game/items/item_loop.gd; optional focused game/items/location_item_state.gd; game/world/dreamscape.gd; game/tests/test_location_travel.gd; new game/tests/test_bag_travel.gd; Makefile. All other feature work is outside this package.

Contract: Session stores location ID → ordered records of the original ItemInstance and world transform. No Node references in records. Empty initialized locations stay empty. Only a verified travel commit swaps representations.

Steps:

1. Snapshot source state, stage destination and validate destination-only support before ownership changes.
2. Deactivate outgoing collision correctly and bind the item controller to active location roots; preserve existing travel rollback.
3. Restore/seed destination records once, destroy outgoing world visuals after safe commit, keep bag active everywhere. Remove travel_only restrictions on item controls in destinations.
4. Inject missing-resource and unsafe-arrival failures in tests; assert source/bag records unchanged.

Checks and evidence: Run test_bag_travel.gd and location travel. Required route: street pickup, Pazo drop, Casa visit, Pazo recovery, street return; add two items in different locations and an empty source. Compare reference/ID/pose and uniqueness.

Acceptance: Placed objects survive return trips in memory; no duplicate seed, dangling node or lost object on failed travel. Reload persistence is explicitly absent.

## B6 — Enable safe placement on each place’s terrain

Status: done. Owner: the session executor/integrator.
Dependencies: B5. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 R6; street support and overlap queries; home/Pazo geometry and location scaling.
Allowed edits: game/items/street_item_loop.gd or focused shared support helper; game/items/item_loop.gd; game/world/dreamscape.gd location binding; minimal support-group metadata in location scenes/scripts; new game/tests/test_place_support.gd; Makefile. All other feature work is outside this package.

Contract: Support eligibility is explicit per active place. Center/corners raycast actual current terrain; ignore only legitimate support contacts in overlap checks. Definition size is independent of place scale.

Steps:

1. Generalize the street validator to active floor/terrain bodies and elevation, without accepting arbitrary physics props as floors.
2. Verify world/local transforms in scaled locations and Pazo terrace. Reject stale source-world hits during travel.
3. Cover walls, ledges, slopes, stairs, another item and any NPC; leave invalid preview visible and bag unchanged.

Checks and evidence: Run test_place_support.gd, street item, bag travel and connected stairs. Native captures of valid Pazo terrace placement and red unsupported/home-edge preview.

Acceptance: Beer can be placed on all three current zones and the supported terrace; cannot float, overlap, use NPC as support or pass through walls.

## B7 — Complete the playable round trip and handoff

Status: done. Owner: the session executor/integrator.
Dependencies: B6. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 012 acceptance; package evidence; NPC spec shared controls if installed.
Allowed edits: relevant fixes within this plan; game/tests/test_bag_travel.gd and test_bag_ui.gd; docs/development.md; specs/plans indexes. All other feature work is outside this package.

Contract: Finish the actual production path, not just data-model tests. No optional feature expansion.

Steps:

1. Execute the full acceptance round trip with existing input and eight-slot/full/cancel cases.
2. Run make check once after final runtime fixes; inspect warnings and exported Web. Test browser gameplay when available, stating actual coverage.
3. Capture bag, beer placement and return recovery. Mark spec implemented only after code/gates; keep developer art acceptance open.

Checks and evidence: Full make check, native bag/travel UI route and practical exported browser test. Record unsupported device checks honestly; review all logs, then commit.

Acceptance: Each AC has evidence or explicit remaining manual acceptance; next executor can resume from named commit without re-auditing everything.

## Copy/paste execution prompt

> Use Sol 5.6 Medium. Implement Plan 011 and Spec 012 from the current branch,
> beginning with the first unfinished package. This starts implementation of the
> specified scope. Read only its minimum context and previous handoff, complete
> one working package at a time, run its checks, commit it and record the next
> package. Continue sequentially until B7 unless I explicitly request one package
> only. Preserve identity, UI input isolation and session-only cross-zone records.
> Do not expand scope or mark browser/device/art acceptance without evidence.

## Handoff

Planning base `2a059ce`; implementation base `78e5485`; B1–B7 complete. Commits
`c371697`, `5497336`, `d1607c0` and `9b75d8a` deliver stable slots, Birra Dreamscape,
the pixel bag UI and cross-location world records/support validation respectively.
The full route preserves instance references, IDs and transforms, and an empty
initialized street does not respawn its seed. Final `make check` passed 902 checks
with zero failures and produced the Web release; evidence is in
`build/verification/bag/full-check.log`. Native captures are in the same bag
evidence directory. Developer art review and physical-device gameplay remain open.
