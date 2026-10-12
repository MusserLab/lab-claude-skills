---
name: analysis-distillation
description: >
  Distill exploratory or complex scientific analysis into the smallest readable workflow that
  supports a phase review, paper, report, or durable handoff. Use when a settled phase result
  needs consolidation, or selected results need publication-ready code, a newcomer reproduction
  route, or a maintained analysis path. Do not use to choose an
  unresolved scientific method, perform ordinary session cleanup, or rewrite a working pipeline
  merely to impose a preferred structure.
---

# Distill a Scientific Analysis

Turn the selected analysis into a workflow a researcher can understand, run, inspect, and
troubleshoot without an agent. Preserve the scientific implementation and evidence that support
the deliverable while reducing the maintained reader path.

Distillation begins after the relevant scientific question and selected results are sufficiently
settled. If a proposed change would choose a new normalization, threshold, exclusion, model,
classification, or interpretation, return that scope to scientific discussion or exploration.
A phase result can be settled enough to simplify before human acceptance; simplification neither
accepts it nor authorizes downstream work. For phase review, consolidate only its retained path
within agreed scope. Public packaging and clean-machine release validation apply only when that
deliverable is requested. Ordinary exploration and phase implementation already follow the
[readability and focused-test standard](../script-organization/SKILL.md#readable-analysis-and-focused-tests).

## Establish the retained path

Read the project's scientific and active-file authorities before editing. Identify:

- the claims, figures, tables, controls, and sensitivity results that will be retained;
- the exact producers, meaningful helpers, inputs, parameters, environments, outputs, and
  completed-run evidence supporting them;
- influential exploration, negative results, and post hoc choices that explain why this path was
  selected;
- missing source, execution, validation, or documentation evidence that must actually be closed.

Map each retained deliverable backward to its calculation and inputs. Keep this map in an existing
plan, scientific record, or concise reader diagram rather than creating a parallel lifecycle file.
Distinguish the maintained execution path from preserved exploratory evidence.

## Simplify the implementation

Start from the working scientific implementation. Refactor when it removes ambiguity, exposes the
specified method, eliminates a hidden dependency, or materially improves durability or reader
comprehension. A new directory, framework, wrapper, or rewritten language is not progress by
itself.

Make the normal path read in scientific data-flow order:

1. purpose and necessary background;
2. inputs and their biological or experimental meaning;
3. transformations, parameters, exclusions, and counting units;
4. focused checks that protect interpretation;
5. outputs and their downstream or manuscript use.

Inspect the source itself: use interpretable object/function names and meaningful section
headers. Each producer explains its purpose, necessary background, inputs and outputs. Each
substantive function briefly explains why it exists, its important input shape/IDs/units, what
it returns or writes, and non-obvious scientific assumptions. Annotate consequential joins,
transformations, exclusions and workarounds where they occur. Avoid comments that restate syntax.
A README, dashboard or external walkthrough supplements these annotations; it cannot replace them.

Use one script per coherent analysis or figure when that helps navigation. A long script is
acceptable when its sections follow one calculation clearly. Split when languages, independent
reuse, execution boundaries, or distinct scientific questions make the separation useful. Create
a helper only when actual reuse or conceptual clarity outweighs the cost of another file. Keep
sole-use logic with its caller when that is easier to understand.

Remove maintained branches that do not support the selected deliverable. Preserve influential
exploration and its conclusions in the project's established historical or evidence location;
do not erase the reason a method or result was selected.

## Put checks at the right layer

Keep checks that can distinguish a plausible error capable of changing the result or its
interpretation.

**Inside scientific producers:** select concise checks of actual data assumptions that protect
interpretation, such as identifier alignment, join coverage, missingness, filter effects, units,
denominators or category conservation. This is not a checklist to repeat at every step. Keep
consequential parameters and explicit seeds visible.

**In focused tests:** stable consequential transformations with a known answer, boundary cases,
and small file-based integration seams, in separate test files that call the actual analysis
functions. Select the test type for a plausible failure, not to fill every category. Preserve
useful existing tests. Do not add tests for cosmetic rendering, library behavior already relied
upon directly, or checks that merely repeat
the implementation.

**At the workflow or release level:** environment reconstruction, input acquisition and identity,
one complete source-to-result execution, expected output coverage, packaging, and comparison with
the selected baseline. Reuse valid evidence when the relevant code, inputs, settings, and
environment remain covered. Repeat expensive computation only when a changed dependency or the
acceptance criterion requires it.

Remove or centralize repeated Git interrogation, file hashing, font-file verification, HTML status
pages, nested receipts, and output manifests when they do not protect scientific meaning. A fixed
input analysis needs less defensive code than a reusable pipeline accepting unknown inputs.

## Record provenance without obscuring the science

Provenance is a required outcome, not a required in-script implementation. Use the project's
existing engine records, logs, environment specifications, input registry, and Git history first.
For a small workflow, one contemporaneous run note can identify the command, producing revision,
inputs, resolved settings, seed, environment, completion checks, and outputs. The workflow owner
verifies that the relevant producers, helpers and configuration match that revision at execution
and completion; recording HEAD alone is insufficient. Automate capture only when repeated
execution makes that worthwhile.

Do not make every producer query Git, hash its own source, or write a private provenance schema.
Record input checksums or immutable versions once at acquisition or registration rather than at
every use. Keep exact font identity only when typography itself is an acceptance requirement;
ordinary scientific reproduction can document a family or fallback and compare content and
layout appropriately.

Never reconstruct missing execution history from current files. Recover an existing record or
rerun the affected computation. Preserve a baseline before changing code or outputs that still
matter.

## Make reproduction usable by a newcomer

Provide one normal route from checkout or extracted package to the retained outputs. The main
README should state:

- required software and the simplest supported environment setup;
- every external input, where it comes from, and where it belongs;
- both an optional automated acquisition route and enough information to download inputs manually;
- commands in dependency order and what successful completion looks like;
- approximate runtime, storage, and any substantial resource needs;
- common failures and practical alternatives when exact package builds or fonts are unavailable;
- tested platforms and honest limits on other systems.

Environment locks and input checksums support diagnosis; they should not force readers through a
custom restoration framework when standard Conda, renv, or language tooling suffices. Prefer
portable paths and ordinary commands. Keep site-specific launchers optional.

### Optional: prepare a repository for readers

When the user wants the selected analysis presented as a paper, reproduction or handoff repository
on GitHub or another host, read [references/publication-repository.md](references/publication-repository.md).
Use it for an existing repository or an authorized new preview; skip it when the task only needs
local analysis simplification. Repository preparation does not itself authorize public release.

## Implement and verify proportionately

Preserve an inspectable baseline. Make small coherent changes and compare the scientific seams
that could have changed: identities, counts, memberships, numerical values, missingness,
classifications, stochastic results under the stated criteria, and the actual figures.

Run focused tests for changed transformations. Establish one clean execution of the final retained
workflow in an isolated destination when required evidence does not already cover it. A purely
organizational change can reuse an existing clean run after confirming commands, dependencies,
inputs, parameters, and outputs are equivalent. Do not match a known-bad baseline or treat visual
identity as proof of scientific correctness.

Creating a new repository, installing environments, running expensive analysis, depositing data,
or publishing code retains its normal authorization boundary. A private preview repository is
useful when the researcher wants to inspect the result as a newcomer, but it is not mandatory.

## Walk through and hand back

Before asking for acceptance, read the retained workflow in execution order as its intended human
reader would. Inspect naming, section structure and annotations, challenge every remaining layer,
and explain substantial complexity that is still necessary. Verify that tests protect meaningful
scientific failure points without filling the main workflow with test machinery.

Hand back:

- a compact input-to-output diagram grouped by scientific question and deliverable, with the
  detailed producer/dependency map separate when needed;
- the normal setup and execution route;
- what was retained, integrated, preserved as evidence, or removed from the maintained path;
- the checks run, evidence reused, and remaining reproduction limits;
- the actual figures or principal outputs and the scientific questions they support.

Then conduct the project's required scientific and code walkthrough. Successful execution,
source delivery, visual review, scientific acceptance, and public release remain distinct.

## Source note

This workflow was informed by the Dunn Lab's MIT-licensed distillation, workflow-design,
provenance, and validation guidance at commit
`992793ab173386b166c380203373e8b71aef57b7`, then adapted for the researcher's project authority,
human walkthrough, publication-code readability, and proportionate verification requirements.
The upstream copyright and license notice is preserved in
[`references/DUNN_LAB_LICENSE.md`](references/DUNN_LAB_LICENSE.md).
