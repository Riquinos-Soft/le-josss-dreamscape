# Spec 018 — Residents and Lucas beer errand

Status: implemented
Updated: 2026-10-13
Language: en

Authorization: developer requested matching resident proportions, better Lucas
walking, Alba renamed Narci, more NPC activity/smoking, and confirmed the proposed
20-coin beer delivery on 2026-10-13. Previous work pushed first as requested.
Acceptance: implemented; native delivery/art inspection and Web export complete.
Developer mobile/art acceptance remains pending.

## Objective

Make residents visually coherent with Joss, improve Lucas's gait and give travel
to Jacobo Risa a small optional purpose.

## Scope

Replace current resident and Lucas art in place, retain provenance, rename Alba
through scene/resources, improve Lucas patrol cadence and smoking pauses. Add one
session-only errand using the existing inventory and dialogue interaction.

## Non-goals

No persistence, shops, generalized quest framework, economy backend or character
customization system. No changes to world routes or item spawning.

## Requirements

- R1 — Residents use Joss's compact body and large head proportions. Lucas has
  four distinct grounded walking frames per direction and matching idle identity.
- R2 — Narci replaces Alba. Lucas moves on his existing safe route and emits
  visible cigarette smoke during pauses, stopping the effect while walking.
- R3 — First Lucas conversation requests the Birra Dreamscape from Jacobo Risa.
  A later conversation transfers the actual bag item and credits 20 coins once.
  Subsequent conversations retain his existing randomized dialogue collection.
- R4 — Money and mission state survive map travel within the running session.
  Show the balance and objective in the bag. Reloading starts a new session.
  No reward if the item is absent; no repeated payout after completion.

## Acceptance criteria

- AC1 — Inspect normalized sprites and native NPC presentation.
- AC2 — Inspect delivery code for expected-instance inventory transfer, one-time
  reward and travel lifetime; import and Web export must succeed.
- AC3 — Verify rename references and docs. Developer mobile review stays open.

## Validation

Godot 4.7.2 native scene inspection at 844x390 and 1280x720 covered the offer,
actual street item pickup, map travel, delivery and repeat conversation. The bag
changed from one item to zero, balance became 20 and remained 20 on repeat.
Native captures cover Lucas, Narci and the reward bag. Import, GDScript lint,
format and Web export succeeded. Existing gdtoolkit deprecation warning remains.
No new automated tests or full gameplay suite were run; prior dialogue assertions
were updated for four frames and randomized dialogue after the initial offer.
Evidence: `build/verification/residents-errand/`. Developer mobile review pending.
Published as `b9a3ede`; CI/deployment run `38328916165` completed successfully.
Next: developer review of the complete beer route and new art per
[the roadmap](../roadmap.md).

## Open questions

None for the confirmed bounded errand.

## References

- [Inventory](012-eight-slot-bag.md)
- [Character presentation](015-retro-character-clarity.md)
- [Residents and salon](016-lourizan-galleries-and-salon.md)
