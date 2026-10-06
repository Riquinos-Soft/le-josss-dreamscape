# Spec 012 — Eight-slot bag and travelling objects

Status: draft
Updated: 2026-10-06
Language: en

Authorization: developer requested specifications and stepwise plans for both the
bag and NPC on 2026-10-06. This delivery is planning only; start implementation
when the developer launches its execution plan. Draft indicates unimplemented
planning, not missing product requirements. Acceptance: no gameplay changes yet.

## Objective

Pick up the street beer into a visible eight-slot bag, carry it to Casa or
Lourizán, place it on valid ground, leave and return to find the same object.

## Current baseline and governing contracts

At `2a059ce`, `inventory.gd` has one item; `ItemLoop` tracks one world node.
`street_item_loop.gd` assumes one supporting floor body and a fixed block size.
`dreamscape.gd` disables item actions outside the street, dereferences a possibly
null `world_item`, and frees outgoing non-street scenes. Carrying a data reference
alone cannot preserve placed objects through those unloads.
Preserve [ADR 003](../adr/003-item-identity-and-world-representation.md): one
instance, one committed owner, and previews never own or duplicate items.
The one-slot scope of Spec 001 is extended here; its identity rules still apply.

## Requirements

- R1 — Exactly eight stable slots, one instance per slot, no stacking. Pickup
  uses the first empty slot; removing an item leaves that slot empty. Reject
  null/duplicate instances and reject a ninth item without changing the world.
  Show `Bolsa llena` on rejection. There is no weight, equipment or item sorting.
- R2 — Pickup by E or the existing touch action immediately stores the object
  and removes its world representation. Show a brief `Guardado en la bolsa` hint.
  Do not open the bag or start a placement preview automatically.
- R3 — An original pixel backpack icon on the right opens/closes the bag by click
  or tap; B is a keyboard shortcut. Display a 4-column × 2-row grid, all eight
  slots visible, muted fabric/leather background, pixel borders, occupied-slot
  icon and accessible item name. Occupancy `n/8` is visible. Keep it clear of map
  guidance and touch action buttons; respect viewport margins and safe areas.
- R4 — Opening the bag pauses player input, clears held touch/mouse movement and
  consumes UI events. World simulation need not pause. Escape or the close button
  closes it. Keyboard focus can move across slots and Enter selects one. Touch
  targets are at least 48 logical pixels and the grid fits landscape mobile.
- R5 — Clicking/tapping an occupied slot selects that exact instance, closes the
  bag and enters existing aim/rotate/confirm placement. Empty slots do nothing.
  P opens the bag to select an object; it must not select an arbitrary item.
  Q/E rotate in 90-degree steps; existing touch rotate/confirm/cancel stays usable.
  The event that selects a slot must never also confirm placement: release it,
  then require a fresh confirm press. Cancelling retains the same item and slot.
- R6 — The selected item remains committed to its slot during preview. Only a
  successful final validation transfers it to the world. Full overlap, walls,
  player/NPC collision, unsupported ledges, excessive slope, out-of-reach targets
  and blocked line of sight reject placement without losing the item. Reuse the
  2 m reach, normal.y >= 0.9 and 0.12 m support-height tolerance initially.
  Use definition dimensions and all footprint corners; do not hardcode y=0.25.
  Place on eligible floor/terrain, including the Pazo terrace, in all three zones.
  'Anywhere' means reachable supported free ground, not walls or empty space.
- R7 — The bag and item controller belong to the live session. The street may
  remain the host node for compatibility, but its inactive scenery must not
  disable bag/item behavior. World records belong to a location ID. On leaving,
  retain `{item: ItemInstance, transform: Transform3D}` in session memory; unload
  only representations. Restore the same references/IDs/poses on return.
  Keep an initialized-location set, so an empty visited location does not respawn
  its initial object. Session-local IDs are monotonically allocated, never reused.
- R8 — Travel is transactional: cancel preview safely before opening the map;
  close bag and clear pending item inputs. Do not commit outgoing records or
  consume anything until the destination and safe arrival are verified. Failed
  travel retains the source world and all item ownership. Queries/placement must
  use only the active location's eligible support bodies; inactive colliders and
  temporary destination nodes must not supply false support. Restore controls
  correctly after travel cancellation, failure, respawn or application focus loss.
- R9 — Replace the initial purple street block with `Birra Dreamscape`: a small
  original amber beer bottle with cream/teal label and cap, plus matching slot
  icon. Suggested collision size is 0.12 × 0.30 × 0.12 m; tune readability with
  label contrast and proximity highlight, not a huge collider. Its definition
  owns type ID, display name, dimensions and visuals. Preview uses the same
  silhouette with valid/invalid feedback. Keep the block as a regression fixture
  if useful. Do not add drinking, intoxication, consumption or branded packaging.

## Minimal implementation contract

Extend `Inventory` with `CAPACITY = 8`, `get_item(index)`, `first_free_slot()`,
`put(item) -> bool`, `take_at(index, expected) -> ItemInstance` and `changed`.
Do not expose a mutable slots array. Migrate all old `.item` callers/tests rather
than keeping a misleading single-item API indefinitely.

Extend the existing item loop to a list of world representations and a selected
slot/reference. Nearest reachable candidate wins; tie-break on session ID. Keep
session records and a small ID allocator here (or a focused adjacent RefCounted
file); no singleton service or persistence infrastructure. Bind player, camera,
active location root and support bodies explicitly. ItemInstance never owns a Node.
Support queries must distinguish floor/terrain from furniture and NPCs: placement
cannot use a beer, statue or NPC as its supporting surface. An active world node is the committed owner; staged snapshots are non-owning
references until a successful travel swap. Store world transforms and restore via
`global_transform` after parenting, so location scale is not applied twice.
Keep final overlap
checks against terrain sides, other items, player and NPC; ignore only the actual
support contact bodies when justified by the existing validator.

Use a small bag Control/CanvasLayer at `game/inventory/bag_ui.tscn` with a paired
script and original art under `game/assets/art/ui/` and `game/assets/art/items/`.
Reuse the pixel presentation; do not set a new global rendering resolution.

## Shared input contract with Spec 013

Only one of travel map, bag or conversation may be open. Opening another is
blocked while a modal is active; Escape closes the current modal. Placement is a
separate active action: map opening cancels it, bag opening cancels it and opens
slots, dialogue cannot start until it is cancelled. Use focused predicates in
`dreamscape.gd`, not a new modal framework. Every consumed UI event is marked
handled; clear queued gameplay commands on entering/leaving a modal.
Outside modals, NPC talk has priority over pickup if both are in reach; during
placement E exclusively rotates. A contextual prompt must name the action.

## Non-goals

No persistence across reload/restart, stack counts, drag/drop rearrangement,
containers, equipment, crafting, database, multiplayer or unlimited world manager.
Placed objects survive travel only within the current running session.

## Acceptance criteria

- AC1: Eight distinct instances fill eight slots; ninth pickup stays on the ground.
  Repeated pickup/confirm input cannot duplicate IDs or lose references.
- AC2: Pickup shows the beer in the bag with no preview. Slot selection starts
  preview; cancel/invalid placement retain its original slot. UI click-through
  cannot place, move Joss or accidentally open travel.
- AC3: Pick up in street → travel to Pazo → place → visit Casa → return to Pazo
  → pick up → return to street. Preserve reference, ID and final transform;
  empty source remains empty. Repeat with multiple items in different zones.
- AC4: Validate Pazo ground and terrace, home slope/edge and street collision;
  block overlaps, unsupported placement and placement through walls. A failed
  destination load/arrival leaves bag/world unchanged, including when world is empty.
- AC5: Bag, map and dialogue exclusion works for keyboard, mouse and simulated
  touch. Inspect bag at 1280×720 and 844×390, plus production walking/placement.
- AC6: Relevant regressions and Web export pass; separately record native,
  browser and physical mobile acceptance and any unavailable checks.

## Validation and open questions

Planning only: run documentation validation now. Runtime validation belongs to
[Plan 011](../plans/011-eight-slot-bag.md). No blocking product question; physical
bag skin/beer art remains subject to developer visual review. Any durable save
or generalized inventory request is a new decision, outside this plan.

## References

[Spec 009](009-lourizan-and-map-travel.md), [Spec 005](005-beta-controls-and-pixels.md),
[agent workflow](003-agent-workflow.md), and the repository
[material-world vision](../../README.md#material-world-and-home). The project Game Bible is an external
Notion authority; no exact page content was supplied in this planning turn.
The developer's explicit brief and the accepted ADR are the operative references.
