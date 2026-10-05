---
name: quarto-docs
description: >
  Quarto document conventions for data science analysis scripts (.qmd). Use when creating or
  rendering .qmd analysis scripts in data science projects with numbered scripts and retained
  outputs. Do NOT load for Quarto books, websites, or ordinary documentation projects.
---

# Quarto Documents

Use this skill when the researcher chooses a Quarto analysis document. R and Python are both
supported; follow the project's agreed language, formats and pipelines. Quarto is useful when
narrative, figures and intermediate results belong together. Plain scripts remain valid choices.
See `script-organization` for analysis layout and provenance; ordinary document editing does
not inherit those analysis requirements.

## Rendering (CRITICAL)

**Use `quarto render`, never `rmarkdown::render()`** for `.qmd` files.

The commands below are standalone examples: no Quarto project configuration, launched from
repository root. Replace the example paths and environment names for the actual analysis.
For a declared Quarto project, use its existing configuration and layout as described below.

```bash
quarto render scripts/01_analysis.qmd --execute-dir "$PWD" --output-dir "$PWD/outs/01_analysis/"
```

If Quarto is not in `PATH`, use the executable declared by the project environment or optional site profile. Do not assume a host-specific installation path.

### Use the declared compatible runtime

Use the project's selected R runtime with renv or its other declared package setup, or its
selected Python runtime with Conda, venv or another established setup. renv manages R packages;
it does not itself select the R executable. Check the actual R version/location or Python
interpreter and selected Jupyter kernel before relying on execution.

When Python uses Conda, setup, activation and rendering must stay in the **same Bash invocation**:

```bash
# Python QMD — when the project selects Conda; setup and render share one shell
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && quarto render scripts/02_plots.qmd --execute-dir "$PWD" --output-dir "$PWD/outs/02_plots/"
```

If Conda is not initially discoverable, prepend the project's declared setup command.
Do not invent a module or installation path.

Activation alone does not prove that a named Jupyter kernel uses that interpreter. See the
kernel troubleshooting below; preserve an established non-Conda runtime.

## Rendering Options

```bash
# Standalone render to the document's default format
quarto render scripts/XX_name.qmd --execute-dir "$PWD" --output-dir "$PWD/outs/XX_name/"

# Standalone render to a specific format
quarto render scripts/XX_name.qmd --to html --execute-dir "$PWD" --output-dir "$PWD/outs/XX_name/"
quarto render scripts/XX_name.qmd --to pdf --execute-dir "$PWD" --output-dir "$PWD/outs/XX_name/"

# Enable execution; this still renders the document
quarto render scripts/XX_name.qmd --execute --execute-dir "$PWD" --output-dir "$PWD/outs/XX_name/"
```

## Rendering Output Location

Keep rendered analysis documents in the producer's output area. Resolve the artifact path for
the actual rendering mode rather than assuming `--output-dir` is relative to the caller:

- **Standalone document (no Quarto project):** for a nested source such as
  `scripts/01_analysis.qmd`, a relative `--output-dir outs/01_analysis/` can land under
  `scripts/outs/01_analysis/`. From repository root, the quoted absolute destination below
  writes the standalone HTML to `outs/01_analysis/01_analysis.html`.
- **Declared Quarto project:** honor `_quarto.yml` and the project's existing render/output
  layout. Quarto can preserve the source's `scripts/` nesting under the chosen output directory,
  even when that directory is absolute. An absolute path does not flatten a project layout;
  do not change project configuration or move files merely to match the standalone example.

```bash
# Standalone document, launched from repository root
quarto render scripts/01_analysis.qmd --execute-dir "$PWD" --output-dir "$PWD/outs/01_analysis/"

# Same standalone case, with a compatible declared R executable when needed
QUARTO_R=/path/to/project/R/bin/R quarto render scripts/01_analysis.qmd --execute-dir "$PWD" --output-dir "$PWD/outs/01_analysis/"
```

After rendering, check the command's exit status and the actual expected HTML/PDF path and
content. A successful computational chunk or run record does not certify the rendered
document; report the whole QMD run complete only after the renderer succeeds and that artifact
is verified.

## Format Choice

| Format | Best for | Notes |
|--------|----------|-------|
| **HTML** | GitHub, web sharing | Reliable text wrapping, self-contained |
| **PDF** | Print, formal docs | Requires LaTeX workarounds for line wrapping |

**Recommendation:** Use HTML for GitHub/web. Use PDF only when print is required.

## Development Checks Without Rendering

Extracted R or Python code may run directly with `Rscript` or `python` in the selected project
runtime for a bounded development check. These outputs are **provisional**: record the actual
extraction/launch command, code state and inputs, and replace the template's `quarto render`
invocation with the command that really ran. Do not report a complete QMD render from extracted
code. Before retained scientific use, rerun the checkpointed saved producer through its agreed
workflow. `quarto render --execute` executes code **and renders**; it is not a code-only command.

---

## QMD Templates

Templates keep the analysis readable and write outputs to the producer's directory. Adapt source
paths, output names and the seed to the actual analysis and random APIs. The project's established
run record, workflow engine or execution log binds retained outputs to source, inputs and runtime;
do not duplicate that machinery inside every QMD. The examples assume a standalone render from
repository root. See `script-organization` for provenance, rerun behavior and output preservation.
For lettered workflows, `out_dir` and the render destination name the producer's child directory
under the shared topic root (for example, `outs/15_topic/15b_modules/`).

The setup refuses a nonempty producer directory, including an earlier rendered document. Preserve
that run or choose a fresh destination before rendering again. An explicitly disposable reproduction
destination can use a documented replacement policy instead; do not bypass the guard just to retry.

### Shared YAML Header

The YAML header is similar for R and Python; Python adds the selected Jupyter kernel.
`python3` below is an example, not proof of the intended runtime. If the intended registered
kernel is `PROJECT_ENV`, set `jupyter: PROJECT_ENV` rather than leaving `python3`.

**R:**
```yaml
---
title: "Script Title"
subtitle: "Brief description"
author: "Your Name"
date: today
format:
  html:
    toc: true
    toc-depth: 2
    number-sections: true
    code-overflow: wrap
    code-fold: false
    code-tools: true
    highlight-style: github
    theme: cosmo
    fontsize: 1rem
    linestretch: 1.5
    self-contained: true
execute:
  echo: true
  message: false
  warning: false
  cache: false
---
```

**Python** — same, but select the intended kernel and drop the R-specific `message: false`:
```yaml
---
title: "Script Title"
subtitle: "Brief description"
author: "Your Name"
date: today
jupyter: python3
format:
  html:
    toc: true
    toc-depth: 2
    number-sections: true
    code-overflow: wrap
    code-fold: false
    code-tools: true
    highlight-style: github
    theme: cosmo
    fontsize: 1rem
    linestretch: 1.5
    self-contained: true
execute:
  echo: true
  warning: false
  cache: false
---
```

---

### AI Attribution Block

When an agent generates a QMD script, include an attribution callout immediately after the YAML
header (before any content). Record the actual agent and model when known; say the model is
unknown when it is not exposed. Attribution records authorship, not a reproducibility guarantee.

````markdown
::: {.callout-note title="Code generation"}
This script was generated by **[actual agent and model]**. Human review is pending.
:::
````

**Rules:**

- **Always include** when Codex, Claude or another agent writes a new QMD script
- **Use truthful agent/model attribution**; requested settings are not evidence of the serving model
- **Record completed review only when it occurred.** Replace the pending statement with the
  actual reviewer's name after review; the YAML author alone is not evidence of review.
- **Do NOT include** when a human wrote the script and an agent only made minor edits — instead, note the agent's contributions in a comment near the edited code
- **Do NOT remove** an existing attribution block when editing an agent-generated script
- The callout renders visibly in the HTML output so readers know the provenance at a glance

---

### R Template Chunks

**Setup chunk:**

````
```{r setup}
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  # ... other packages
})

options(stringsAsFactors = FALSE)
random_seed <- 42
set.seed(random_seed)

# This producer's directory; document whether a rerun replaces or preserves existing outputs.
out_dir <- here("outs/XX_script_name")
if (dir.exists(out_dir) && length(list.files(out_dir, all.files = TRUE, no.. = TRUE)) > 0) {
  stop("Preserve existing outputs or choose a fresh destination: ", out_dir)
}
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
# source(here("R/helpers.R"))
```
````

**Input section** (immediately after setup):

````
```{r inputs}
# --- Inputs (from other scripts) ---
mdata <- readRDS(here("outs/01_analysis/mdata.rds"))

# --- Inputs (external data) ---
gene_names <- read_tsv(here("data/gene_naming/names.tsv"))
```
````

**Final chunk** (after all outputs are written):

````
```{r output-checks}
expected_outputs <- c(file.path(out_dir, "result.tsv")) # replace with this script's outputs
missing_outputs <- expected_outputs[!file.exists(expected_outputs)]
if (length(missing_outputs) > 0) stop("Expected outputs are missing: ", paste(missing_outputs, collapse = ", "))
cat("Wrote", length(expected_outputs), "outputs to", out_dir, "\n")
```
````

---

### Python Template Chunks

**Setup chunk:**

````
```{python}
#| label: setup

import sys
import random
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# The documented render command sets Quarto's execution directory to the repository root.
PROJECT_ROOT = Path.cwd()
sys.path.insert(0, str(PROJECT_ROOT / "python"))

# ---- Options ----
RANDOM_SEED = 42
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)
pd.set_option("display.max_columns", None)
sns.set_theme(style="whitegrid")

# ---- Paths ----
# This producer's directory; document whether a rerun replaces or preserves existing outputs.
out_dir = PROJECT_ROOT / "outs/XX_script_name"
if out_dir.exists() and any(out_dir.iterdir()):
    raise FileExistsError(f"Preserve existing outputs or choose a fresh destination: {out_dir}")
out_dir.mkdir(parents=True, exist_ok=True)
# from helpers import ...
```
````

**Input section** (immediately after setup):

````
```{python}
#| label: inputs

# --- Inputs (from other scripts) ---
modules = pd.read_csv(PROJECT_ROOT / "outs/02_module_lists/modules.tsv", sep="\t")

# --- Inputs (external data) ---
gene_names = pd.read_csv(PROJECT_ROOT / "data/gene_naming/names.tsv", sep="\t")
```
````

**Saving figures:**

````
```{python}
#| label: fig-example
#| fig-cap: "Description of figure"

fig, ax = plt.subplots(figsize=(6, 4))
# ... plotting code ...
plt.tight_layout()

# Save the phase-final figure at the explicit 6 x 4 inch canvas, then display inline.
# A preliminary-only run may use just PNG.
for extension in ("png", "pdf", "svg"):
    fig.savefig(out_dir / f"figure_name.{extension}", dpi=300)
plt.show()
```
````

For seaborn:
````
```{python}
g = sns.catplot(data=df, x="condition", y="value", kind="box", height=4, aspect=1.5)
for extension in ("png", "pdf", "svg"):
    g.figure.savefig(out_dir / f"boxplot.{extension}", dpi=300)
plt.show()
```
````

**Final chunk:**

````
```{python}
#| label: output-checks

EXPECTED_OUTPUTS = [out_dir / "result.tsv"]  # replace with this script's outputs
missing_outputs = [path for path in EXPECTED_OUTPUTS if not path.is_file()]
if missing_outputs:
    raise RuntimeError(f"Expected outputs are missing: {missing_outputs}")
print(f"Wrote {len(EXPECTED_OUTPUTS)} outputs to {out_dir}")
```
````

---

### R vs Python Quick Reference

| Convention | R | Python |
|------------|---|--------|
| **Project root** | `here::here()` | `Path.cwd()` with `quarto render ... --execute-dir "$PWD"` from repository root |
| **Read CSV** | `read_csv(here("data/file.csv"))` | `pd.read_csv(PROJECT_ROOT / "data/file.csv")` |
| **Read TSV** | `read_tsv(here("data/file.tsv"))` | `pd.read_csv(PROJECT_ROOT / "data/file.tsv", sep="\t")` |
| **Read Parquet** | `arrow::read_parquet(here(...))` | `pd.read_parquet(PROJECT_ROOT / ...)` |
| **Read RDS** | `readRDS(here(...))` | N/A (use Parquet for cross-language) |
| **Save figure** | `ggsave(file.path(out_dir, "fig.pdf"))` | `fig.savefig(out_dir / "fig.pdf")` |
| **Random seed** | `set.seed(42)` | `random.seed(42)` + `np.random.seed(42)` |
| **Runtime diagnostics** | `sessionInfo()` + `R.home()` | `sys.version` + `sys.executable`; optional `session_info.show()` |
| **Suppress startup** | `suppressPackageStartupMessages()` | N/A (Python imports are quiet) |
| **Chunk label** | `{r label-name}` or `#| label:` | `#| label:` only |
| **Helper loading** | `source(here("R/helpers.R"))` | `sys.path.insert(0, str(PROJECT_ROOT / "python"))` |

---

### Language Mixing

**Prefer one language per analysis file.** Follow `script-organization`'s existing exception
when both languages work on the same data in a tight pipeline: a mixed `.qmd` may use files
for interchange. Preserve the project's agreed workflow; do not infer shared-memory exchange.

---

## What Shows in the Rendered Output

Keep routine startup/validation detail quiet, but print substantive data summaries and anomaly
summaries in visible chunks. `#| include: false` hides **all** cell output, including warnings
and messages; consequential failed checks should stop execution, but a hidden warning is not
guaranteed to reach the reader.

The example YAML suppresses messages/warnings globally. Override those defaults in a visible
cell when a warning or message matters. For R, use `#| include: true`, `#| warning: true` and
`#| message: true` as relevant; for Python/Jupyter use a visible cell with `#| warning: true`.
Print the substantive summary as well, so it appears with the results.

````
```{r anomaly-summary}
#| include: true
#| warning: true
#| message: true
print(summary_table)  # actual counts/coverage and unresolved cases
if (n_unmatched > 0) warning("Unmatched inputs remain; see the summary above")
```
````

Use R `print()`/`glimpse()` or Python `print()`/`df.info()`/`df.describe()` for visible summaries.
What to validate and which anomalies need attention belongs to the `data-handling` skill.

---

## Troubleshooting Quarto Rendering

### Shell commands in Python cells

Quarto's **Jupyter engine supports `!command` shell syntax**; its Python kernel is not
universally plain Python. See [Quarto shell commands](https://quarto.org/docs/computations/execution-options.html#shell-commands).
Prefer `subprocess` when the same code should also run as an extracted plain-Python script.
Jupyter shell syntax is not portable to plain Python or a Python chunk executed by Knitr/reticulate.

```python
# Portable to Jupyter and plain Python
import subprocess
subprocess.run(["tool", "--version"], check=True)
```

### Triple backticks inside a Python string break the code fence
**Cause:** Quarto parses the raw `.qmd` file for code fences before Python ever sees the string
contents, so a literal ` ``` ` inside a Python string (e.g. a markdown-report template) is read as
the *cell's own* closing fence, truncating the cell.
**Fix:** Store any template that itself contains markdown code blocks as a separate `.md` file
(e.g. under `templates/` alongside the script) and load it at runtime with `read_text()`, rather
than embedding it as a Python string literal in the `.qmd`.

### Python QMD: `__file__` is not defined
**Cause:** Quarto runs Python QMDs via Jupyter, where `__file__` doesn't exist.
**Fix:** For the root-launched examples in this skill, set Quarto's computation directory with
`--execute-dir "$PWD"`, then use `Path.cwd()`. If a project supports launching elsewhere, pass its
root explicitly or use its established project-root helper. Never use `Path(__file__)` in QMD files.

```python
# Correct when the render command uses --execute-dir "$PWD"
PROJECT_ROOT = Path.cwd()

# WRONG — fails in Jupyter/Quarto
PROJECT_ROOT = Path(__file__).resolve().parents[1]
```

### Missing `nbformat`, `nbclient`, or `ipykernel`

Diagnose the actual interpreter and selected Jupyter kernel first; a missing package may mean
the wrong runtime was selected. Check these execution dependencies in the declared environment.
If a dependency change is necessary, coordinate it through the lead and the project's existing
environment/specification procedure. Do not blindly install packages, create an environment or
register a global kernel as a rendering remedy.

### HTML output lands under `scripts/` or in an unexpected nested directory

Check whether this is a standalone document or a declared Quarto project and inspect the actual
artifact path. For the standalone root-launched case, use:

```bash
quarto render scripts/XX_name.qmd \
  --execute-dir "$PWD" \
  --output-dir "$PWD/outs/XX_name/"
```

For a Quarto project, honor the configured layout and any preserved source-directory nesting;
see Rendering Output Location above. Check exit status and the expected artifact's content.

### Quarto uses the wrong Python kernel

Inspect the selected environment's `sys.executable`, the document's `jupyter` metadata and the
intended kernelspec. See [Quarto kernel selection](https://quarto.org/docs/computations/python.html#kernel-selection).
When the project uses Conda, activate it in the same Bash invocation as diagnostics/rendering;
using the declared setup, for example when Conda is discoverable:

```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && python -c 'import sys; print(sys.executable)'
```

Only if an intended named kernel is missing and user-level registration is authorized, register
it from the selected runtime. `--user` changes host-level Jupyter state; it is not an automatic
step of creating a QMD. Conditional Conda examples:

```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && python -m ipykernel install --user --name PROJECT_ENV
```

Registration alone does not select that kernel. Choose it in the QMD metadata:

```yaml
jupyter: PROJECT_ENV
```

Then render with the same runtime setup as above and verify the actual interpreter reported by
the executed document. Apply the project's equivalent procedure for a non-Conda runtime.

---

## Reference Files

| Topic | File |
|-------|------|
| Narrative structure and publication-quality HTML/PDF options; read when drafting those parts | [references/pdf-formatting.md](references/pdf-formatting.md) |
