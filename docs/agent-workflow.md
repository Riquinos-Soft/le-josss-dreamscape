# Agent workflow for Dreamscape

Adopted 2026-09-24 from the developer-supplied *Jev Engineering for Coding Agents*. This guide applies its context and continuity ideas to development of the game. Project scope and architecture remain governed by the active spec and accepted ADRs.

## Select context for the current question

The paper argues that reading, searching, and replaying information can dominate agent work (pp. 3-7). Treat that as a reason to make retrieval deliberate; its token percentages are illustrative or attributed to external work, not a Dreamscape benchmark.

Start with the request, `git status --short --branch`, the relevant spec section, and a targeted search. Read the implementation and its callers/tests as needed. Preserve an exact path or symbol so a finding can be retrieved without searching the whole repository again. Re-read when the underlying files change or a new question needs more detail.

Use existing documentation according to the task:

- Gameplay acceptance and current scope: [Spec 001](specs/001-vertical-slice.md).
- Scene composition, movement, and item boundaries: the relevant section of [architecture](architecture.md); read [ADR 003](adr/003-item-identity-and-world-representation.md) when changing identity or transfers.
- Godot setup, export, and browser verification: [development](development.md) and [ADR 001](adr/001-engine-and-web-baseline.md).
- Asset authoring and imports: [the asset workspace](../assets/README.md) and [ADR 002](adr/002-offline-asset-boundary.md).

For example, a placement regression starts with `game/items/item_loop.gd`, `game/tests/test_item_lifecycle.gd`, and the placement criteria. Follow references into player or geometry code when the failure requires it. Future housing and reconstruction notes need not accompany every item fix.

Use skill descriptions and tool search to select capabilities before loading their full instructions (pp. 8-9). This is a reading practice; repository Markdown cannot control the host's context assembly, KV cache, or compaction. Create local guidance only when a real recurring problem needs it, rather than adding an instruction file to every directory.

## Preserve recoverable state

The paper's explicit-state proposal motivates a small, durable record of decisions and evidence (pp. 5-9). Use the files we already have:

- The active spec owns scope, acceptance status, and the next unresolved step.
- `docs/development.md` owns reproducible commands, environment issues, and validation records.
- ADRs own consequential durable decisions; Git commits own the implementation history.
- Ignored `build/verification/` holds detailed local evidence when useful. These logs are not shared by a clean checkout, so commit a concise result and reproduction command in the relevant document.

Update current status when behavior changes. Label old records as historical or superseded so an earlier failure or control description cannot be mistaken for current behavior. Distinguish implemented, automatically checked, manually accepted, and still pending.

For a substantial handoff or interrupted task, add a short checkpoint to the relevant spec or development section:

```text
Goal / acceptance criterion:
Relevant paths and commit (or uncommitted changes):
Completed work / decisions:
Checks: command, result, evidence path, environment and limitations:
Unresolved issue / next action:
```

Record observable facts and decisions. Before resuming, compare the checkpoint with Git and the current files, then continue at the unresolved step. Do not repeat completed work solely because the session changed.

## Judge delegation by total work

The routing example includes the cost of loading context and reviewing returned output, not just a model's unit price (pp. 3-4, 7-8). Its prices and cost totals are illustrative; they do not establish a preferred model or savings for this project.

Keep routine work on the session's normal model as required by `AGENTS.md`. When delegation is explicitly requested, provide the goal, relevant paths, constraints, expected evidence, and ownership of writes. Request findings with file references, a bounded diff, and test results instead of a transcript. Check completed and in-progress work before starting another task. Share already located evidence with reviewers; avoid having each reviewer rediscover the repository or edit the same files.

Data sensitivity also matters (pp. 9-10). The study's provider categories are examples, not a trust assessment. Use the session's approved tools and permissions; do not send repository data or credentials to a new service merely because its model is cheaper. Inspect unfamiliar script contents and their side effects before execution (p. 6).

## Keep feedback concrete

Use the existing `Makefile` and CI for deterministic checks. For gameplay changes, run the relevant automated tests, a native run when practical, and Web export. `make check GODOT='/Applications/Godot.app/Contents/MacOS/Godot'` runs lint, import, tests, and export once the documented dependencies are installed. A documentation-only change needs diff/link review, not a new gameplay test cycle.

Read the output as well as the exit status: Godot has previously returned zero despite a script startup error. Preserve relevant warnings and failed attempts with their resolution or limitation. A successful export or native test does not certify Chrome/Safari gameplay; record that acceptance separately.

For a bug, add a focused regression check that exercises the failure when practical. For example, movement during placement must leave the real item in inventory and maintain a single preview. The existing lifecycle test covers that behavior. Avoid tests that merely restate implementation details.

The paper proposes shared retrieval for background review and explanations (pp. 10-11). Here, reuse the same relevant diff, source paths, and test evidence when a review is requested. Additional review services, dashboards, or perpetual background agents would need a demonstrated project need.

## Ideas retained for reference

The paper describes a Jev decision model, typed context chunks, dynamic cache selection, tool routing, programmable permissions, and concurrent agents. Those are proposals for building an agent harness. This adaptation adds development guidance; it does not integrate Jev or implement those systems in Dreamscape.

Its tool shortlist (p. 11) includes headroom, rtk, ast-grep, ast-outline, fastcontext, and fff. Evaluate a tool only against a recurring measured problem, its GDScript suitability, setup cost, and whether it preserves diagnostics. Current repository search, Git, Godot tests, and CI remain sufficient for the adopted workflow.

## Source and limits

*Jev Engineering for Coding Agents: The TypeSafe Founder's Blueprint for Building with Jev*, September 2026, 12 pages. The cover and source note describe an independently compiled study based on design notes attributed to Diogo Almeida, with no TypeSafe affiliation or endorsement; the compiler is not named. Page references above refer to PDF pages 1-12.

Developer-supplied local source: `~/Documents/Jev-Engineering-for-Coding-Agents.pdf`. SHA-256: `7d77a5f479040d72e871f7570fb59000d8e2899fa5180a54d58a3f1917b6d029`. The original remains outside the repository; this guide captures the project-specific adaptation with attribution.

All 12 pages were read; diagrams on pages 1, 4, and 9 were also inspected visually. The cited pricing, token estimates, external benchmark claims, and tool capabilities were not independently verified. They are not performance promises, current vendor documentation, or instructions overriding the developer's scope and tool permissions.
