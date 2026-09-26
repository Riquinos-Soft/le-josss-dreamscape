# Specification index and authoring rules

This index assigns spec IDs. The Game Bible defines product/art direction,
accepted ADRs define durable technical decisions, and each spec defines a bounded
deliverable. Plans describe execution; the [roadmap](../roadmap.md) proposes order.
None of these documents silently authorizes unrelated work.

## Registry

| ID | Specification | Status | Remaining acceptance |
| --- | --- | --- | --- |
| 001 | [Vertical slice](001-vertical-slice.md) | implemented | Full browser item-loop, art and sustained performance review |
| 002 | [Scanned street and pixel art](002-street-trial.md) | implemented | Developer art review, full browser/mobile gameplay |
| 003 | [Astra and economical-agent workflow](003-agent-workflow.md) | implemented | Protocol documented; Grok automation is not connected |
| 004 | [Landscape mobile controls](004-mobile-touch.md) | implemented | Physical Android/iOS checks; layout refined by 005 |
| 005 | [Touch placement and pixel comparison](005-beta-controls-and-pixels.md) | implemented | Physical devices and developer art review |
| 006 | [Branded boot splash](006-boot-branding.md) | implemented | Manual visual acceptance |
| 007 | [OVH hosting preparation](007-vps-hosting.md) | implemented | Operational checks tracked separately; no multiplayer runtime |

Next available spec ID: **008**. Recompute from this registry before reserving;
this line is not a standing reservation for an agent or a feature.

## Language and file naming

- Write every spec in **English**: title, metadata, scope, requirements,
  acceptance criteria, validation and open questions. Translate incoming Spanish
  requests faithfully without changing the product decision.
- Keep literal product labels, proper names and quoted source text in their
  original language when necessary, with an English explanation. User-facing
  game text and conversational replies need not become English.
- Use `NNN-short-english-kebab-case.md` and title `# Spec NNN — English title`.
  IDs are unique in this directory, stable and never reused, including retired
  specs. Numbers identify documents; they do not imply delivery priority.
- Before creating a spec, read the index and relevant existing spec. Extend an
  existing spec for another iteration of the same feature. Create a new one for
  a distinct bounded deliverable with its own acceptance criteria.
- Reserve the next number in this index in the same change that adds the file.
  One integrator assigns IDs during concurrent work. Check newly merged index
  changes before committing; resolve a reservation collision before publication.
- Plans and ADRs have independent number spaces. Their IDs need not match spec
  IDs; use explicit links. Never infer a relationship from equal numbers.

## Required content for new or substantially revised specs

Start with [the template](template.md). Include:

1. Title/ID, `Status`, `Updated` date (`YYYY-MM-DD`) and `Language: en`.
2. Objective: concrete player/developer outcome and reason.
3. Scope and non-goals: affected behavior and explicit exclusions.
4. Requirements: observable triggers/results, invariants and edge cases.
5. Numbered acceptance criteria (`AC1`, `AC2`, ...), each with a verification method.
6. Validation: actual commands, environments, results, evidence and limitations.
7. Open questions: unresolved choices, owner and whether they block implementation.
8. References: relevant Bible page, ADRs, other specs and execution plan.

Do not invent budgets, providers, approvals or implementation details that have
not been decided. Escalate only under [Spec 003](003-agent-workflow.md).
Existing historical evidence may keep its original section structure; the
current status must appear first and clearly supersede obsolete observations.

## Lifecycle and evidence

`draft → approved → in-progress → implemented → accepted`, or `superseded`.

- **draft:** proposal; open decisions or authorization remain.
- **approved:** scope authorized by the developer; record that source.
- **in-progress:** authorized implementation underway.
- **implemented:** code/deliverable exists; list checks passed and any acceptance
  still pending. Never use this as a synonym for user acceptance.
- **accepted:** all agreed criteria have evidence, including required developer
  review. Name the acceptance source/date; do not infer it from silence.
- **superseded:** retained with a link to its replacement and a migration note.

Task states such as `ready`, `review` and `done` belong to plans. A completed task
does not automatically complete a spec. Partial supersession must name the exact
clauses replaced. Record manual, automated, native, browser-emulated and physical
device checks distinctly; HTTP/export success is not gameplay acceptance.

## Review and checks

Update incoming/outgoing links, the registry and relevant roadmap status together.
Run `python tools/check_docs.py` from the repository root (Windows local venv:
`.venv/Scripts/python.exe tools/check_docs.py`). The check verifies IDs, titles,
metadata, registry coverage and relative Markdown links. CI runs it too.
English prose and faithful translation require human/agent review; a metadata
declaration is not automatic language detection. Documentation-only edits do not
require replaying gameplay tests.

## One-time normalization — 2026-09-26

Duplicate spec 003 for boot branding became **006**; duplicate spec 002 for VPS
hosting became **007**. Street 002 and workflow 003 retain their established IDs.
The duplicate Joss/art plan 004 became plan **008**. Old filenames are discoverable
in Git history; active links now use the canonical names. This repair is not a
policy of routinely renumbering documents. The three Spanish specs were translated
to English without marking their pending acceptance complete.
