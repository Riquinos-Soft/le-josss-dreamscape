# Execution plan index

Plans decompose a spec into reviewable work; they do not approve new scope.
Use the [task template](task-template.md) for new plans and write new/reworked
plans in English. Historical Spanish execution records remain as evidence;
the English-only specification rule applies to every document in `docs/specs/`.

| ID | Plan | Governing spec |
| --- | --- | --- |
| 004 | [Mobile touch](004-mobile-touch.md) | [004](../specs/004-mobile-touch.md) |
| 005 | [Touch/pixel beta](005-beta-controls-and-pixels.md) | [005](../specs/005-beta-controls-and-pixels.md) |
| 006 | [Contextual actions](006-contextual-actions.md) | [005](../specs/005-beta-controls-and-pixels.md) |
| 007 | [Video-guided street decor](007-street-video-decor.md) | [002](../specs/002-street-trial.md) |
| 008 | [Joss animation and street art](008-joss-animation-and-street-art.md) | [002](../specs/002-street-trial.md), [003](../specs/003-agent-workflow.md) |
| 009 | [Street bank composition](009-street-bank-composition.md) | [002](../specs/002-street-trial.md) |
| 010 | [Lourizán map travel](010-lourizan-map-travel.md) | [009](../specs/009-lourizan-and-map-travel.md) |
| 011 | [Eight-slot bag](011-eight-slot-bag.md) | [012](../specs/012-eight-slot-bag.md) |
| 012 | [Lourizán guide](012-lourizan-guide.md) | [013](../specs/013-lourizan-guide-dialogue.md) |
| 013 | [Lucas garden patrol](013-lucas-garden-patrol.md) | [014](../specs/014-lucas-garden-patrol.md) |
| 014 | [Lucas atlas and Pazo refinement](014-lucas-atlas-and-pazo-refinement.md) | [014](../specs/014-lucas-garden-patrol.md), [010](../specs/010-camera-scale-and-lourizan-art.md), [015](../specs/015-retro-character-clarity.md) |

Next available plan ID: **015**. IDs 001–003 are not backfilled. Plan IDs are
independent of specs and ADRs. Reserve a unique next ID here, use
`NNN-short-english-kebab-case.md` and title `# Plan NNN — English title`, and update
references in the same change. Existing IDs remain stable. During parallel work
the integrator allocates IDs and owns the index.

The Joss/art plan moved from duplicate 004 to 008 during the one-time 2026-09-26
repair. Its history and task evidence are preserved; the move does not reopen
settled decisions or make historical scope restrictions current again.
