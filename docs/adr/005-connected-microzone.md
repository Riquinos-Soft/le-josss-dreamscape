# ADR 005 — One physical microzone with building cutaways

Status: accepted for the renewed connected-microzone priority on 2026-09-30. Physical placement of house interiors and the bar awaits real layout references. The earlier invented blockout remains rejected and is not shipped. The first implemented component is a reusable static stair flight, verified separately with the existing player.
## Decision

House, street, parking and bar occupy one Godot scene and physics space. House and bar are independent child scenes, composed from simple metre-scale geometry. Stairs use continuous inclined collision beneath visible steps, so the existing CharacterBody3D can climb without a new step-solving controller. Doors control physical passage locally.

The fixed elevated camera follows the existing player. Buildings hide roof and upper-storey visuals when the player is inside, plus tall wall visuals on the current floor; collision remains intact. Mouse steering projects onto the player's elevation. The existing item loop remains in the courtyard for now; its single-floor targeting must be adapted before enabling placement on microzone floors. Instance ownership remains unchanged.

## Alternatives and consequences

Separate interiors with transitions would require carrying player/item state across scene replacement and complicate the requested uninterrupted walk. Streaming adds lifecycle and visibility concerns with no demonstrated need at this size. Keep scene boundaries for later replacement/loading, but implement neither approach now.

Authored cutaways are local to these buildings, not a general camera-occlusion system. Floor placement supports flat surfaces only; stairs remain traversable rather than valid furniture supports. Runtime restart resets the session. Persistent housing, durable IDs, networking and larger worlds remain future decisions.
