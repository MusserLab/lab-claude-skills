---
name: analysis-review-dashboard
description: >
  Build or refresh a browser dashboard for independently reviewing a scientific analysis,
  from a short workflow to a branching pipeline. Organize existing evidence into a pipeline
  overview, scientific task pages and complete script reviews with file and object previews.
  Use when the user asks for an analysis review dashboard or linked pipeline/task/script pages.
  Do not use for a task-status dashboard, source-code distillation alone, or a script audit alone.
---

# Scientific analysis review dashboard

Help a researcher follow what an analysis did, what it produced and why its analytical choices
matter, then inspect the actual files and code independently. Write for a beginning
bioinformatician: explain biological terms, measurements and units; avoid software jargon that
adds no understanding. A dashboard is a derived review aid, not a new project plan, status
ledger, provenance authority or acceptance record.

Assume the reader is returning after a gap and has not read the chat. Give each independently
opened page enough context to understand its question, inputs/comparison, main result and limits.
Explain the main analytical steps in ordinary language: what was combined or compared, what was
measured, why that approach answers the question, and what the reader should take away. A list
of scripts, tests or completed stages does not explain the method. Rewrite dense prose; a glossary
alone cannot make a page understandable. Explain familiar analytical terms in their local context.
Define necessary terms, acronyms, metrics and project-specific labels before using them; explain
why a distinction matters with a concrete example when useful. Use descriptive headings, keeping
exact filenames and identifiers as supporting traceability. Do not invent a new vocabulary for
the project or infer biological identities from suggestive identifiers.

Use the [page design](references/page-design.md) when building each page. Start from the
[templates](templates/README.md), preserving the agreed hierarchy while adapting to the
scientific workflow.

## 1. Establish scope and evidence

Read the project's root instructions, canonical project instructions and registered active-file
records before reading scripts or data. Identify the scientific question or retained workflow
being reviewed, its active producers, relevant helpers, inputs, saved outputs and downstream use.
Reuse existing audits and run/provenance records; this skill does not require a new broad audit.

Check what is accessible on the actual host. Distinguish the displayed current source from the
source that produced a saved result. Record the producing version, inputs, environment and run
when known; say what has not been verified. Never imply that a downloaded preview copy produced
canonical results. For a saved-result review, prefer the producing source. If displaying a later
distilled/current version, explain the relevant correspondence evidence and any unresolved
differences; do not attribute its unverified changes to the old run. Use existing identity evidence
rather than inventing a manifest.

Agree unresolved scientific scope with the user. Routine page construction is yours; changing
methods, running substantial analyses, refactoring source, replacing outputs or accepting results
requires the authority of the relevant project workflow. Missing evidence is a visible gap, not
permission to fabricate a plausible example or infer successful completion.

## 2. Group scientific tasks and choose page depth

A task answers a coherent scientific question or produces a necessary scientific intermediate.
Group by purpose and meaningful data flow, not one script per task. Preparation can span several
scripts; one standalone script can be a task. Explain the proposed grouping briefly and reuse
already settled groupings. Return to the user when alternatives materially change review scope
or scientific interpretation; do not make them resolve routine page subdivisions.

- Split a task when its outputs support distinct questions that need separate interpretation.
- Keep coupled steps together when reviewing them separately would hide their shared assumptions.
- Show real branches and shared inputs. Arrows mean a documented data/dependency relationship,
  not merely adjacent script numbers. Keep dependencies compact; details belong on task pages.
- If one script serves multiple tasks, create one complete script page and link each task to its
  relevant sections. Do not duplicate or truncate that source into competing reviews.
- Include the project-owned helpers needed to understand the retained path in their caller's
  context. Link complete helper source; do not reproduce imported libraries or vendored packages.
  A shell wrapper is execution support, not the complete analytical implementation. Name any
  external producer, its recorded version and which implementation source is actually available.
- For a large workflow, use a legible overview of scientific stages/branches, then task pages for
  detail. Preserve actual script filenames and task relationships within that hierarchy; avoid
  an enormous diagram that requires zoom/pan controls just to read it.
- For one short script answering one question, combine the overview and task summary on one
  page and retain a separate complete script review. This is the compact default. A long script
  answering several questions can still need several task pages; script count does not determine
  page depth. Remove empty/redundant levels and panels while keeping the same review content.

Task numbers are navigation labels, not edits to the project's plan/phase numbering. Preserve
existing scientific terminology and make the mapping clear when labels differ.

## 3. Build the overview, task and script pages

Follow the [page design](references/page-design.md). Keep each layer's job distinct:

| Page | Main content |
|---|---|
| Overview | Brief scientific summary; clean task diagram with scripts and an **Open task** link for every task; actual main scientific outputs and short captions. |
| Task | **Task number and concrete title in the visible heading**, question second; inputs → approach → outcome; a left section-navigation rail; script diagram; concise per-script files, task-specific evidence and run guidance. |
| Script | Top links between this task’s scripts; whole-script file details; simple **Script sections** diagram; all source in meaningful sections with original numbering, concrete section introductions, yellow analytical-choice explanations/highlights and adjacent function cards. |

Place the principal figure/output gallery on the overview. Task pages explain that task's result
and useful intermediate evidence; link to the main figure rather than repeating the gallery.

For each important plot, explain the question, displayed groups/measurements, selection rule,
how to read colors or symbols, and the takeaway with its limits. Distinguish analysis versions
when an older figure accompanies newer results. Before handoff, check the actual delivery format:
essential explanations must remain visible in an export, and required figures/links must work
from the delivered location or be explicitly identified as unavailable. A printed collapsed
panel or a link into the author's local filesystem cannot supply essential context to a recipient.
For workflows producing tables, databases, reports or sequences, show their actual main outputs
and meaningful examples instead of inventing a figure gallery or a biological conclusion.

An analytical-choice explanation states the software/method, consequential parameters or
population definitions, why chosen, and relevant limits, with exact source references. Explain
normalization, tests, models, thresholds, exclusions, classification and what a measurement means.
Routine table plumbing is not automatically a scientific decision. Do not turn choices into an
autogenerated questionnaire or a repeated numbered index. Distinguish a method's observable
effect from the recorded reason for choosing it. When rationale is undocumented, say so; do not
invent an author justification or silently choose a replacement method.

Keep complete source intact and annotated throughout. Explain sections outside the code; do not
present dashboard prose as comments that were actually run. If annotations or readability are
inadequate, report the specific source gap and route improvement to the authorized source work
or `analysis-distillation`. A dashboard must not silently rewrite scientific source. Use
`audit-script` for an agreed technical audit when needed; this presentation does not substitute
for either audit or scientific acceptance.

## 4. Describe real files and objects

Use the file/preview contract in the page design. Reuse one underlying description for a file
that appears as an output and downstream input, while explaining its different use at each step.
Existing project records can supply that description; no new metadata schema is mandatory.
Give every substantive output the same minimum useful detail, including later scripts.

For external inputs, name the actual file, contents, source paper, dataset/file-listing page and
exact download when known. Explain selection/version context. Label local acquisition lists as
local lists. Never invent a citation, download link, filtering rationale or missing field.

Offer bounded **real captured previews** as the baseline across R, Python and shell workflows.
Show object structure as well as examples: class/shape, identifiers, fields/units and the unit
represented by a row or axis. Identify the actual file/version and the preview's selection and
truncation. Paired before/after previews sit outside the code beneath a relevant transformation,
only where they help; they are not input/output panels repeated for every section.

Prefer existing exports and small captures. Do not load huge objects into the browser, rerun the
pipeline or inspect sensitive records just to decorate the page. Use the project's environment,
data rules and cluster allocation policy for any separately authorized capture; load `data-handling`
before writing capture code that manipulates data. A live explorer is optional separate work:
never silently execute analysis code or expose a service. Keep captured previews usable without it.

Every script input/output file card includes a compact **File location** disclosure showing its
host and selectable full absolute filesystem path, plus **Copy full path** using that same path.
Resolve relative file references on the verified project/run host when generating the page; never
copy a project-relative path or derive the file location from the browser's dashboard directory.
If the full location is unknown, label that gap instead of offering a misleading copy action.
Link accessible files; remote paths are not Mac file links. Do not promise Finder/Explorer
integration or Windows behavior without testing it. Keep relative links for dashboard navigation.

## 5. Check and hand back

Read the main review path as the user would: overview → one task → its inputs → consequential
calculation → actual output and interpretation. Remove repeated headings, instruction sentences,
empty panels and redundant navigation. Preserve useful navigation: the task rail and top sibling-script
links are part of the accepted design. Keep the accepted visual hierarchy; do not add a dashboard
framework, status database, generic data discovery or a live server without a concrete need.

Check the actual changed surface:

- The visible task heading includes its number; task-rail links reach actual sections; sibling-script
  links are available at the top and identify the current script. A compact single-script review
  omits an empty switcher and may use compact section navigation instead of a rail.
- Page destinations and anchors exist; every task opens a task view. File/source links identify
  the intended files; inaccessible evidence is labelled honestly. Every script input/output card has
  the path disclosure; its displayed and copied full paths agree and belong to the stated host.
- Complete selected source is present once and in order; original line numbers or notebook cell
  identities are preserved. Highlight and explanation references point to the actual decision.
- Captured previews and plots are real, traceable and correctly labelled; saved-result identity
  and current source are not conflated. Reuse existing evidence for unchanged artifacts.
- The map represents real data flow; captions and output descriptions explain scientific meaning
  without claiming more than the recorded evidence supports.
- Inspect layout and interaction in the intended permitted browser when available: task links,
  section links, enlargement, long filenames/code and narrow-screen reading. Never evade browser
  policy or call static checks a browser test. Report any untested browser/platform behavior.

## 6. Package remote reviews for laptop use

On a cluster or another remote host, create a portable ZIP as part of the normal handoff unless
the user explicitly wants a host-only review. Package the selected review, not the whole project:

- Put one descriptively named overview HTML file at the extracted top level, for example
  `Project-Review.html`, and all supporting pages/files in one folder such as
  `review-files/`. Give the archive the same clear project/review identity. Update relative links
  in both directions when arranging this handoff; keep original source filenames inside the folder.
- Include the overview, task/script pages, local CSS/JavaScript, figures and captured
  previews. Include unchanged copies of the complete selected scientific scripts and project-owned
  helpers, plus relevant tests/wrappers and small existing provenance records needed for this review.
  Preserve the displayed source version and original filenames; distinguish it from the version
  that produced saved results. Use relative links to bundled copies while retaining original host
  labels and full paths on file cards.
- State briefly on the overview which inputs/results are included in full, represented only by
  previews, or left on the original host. Large datasets, environments and unrelated project files
  stay out by default. This is a review bundle; do not present it as a runnable reproduction checkout.
- Inspect the selected bundle contents and local dependencies before archiving. Do not accidentally
  follow links into unrelated directories or include credentials/private configuration. Use existing
  archive tools and a fresh, descriptive ZIP name outside the bundled directory. Preserve retained
  reviews and archives; no new packaging framework or scientific rerun is needed.
- Test ZIP integrity, extract into a fresh temporary directory and check that the bundled pages,
  assets, source and preview links resolve there. In the intended permitted laptop browser, when
  available, open the named overview HTML file and test navigation, figures and path-copy behavior.
  Repair missing required local assets before calling the bundle portable. Report extraction/link
  checks separately from browser checks and name any untested behavior.

Provide the actual archive path, size, front-page filename and short download/unzip/open directions.
Prefer an existing authenticated browser file service, such as an institutional Open OnDemand Files
page, when available. Verify the host and route before offering a clickable download; a portal login
page or a remote filesystem Markdown link does not establish a working file download. If only the
portal is verified, link it with the exact archive path and label the download untested; give a
verified-host `scp` alternative where useful. Keep authentication with the user. Do not introduce
public hosting, a new server, or an upload to another service as part of this handoff.

Hand back the actual overview link, selected grouping, source/result coverage, important evidence
or annotation gaps and checks/limits. Stop for critique or scientific review at the agreed scope.
Do not infer scientific acceptance from page use. A skill candidate, installed skill, project
adoption, natural use and lab-plugin release are separate states.
