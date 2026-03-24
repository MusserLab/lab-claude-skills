---
name: script-organization
description: >
  Script organization for data science analysis projects with numbered scripts, data/outs/
  directories, and reproducibility conventions. Use when creating new analysis scripts in
  projects that follow data science conventions (numbered XX_ prefix scripts, outs/ directories,
  BUILD_INFO.txt). Do NOT load for documentation projects (Quarto books), infrastructure repos,
  or projects without data/outs/ directory structure.
user-invocable: false
---

# Script Organization and Reproducibility

Conventions for script numbering, input/output tracking, directory structure, and build provenance. The goal is to make data flow between scripts self-documenting through directory structure and path references, without requiring separate manifest files or pipeline tools.

---

## Directory Structure

### Flat Layout

For small projects with <10 scripts on a single topic:

```
project/
  R/                          # Shared R helpers
  python/                     # Shared Python helpers
  scripts/
    01_analysis.qmd
    02_plots.qmd
    exploratory/              # One-off analyses
  data/                       # External/immutable inputs only
  outs/
    01_analysis/              # Outputs from script 01
      mdata.rds
      01_analysis.html        # Rendered HTML
      BUILD_INFO.txt
    02_plots/
      volcano.pdf
      02_plots.html
      BUILD_INFO.txt
    exploratory/
```

### Sectioned Layout

For larger projects with multiple analytical threads:

```
project/
  R/                          # Shared R helpers (project-level)
  python/                     # Shared Python helpers (project-level)
  scripts/
    phosphoproteomics/
      01_analysis.qmd
      02_volcano_plots.qmd
    transcriptomics/
      01_heatmaps.qmd
    exploratory/
  data/
    gene_naming/              # Shared external data
    phosphoproteomics/        # Section-specific external data
    transcriptomics/
  outs/
    phosphoproteomics/
      01_analysis/
      02_volcano_plots/
    transcriptomics/
      01_heatmaps/
    exploratory/
  .claude/
    PHOSPHOPROTEOMICS_PLAN.md
    TRANSCRIPTOMICS_PLAN.md
```

Each section has its own script numbering (starting at `01_`). Sections may have one or more planning documents in `.claude/`.

### Cluster Projects

Projects that submit SLURM jobs on the HPC cluster add two directories:

```
project/
  batch/                        # SLURM batch scripts (.sh)
  logs/                         # SLURM output files (slurm-*.out)
  scripts/
  data/
  outs/
```

Both `batch/` and `logs/` must be in `.gitignore` — they are ephemeral and machine-specific.
See the `hpc` skill for batch script conventions and job resource templates.

**Script format on the cluster:** Use `.py` scripts, not `.qmd`. Quarto has NFS cleanup
issues and requires extra Jupyter dependencies that may not be installed in every conda env.
`.py` scripts run anywhere with a Python interpreter and produce the same outputs (plots
saved to files, BUILD_INFO.txt, summary stats printed to stdout).

`.qmd` remains available for **locally rendered reports** — interactive exploration,
publication figures with narrative, or when inline HTML output is valuable. But `.py` is
the default for analysis scripts in cluster projects.

### Choosing a Subdirectory

When creating a new script in a sectioned project:

1. Check the project's CLAUDE.md for a **Script Subdirectories** table listing each subdirectory and its scope
2. If the task clearly fits one subdirectory, use it
3. **If ambiguous, ask the user** which subdirectory to use before creating the script
4. If none of the existing subdirectories fit, propose creating a new one

### When to Use Each Layout

- **Flat**: Single topic, small scope, fewer than ~10 scripts
- **Sectioned**: Multiple distinct analytical threads, especially when different people work on different sections

---

## `data/` vs `outs/`

| Folder | Contains | Written by |
|--------|----------|------------|
| `data/` | External/immutable inputs: raw data, collaborator files, annotations, database exports | Nothing in this project — files arrive from outside |
| `outs/<script_name>/` | All outputs produced by a script (data files, plots, rendered HTML, BUILD_INFO.txt) | That script only |

**Rule:** If your code produced it, it goes in `outs/`. If it came from anywhere else, it goes in `data/`. Scripts never write to `data/`.

---

## Script Numbering

Scripts are numbered per-section (`01_`, `02_`, etc.) so `ls` shows them in a sensible order. **Numbers are labels, not dependency order.** Dependencies are encoded entirely by input paths within each script.

- Assign the next available number when adding a script
- Never renumber existing scripts when one is archived or deleted
- In sectioned projects, numbering restarts at `01_` in each section

### Letter Suffixes (a, b, c)

Use letter suffixes when a **single topic** requires multiple scripts. Common reasons:

- **User review needed between steps** (e.g., threshold selection → module detection)
- **Different output types** (e.g., main analysis `.qmd` + plotting companion `.R`)
- **Language split** when R and Python steps cannot share a `.qmd` (see Cross-Language rule below)

Rules for lettered scripts:

1. **Same topic, same number.** A new topic gets a new number, not a new letter.
2. **Shared output directory.** All scripts in a lettered set write to `outs/XX_topic_name/` — NOT `outs/XXa_name/`, `outs/XXb_name/`. The output dir uses the number without a letter.
3. **The `a` script runs first.** Letters imply execution order within the set.
4. **Name the set consistently.** `15a_wgcna_threshold.qmd`, `15b_wgcna_modules.qmd`, `15c_wgcna_plots.R` — all share `outs/15_wgcna_platynereis/`.
5. **Companion scripts** (`.R` or `.py` alongside `.qmd`) are acceptable for lightweight tasks (plotting, utilities). Main analysis should be `.qmd`.

**When to use a new number vs a letter:**
- New number: different analytical question, different input data, different topic
- Letter suffix: same topic split across steps, same conceptual analysis

---

## Script Lifecycle

Every analysis script declares its status:

- **`.qmd`** — `status` field in YAML frontmatter
- **`.py`** — `Status: development` line in the module docstring

| Status | Meaning | Location |
|--------|---------|----------|
| `development` | In active development, outputs are provisional | `scripts/` |
| `finalized` | Outputs are publication-ready; modify only with deliberate re-validation | `scripts/` |
| `deprecated` | Superseded; kept for reference | `scripts/old/` or `scripts/<section>/old/` |

When deprecating, note the replacement in the frontmatter (`.qmd`) or docstring (`.py`).

Planning documents remain the authoritative tracker of script status across the project.

---

## Exploratory Directory

`scripts/exploratory/` (or `scripts/<section>/exploratory/`) is for one-off analyses, quick tests, and feasibility checks:

- No number prefixes or BUILD_INFO.txt required
- Other scripts must **never** depend on exploratory outputs (one-way dependency: exploratory scripts can read from any section's `outs/`)
- Can be cleaned out periodically without breaking anything
- No planning document needed
- Good candidates for promotion: if an exploratory script proves useful, promote it to a numbered script in the appropriate section

---

## Input/Output Tracking

Dependencies between scripts are self-documenting through paths. Group all input reads at the top of each script (or in the setup chunk), with comments distinguishing external data from other scripts' outputs.

**R example:**

```r
# --- Inputs (from other scripts) ---
mdata <- readRDS(here("outs/phosphoproteomics/01_analysis/mdata.rds"))
modules <- read_tsv(here("outs/phosphoproteomics/02_module_lists/modules.tsv"))

# --- Inputs (external data) ---
gene_names <- read_tsv(here("data/gene_naming/spongilla_gene_names_final.tsv"))
```

**Python example:**

```python
# --- Inputs (from other scripts) ---
modules = pd.read_csv(PROJECT_ROOT / "outs/phosphoproteomics/02_module_lists/modules.tsv", sep="\t")

# --- Inputs (external data) ---
gene_names = pd.read_csv(PROJECT_ROOT / "data/gene_naming/spongilla_gene_names_final.tsv", sep="\t")
```

Reading the top of any script shows exactly what it depends on and which upstream scripts produced those files. No separate DAG documentation needed.

---

## Provenance

### Archive Before Overwrite

When a script re-renders, it should archive existing outputs before writing new ones.
This prevents stale files from previous runs from lingering in `outs/` and provides
a history of previous outputs.

**Convention:** At the start of each script (after creating `out_dir`), move all
existing files into `out_dir/_archive/<timestamp>/`. The timestamp comes from the
previous `BUILD_INFO.txt` mtime (reflecting when those outputs were actually produced),
falling back to the newest file mtime if `BUILD_INFO.txt` doesn't exist.

**Python:**

```python
import shutil
from datetime import datetime

existing_items = [f for f in out_dir.iterdir() if f.name != "_archive"]
if existing_items:
    build_info = out_dir / "BUILD_INFO.txt"
    if build_info.exists():
        orig_time = datetime.fromtimestamp(build_info.stat().st_mtime)
    else:
        all_files = [f for f in out_dir.rglob("*") if f.is_file() and "_archive" not in str(f)]
        orig_time = datetime.fromtimestamp(max(f.stat().st_mtime for f in all_files)) if all_files else datetime.now()

    archive_dir = out_dir / "_archive" / orig_time.strftime("%Y-%m-%d_%H%M%S")
    archive_dir.mkdir(parents=True, exist_ok=True)
    for item in existing_items:
        shutil.move(str(item), str(archive_dir / item.name))
    print(f"Archived {len(existing_items)} items → {archive_dir.name}")
```

**R:**

```r
existing_files <- list.files(out_dir, full.names = TRUE)
existing_files <- existing_files[!file.info(existing_files)$isdir]
if (length(existing_files) > 0) {
  build_info <- file.path(out_dir, "BUILD_INFO.txt")
  if (file.exists(build_info)) {
    orig_time <- file.info(build_info)$mtime
  } else {
    orig_time <- max(file.info(existing_files)$mtime)
  }
  archive_dir <- file.path(out_dir, "_archive", format(orig_time, "%Y-%m-%d_%H%M%S"))
  dir.create(archive_dir, recursive = TRUE, showWarnings = FALSE)
  file.rename(existing_files, file.path(archive_dir, basename(existing_files)))
  message("Archived ", length(existing_files), " previous outputs → ", basename(archive_dir))
}
```

**Notes:**
- Only files are archived, not subdirectories (so `_archive/` itself is never moved)
- The `_archive/` directory accumulates over time; periodically clean old archives
- This pattern applies to all script types (`.qmd`, `.py`, `.R`)

---

### Git Hash

Every script captures the current git commit hash in its setup chunk and prints it into the rendered output. Six months later, you can check out that exact commit to see the state of all code at the time the output was produced.

### BUILD_INFO.txt

Every script writes a `BUILD_INFO.txt` to its output folder as its last action:

```
script: 01_analysis.qmd
commit: a1b2c3d
date: 2026-02-14 15:30:00
slurm_job_id: 6380027
```

The `slurm_job_id` line is written only when the script runs via SLURM (i.e., `$SLURM_JOB_ID`
is set). This links the output folder to its log file (`logs/slurm-*-<job_id>.out`), which
is essential when reruns produce multiple log files. In Python:

```python
slurm_job_id = os.environ.get("SLURM_JOB_ID", "")
# ... in BUILD_INFO write block:
if slurm_job_id:
    f.write(f"slurm_job_id: {slurm_job_id}\n")
```

This answers: "When was this output folder last regenerated, from what code, and which log file has the details?" If downstream plots look wrong, check the upstream folder's BUILD_INFO.txt to see whether it was generated from current code or something stale.

BUILD_INFO.txt lives in `outs/` and is not tracked by git (since `outs/` is in `.gitignore`).

### Rendered HTML

Rendered `.html` output goes into `outs/<script_name>/` alongside data outputs, keeping `scripts/` clean.

See the `quarto-docs` skill for complete QMD templates with git hash and BUILD_INFO.txt chunks.

### `.py` Analysis Script Template

For cluster projects, `.py` is the default analysis script format. The template carries
over the same reproducibility features as `.qmd` (git hash, BUILD_INFO.txt, structured
inputs, archive-before-overwrite) without requiring Quarto.

```python
#!/usr/bin/env python3
"""Short description of what this script does.

Input:  data/... (external), outs/.../file.tsv (from script XX)
Output: outs/section/XX_script_name/

Status: development
"""

import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import matplotlib
matplotlib.use("Agg")  # headless — saves to files, no display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# ── Setup ─────────────────────────────────────────────────────────────────────

PROJECT_ROOT = Path(
    subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
)
sys.path.insert(0, str(PROJECT_ROOT / "python"))

GIT_HASH = subprocess.check_output(
    ["git", "rev-parse", "--short", "HEAD"], text=True
).strip()
print(f"Git hash: {GIT_HASH}")

OUT_DIR = PROJECT_ROOT / "outs" / "section" / "XX_script_name"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ── Archive previous outputs ─────────────────────────────────────────────────

import shutil

existing_items = [f for f in OUT_DIR.iterdir() if f.name != "_archive"]
if existing_items:
    build_info = OUT_DIR / "BUILD_INFO.txt"
    if build_info.exists():
        orig_time = datetime.fromtimestamp(build_info.stat().st_mtime)
    else:
        all_files = [
            f for f in OUT_DIR.rglob("*")
            if f.is_file() and "_archive" not in str(f)
        ]
        orig_time = (
            datetime.fromtimestamp(max(f.stat().st_mtime for f in all_files))
            if all_files else datetime.now()
        )
    archive_dir = OUT_DIR / "_archive" / orig_time.strftime("%Y-%m-%d_%H%M%S")
    archive_dir.mkdir(parents=True, exist_ok=True)
    for item in existing_items:
        shutil.move(str(item), str(archive_dir / item.name))
    print(f"Archived {len(existing_items)} items -> {archive_dir.name}")

# ── Inputs ────────────────────────────────────────────────────────────────────

# --- Inputs (from other scripts) ---
# upstream = pd.read_csv(PROJECT_ROOT / "outs/.../file.tsv", sep="\t")

# --- Inputs (external data) ---
# raw_data = pd.read_csv(PROJECT_ROOT / "data/.../file.tsv", sep="\t")

# ── Analysis step 1 ───────────────────────────────────────────────────────────
#
# Describe WHAT this step does and WHY — the analytical reasoning, not just
# code mechanics. What question does this step answer? What should the reader
# look for in the output? This replaces the markdown narrative from .qmd files.
#
# Each major section should have a block comment like this. Not every line
# needs a comment, but every analytical step needs context. Also annotate:
# - Critical lines (thresholds, assumptions, non-obvious logic)
# - Tricky or surprising code that would confuse a reader

# ... analysis code, plots saved to OUT_DIR ...

# ── BUILD_INFO ────────────────────────────────────────────────────────────────

slurm_job_id = os.environ.get("SLURM_JOB_ID", "")
with open(OUT_DIR / "BUILD_INFO.txt", "w") as f:
    f.write(f"script: scripts/section/XX_script_name.py\n")
    f.write(f"commit: {GIT_HASH}\n")
    f.write(f"date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    if slurm_job_id:
        f.write(f"slurm_job_id: {slurm_job_id}\n")
print("BUILD_INFO.txt written")
```

**Key features:**
- `matplotlib.use("Agg")` for headless rendering (no display server needed)
- Git hash captured at start, printed to stdout, written to BUILD_INFO.txt
- Archive-before-overwrite preserves previous outputs
- Docstring with status, inputs, outputs serves as the script's documentation
- All output goes to `outs/`, all reads from `data/` or upstream `outs/`
- `PROJECT_ROOT` from git, not hardcoded paths
- Stdout serves as the execution log (redirect with `python script.py | tee log.txt`)

---

## Helper Functions

### Project-Level

Shared helper functions live in `R/` and `python/` at the project root:

```r
# R scripts load helpers with:
source(here("R/gene_name_helpers.R"))
```

```python
# Python scripts load helpers with:
import sys
sys.path.insert(0, str(PROJECT_ROOT / "python"))
from gene_name_helpers import normalize_name
```

**Rules:**
- **Do not version function names** (`make_gene_short`, not `make_gene_short_v2`). Fix functions in place; git tracks the history. If a function's interface genuinely changes (different inputs/outputs/purpose), give it a descriptive name reflecting what it does, not when it was written.
- **Do not duplicate the same function in both R and Python** within a project. Each function lives in one language. If a script in the other language needs that logic, rewrite it once in the new language and retire the old one.

### Cross-Project

Functions shared across multiple projects live in `~/lib/R/` and `~/lib/python/`:

```r
source("~/lib/R/plotting_helpers.R")
```

When a project-level function proves useful across 2+ projects, promote it to `~/lib/`. The `~/lib/` directory should be a git repository for version tracking.

**Future**: When distributing functions to collaborators, graduate shared functions into installable R/Python packages.

---

## Cross-Language Data Interchange

When data produced by an R script will be read by a Python script (or vice versa), use **Parquet**:

- Smaller than TSV, preserves column types, fast in both languages
- R: `arrow::write_parquet()` / `arrow::read_parquet()`
- Python: `pd.to_parquet()` / `pd.read_parquet()`

Avoid `.rds` (R-only) or `.pkl` (Python-only) for data that crosses the language boundary. Within a single language, native formats (`.rds` for R) are fine.

### Cross-Language Scripts

**Prefer single-language `.qmd` files.** When a script needs both R and Python, split into lettered scripts (e.g., `XXa_` in Python, `XXb_` in R) that communicate through files in `outs/XX_topic/`.

**Exception:** A single mixed-language `.qmd` is acceptable when both languages operate on the same data in a tight pipeline (e.g., Python reads h5ad → saves TSV → R builds a tree in the next chunk). In this case, data passes via files on disk, not shared memory — do not rely on `reticulate` object passing.
