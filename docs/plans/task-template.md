# Execution plan and delegable task template

Write in English. Reserve a unique plan ID in the [index](README.md); use
`# Plan NNN — English title` for the copied document. Complete the fields; empty
placeholders are not settled requirements. Small tasks may be brief, while complex
ones need all relevant contracts.

## Plan header

- Observable objective and governing spec:
- Exact Game Bible/design references:
- Actual base commit and pre-existing local changes:
- Status and last review date:
- Settled decisions / unresolved Astra decisions:
- Single integrator:
- Non-goals:
- Dependency order and any authorized parallel waves:
- Shared files reserved for the integrator:

## Package `<ID> — <outcome>`

### Assignment

- Status: planned / ready / running / review / done / blocked.
- Preferred executor and verified capability:
- Actual task owner:
- Dependencies that must be delivered:
- Expected size / explicit budget, if one exists:

### Minimum context

1. Read `<path:section>` for `<contract>`.
2. Read `<path>` to reuse `<existing behavior>`.
3. Do not reread the whole repository. Identify missing inputs and their impact.

### Edit boundaries

| Allowed file | Allowed change | Owner |
| --- | --- | --- |
| `<path>` | `<responsibility>` | `<ID>` |

Do not touch: `<files / contracts / areas>`.
If a change outside the list becomes necessary, explain it to the integrator
before editing. Do not assume ownership of another agent's reserved files.

### Input/output contract

- Inputs: formats, dimensions, names, prior state and units.
- Outputs: exact paths, types, fields, signals, APIs or assets.
- Observable behavior: trigger → result.
- Errors/edge cases: state-preserving behavior or explicit failure.
- Invariants that must remain unchanged.

### Executable steps

1. Check preconditions with `<command/reading>`.
2. Implement `<localized action>` by reusing `<existing component>`.
3. Cover `<relevant cases>`; do not write tests that merely mirror implementation.
4. Run `<exact commands>` and inspect their output, not only exit codes.
5. Inspect `<capture/result>` at `<resolution/conditions>` for visual work.
6. Deliver the package below without unrelated edits.

### Acceptance criteria

- [ ] `<verifiable criterion with concrete test/evidence>`.
- [ ] `<regression behavior to preserve>`.
- [ ] `<limitation explicitly recorded>`.

### When to stop and request Astra

`<specific unresolved consequential decision; not merely "if problems arise">`.
Syntax/import errors and straightforward local corrections remain with the executor.
Follow [Spec 003](../specs/003-agent-workflow.md), preserving existing authorization.

### Executor delivery

```text
Task / package version / actual base commit:
Observable outcome:
Changed files:
Checks: command → actual result → log path:
Visual evidence:
Limitations / open decisions:
Changes outside package: none, or authorization details:
Elapsed time / retries / actual available cost:
Proposed status: review; not done before integration:
```

### Integrator review

- Inspect the diff and confirm file ownership.
- Verify every criterion against supplied evidence.
- Run affected integration checks; repeat only for a concrete reason.
- Resolve conflicts without discarding others' work.
- Create an atomic commit and record its SHA, result and next unblocked task.
- Update the spec/plan indexes and run the documentation check.
