# Agent working guidelines

## Working style

- Use lightweight spec-driven development.
- Before changing code, read only files relevant to the task and applicable specs or ADRs.
- Do not repeatedly revisit settled architectural decisions.
- Avoid external research unless it is genuinely necessary.
- Prefer implementation over lengthy explanation when requirements are decided.
- Keep final reports concise: mention only meaningful changes, tests, warnings, and next steps.

## Scope discipline

- Implement only the requested feature.
- Do not build speculative systems for future requirements.
- Do not add multiplayer, persistence, backend infrastructure, ECS, service locators, generalized event buses, or large abstractions unless an approved spec or ADR explicitly requires them.
- Prefer the smallest architecture that preserves the documented long-term direction.
- Create ADRs only for consequential architectural decisions.

## Godot baseline

- Use Godot 4.7.2 standard edition, GDScript, and the Compatibility renderer.
- Treat Web as a first-class target.
- Use 1 Godot unit = 1 meter.
- Keep eventual mobile compatibility and Web performance in mind.
- Prefer simple scene composition and small, focused scripts.

## Validation

For gameplay or runtime changes:

- Run relevant automated tests.
- Run the project natively when practical.
- Verify Web export still succeeds when runtime behavior is affected.
- Do not claim manual Chrome or Safari validation unless the developer actually performed it or it was successfully executed.
- Never hide warnings or errors to report a clean result.

## Git workflow

- Work directly on the current branch unless explicitly instructed otherwise.
- Create an atomic commit automatically after each coherent, working unit of change.
- Each commit must represent one logical change, include relevant tests when applicable, leave the project working, and use a concise conventional-style message, such as `feat: add mouse steering`, `fix: preserve movement during placement`, `test: cover item round trips`, or `docs: update prototype controls`.
- Do not commit partially working states or combine unrelated changes.
- Do not create pull requests unless explicitly requested.
- Do not force-push, rewrite history, or perform destructive Git operations unless explicitly requested.
- Do not push automatically. Keep commits local until the developer explicitly requests a push.

## Model and token efficiency

- Follow `docs/specs/003-agent-workflow.md` for escalation, low-cost execution, file ownership, and integration. Prepare delegable plans with `docs/plans/task-template.md` before multi-agent implementation. Prefer Grok for bounded execution when available and authorized; never claim it is connected or selected without checking.
- Request Astra before implementing unresolved consequential decisions described in that protocol. Continue routine work under already settled contracts without repeated confirmation. During parallel work, only the assigned integrator commits shared-workspace results; this refines the automatic commit rule without authorizing branches, pushes, or unrelated edits.

- Treat expensive, high-reasoning models as an architectural resource, not the default implementation engine.
- Use the session's normal, efficient implementation model for routine implementation, tests, local refactors, documentation, and straightforward fixes.
- Do not request or recommend a higher-reasoning model for routine work.
- If work reaches a genuinely consequential architectural decision, difficult cross-system debugging, major performance investigation, or ambiguity likely to cause expensive rework, stop before implementing that part and briefly recommend switching to a higher-reasoning model such as Astra Medium. Do not repeat the recommendation or assume agents can change Orca's selected model.
- Inspect only relevant repository areas. Prefer targeted searches, do not summarize unchanged files or repeat established context, and do not reopen every spec or ADR without cause.
- Stop when the requested scope is complete.

## Project philosophy

Respect the existing product vision and accepted ADRs:

- Prefer richer world interaction over excessive graphical fidelity.
- Keep item identity independent from its current visual scene representation.
- Do not let future dreams, alternate realities, housing, or persistence cause premature implementation of those systems.
