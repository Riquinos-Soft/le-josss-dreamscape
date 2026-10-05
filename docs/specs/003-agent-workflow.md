# Spec 003 — Astra escalation and economical-agent workflow

Status: implemented
Updated: 2026-09-26
Language: en

Acceptance: the requested protocol is documented. Automatic Grok execution is
not connected or validated in this session; documentation is not automation.

## Objective and scope

Reserve Astra for decisions with substantial rework risk and hand bounded tasks
to Grok or another available economical model. Reduce total cost, including
retries and review, rather than optimizing the cost of a single call.

This protocol adds no orchestrator, backend, agent framework or game dependency.
It does not change the engine or accepted repository architecture. The Notion
Game Bible remains the design/art authority. A feature spec defines scope and
acceptance; a plan in `docs/plans/` breaks implementation into tasks. Do not create
a spec for every subtask or treat a proposal as approved.

## Requirements

### When to request Astra

Stop before implementing the affected part when resolving:

- Changes to architecture, shared contracts or an accepted ADR.
- A cross-project visual standard: final logical resolution, units, shared
  camera, master animation format or asset pipeline.
- Conflicts between the Bible, a spec and code likely to require migration or
  rebuilding multiple assets/systems.
- Demonstrated cross-system failures, or measured optimizations that compromise
  design or Web compatibility.
- Scope expansion or costly-to-reverse alternatives not settled in the task.

Routine renaming, imports, syntax errors, locally understood test failures,
documentation and implementation of settled contracts do not require Astra.
A long task is not automatically an architectural decision.

Use a brief escalation report:

```text
Decision requiring Astra:
Stopped task/step:
Evidence: failure, measurements, requirements, files and lines:
Options A/B, consequences and recommendation:
Risk of proceeding without resolution:
Independent work that can continue:
```

Ask the developer to switch only when Astra is not already active or authorized
for that decision. Do not repeat the request or pretend to change the selected
model. Review must close the decision, update the contract and return routine
execution to the executor.

### Roles and ownership

| Role | Responsibility | Boundaries |
| --- | --- | --- |
| Astra planner/reviewer, when needed | Resolve consequential decisions, contracts and risks | Do not reopen settled ADRs without evidence or take over routine execution |
| Grok/economical executor | Implement a bounded package, verify it and provide evidence | Do not change shared contracts, expand scope or mark developer art acceptance complete |
| Single integrator | Reserve files, inspect results, run integration checks and commit | Do not accept unverified summaries or automatically push |
| Developer | Product direction, art acceptance and requested decisions | Do not request confirmation again for already authorized reversible work |

Grok is a preference, not an assumed capability. Check available agents/models
before assigning work. If unavailable, prepare a package for an external session
or use the already authorized executor. Do not install providers, spend credits,
invent prices or claim parallel work that did not happen.

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
  Request Astra only when an escalation criterion applies; repeated local errors
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
- Astra blockers include evidence and a clearly stated decision.
- Shared files and integration commits have one responsible integrator.
- Documentation readiness is distinct from connected automation.

## Validation

The protocol and task template exist and were reviewed for the requested workflow.
Grok connectivity, model selection and cost savings are not claimed.
