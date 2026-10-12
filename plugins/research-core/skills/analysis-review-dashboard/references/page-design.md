# Page design and behavior

Preserve this hierarchy and restrained visual style. Prefer clear green task/step cards, white
content cards, dark readable filenames and code, and yellow analytical-choice notes/highlights.
Whitespace and boundaries separate ideas. Use a readable page width, wrapping filenames and
horizontally scrolling code; do not turn paragraphs into full-width walls of text. Source code
must remain selectable and accessible. Use ordinary links, native disclosures and a figure dialog;
no arrow-button panning, giant zoom canvas, crowded legends or gratuitous instructional copy.

## Overview

1. Concrete workflow/phase title and a brief scientific summary. Say what went in, what question
   was asked, how it was approached and what the saved results tell us. Describe actual outcomes,
   including limits or pending interpretation, rather than merely enumerating documents.
2. Clean task diagram. Each card shows **Task N · concrete scientific task**, a brief purpose,
   actual script filenames and exactly one **Open task** link. Connect only documented
   dependencies. Show branches without crossing spaghetti arrows. More than a handful of tasks
   can be grouped into scientific stages; each visible stage links to its task detail/navigation.
   Do not hide scripts behind unexplained labels or duplicate the plan's task ledger here.
3. Principal saved outputs. For figures, show actual artwork, a short description of what it
   measures and a substantive observation/interpretive limit. Keep **Enlarge figure**. A real
   alternative view may have a clearly labelled selector. No extra file/task links inside every
   figure card, “view saved figures” jump link or sentence explaining that artwork can be opened.
   For nonfigure outputs, use an appropriate real table/record/report preview with its meaning.
4. Bottom expandable **Figure files and source records** (or the output-specific equivalent).
   Identify the files displayed on this page, direct source locations and existing version/run
   records. This is not an unlabeled inventory of every pipeline file. Keep filenames and paths
   selectable; file links must point directly to the identified file when accessible.

A short status note is useful if interpretation is unfinished. Describe technical completion,
scientific review and figure acceptance separately, once at a useful location. Do not repeat a
warning or acceptance disclaimer in every card or add invented review-status controls.

## Task

1. At the top, in the visible main heading: **Task N · short concrete title**. A small label or
   browser-tab title alone is insufficient. Under it: the scientific question(s), then a concise
   abstract connecting input data, approach, output and scientific meaning. Retain a slim left
   navigation rail linking to the actual sections on substantive task pages; at narrow widths,
   place these links above the content. A compact combined overview/task can use a small local
   navigation row when a rail would add more structure than useful content.
2. Clean script diagram. Card tops explicitly say **Script N · operation**, with the actual
   filename immediately below. Make clear this diagram is within the named task. Preserve real
   script numbers where used; do not confuse display-task numbers with source script numbers.
3. Task-specific results/evidence. Explain what was obtained, what is odd or unresolved and how
   it is used next. Show useful intermediate evidence and links to the overview's main plots.
   Do not repeat the entire main gallery. If the result is only preparation, describe what was
   made ready and preserved; do not invent a scientific discovery.
4. **Input and output files by script**. Short groups for each script: real filenames, file types
   and one or two sentences about contents/use. Link to that script's fuller file description.
   External task inputs and internal produced→consumed files should be distinguishable. Reuse
   descriptions rather than maintaining contradictory duplicates at both levels.
5. **Run this task yourself**. Use the actual declared environment and a few explicit commands,
   expected successful outputs and any realistic runtime/resource requirement already known.
   State whether commands reuse outputs or require a fresh destination. Respect retained-result
   protections. Do not invent a runtime estimate, environment name or safe-rerun behavior.
   If the task is not ready to run, state the concrete missing requirement instead of presenting
   a supposedly runnable command. Offer help where environment/cluster execution is substantial.

Keep the broader position among tasks on the overview; do not duplicate its pipeline map or
add a neighboring-task strip to the task page. The task’s own script diagram remains here.

File-group headings describe what they are: “Gene-program input files”, “Stylophora atlas files”,
“Protein-search results”. Avoid “What did this task start with?”, a species name alone or a vague
“source evidence” heading when a more concrete one is possible.

## Script

### Top and whole-script files

Show the script name and role within its task, with a short purpose/result summary. At the top,
provide direct links to the other scripts in that task and visibly mark the current script. Keep
this switching row distinct from links back to the task/overview; a one-script task needs no empty
switcher. Shared scripts preserve the relevant task contexts rather than selecting only the first.
If displayed
source differs from the saved run, make that distinction visible before the code and link to its
full correspondence/identity evidence; do not bury it only in a footer. Use a simple
**Script sections** diagram: meaningful calculations, the main data flow and helpers where used.
Do not draw a false linear flow based on where function definitions appear in the file. Link map
nodes to actual section anchors. Do not add “Boxes follow the calculations…” or another diagram
instruction sentence. The code itself stays in original source order, even if the map follows
execution order; link helper calls to definitions to bridge those two views.

Give whole-script **Input files** and **Output files** cards with the detailed descriptions below.
Expandable structure/example previews belong to these cards. Shared outputs point to the
producer's description and say how this script uses them. Input/output cards are not repeated
inside every code section. Run guidance can link to the task's commands, with script-specific
arguments where helpful. Preserve complete source access; file details should not bury the code
under many expanded panels.

### A source section

A shared script page links to all relevant task views and identifies the run guidance for its
actual execution context. It must not imply it belongs only to the first task. One page still
contains the complete selected source once.

Use only the content that helps with this section, in this order:

1. Section title, original source range and a concrete plain-language introduction. Orient the
   reader to the relevant data or objects, explain what is calculated or defined here, and say
   what the result enables next. A substantive section often needs a short paragraph of two to
   four sentences; use the detail needed, not a sentence quota. Name important populations, units
   or transformations rather than saying “prepare evidence” or “process the data.” For helper
   definitions, explain the operation and where the main workflow uses it. Simple setup needs
   less space. Avoid repeating the file cards or every decision rationale in this introduction.
2. A yellow box for each consequential analytical decision here. Give a concise explanation,
   exact lines/cell references, software/algorithm and relevant parameters, why this choice, and
   a meaningful limitation. No box when the section has no such decision. Highlight matching
   code ranges with a light yellow background and a visible decision label, so color is not the
   only cue. Distinguish what the code does from a documented rationale; explicitly identify an
   unknown rationale. For consequential library defaults, check the relevant software version
   and effective setting; label unrecoverable settings rather than applying current defaults to
   an older run. Yellow does not mean the code failed an audit or the choice is accepted.
3. Actual annotated source with global original line numbers. Preserve blank lines and comments
   in the complete selected source; do not silently replace code with paraphrase or excerpts.
   Default to visible manageable sections, not dozens of collapsed code disclosures. Optional
   folding must not remove code from the page. Avoid a redundant section index above the map.
4. Relevant function cards alongside the source on wide screens, below it on narrow screens.
   Each gives name, purpose, what it takes/returns with meanings, shape/units when relevant and
   a source link. Include substantive helpers and important library calls that need explanation;
   do not create a card for every trivial builtin. Empty sidebars are omitted.
5. An optional paired before/after preview beneath the code for a transformation that is easier
   to understand by seeing real objects. It is separate from the code block, small and labelled.
   Explain a meaningful change in dimensions/labels and what evidence supports its cause.

Remove top “scientific choices” indexes, green reading-note overlays, per-section input/output
boxes, redundant “complete script in meaningful sections” boxes and empty “main workflow” panels.
Code comments should carry scientific annotations. Dashboard explanations contextualize decisions;
they do not impersonate source comments. If source annotations are sparse, show original source,
identify that gap and arrange separate authorized distillation/source improvement. Do not add a
review-only comment stream to conceal the problem.

For notebooks, retain code and relevant markdown in original cell order, with stable cell
identities or labelled notebook-order positions. Do not present generated export line numbers as
original notebook coordinates. For Quarto or mixed-language sources, preserve the actual source
and label languages; adapt the diagram and cards without forcing an R-only workflow.

## File descriptions

Each substantive file needs an understandable description; later producers are not exempt.
Technical logs, checksums and environment files may be grouped concisely by their actual role.

| Content | What to supply |
|---|---|
| Identity/location | Actual filename, format, host and active/copy/legacy status; accessible link, compact **File location** disclosure and **Copy full path** control. Reuse recorded identities/version evidence and state unverified details. |
| Contents | What it contains biologically/analytically; object class, dimensions and row/column unit, or document/sequence structure. Fields and units necessary to understand its use. |
| Purpose | Why this script needs or produces it; which script/figure reads it next or its terminal scientific use. |
| Origin | Input producer or external study/provider. For external data, paper link, dataset landing page, page listing the specific file, and exact download where available. Distinguish those links and show the final filename beside them. |
| Selection/context | Why this input/version/population was used; exclusions or substitutions. If the authors' reason is unknown, say so rather than attributing filtering to them. |
| Preview | Small real examples and structure, with file/version, capture date, selection, truncation and any sensitive-data restriction. No made-up values. |

Some formats do not have rows/columns; describe their real structure rather than forcing this
vocabulary. When metadata is missing, mark the specific unknown and investigate only what is
necessary. Do not fill every field with an empty label or a repetitive “not available” paragraph.

Use filename-level exact paths and source-page links. A source repository home is less useful
than the page listing the named file. Locally authored settings/download lists are local inputs,
not published experimental measurements. Distinguish a locally staged preview file from the
project's canonical dataset/results. A basename match alone does not establish identity.

On every script input/output file card, keep the full location in a small native `<details>`
disclosure labelled **File location**, separate from the object preview. Opening it shows the
host and full absolute filesystem path as selectable, wrapping text. The adjacent **Copy full
path** button copies exactly that path without a host prefix, `file://` URL or shell command.
Resolve project-relative references and home/environment shortcuts on the verified file host
when generating the dashboard. Use the actual project/run location, not the browser's HTML
location; this matters for downloaded reviews of cluster projects. Preserve Windows drive/UNC
paths when that is the file's actual host. If the full location is unknown, show that limitation
and omit/disable copying until resolved. Relative filenames can remain as compact labels and
relative links can still connect dashboard pages.

## Captured object previews

A disclosure on the file card can contain tabs or subheadings for **Structure**, **Example values**
and **Summary**. Structure is central: summary statistics alone do not make the object tangible.
Only add interactive tabs if useful; native expandable sections are enough for small previews.

- **R:** real class, dimensions, list/slot names and a bounded `str`-style structure; matrix
  orientation, relevant assay/metadata fields, a small real row/column excerpt. For sparse or
  Seurat objects, inspect structure without expanding a full dense matrix.
- **Python:** real type, shape, dtypes/keys, index/column meaning and a small excerpt. Arrays need
  axis meanings; AnnData can show obs/var/obsm/layers structure without materializing huge data.
- **Shell/file workflows:** actual format, headers and selected records; relevant record/sequence
  counts and lengths when recorded or cheaply obtained. Compressed/binary formats need the
  correct reader/format-aware command. Raw `head` on a BAM or gzip stream is not a useful preview.
- **Databases/indexes:** documented tables/collections/fields and a bounded real query/result
  where already available and safe. Do not require an entire database or a live query service in
  the browser. An external dependency is labelled, not copied into a competing project pipeline.

Offer a small “Inspect it yourself” command when useful, matching the actual format and existing
project environment. Clarify if loading the object needs a cluster allocation. Keep privacy and
capture-size limits from project instructions. An inaccessible object is an explicit preview gap;
its absence does not prevent reviewing available code and other evidence.

## Refresh and portability

Static HTML with local assets and relative links is the baseline; no mandatory web server, CDN,
package install, or browser-executed scientific runtime. Escape source code and file/content text
when inserting it into HTML; validate destinations rather than treating source strings as markup.
Keep page assets together and preserve important older reviews before replacing a used dashboard.
On refresh, update affected file descriptions, task summaries, source lines/highlights and previews
together; do not leave a decision attached to stale line numbers. Use a capture/source note and
existing producing-state records; no separate status ledger or mandatory new manifest.

Local file links are optional host-specific conveniences. Show remote paths with their host and
copyable text; do not make a remote cluster path look like a Mac-local file link. Folder-reveal
and clipboard operations depend on the browser; supply readable fallbacks. Do not claim native
Windows/macOS integration until tested. Live cross-host object exploration remains optional work.

For a remote review, follow the skill's portable-ZIP handoff: one descriptively named overview
HTML file at the top level, with every supporting page/file in one folder. Link included source,
previews and pages relatively, including return links from that folder to the overview, so
navigation survives extraction. File-location disclosures continue to
show the original host and absolute path. A bundled copy is labelled as a copy. On the overview,
briefly explain the bundle's coverage: full files, captured previews and evidence remaining on the
original host. Keep those distinctions visible when a remote file cannot be opened on the laptop.
