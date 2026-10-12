# Prepare a research repository for readers

Use this optional branch when the deliverable includes a repository that another researcher will
browse, download and run. It applies to an existing repository and to a separately requested
preview. Local distillation does not require a new repository, public release or this extra work.

## Establish the destination and content

Reuse the agreed repository, audience and scope. If creating a remote or changing visibility is
needed, resolve the owner, name, destination and visibility under the current authorization; do not
infer public release from "publication-ready." An authorized private preview can support review
before public release. Reuse settled permissions rather than asking again for unchanged actions.

Build from the selected producing version and the project's active-file authority. Keep its
relationship to the scientific source inspectable through existing Git history or a concise source
note. A separate repository is optional; do not impose an exporter, second pipeline or maintenance
framework. Preserve the baseline and show meaningful changes without copying unrelated dirty work.

Include the producers, needed helpers, small configuration, environment specifications, focused
tests and permitted inputs. Check for dependencies on private checkout paths, caches or unavailable
intermediate results. For a selected upstream result used as an input, explain its origin and the
workflow's starting point; do not imply this repository recomputes it. Preserve useful provenance
and scientific limitations in reader-accessible form. Internal session logs and review receipts
need not become the normal reading path, but removing them must not remove the only evidence.

## Write the README for someone arriving from the paper

For a paper repository, start with the actual paper title and verified citation or manuscript
status; for another reproduction or handoff repository, start with its purpose and outputs. Then
describe what the repository contains and where its analysis begins. Use direct language such as
"Analysis code for ..." or "This repository contains ...". Avoid internal descriptions such as
"human-readable version," "retained workflow" or a dated refactor history as the introduction. Name the actual
tables, analyses and figures. Keep relevant limitations explicit without making the reader learn
the development process.

Organize the README around the reader's questions; combine sections for a small project:

- **What does this produce?** State the analysis scope and, when helpful, map paper figures/tables
  to their scripts and main outputs. Separate upstream analyses supplied as inputs from work run here.
- **How does the science flow?** Use a compact diagram of meaningful preparation and analysis
  branches leading to deliverables. Keep the detailed file/dependency map separate when needed.
- **How do I set it up and run it?** Give the supported runtime and standard environment route,
  data acquisition, commands in dependency order, expected outputs and success checks. State the
  launch directory, which scripts call helpers, rerun behavior, and substantial resource needs.
- **What has been checked?** Distinguish focused tests, subset execution, full workflow execution,
  comparison with reference results and tested platforms. Do not imply a simplified workflow was
  run end to end merely because its predecessor ran or its README improved.
- **How may I use or cite it?** Give data availability, source/asset attribution, the established
  code/data license terms, citation and contact information as applicable. Flag unresolved release
  decisions for the owner rather than inventing authorship, permissions or a license.

A figure, numbered stage and producer file are different things. Report their counts accurately
when useful, and do not create a target script or diagram-box count. A crowded diagram calls for
a better overview; it does not by itself justify restructuring sound analysis code. Once the reader
path is useful, proceed to the walkthrough instead of repeatedly redesigning the repository.

## Make acquisition and execution work outside the development checkout

Keep the normal route usable without an agent. Prefer the project's standard Conda, renv or other
established tooling and direct commands. Preserve the supported reference environment; diagnose a
restore problem before proposing alternatives, and identify any changed environment as unverified
until the relevant results are checked. Do not silently relax locked versions to make setup pass.

For external inputs, give the source record or landing page, specific file, destination and an
adequate identity/version/checksum. Reuse an existing input table rather than maintaining competing
lists. A small optional downloader may help, but the manual route must explain acquisition and
verification without private caches, missing source files or agent-only steps.

If automated access fails, distinguish a missing or changed source from an access restriction.
Give an actionable browser/manual route where available, the expected filename/path, verification
and how to resume. Do not assume the same blocked download URL will work in a browser, label an
untested fallback as verified, or replace the input silently. Preserve already verified downloads
and inspect unexpected existing files before replacing them.

## Inspect the actual reader experience

Review the README as rendered on the intended host when available: links, tables, diagram,
terminology and command order. File/link checks alone do not establish that the overview is readable.
If rendering is unavailable, state that limit. Make the smallest revision addressing what the
reader found confusing; keep substantive code restructuring a separately justified decision.

Check the documented route in a fresh authorized checkout or extraction when that evidence is
needed, without relying on unstated developer files. Reuse valid inputs and previous execution
evidence where appropriate, and report that reuse. Setup success, acquired data, generated figures
and scientific acceptance are separate outcomes. Preserve the failing step and useful error when
the route stops; update the relevant instructions after a verified repair. Avoid a new wrapper or
validation system merely to demonstrate these checks.

Before a requested public release, review the included files and any outgoing history for private
material and resolve code/data/artwork redistribution, attribution, final naming and visibility.
Preview approval does not settle those choices. Publish only within the approved scope, verify the
actual remote/version and visibility, and report the link and any remaining execution or review
limits. Do not create a release, DOI deposit or extra repository unless it serves the requested task.
