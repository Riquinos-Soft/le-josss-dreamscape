# Spec 003 — Astra escalation and economical-agent workflow

Status: implemented
Updated: 2026-10-18
Language: en

Acceptance: the requested protocol is documented, including the 2026-10-18
model-selection and recovery policy. No automatic model switching is implemented.

## Objective and scope

Use Sol 6.1 Medium for ordinary implementation and integration. Use available
Luna Low/Medium for small fully specified work, Sol 6.1 High for difficult
reasoning/debugging, and Astra Medium/High for especially critical architecture,
security, distributed systems, deep audits or problems Sol cannot resolve. Reduce
total cost, including retries and recovery; quality and security remain required.

This protocol adds no orchestrator, backend, agent framework or game dependency.
It does not change the engine or accepted repository architecture. The Notion
Game Bible remains the design/art authority. A feature spec defines scope and
acceptance; a plan in `docs/plans/` breaks implementation into tasks. Do not create
a spec for every subtask or treat a proposal as approved.

## Requirements

### Model selection before a new task

The distribution and exact Spanish notification format in [AGENTS.md](../../AGENTS.md)
are authoritative. Check the selected model through Orca when exposed, or use the
developer's confirmation. Never invent the selected model/effort or switch it.
Before affected work, recommend an available substantially cheaper sufficient
model or a necessary stronger model, then stop until the developer switches or
explicitly authorizes the current model. Do not repeat an approved task notice.
Ask about an unknown model only when needed; avoid blocking minor work needlessly.

Resolve shared-contract decisions before implementing their consequences, using
the least expensive sufficient model. Ordinary integration, routine refactoring,
known tests and settled contracts do not automatically require Astra. Escalate
first to Sol 6.1 High for difficult work when sufficient; reserve Astra for the
critical cases above. A long task alone is not an escalation criterion.

A focused escalation records the stopped step, evidence, viable alternatives,
recommendation and the risk of proceeding. Close the decision in the relevant
contract and continue bounded execution without repeated approval.

### Roles and ownership

| Role | Responsibility | Boundaries |
| --- | --- | --- |
| Stronger-model planner/reviewer, when justified | Resolve consequential decisions, contracts and risks | Do not reopen settled ADRs without evidence or take over routine execution |
| Sol 6.1 Medium / available economical executor | Implement a bounded package, verify it and provide evidence | Do not change shared contracts, expand scope or mark developer art acceptance complete |
| Single integrator | Reserve files, inspect results, run integration checks and commit | Do not accept unverified summaries or automatically push |
| Developer | Product direction, art acceptance and requested decisions | Do not request confirmation again for already authorized reversible work |

Availability is not assumed. No subagent work is authorized by this policy.
Do not install providers, spend credits or claim parallel work without the
required authorization and verified capability.

### Recovery checkpoint

Maintain `.codex/SESSION_HANDOFF.md` after meaningful phases with the active goal,
modified paths, completed and pending work, actual checks and next concrete step.
Keep it local and excluded from automatic commits; never put secrets there.
Recovery checks branch/status/recent commits/diffs before editing, preserves all
existing work and reports any specific missing fact rather than inventing it.

### Task lifecycle

`planned → ready → running → review → done`, or `blocked` with a reason and next step.

1. Read only relevant specs, Bible pages and files. Record the actual base commit
   and pre-existing changes; exclude unrelated edits from the delivery.
2. Resolve open decisions before marking a package ready.
3. Use the [task template](../plans/task-template.md): inputs, allowed files,
   steps, contracts, checks and exclusions.
4. Assign one owner per task and reserve files before writing.
5. Implement, inspect and fix local failures. Save useful logs, not entire
   sessions or secrets.
6. Deliver the diff, actual test results, visual evidence and limitations.
7. The integrator reviews, runs relevant integration checks and makes one local
   commit per working unit. Only then mark implementation done.
8. Update the plan and documentation. Do not rerun gameplay suites after text-only
   changes or reinvestigate unchanged decisions.

### Parallel work without overlapping edits

- Do not start tasks with unresolved dependencies merely because agents are free.
- Two writers must not share a file. Composition files, test lists, specs and
  status records belong to the integrator.
- Read/review work may run concurrently; writes require disjoint ownership.
- Work on the current branch. Do not create branches/worktrees or change the Git
  workflow without explicit instruction. Integrate shared-workspace edits serially.
- Only the integrator commits during a parallel wave, preventing accidental
  inclusion of another agent's edits. A single executor follows normal automatic
  atomic-commit rules.
- A changed user requirement invalidates affected packages first; notify owners
  and revise versions/dependencies before continuing.
- If exclusive ownership cannot be guaranteed, serialize. More agents do not
  necessarily reduce cost or elapsed time.

### Cost and context

- Divide packages by independently reviewable outcomes, not arbitrary line counts.
- Provide a sufficient reading list and contracts, not the entire conversation or
  a request to audit the whole repository for each task.
- Do not implement the same task with two models merely to compare them.
- After two targeted failed attempts, summarize evidence and revisit the diagnosis.
  Recommend a stronger model only when justified; repeated local errors
  do not authorize migration or automatic escalation.
- Record elapsed time, retries and actual tokens/cost when available. Otherwise
  write `unavailable`; do not present estimated savings as facts.
- Use only numerical budgets agreed with the developer. This protocol authorizes
  neither unlimited spending nor invented quotas.

## Non-goals

No gameplay change, provider setup, automatic agent connection, pull request or
publication follows merely from implementing this protocol.

## Acceptance criteria

- A concrete plan records dependencies and copyable bounded packages.
- Each package specifies output, file ownership and verification without guessing.
- Model changes pause work with evidence and the required notification.
- Shared files and integration commits have one responsible integrator.
- Documentation readiness is distinct from connected automation.

## Validation

The protocol and task template exist and were reviewed for the requested workflow.
Automatic model switching, global Orca instructions and cost savings are not claimed.
