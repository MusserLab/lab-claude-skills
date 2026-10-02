---
name: quarto-docs
description: >
  Quarto document conventions for data science analysis scripts (.qmd). Use when creating or
  rendering .qmd analysis scripts in data science projects with numbered scripts,
  producing-state capture, and BUILD_INFO.txt. Do NOT load for Quarto books, websites, or documentation
  projects — those use standard Quarto conventions without numbered script prefixes or BUILD_INFO.txt.
---

# Quarto Documents

Use this skill when the researcher chooses a Quarto analysis document. R and Python are both
supported; follow the project's agreed language, formats and pipelines. Quarto is useful when
narrative, figures and intermediate results belong together. Plain scripts remain valid choices.
See `script-organization` for analysis layout and provenance; ordinary document editing does
not inherit those analysis requirements.

## Rendering (CRITICAL)

**Always use `quarto render`, never use `rmarkdown::render()`** for `.qmd` files.

```bash
# CORRECT: Use quarto CLI
quarto render scripts/01_analysis.qmd --output-dir outs/01_analysis/

# WRONG: Do NOT use rmarkdown
Rscript -e "rmarkdown::render('script.qmd')"  # Will fail with pandoc error
```

If Quarto is not in `PATH`, use the executable declared by the project environment or optional site profile. Do not assume a host-specific installation path.

### Python QMDs require conda activation

**CRITICAL:** For Python `.qmd` files, the project's conda environment must be active before rendering. Otherwise Quarto will use the wrong Python or fail to find packages.

```bash
# R QMD — use the project's declared R/renv environment
quarto render scripts/01_analysis.qmd --output-dir outs/01_analysis/

# Python QMD — setup, activation, and render stay in one shell call
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && quarto render scripts/02_plots.qmd --output-dir outs/02_plots/
```

If `conda` is not initially discoverable, prepend the setup command declared by the project or
selected site profile. Do not invent a module or installation path.

## Rendering Options

```bash
# Render to default format, output to outs/
quarto render scripts/XX_name.qmd --output-dir outs/XX_name/

# Render to specific format
quarto render scripts/XX_name.qmd --to html --output-dir outs/XX_name/
quarto render scripts/XX_name.qmd --to pdf --output-dir outs/XX_name/

# Render with execution
quarto render scripts/XX_name.qmd --execute --output-dir outs/XX_name/
```

## Rendering Output Location

**CRITICAL:** Always use `--output-dir` to render HTML directly into the script's `outs/` folder. Never leave rendered HTML next to the `.qmd` source file.

```bash
# CORRECT: Render directly to outs/ folder
quarto render scripts/01_analysis.qmd --output-dir outs/01_analysis/

# CORRECT: With the R executable declared for this project
QUARTO_R=/path/to/project/R/bin/R \
  quarto render scripts/01_analysis.qmd --output-dir outs/01_analysis/

# WRONG: Do NOT render in place (pollutes scripts/ with HTML)
quarto render scripts/01_analysis.qmd
```

The `--output-dir` path is relative to the project root (where you run the command from).

## Format Choice

| Format | Best for | Notes |
|--------|----------|-------|
| **HTML** | GitHub, web sharing | Reliable text wrapping, self-contained |
| **PDF** | Print, formal docs | Requires LaTeX workarounds for line wrapping |

**Recommendation:** Use HTML for GitHub/web. Use PDF only when print is required.

## Running Code Without Rendering

When you just need outputs, not the rendered document:

**R:**
- Extract R code and run with `Rscript` directly
- Or use `quarto render script.qmd --execute`

**Python:**
- Extract Python code and run with `python` directly (with conda env active)
- Or use `quarto render script.qmd --execute` (with conda env active)

---

## QMD Templates

Templates bind retained outputs to a commit containing the declared producing files and write
BUILD_INFO.txt provenance.
See the `script-organization` skill for input/completion checks and output preservation.
For new lettered workflows, `out_dir` and the render destination name the producer's child
directory under the shared topic root (for example, `outs/15_topic/15b_modules/`). Each stage
has its own completion record and may read upstream files from siblings. Preserve existing
project paths pending separately scoped adoption; the generic directory guard is not suitable
for a legacy flat directory shared by multiple producers without adapting its ownership checks.

### Shared YAML Header

The YAML header is identical for R and Python, except Python adds `jupyter: python3`:

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

**Python** — same, but add `jupyter: python3` and drop `message: false` (not applicable):
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

When an agent generates substantial code for a new QMD script, include an attribution callout immediately after the YAML header. Record the actual agent and model; do not infer human review from the YAML author field.

````markdown
::: {.callout-note title="Code generation"}
This script was generated by **[actual agent and model]**. Human review is pending.
:::
````

**Rules:**

- Include the callout for substantial agent-generated code, using the actual agent and model.
- Record completed review only when it occurred; otherwise retain the pending statement.
- For minor agent edits to human-authored code, note the contribution near the edit when useful.
- Preserve an existing accurate attribution and update it only when its recorded state changes.
- Keep the provenance visible in rendered output.

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

# Declare the committed producer, sourced helpers, non-secret configuration and environment lock.
relevant_source_paths <- c("scripts/XX_script_name.qmd")
input_identities <- c(
  "data/.../file.tsv | external input; checksum/manifest: <identity>",
  "outs/.../file.tsv | producer completion record: <path and identity>"
)
invocation <- "quarto render scripts/XX_script_name.qmd --output-dir outs/XX_script_name/"

options(stringsAsFactors = FALSE)
random_seed <- 42
set.seed(random_seed)

# This producer's directory, e.g. outs/15_topic/15b_modules/ for a lettered stage.
out_dir <- here("outs/XX_script_name")
if (dir.exists(out_dir) && length(list.files(out_dir, all.files = TRUE, no.. = TRUE)) > 0) {
  stop(
    "Output destination is not empty; use a fresh path or preserve/clear it only after ",
    "confirming the existing producer-owned outputs are disposable"
  )
}
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
build_info_path <- file.path(out_dir, "BUILD_INFO.txt")

relevant_files <- file.path(here(), relevant_source_paths)
if (!all(file.exists(relevant_files) & !dir.exists(relevant_files))) {
  stop("A declared producing file is missing")
}
git_commit <- system2("git", c("-C", shQuote(here()), "rev-parse", "HEAD"), stdout = TRUE)

git_value <- function(arguments) {
  value <- suppressWarnings(system2(
    "git", c("-C", shQuote(here()), arguments), stdout = TRUE, stderr = TRUE
  ))
  if ((!is.null(attr(value, "status")) && attr(value, "status") != 0L) || length(value) != 1) {
    return(NA_character_)
  }
  unname(value)
}
committed_blobs <- vapply(
  relevant_source_paths,
  function(relative) git_value(c("rev-parse", shQuote(paste0(git_commit, ":", relative)))),
  character(1)
)
working_blobs <- vapply(
  relevant_source_paths,
  function(relative) git_value(c("hash-object", shQuote(relative))),
  character(1)
)
if (anyNA(committed_blobs) || anyNA(working_blobs) || !identical(committed_blobs, working_blobs)) {
  stop("Relevant producing files do not match HEAD; make a focused commit before retained execution")
}
cat("Producing commit:", git_commit, "\n")

# source(here("R/helpers.R"))  # include it in relevant_source_paths above
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
```{r build-info}
expected_outputs <- c(file.path(out_dir, "result.tsv")) # replace with this script's outputs
missing_outputs <- expected_outputs[!file.exists(expected_outputs)]
if (length(missing_outputs) > 0) stop("Expected outputs are missing: ", paste(missing_outputs, collapse = ", "))
final_working_blobs <- vapply(
  relevant_source_paths,
  function(relative) git_value(c("hash-object", shQuote(relative))),
  character(1)
)
if (anyNA(final_working_blobs) || !identical(committed_blobs, final_working_blobs)) {
  stop("Relevant producing files changed during execution")
}

session_evidence <- capture.output(sessionInfo())
build_lines <- c(
  "completion: complete",
  "script: scripts/XX_script_name.qmd",
  paste("date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  paste("commit:", git_commit),
  paste("environment:", R.version.string),
  paste("invocation:", invocation),
  paste("seed:", random_seed),
  paste("input:", input_identities),
  paste("source:", relevant_source_paths, "| content verified against commit"),
  paste("output:", expected_outputs),
  paste("session:", session_evidence)
)
writeLines(build_lines, build_info_path)
```
````

---

### Python Template Chunks

**Setup chunk:**

````
```{python}
#| label: setup

import subprocess
import sys
import random
import platform
from pathlib import Path
from datetime import datetime

import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

PROJECT_ROOT = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).decode().strip())
sys.path.insert(0, str(PROJECT_ROOT / "python"))

# Declare the committed producer, imported helpers, non-secret configuration and environment lock.
RELEVANT_CODE_PATHS = [Path("scripts/XX_script_name.qmd")]
INPUT_IDENTITIES = [
    "data/.../file.tsv | external input; checksum/manifest: <identity>",
    "outs/.../file.tsv | producer completion record: <path and identity>",
]
INVOCATION = "quarto render scripts/XX_script_name.qmd --output-dir outs/XX_script_name/"

# ---- Options ----
RANDOM_SEED = 42
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)
pd.set_option("display.max_columns", None)
sns.set_theme(style="whitegrid")

# ---- Paths ----
# This producer's directory, e.g. outs/15_topic/15b_modules/ for a lettered stage.
out_dir = PROJECT_ROOT / "outs/XX_script_name"
if out_dir.exists() and any(out_dir.iterdir()):
    raise RuntimeError(
        "Output destination is not empty; use a fresh path or preserve/clear it only after "
        "confirming the existing producer-owned outputs are disposable"
    )
out_dir.mkdir(parents=True, exist_ok=True)
build_info_path = out_dir / "BUILD_INFO.txt"

RELEVANT_CODE_PATHS = [Path(relative) for relative in RELEVANT_CODE_PATHS]
if any(relative.is_absolute() or ".." in relative.parts for relative in RELEVANT_CODE_PATHS):
    raise ValueError("Relevant producing paths must be repository-relative")
if any(not (PROJECT_ROOT / relative).is_file() for relative in RELEVANT_CODE_PATHS):
    raise FileNotFoundError("A declared producing file is missing")

GIT_COMMIT = subprocess.check_output(
    ["git", "rev-parse", "HEAD"], cwd=PROJECT_ROOT, text=True
).strip()

def relevant_blob_ids():
    committed = []
    working = []
    for relative in RELEVANT_CODE_PATHS:
        committed.append(subprocess.check_output(
            ["git", "rev-parse", f"{GIT_COMMIT}:{relative.as_posix()}"],
            cwd=PROJECT_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip())
        working.append(subprocess.check_output(
            ["git", "hash-object", str(relative)], cwd=PROJECT_ROOT, text=True
        ).strip())
    return committed, working

try:
    COMMITTED_BLOBS, WORKING_BLOBS = relevant_blob_ids()
except subprocess.CalledProcessError as error:
    raise RuntimeError(
        "Relevant producing files do not match HEAD; make a focused commit before retained execution"
    ) from error
if COMMITTED_BLOBS != WORKING_BLOBS:
    raise RuntimeError(
        "Relevant producing files do not match HEAD; make a focused commit before retained execution"
    )
print(f"Producing commit: {GIT_COMMIT}")

# from helpers import ...  # include the module path in RELEVANT_CODE_PATHS above
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
#| label: build-info

EXPECTED_OUTPUTS = [out_dir / "result.tsv"]  # replace with this script's outputs
missing_outputs = [path for path in EXPECTED_OUTPUTS if not path.is_file()]
if missing_outputs:
    raise RuntimeError(f"Expected outputs are missing: {missing_outputs}")
try:
    _, FINAL_WORKING_BLOBS = relevant_blob_ids()
except subprocess.CalledProcessError as error:
    raise RuntimeError("Relevant producing files changed during execution") from error
if FINAL_WORKING_BLOBS != COMMITTED_BLOBS:
    raise RuntimeError("Relevant producing files changed during execution")

# Collect session evidence before writing the completion record. These values use only the
# standard library and packages already required by this script.
session_evidence = [
    f"python: {sys.version.splitlines()[0]}",
    f"executable: {sys.executable}",
    f"platform: {platform.platform()}",
    f"numpy: {np.__version__}",
    f"pandas: {pd.__version__}",
    f"matplotlib: {matplotlib.__version__}",
    f"seaborn: {sns.__version__}",
]

lines = [
    "completion: complete",
    "script: scripts/XX_script_name.qmd",
    f"date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
    f"commit: {GIT_COMMIT}",
    f"environment: {sys.version.splitlines()[0]}",
    f"invocation: {INVOCATION}",
    f"seed: {RANDOM_SEED}",
]
lines.extend(f"input: {identity}" for identity in INPUT_IDENTITIES)
lines.extend(f"source: {relative} | content verified against commit" for relative in RELEVANT_CODE_PATHS)
lines.extend(f"output: {path.relative_to(PROJECT_ROOT)}" for path in EXPECTED_OUTPUTS)
lines.extend(f"session: {item}" for item in session_evidence)
build_info_path.write_text("\n".join(lines) + "\n")
```
````

---

### R vs Python Quick Reference

| Convention | R | Python |
|------------|---|--------|
| **Project root** | `here::here()` | `PROJECT_ROOT` (from git) |
| **Read CSV** | `read_csv(here("data/file.csv"))` | `pd.read_csv(PROJECT_ROOT / "data/file.csv")` |
| **Read TSV** | `read_tsv(here("data/file.tsv"))` | `pd.read_csv(PROJECT_ROOT / "data/file.tsv", sep="\t")` |
| **Read Parquet** | `arrow::read_parquet(here(...))` | `pd.read_parquet(PROJECT_ROOT / ...)` |
| **Read RDS** | `readRDS(here(...))` | N/A (use Parquet for cross-language) |
| **Save figure** | `ggsave(file.path(out_dir, "fig.pdf"))` | `fig.savefig(out_dir / "fig.pdf")` |
| **Random seed** | `set.seed(42)` | `random.seed(42)` + `np.random.seed(42)` |
| **Session info** | `sessionInfo()` captured in `BUILD_INFO.txt` | Python/platform/imported package versions captured in `BUILD_INFO.txt` |
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

Validation is noisy and belongs out of the rendered document; data summaries are the point of it
and belong in. Put checks in a chunk marked `#| include: false` and keep the summary chunk visible.

**R** — `cat()` for verbose diagnostics (hidden by `include: false`), `message()` for warnings that
must appear during rendering, `print()` and `glimpse()` for summaries you want in the document.

**Python** — `print()` for diagnostics, `warnings.warn()` for warnings that must surface in the
render, `df.info()` / `df.head()` / `df.describe()` for summaries you want in the document.

What to validate, and what counts as a summary worth showing, belongs to the `data-handling` skill.

---

## Troubleshooting Quarto Rendering

### Python QMD: prefer `subprocess` for portable shell commands
Quarto's [shell-command documentation](https://quarto.org/docs/computations/execution-options.html#shell-commands)
distinguishes its execution engines. Jupyter Python cells support shell magic such as `!command`;
the Knitr route uses `{bash}` cells and can execute Python through reticulate, where IPython syntax
is not valid Python. Use `subprocess` when the command belongs in Python code that should work
across those contexts:

```python
# Portable Python
import subprocess
git_head = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()

# Jupyter-specific shell magic; valid only when the document uses the Jupyter engine
git_head = !git rev-parse HEAD
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
**Fix:** Use `git rev-parse --show-toplevel` for PROJECT_ROOT (already in the template above). Never use `Path(__file__)` in QMD files.

```python
# CORRECT — works in Jupyter and standalone
PROJECT_ROOT = Path(subprocess.check_output(
    ["git", "rev-parse", "--show-toplevel"], text=True
).strip())

# WRONG — fails in Jupyter/Quarto
PROJECT_ROOT = Path(__file__).resolve().parents[1]
```

### Missing `nbformat`, `nbclient`, or `ipykernel`
**Cause:** Quarto needs these packages in the active Conda environment to execute Python QMDs.
**Fix:** Add all three to the project's environment specification, reconcile the lock or exported
environment, then install through the declared environment workflow. For a temporary diagnosis:
```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && python -m pip install nbformat nbclient ipykernel
```

### HTML output lands in `scripts/` instead of `outs/`
**Cause:** Forgot `--output-dir` flag.
**Fix:** Always specify output directory:
```bash
quarto render scripts/XX_name.qmd --output-dir outs/XX_name/
```

### Quarto uses wrong Python kernel
**Cause:** Conda env not activated before `quarto render`, or wrong kernel registered.
**Fix:** Activate the declared Conda environment first. If the project requires a named
kernel, register it deliberately, then render in the same environment:
```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && python -m ipykernel install --user --name PROJECT_ENV
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate PROJECT_ENV && quarto render scripts/XX_name.qmd --output-dir outs/XX_name/
```

---

## Reference Files

| Topic | File |
|-------|------|
| Publication-quality YAML templates (HTML and PDF) | `references/pdf-formatting.md` |
