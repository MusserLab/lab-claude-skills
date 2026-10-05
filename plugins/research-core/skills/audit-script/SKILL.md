---
name: audit-script
description: >
  Audit a scientific or data-analysis script, connected workflow, or publication producer for
  bugs, analytical validity, data handling, reproducibility, outputs, and readability. Use when
  reviewing code, preparing a substantial phase for scientific discussion, checking collaborator
  code, or investigating whether retained results can be trusted. Do not use for a quick question
  about one line or for project-document drift (use audit-project).
---

# Audit Scientific Code in Context

An audit prepares evidence for scientific discussion. It does not accept a method, result, phase,
or manuscript claim. Calibrate depth to the consequences, uncertainty, anomalies, novelty, and
existing project gates.

## Establish the real scope

Read the project instructions and registered active-file/scientific authority before opening
scripts or data. Confirm the host, checkout, environment guidance, dirty state, and which outputs
must be preserved. Identify the scientific question, the intended use of the result, and any
specific concern already raised.

Do not assume the filename supplied by the user is the whole audit unit. For a substantial phase,
trace the connected retained workflow:

- exact inputs and versions;
- every producer that materially contributes to the retained result;
- meaningful shared helpers and upstream calculations;
- influential exploration that changed scope, method, interpretation, or retained output;
- resulting tables, figures, reports, and downstream consumers;
- superseded or dismissed branches whose disposition matters to the conclusion.

Organize review around conclusions and data flow. Account for each contributing producer without
creating one worker, checklist, or permanent report per script. A terminal figure or report is a
real output even if no later script reads it.

If the user asks about one bounded script, keep the scope bounded unless evidence shows that a
connected producer/helper can change the answer. Explain any necessary expansion and its benefit.

## Choose assurance from consequence

Decide which combination of static inspection, small diagnostics, fixtures, execution,
equivalence comparison, domain research, and independent review can distinguish the plausible
failure modes. Reuse recent valid evidence for unchanged code.

Normally obtain an independent perspective for substantial scientific work. A lead reviewing
worker-authored code can provide it; lead-authored, consequential, unfamiliar, or complex work
usually benefits from a fresh reviewer. Keep small or tightly coupled review local. Choose the
reviewer count and tools from separable work and lead review capacity, without fixed fan-out.
The optional [auditor prompt](templates/auditor-prompt.md) can brief a bounded cold read.

Research unfamiliar tool, file-format, library, or method semantics when correctness depends on
them. Prefer primary documentation and record the exact unresolved assumption. Familiar operations
do not require a ceremonial web search or a comprehensive domain checklist.

Before running anything, state the failure being tested, the expected discriminating evidence,
and the authorized inputs/outputs. Use the project environment. Do not rerun expensive science,
replace retained outputs, install dependencies, or launch jobs merely because an audit is active.
Use a fresh or confirmed disposable destination when execution is appropriate.

## Follow the evidence through the workflow

Read the main workflow in execution/data-flow order and inspect helpers where they are called.
Evaluate what is relevant from these connected questions.

### Purpose and scientific reasoning

- Does the code answer the stated question with the intended population, unit, comparison, and
  denominator?
- Are inclusions, exclusions, thresholds, transformations, controls, models, and alternatives
  visible and justified?
- Do the actual input versions and contents remain appropriate for the question? Explain relevant
  alternatives or newer inputs and any substitutions, preserving a justified frozen comparison.
- Could a technically correct operation support a misleading interpretation?
- Are negative, partial, and Unknown outcomes distinguished from broken lineage or missing checks?

### Identity and data handling

- Do file identities, versions, schemas, coordinate systems, units, and category meanings match
  what the code assumes?
- Are join keys unique at the intended level? Measure matches, unmatched cases, multiplicity, and
  row/count changes where consequential.
- Are missing values, duplicates, filters, aggregation, and exclusions visible rather than
  silently lost or forced into a real class?
- Does upstream ambiguity propagate into denominators, statistics, plots, or downstream claims?

### Correctness and statistics

- Check formulas, variable references, boundary conditions, grouping, ordering, random seeds, and
  library/tool semantics that can change the result.
- Evaluate statistical assumptions, design, multiple testing, normalization, independence, power,
  and uncertainty to the degree needed for the claim.
- Prefer focused fixtures or diagnostics for consequential transformations. A known-bad retained
  output cannot define correctness merely because new code matches it.

### Producing state and reruns

- Identify the actual code, launcher/wrapper, relevant helpers/configuration, inputs, command, seed,
  and environment that produced the result.
- Retained scientific use requires the relevant producer, wrapper, helpers and configuration to
  match a focused commit. Reuse that commit when the source is unchanged; unrelated dirty work is
  not a defect. If a result was produced before the commit, require adequate producing-state
  evidence that the earlier run used those exact bytes; matching the current filesystem alone does
  not establish that. Without that evidence, require a rerun from the committed source before
  reliance.
- Keep source in its tracked source locations and results in their owned output locations. Do not
  require a generic code-copy bundle in `outs/` or replace an existing specialized custody record.
- Confirm whether a rerun reuses completed products, writes a fresh destination, or regenerates a
  destination already established as producer-owned and disposable.
- Preserve retained, shared, manually edited, or downstream-consumed outputs regardless of Git or
  ignore status.
- When publication preparation is in scope, inspect the reader-facing setup and execution route:
  can a researcher without an agent obtain and verify the inputs, set up the environment, run the
  analysis and recognize success? Require understandable manual environment/data instructions;
  installer/download helpers must not be the only route. Check likely platform-specific setup
  failures against the documented recovery steps.
- Distinguish intended platform support, source inspection and actual clean-workspace execution.
  Preserve the pinned reference environment and require evidence for an acceptable alternative;
  do not equate scientific equivalence with byte-identical cross-platform rendering. A successful
  run on one machine does not validate another platform. Record untested routes as limits, without
  expanding the audit into unauthorized installs or scientific reruns.

### Outputs and readability

- Cross-check plots/tables against their source values, denominators, labels, scales, exclusions,
  and saved dimensions. Matching pictures alone do not establish equivalence.
- Preliminary plots may be PNG. The figure-producing run retained for phase-final review must
  produce PNG, PDF, and SVG, independently of any script-status label.
- Read the workflow as a researcher would: purpose, inputs, operations, consequential choices,
  outputs, and next uses should be understandable without production-framework ceremony.
- Flag abstractions, defensive machinery, duplicated bookkeeping, or helpers that obscure the
  science. Fixed known inputs need less defensive code than reusable pipelines with unknown inputs.

For collaborator code, judge the intended scientific purpose and operating context. Do not impose
one researcher's preferred directory, numbering, Quarto, or documentation patterns as universal correctness.

## Verify findings before escalating them

For each consequential candidate finding, determine whether it actually occurs in the intended
use case and what it changes. Run a focused diagnostic when authorized and useful; otherwise label
the finding as static or unverified. Separate:

- **Critical:** invalidates a retained result or creates material data/custody risk;
- **Major:** can materially change validity, interpretation, or reproducibility;
- **Moderate:** real weakness with bounded effect or important fragility;
- **Minor:** readability or maintainability improvement with no present result effect;
- **Awareness:** a contextual limitation or hypothetical that does not warrant code change.

Severity follows consequence, not aesthetics. Do not turn theoretical edge cases into action
items, and do not recommend a more complex fix unless it reduces a plausible risk.

## Integrate evidence and prepare discussion

For substantial phase work, preserve one concise durable audit record in the appropriate existing
plan, Issue, or audit report. It should contain:

- scope and connected workflow reviewed;
- static, executed, compared, and inaccessible evidence;
- consequential findings with impact and disposition;
- affected outputs/downstream basis and required reruns or preservation;
- limitations, unresolved scientific choices, and what remains unverified.

Create a separate report only when it will be a useful handoff or project record. A small review
can stay in the task/plan discussion. Worker notes are inputs to the integrated record, not a
required permanent artifact of their own.

Hand back the scientific question, approach, principal findings, actual data-flow path, and the
plots/tables or examples that matter. Explain influential exploration and dismissed results in
proportion to their effect. Distinguish code defects, method choices, interpretation questions,
and presentation issues.

The subsequent joint review proceeds in this order: what was done, what it means, whether the
approach is scientifically right, and then whether the code implements it faithfully. Invite the
scientist's interpretation. A passing audit or “no findings” supplies neither scientific acceptance
nor permission for downstream work.

After substantive fixes or investigation, reassess the integrated updated result and downstream
basis. Reuse still-valid evidence; do not present only the latest changed script. Report actual
checks and limits, and stop when additional checks would repeat the same evidence rather than
change confidence.
