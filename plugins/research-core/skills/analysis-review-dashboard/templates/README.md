# Use the page templates

Copy these files into the chosen, authorized review-output directory, preserving any used earlier
review. They are editable presentation scaffolds, not a data-discovery tool or scientific runner.
Keep `review.css` and `review.js` beside the finished pages. The templates do not contain fabricated
scientific examples. The agent supplies verified content using the page design.

- `overview.html`: save as `index.html` for the main overview.
- `task.html`: make one `task-N.html` for each scientific task.
- `script.html`: make one `script-N.html` for each selected producer; shared producers have one page.

For one short script answering one question, use `task.html` as `index.html`, add the real main
outputs and bottom source-record disclosure from the overview, and remove the self-link to the
overview. Give the task content a stable anchor (for example `#task-1`) and keep its run guidance
at `#run`. The separate script page links back to those anchors. Do not repeat the abstract,
gallery or a one-task card that merely links to the same content. Multi-question workflows retain
the task pages needed for their scientific scope, even when they share one script.

In `task.html`, keep **Task N · title** in the visible `h1`. Fill `TASK_SECTION_NAVIGATION`
with a slim local rail using the pattern below. Link only existing content; use the provided
`#task-summary`, `#scripts`, `#results`, `#files` and `#run` anchors plus an actual source-record
anchor when present. The CSS turns the rail into a compact row on narrow screens. For a tiny
combined overview/task, omit the rail or keep a compact row if useful; do not add empty navigation.
The task’s script diagram stays here; its relationship to other tasks belongs on the overview.

In `script.html`, fill `SIBLING_SCRIPT_NAVIGATION` with a small top navigation row linking this
task’s actual scripts and marking the current link with `aria-current="page"`. Omit it for one
script. Use real script labels/filenames; numbered script labels are not mandatory for unnumbered
projects. Fill `TASK_NAVIGATION_LINKS` with links to every relevant task (one for an ordinary
producer). Fill `RUN_GUIDANCE_LINKS` with the applicable task/run links, labelled by execution
context if more than one is needed. Do not replace a shared script with duplicate source pages.
If displayed source differs from the saved run, use `OPTIONAL_SOURCE_VERSION_NOTE` for a short
visible note before the code, linking to the full identity/correspondence record below. Otherwise
omit it. Remove the duplicate overview link from a compact script page if its task link already
returns to that combined overview/task page.

Replace all `{{UPPER_CASE_SLOTS}}` before handback. Slots for cards/sections contain HTML assembled
from the patterns below; escape every inserted source/text value (`&`, `<`, `>`, quotes) and encode
URL paths safely. Preserve actual source lines and blank lines. Ordinary prose slots also need
escaping. Do not leave template instruction comments or empty optional panels in the finished UI.

The templates provide styling and basic native interactions. Adapt diagram layout to the actual
dependency graph; `.flow` alone is a linear map and must not misrepresent branching. Use short
branch rows or a small explicit SVG with labelled connections for branching. At narrow widths,
replace visual connectors with readable dependency text rather than inventing a new linear order.

## Task rail and sibling-script links

```html
<aside class="task-navigation"><nav aria-label="Task sections">
  <a href="#task-summary">Summary</a><a href="#scripts">Scripts</a>
  <a href="#results">Scientific outcome</a><a href="#files">Input and output files</a>
  <a href="#run">Run this task</a><a href="#sources">Source records</a>
</nav></aside>
<nav class="script-switcher" aria-label="Scripts in this task">
  <a href="script-01.html" aria-current="page">Script 01</a>
  <a href="script-02.html">Script 02</a>
</nav>
```

Adapt these links to actual page contents and task membership; never retain a missing destination.

## Task/step card

```html
<article class="step" id="task-N">
  <span class="eyebrow">Task N</span><h3>Concrete scientific task</h3>
  <p>Brief purpose.</p><p class="filenames"><code>actual-script.ext</code></p>
  <a href="task-N.html">Open task</a>
</article>
```

Task-page cards label **Script N** instead, list the actual filename and link to its complete
script review. Script-section cards link to section anchors. Do not insert repetitive “Choices”.

## File card

```html
<article class="card file" id="file-STABLE-NAME">
  <h3><code>actual-filename.ext</code></h3>
  <p>What it contains, row/axis meanings, relevant units and its use here.</p>
  <p>Produced by/used next by the actual script, or terminal scientific role.</p>
  <details class="file-location">
    <summary>File location</summary>
    <p>Host: ACTUAL_HOST</p>
    <p class="path"><code>ACTUAL_ABSOLUTE_PATH</code></p>
  </details>
  <button type="button" data-copy="ACTUAL_ABSOLUTE_PATH">Copy full path</button>
  <details><summary>Source and object preview</summary>REAL_CONTENT</details>
</article>
```

Use this location disclosure and copy control on every script input/output file card.
Replace both `ACTUAL_ABSOLUTE_PATH` slots with the same full filesystem path resolved on the
verified project/run host; escape the text and attribute values. Do not use a relative path,
host prefix, `file://` URL or the dashboard's own directory as the copy value. For an unknown
full location, show the limitation and omit/disable the copy control. The native disclosure
makes the path visible without copying and remains usable when clipboard access fails.

Include source paper/file-listing/download links for external inputs when known. Use one existing
file description across producer/consumer views. Omit an absent preview control rather than
showing a working-looking empty button. Copy failure is handled with selectable text.

## Script section with decision and function card

```html
<section class="source-section" id="section-STABLE-NAME">
  <h2>Section title</h2><p class="quiet">Source lines START–END</p>
  <p>Concrete introduction: relevant data, what this section calculates or defines, and what
  the result enables next. Give substantive sections enough simple detail to orient the reader.</p>
  <aside class="decision"><strong>Analytical choice · lines A–B</strong>
    <p>Method/parameters, rationale and meaningful limit.</p></aside>
  <div class="code-layout"><div class="code" aria-label="Actual source">
    <div class="source-line" id="L1"><a class="line-number" href="#L1">1</a><code>ESCAPED_SOURCE</code></div>
    <div class="source-line consequential" id="L2" aria-label="Line 2, analytical choice"><a class="line-number" href="#L2">2</a><code>ESCAPED_SOURCE</code></div>
  </div><aside class="functions">
    <article class="function-card"><h3><a href="#LDEFINITION">Actual function</a></h3>
      <p>Purpose.</p><dl><dt>Takes</dt><dd>Objects and meanings.</dd>
      <dt>Returns/writes</dt><dd>Objects, shapes, units and use.</dd></dl></article>
  </aside></div>
  <!-- Only if helpful: a real paired preview outside the source block. -->
</section>
```

Generate one `.source-line` for each original line, including blanks, in original order. Never
renumber separately by section. Omit unused decision/sidebar elements. Do not add explanatory
comments inside displayed source. Notebook cells use honest cell IDs instead of invented original
line numbers. Use a `.paired` grid with two labelled real captured previews below relevant code.

## Saved figure card

```html
<figure class="card figure">
  <img src="assets/ACTUAL_IMAGE.png" alt="Scientific description">
  <figcaption><h3>Figure name</h3><p>What it shows and what can be learned.</p>
    <button type="button" data-enlarge="assets/ACTUAL_IMAGE.png" data-title="Figure name">Enlarge figure</button>
  </figcaption>
</figure>
```

File links belong in the overview's bottom source-record disclosure. Real nonfigure outputs can
use a table, selected records or a short report excerpt in a card instead. Use the dialog and
script for enlargement; do not add a button when the actual image is unavailable. Each page
template includes that dialog, so task-specific intermediate plots can also be enlarged. Remove
the unused dialog from a finished page that contains no enlargement buttons.

## Nonfigure output card

```html
<article class="card output">
  <h3><code>actual-output.ext</code></h3>
  <p>What it contains, its unit and scientific use.</p>
  <details><summary>Structure and captured preview</summary>
    <p>Actual file/version, capture date, selected fields/records and truncation.</p>
    <pre><code>ESCAPED_REAL_CAPTURE</code></pre>
  </details>
</article>
```

Use a real structure/header alongside the bounded record, rather than only totals. A release
descriptor is a descriptor; do not represent it as a preview of unavailable database contents.
Keep exact file access in the page's source records or whole-script file card.
