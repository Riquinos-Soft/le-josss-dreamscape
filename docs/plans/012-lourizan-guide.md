# Plan 012 — Lourizán guide

Governing spec: [013](../specs/013-lourizan-guide-dialogue.md).
Status: done, 2026-10-06. Implementation authorized and completed.
Actual planning base: `2a059ce`; implementation base: `426b83c`.
Design references: developer's NPC/old RPG balloon brief, Spec 009 travel,
Spec 005 touch and the sourced dialogue in Spec 013. No external Bible page was
provided. Observable objective: walk up, talk, advance four paragraphs and leave.
Settled choices: Lucas Maconheiro, fictional stationary hippie forest-worker guide, explicit page advance, screen-clamped
balloon anchored overhead, no AI/quest/reward. No unresolved architecture decision.
Recommended order: this short feature before Plan 011; either can be launched
first. Do not require the bag to implement the NPC. N1 → N6 runs sequentially;
shared session/touch files belong to the sole integrator.

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

## N1 — Place a visible stationary guide

Status: done. Owner: the session executor/integrator.
Dependencies: developer starts this plan. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 013 R1 and local Pazo composition; current pixel character art conventions.
Allowed edits: game/npcs/lourizan_guide.gd and .tscn; game/assets/art/characters/lucas_maconheiro_*; game/world/locations/lourizan.tscn and preview if appropriate; minimal placement hook in lourizan_exterior.gd. All other feature work is outside this package.

Contract: Lucas Maconheiro with the hippie forest-worker costume defined in Spec 013, stable foot pivot and human-scale collider, on supported reachable ground. Keep the generator’s 1.2 scale accounted for exactly once.

Steps:

1. Create original Lucas Maconheiro art: field greens/earth tones, worn boots, long or tied-back hair, satchel and a handmade detail. A temporary human placeholder is allowed for grounding, but final character art is required before N5 acceptance.
2. Position near the candidate forecourt coordinate, project to ground and ensure it does not block the existing stair/exit route.
3. Give the node a clear ID/group for direct session lookup after travel; no navigation or NPC service.

Checks and evidence: Native arrival capture, Pazo traversal and location travel tests. Assert one guide after a return trip and inspect foot grounding; final art source metadata accompanies the asset.

Acceptance: A recognizably separate NPC is visible and reachable, with no duplicate spawn or blocked passage.

## N2 — Add a proximity talk prompt

Status: done. Owner: the session executor/integrator.
Dependencies: N1. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 013 R2/shared input; dreamscape.gd active location and touch_controls.gd action routing.
Allowed edits: game/npcs/lourizan_guide.gd; game/world/dreamscape.gd; game/player/touch_controls.gd; new game/tests/test_lourizan_dialogue.gd; Makefile. All other feature work is outside this package.

Contract: Expose guide can_talk(player) with 2 m range and line-of-sight excluding its own collider. Show E · Hablar and touch Hablar only for a valid nearby guide.

Steps:

1. Bind/unbind the active guide on successful travel.
2. Add reach/line-of-sight checks and a visible overhead marker; route E only outside placement and modals.
3. Until N3/N4 connect dialogue, make the request visibly acknowledge once in a temporary local test UI; remove that placeholder on integration.

Checks and evidence: Test reach, obstruction, placement E priority and guide cleanup on travel. Native approach screenshot; no permanent debugging UI in the final feature.

Acceptance: Talk is discoverable; its input does not pick up an item simultaneously. No prompts remain after departure.

## N3 — Implement the balloon and page state locally

Status: done. Owner: the session executor/integrator.
Dependencies: N1; N2 integrated before production wiring. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 013 R3–R5 and exact four paragraphs; travel_map UI patterns for handled input.
Allowed edits: game/dialogue/dialogue_bubble.gd and .tscn; game/dialogue/lourizan_history.gd or tiny data Resource; game/assets/art/ui/dialogue_*; game/tests/test_lourizan_dialogue.gd; optional test-only fixture. All other feature work is outside this package.

Contract: UI API open/advance/close with closed signal. Full paragraph appears at once; clamp anchor and reflow pages without losing text. Copy comes from the spec, source URL is developer metadata.

Steps:

1. Build original pixel panel/tail, speaker name, paragraph, Continue/Finish and close control.
2. Implement index/end/reset and fresh-press guards; use native GUI event handling for keys/clicks/taps.
3. Project head anchor and clamp; handle resized viewport and text overflow deterministically.

Checks and evidence: Fixture/native captures at 1280×720 and 844×390. Test open shows page zero, one press advances once, held input/emulated duplicate does not skip, final/early close and reopen reset.

Acceptance: All supplied text is legible and complete, above or pointing to the NPC; buttons stay in viewport.

## N4 — Connect conversation to session controls

Status: done. Owner: the session executor/integrator.
Dependencies: N2 and N3. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 013 R6/R7; player.set_input_locked; dreamscape map locks; touch input consumption; installed bag contracts if any.
Allowed edits: game/world/dreamscape.gd; game/npcs/lourizan_guide.gd; game/dialogue/dialogue_bubble.gd; game/player/touch_controls.gd; necessary item input gate; game/tests/test_lourizan_dialogue.gd and test_touch_controls.gd. All other feature work is outside this package.

Contract: One active modal; clear queued movement/item input, lock player, consume UI action, restore only this modal’s lock. No generic event bus/modal framework.

Steps:

1. Open bubble through the contextual talk action and prevent initial press from advancing.
2. Block map/bag/items while talking; if bag exists use its direct gate, otherwise add only the dialogue/map checks needed now.
3. Route touch to dialogue even when the touch movement handler would consume it.
4. Close safely on Escape, focus loss, respawn, missing NPC or location teardown; require fresh movement input.

Checks and evidence: Test actual dispatched mouse/key/touch events, right-button steering held on entry, queued pickup, E during placement, cancel and focus loss. Native full conversation.

Acceptance: Conversation works in the actual game; Joss stays still and no hidden pickup/travel action fires. Closing restores control reliably.

## N5 — Verify travel, replay and final art

Status: done. Owner: the session executor/integrator.
Dependencies: N4. Size: one focused working commit; no numeric budget assumed.

Minimum context: Spec 013 acceptance and existing travel tests; guide source notes.
Allowed edits: game/tests/test_lourizan_dialogue.gd; game/tests/test_location_travel.gd; focused NPC/UI placement/art fixes; docs/development.md. All other feature work is outside this package.

Contract: Repeated travel/replay cannot duplicate NPCs or signal handlers; historical text remains source-backed and exactly the intended sequence.

Steps:

1. Walk from arrival to the guide, read every paragraph with Continue/Finish, walk away and open map.
2. Visit Casa/street and return twice; restart dialogue and verify page one and one guide.
3. If bag is installed, test nearby beer pickup/talk priority and modal exclusion; otherwise record that cross-feature check belongs to the later integration.

Checks and evidence: Native screenshots first/last paragraph, landscape mobile-size layout and normal movement after closing. Run focused dialogue/travel/touch tests; check copy against source-linked spec.

Acceptance: No stale UI or lock across return trips; copy and art have concrete reviewable evidence.

## N6 — Validate Web and record completion

Status: done. Owner: the session executor/integrator.
Dependencies: N5. Size: one focused working commit; no numeric budget assumed.

Minimum context: All Spec 013 ACs and package evidence.
Allowed edits: relevant scoped fixes; Makefile/test registration; docs/development.md and specs/plans indexes. All other feature work is outside this package.

Contract: No scope expansion; distinguish implemented from developer-accepted.

Steps:

1. Run final make check including dialogue test; inspect import/shader/runtime warnings.
2. Open exported Web when practical and exercise talk/continue/finish; report browser/device unavailable coverage explicitly.
3. Commit working feature and record current SHA, checks, evidence and any remaining visual/device acceptance.

Checks and evidence: Full check, native dialogue route and practical browser test. No claimed physical mobile acceptance from emulation alone.

Acceptance: Feature can be picked up from a clean checkout and its evidence supports implementation status.

## Copy/paste execution prompt

> Use Sol 5.6 Medium. Implement Plan 012 and Spec 013 on the current branch,
> starting with the first unfinished package. This starts implementation of the
> specified NPC scope. Complete N1–N6 sequentially in working commits, inspect
> native screenshots, run each package’s checks and update handoff evidence.
> Use Lucas Maconheiro’s hippie forest-worker appearance and the four sourced
> Spanish paragraphs. Keep the balloon above the NPC,
> advance only on fresh input and preserve map/bag/item exclusion. Do not create
> NPC AI, quest systems or require the bag feature to start this plan.

## Handoff

Planning base `2a059ce`; implementation base `426b83c`; N1–N6 complete. Lucas is
composed only in Lourizán at local `Vector3(5, 0.2, 4.5)`, with original four-way
sprite art, 2 m range/line-of-sight talk checks, overhead paged dialogue and
desktop/touch input gating. Dialogue closes safely on focus loss, respawn and
location changes; returning creates one guide and restarts at page one.

Final evidence: `make check GODOT=/Applications/Godot.app/Contents/MacOS/Godot`
passed documentation, lint/import, 786 checks and Web export; log
`build/verification/lucas/full-check.log`. Native captured dialogue passed 34
checks; log `build/verification/lucas/dialogue-native-final.log` and screenshots
in the same directory. The pinned gdtoolkit deprecation remains. Browser and
physical mobile conversation checks, plus developer art/copy acceptance, remain
open and do not prevent the spec's implemented status. Plan 011 is now the next
prepared feature candidate.
