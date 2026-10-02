---
name: planning
description: >
  Create, shape, extend, or selectively improve a registered plan for substantial work, or create
  a scientific/data/reference record. Use for /planning, planning consequential work, developing
  a phase with the user, or recording programme decisions under Plan/Hybrid coordination.
---

# Plan Consequential Work

Planning is a discussion and evidence process, not a document template. Understand the user's
purpose and reasoning well enough that routine execution can proceed autonomously, then leave the
smallest durable record a fresh lead needs.

## Route by current authority

Read [Work coordination](../new-project/references/work-coordination.md) and the project declaration
with its read-only reader. Project type and task authority are independent.

- **Plan/undeclared:** use the established planning record. Missing declarations preserve existing
  behavior; do not infer adoption.
- **GitHub:** Issues own executable task state. Do not create a Markdown task plan merely because
  work spans sessions. A requested architecture, scientific, data, or reference record can proceed
  under its own authority.
- **Hybrid:** plans own programme intent, consequential decisions, phase boundaries,
  cross-phase relationships, and human acceptance; Issues own executable tasks. Cross-link them
  without copying Issue checklists, labels, assignees, state, or counts.
- **Invalid/conflicting:** explain the declaration problem and hold model-dependent creation or
  GitHub actions. Preserve valid independent work.

Closing an Issue never accepts a dataset, scientific result, or programme phase. This skill does
not create or mutate Issues, milestones, or coordination declarations.

## Inspect before questioning

Read the project instructions, registry, current plan or Issues, active scientific/data records,
recent relevant history, and actual evidence. Recheck current authority rather than trusting a
dated summary. For an existing plan, use [upgrading existing plans](references/upgrading-existing-plans.md)
and change structure only where it improves current use.

Distinguish four cases:

- create a missing programme/phase plan;
- extend or reconcile an active plan;
- leave an already usable plan unchanged;
- create a scientific/data/reference document that should not become task authority.

Do not reopen settled choices without contradictory evidence. When a comparable analysis exists,
explain its scientific and data similarity and the meaningful differences before asking whether to
reuse its approach.

## Develop shared understanding

Orient the user to the larger project, the current scientific or technical question, what this part
will enable, and why the decision matters. Inspect facts independently, then question the
consequential branches rather than presenting a nearly finished plan for assent.

Cover what is material to this phase:

- intended question, claims, and downstream use;
- inputs, inclusions/exclusions, identities, and assumptions;
- methods, comparisons, thresholds, models, and plausible alternatives;
- possible positive, negative, partial, or Unknown outcomes and their interpretation;
- evidence, outputs, compute/resource scope, and preservation needs;
- work the lead/workers may pursue autonomously and return points requiring the user's scientific
  contribution;
- review questions, acceptance owner, and what acceptance permits or leaves blocked.

Use concrete input-to-result examples for unfamiliar or consequential scientific choices. Follow
answers with questions that expose assumptions or disagreements. Group related independent choices;
ask dependent ones after their prerequisites. Reuse documented answers and useful precedent.

For exploratory work, agree an initial strategy, scientific boundaries, evidence to preserve, and
return points. Readiness does not require predicting discoveries. Investigate routine surprises
within scope; bring evidence back when interpretation or a consequential direction needs joint
thinking. Continue independent work that does not depend on the unresolved decision.

Directly testable software/system work can use short build–try–adjust cycles. Do not impose a long
scientific interview when purpose and checks are already clear. An already agreed phase does not
need a new interview unless new evidence changes a consequential premise.

Before launch, explain the integrated approach back to the user from purpose and inputs through
methods, possible outcomes, evidence, discussions, and acceptance. Resolve substantive mismatch;
routine implementation detail remains agent-owned.

## Write the smallest useful contract

The familiar **Purpose / Ready / Review-ready / Acceptance** structure is useful when it clarifies
a substantive unit; it is not a mandatory schema or script lifecycle system.

- **Purpose:** the question or capability, why it matters, project context, and intended handoff.
- **Ready:** canonical inputs/dependencies, settled choices, unresolved blockers to the next action,
  agent authority, resource scope, and return points.
- **Review-ready:** required products and evidence, defensible result branches, anomalies and
  limitations to surface, and defects that require rework.
- **Acceptance:** the user's substantive questions and evidence, required assurance, exact accepted
  scope, downstream permission, and remaining blocks.

Omit irrelevant headings. A compact one-outcome plan may be a few paragraphs. A larger programme
may use a root phase map plus one attached phase plan where detail materially improves navigation.
Use at most two authored plan levels; manifests, schemas, data records, provenance, and historical
logs are field-specific evidence, not extra plan tiers.

Do not require Draft/Ready/In progress/Review-ready/Complete labels. If an existing project uses
them, preserve their accepted meaning without forcing them onto other records. State current focus,
the next substantive action, unresolved dependency, and evidence date in ordinary language.

### Scientific and analytical detail

Record exact input versions and roles, consequential choices, expected producers/helpers and
outputs, seeds, checks, and plots/tables to review. Before a run is retained for scientific use,
verify that its relevant producer, wrapper, helpers and configuration match a focused commit.
Reuse an existing commit when those source bytes are unchanged; unrelated dirty work does not
block a scoped commit. Record the command, inputs, seed, environment, outputs and commit identity
in the project's established provenance record. Keep code in source directories and outputs in
their owned destinations rather than copying a generic source bundle into `outs/`. The lead or
assigned worker handles any needed scoped commit or working-branch push only when the current task
and native user or project instructions authorize it; the analysis script itself
must not call `git add`, `git commit`, or `git push`. Owned draft or experimental code may be saved
to Git before scientific acceptance. Retained scientific use still requires the approach to be settled and the
relevant source to match its recorded commit.

Plan predictable reruns and output preservation. Existing retained, shared, manually edited, or
downstream-consumed outputs remain protected regardless of Git/ignore state.

Preliminary plots may be PNG. The retained figure-producing run used for phase-final review must
produce PNG, PDF, and SVG. This trigger is the phase-final result, not a lifecycle label and not a
later publication-preparation choice.

For a substantial phase, plan audit/review around the connected retained workflow: contributing
producers, meaningful helpers/upstream calculations, influential exploration, outputs, and
downstream basis. Depth follows consequence and uncertainty. Normally include an independent
perspective, without prescribing worker counts, tools, or one report per script. Preserve one
integrated durable audit record in an existing plan, Issue, or useful report.

### Publication preparation remains separate

Scientific acceptance may lead to further analysis, immediate publication preparation, deferred
preparation, or no publication package. Do not silently turn an accepted analysis into a release
refactor. If publication preparation is chosen, record its intended readers/outputs, frozen input
boundary, execution order, exact producing source commit, environment setup, equivalence checks,
package contents, and separate scientific/visual/release acceptance.

Publication quality includes the reader's route from obtaining the code to recognizing a
successful analysis, without an AI agent. Plan a simple, documented manual route for environment
setup and data acquisition; installer/download helpers may offer convenience but must not be the
only understandable route. Name required inputs, their sources, destinations and integrity checks,
dependencies, execution order and expected outputs. State platform-specific prerequisites and
recovery steps for likely setup problems, rather than leaving readers to debug a helper script.
Keep intended platform support separate from platforms actually tested, and check the documented
route in a clean workspace when release validation is authorized. Preserve a pinned reference
environment; any alternative needs explicit compatibility evidence before being called acceptable.
Distinguish scientific equivalence from byte-identical cross-platform rendering. Use ongoing
project experience to refine these instructions; do not invent a universal installer or claim
cross-platform reproduction from a successful run on one machine.

## Plan the joint review

The review should let the user understand and explain the work. Begin with the question, approach,
and principal findings; show actual inputs, producers/helpers, transformations, outputs, figures,
and downstream uses. Distinguish planned work, what ran, retained and dismissed findings,
influential exploration, and proposed future work.

Follow the order: what was done, what it means, whether the scientific approach is right, then
whether the code implements it faithfully. Show actual plots and evidence and invite the user's
interpretation. Enter code where it clarifies a consequential point or the user asks.

For branching work, prepare a visual/data-flow overview with source links and highlight the path
supporting the paper or intended product. Vary presentation depth by what the decision needs,
without turning “brief/focused/comprehensive” into mandatory modes or allowing presentation depth
to waive assurance or acceptance.

After substantive follow-up, return to the complete integrated updated result before acceptance.
A quick check can remain within the ongoing review only when it leaves methods, result,
interpretation, and downstream basis unchanged.

## Assemble, register, and preserve meaning

Use the project's established location and naming. The root registry is a concise discovery index:
register the record once, describe its purpose, and link the field-specific authorities it needs.
Do not copy every numerical result, task status, checklist, or machine-generated fact into prose.
Update only entries affected by the change.

A practical plan may contain:

```markdown
# {Topic} Plan

> Last reconciled: {date and evidence/source}
> Part of / Supports: {optional authority link}

## Purpose and scope
## Current focus and next substantive action
## Phase or dependency map        <!-- only when it helps -->
## {Current phase/question}
### Purpose
### Ready
### Review-ready
### Acceptance
## Key files and evidence
## Consequential decisions
```

Close accepted work by preserving the actual scope, acceptance owner/date, consequential rationale,
canonical evidence/provenance links, deviations and limitations, downstream permission, and the
disposition of unfinished work. Remove obsolete tactical commands or duplicated chronology only
when the durable record remains understandable. Never collapse pending review into completion,
infer parent acceptance from a child, or erase the basis of a historical accepted result.

Tell the user what changed, where it is registered, what is ready, what remains unresolved, the
next substantive step, and when their participation is needed. Do not launch work merely because a
document was created.

## Data and reference records

When the user requests a data/reference document, gather only the missing facts needed for that
record. Cover purpose, source/identity, schema or experimental design, key files/fields, custody or
processing notes, and limitations as relevant. Register it under its actual role. It does not
become a task plan or second progress authority.
