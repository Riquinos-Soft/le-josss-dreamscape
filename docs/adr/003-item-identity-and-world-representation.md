# ADR 003 — Preserve item identity across world and inventory

Status: accepted; minimal single-item implementation completed after developer-reported Chrome/Safari baseline acceptance and explicit gameplay approval.

## Context

The product requires materially interactive objects that can be picked up and returned to the world. Future housing and selected dream/reality transitions may reuse those objects. The earlier count-only inventory proposal discards the distinction between a kind of item and an actual object.

## Decision

Separate shared item definitions from runtime item instances. World representations and inventory hold/reference the same instance as it changes context. Picking up or placing an object preserves its instance ID and state; a new world node does not mean a new item. Exactly one committed location owns the item at a time. Placement previews do not duplicate it, and cancelled/failed transfers leave its committed state unchanged.

For Spec 001, use one non-stackable instance with a session-local ID and definition reference, one inventory slot, and one simple world representation. Pose belongs to the world representation. This does not require an entity framework, persistence schema, durable ID generator, repository layer, or networking abstraction.

## Alternatives and consequences

Type counters are smaller but lose per-object identity and make return-to-world state a later redesign. Keeping live scene nodes in inventory couples item lifetime to scene structure. The chosen boundary adds a small data object and explicit transfer rules while allowing a world representation to be recreated without replacing the item itself.

Identity/transfer invariants require tests, including cancellation and repeated input. Stacks, ownership, containers, saves, housing, provenance, reality transitions, and multiplayer remain deferred; none are implemented merely to make this boundary extensible. Revisit durable identity and location storage when an actual persistence or transition feature demands them.

## First implementation

One constant-data `RefCounted` definition, one `RefCounted` instance (session ID and definition only), one-slot `RefCounted` inventory, and a procedural static `WorldItem`. The courtyard-local `ItemLoop` coordinates synchronous transfers. The preview is only a mesh: it has neither an instance reference nor collision. Tests compare object reference, ID, and definition through three cycles and failed/cancelled operations. The session owns a single authored ID; introducing more items would require local ID allocation, not a persistence service.
