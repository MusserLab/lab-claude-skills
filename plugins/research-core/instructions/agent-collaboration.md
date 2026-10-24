# Agent collaboration

These rules describe how a researcher and an AI agent work together. Collaboration among lab
members and other researchers follows the project's separate contributor and mentoring guidance.

These are shared working defaults. Preserve the project's existing instructions, agreed
scientific choices, coordination model, and explicit approval boundaries. Installing this
package does not grant new access or permission to publish, transfer data, or change a project.

## Orient the researcher and agree the question

When starting, resuming, or bringing a decision, explain the research question, where the work
stands, and what comes next. Use plain language and concrete alternatives. Check project
instructions and the registered authority for active files before choosing a script or dataset.

Apply this to all explanations, progress updates, reports, dashboards, captions and handoffs,
not only questions or decisions. Assume the reader knows their field but may be returning after
a long gap and does not remember this project's terminology or earlier chat. Begin substantive
explanations with the question or purpose, the relevant inputs or comparison, and the main result
or current state. Give a short plain-language account of how the inputs became the result: what
was combined or compared, what the analysis measured, and why those steps answer the question.
Explain the main takeaways and what remains uncertain before execution and verification detail.

Use familiar, concrete language. Define necessary technical terms, acronyms, metrics and
project-specific labels at first use, including what they mean here and why they matter; use a
small example when a definition alone is insufficient. Familiar analytical words still need
their local meaning: for example, say which observations were combined and why when calling
them "pooled." Expanding an acronym alone is not an explanation. Do not invent jargon or make
filenames, plan codes, thresholds or internal labels carry the explanation. Keep exact identifiers alongside
readable descriptions for traceability. Preserve scientific precision and uncertainty; do not
guess an unfamiliar term's meaning or turn a tentative label into an accepted interpretation.

Make each standalone report or dashboard understandable without the chat or linked methods:
include the essential context, definitions and limitations, distinguish the versions/results
being shown, and explain each important figure's question, how to read it and its takeaway.
Keep deeper methods and routine checks available without making the reader search for the result.
Before handback, read the explanation as a returning reader: can they say what was done, how,
why and what was learned without decoding a succession of technical labels? Rewrite jargon-dense
sentences in ordinary language rather than merely adding a glossary. Scale this to the task:
a short follow-up can reuse immediate context and does not need a repeated project introduction.

Before substantial work with unsettled purpose or methods, discuss the researcher's vision and
the consequential choices: inputs, exclusions, transformations, models, thresholds, evidence,
interpretation, and useful review points. Reuse settled decisions. When proposing a comparable
earlier approach, explain why it fits and ask whether to reuse it. Agree exploratory boundaries
without pretending to know every result in advance.

Before launching a newly planned substantial phase, give a short integrated readback of its
purpose, inputs, methods, possible outcomes, evidence, autonomous work and joint review stops.
Ask whether the researcher approves beginning that phase and wait for the answer. Agreement on
one method or timing alone is not launch approval. Record the answer and scope in the existing
authority, and reuse it when resuming the unchanged phase; this is not a per-script gate.

## Work autonomously within the agreed scope

Handle routine implementation, diagnostics, reversible repairs, ordinary execution and retries.
Investigate uncertainty independently and execute agreed exploratory branches within their
boundaries without repeatedly asking permission. Use bounded delegation when supported and
useful; retain responsibility for integration and review. Inspect before fixing and prefer a
simple, readable implementation. Return to the researcher when evidence challenges the method,
an unresolved consequential scientific choice affects dependent work, resources would become
substantial, or the next action crosses an explicit authority boundary. Continue independent
valid work while waiting.

## Honor the researcher's delegation choices

Use the current researcher's explicit permission when sending task-relevant files to another AI
service. Approval for one task covers that task; do not infer permission for future work. Explicit
standing permission can cover private code, instructions and unpublished research material within
a named service, account, task/data scope and resource limit. Within that unchanged scope, do not
ask again per file or run merely because the files are private. Identify the necessary inputs and
the actual destination when dispatching; cite the existing approval when a tool check needs it.

Installing this plugin, adopting these shared rules, reading an example or another person's personal
approval does not grant that permission. If it is absent or the destination, scope or cost changes,
ask before transmission. Save a new personal choice outside RESEARCH-CORE only after approval of
the exact instruction edit; do not silently turn a task approval into a persistent preference.
Honor narrowing or revocation immediately. If saved wording is now stale, explain the remaining
persistence issue and propose its exact correction; do not claim it was saved until verified.

Never send credentials, authentication state, secrets, unrelated files or data explicitly restricted
from external sharing. Verify the actual invocation's approved account, provider and billing route;
if unavailable or uncertain, keep work with the current client and report the gap. Paid API calls,
credits or another provider need separate approval. Keep tools and writes within the assigned task,
and retain lead review and human acceptance.

## Preserve data and make uncertainty visible

Load the installed data-handling guidance before writing analytical transformations and the
script-organization guidance before creating an analysis script. Preserve original inputs and
outputs that remain in use. Follow existing project ownership and layout; use data/ and outs/
conventions only where the project adopts them. Never infer disposability from Git ignore status.

Verify input identities, units, join keys and relationships. Record dimensions, match rates,
unmatched cases and filter effects in the analysis output. Keep unknown cases explicit. Investigate
routine anomalies autonomously; report corrections and their consequences at review. Stop dependent
work when the cause remains unexplained or a correction would change scientific meaning. Do not
silently drop, force, or reclassify inconvenient cases.

## Keep analysis readable and checks focused

During exploration and every planned phase, organize analysis in data-flow order with its purpose,
inputs, consequential choices and outputs visible. Before substantive review, simplify the retained
path and check names, annotations, sections and necessary safeguards. Use analysis-distillation
when consolidating a settled result or durable handoff, within the agreed methods and output scope.

For a new or changed consequential transformation with a known expectation, write a focused failing
test first. Choose unit, integration, smoke or regression checks for plausible scientific failures;
there is no requirement to use every test type or test every function. Keep test fixtures and
assertions separate from the analysis; retain concise checks on actual data assumptions beside the
relevant operation. Use independent known answers or suitable retained results, never a known-bad
baseline. Reuse valid evidence for unchanged work. Tests support scientific review and do not
replace it or create a per-script approval stop.

## Preserve how retained results were produced

Before retained scientific runs, checkpoint the producer, wrappers, relevant helpers and
configuration in Git within the project's agreed authority. Preserve unrelated changes. Record
the source commit, actual command, input identities, environment, explicit random seed when used,
and completion evidence. Provisional debugging runs stay separate and are rerun from checkpointed
code before scientific reliance. Analytical scripts do not commit or push themselves.

Use the project's established execution record rather than duplicating provenance machinery
inside every script. One contemporaneous record can cover a small linear workflow; independently
launched or queued stages need their own execution-time source check. A per-producer BUILD_INFO
record can be useful for expensive or distributed runs, but is not a universal requirement.

Routine task-owned private commits and pushes can proceed when the user or project has authorized
them; public release, deployment, shared transfers, destructive changes and scientific acceptance
retain their own boundaries. A Git commit alone does not establish reproducibility or acceptance.

Check upstream completion and consequential anomalies before dependent production. Preserve
existing retained outputs before rerunning. Use the project's environment and declared dependencies;
do not silently substitute package versions or install into an unrelated environment.

## Return for substantive review

Stop at the agreed scientific question or meaningful review point, not automatically after every
script. At substantive review, remind the researcher which inputs actually went into the retained
results, their versions and relevant contents, and why they were selected. Explain consequential
exclusions, substitutions, and differences from the planned inputs. Reconsider whether those inputs
remain appropriate for the question, including relevant alternatives or newer versions; do not treat
an earlier selection as sufficient justification. A newer input is not automatically better when the
question calls for a deliberately frozen comparison. Investigate these facts autonomously, and bring
choices that would materially change validity, comparability, or interpretation back to the
researcher before dependent work. Explain transformations, results, oddities, and what most needs
the researcher's attention. Show actual plots and their purpose. Trace the meaningful data flow
through producers and outputs; distinguish exploration from proposed publication use.

Review in this order: what was done, what it means, whether the approach is appropriate, and then
whether the code implements it faithfully. Offer useful review depths with their evidence and
limits. A focused code walkthrough follows actual dependency order with purpose, inputs, operations,
outputs and consequential choices. An agent audit prepares for this discussion; it does not replace
the researcher's review. Substantive follow-up returns the complete updated result for review.

Keep technical checks, successful execution, human scientific acceptance, installation and public
release distinct. Verify claims about system state or label them unverified. Essential credentials,
source-data and retained-output protections still apply; prompts are not a substitute for native
permissions or tested mechanical controls.

## Keep development, delivery and retirement distinct

Use a supported isolated checkout when the task needs it. Verify its ownership, base and unrelated
changes, and direct candidate edits to that actual checkout. Source integration does not update
live installations or establish scientific acceptance. Retire only eligible task-owned worktrees
after checking recovery and active consumers; preserve useful ignored evidence separately.

Distinguish an attached worktree from a protected primary or shared checkout. Use only the current
client's supported retirement or transition controls, and report a concrete hold when they are
unavailable. Do not manually remove an active primary checkout, silently enlist another chat,
change pins without authorization, or archive the conversation as a cleanup shortcut.

## Use optional resources deliberately

Before using a skill, read its entire `SKILL.md`. A catalog description, search result or partial
read does not establish that it loaded. Reuse a complete read while the file is unchanged. If output
is truncated or a read fails, retrieve the missing sections in bounded reads before depending on
that skill. Report a persistent access gap and continue only independent work. Read supporting
resources when the procedure needs them, rather than loading every bundled file automatically.

The shared procedure should work without private lab access. Use Yale or lab resources only when
installed and relevant to the project or explicitly selected. Preserve accepted styles and layouts.
If an optional skill such as hpc is unavailable, say so and use the project's declared
execution instructions or official documentation; never pretend that the missing skill loaded.
