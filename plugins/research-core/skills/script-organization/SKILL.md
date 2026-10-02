---
name: script-organization
description: >
  Script organization for data science analysis projects: numbered scripts, data/ vs outs/,
  section layout, dependencies, and producing-state provenance. Use when creating a new analysis
  script, deciding where a script or its outputs belong, numbering or splitting scripts, or
  setting up BUILD_INFO and git-hash provenance. Do NOT load for documentation projects
  (Quarto books), infrastructure repos, or projects without a data/outs/ structure.
---

# Script Organization and Reproducibility

Conventions for script numbering, input/output tracking, directory structure, and build
provenance. Data flow between scripts is self-documenting through directory structure and path
references — no manifest files and no pipeline tool.

---

## Script language and format

Let the researcher choose R or Python and `.qmd`, `.py` or `.R` according to purpose.
Follow the project's agreed formats and existing pipelines. Quarto supports narrative,
figures and interpretation alongside code; plain scripts suit direct command-line execution.
The host determines available runtimes and resources, not the format. Check the chosen
environment before execution; use `quarto-docs` for Quarto analysis documents.

These numbered-script conventions apply to analysis projects that use this layout.
Keep project-specific curation layouts and ordinary document-editing workflows intact.

---

## Directory Structure

```
project/
  R/                          # Shared R helpers (project-level)
  python/                     # Shared Python helpers (project-level)
  scripts/
    phosphoproteomics/        # One section per coherent pipeline
      01_analysis.qmd
      02_volcano_plots.qmd
    transcriptomics/
      01_heatmaps.qmd
    exploratory/              # One-off analyses, no numbering
  data/                       # External/immutable inputs only
    gene_naming/              # Shared external data
    phosphoproteomics/        # Section-specific external data
  outs/
    phosphoproteomics/
      01_analysis/            # Outputs from that script only
        mdata.rds
        01_analysis.html
        BUILD_INFO.txt
    transcriptomics/
      01_heatmaps/
    exploratory/
  .claude/                # or the project's established record directory
    PHOSPHOPROTEOMICS_PLAN.md
    TRANSCRIPTOMICS_PLAN.md
```

Small single-topic projects with fewer than ~10 scripts drop the section level and put numbered
scripts straight in `scripts/`, with `outs/01_analysis/` to match. Each section has its own
numbering starting at `01_`, and may have one or more planning documents in the project's declared record directory.

### Cluster Projects

Projects that submit SLURM jobs add `batch/` (SLURM `.sh` scripts) and `logs/` (`slurm-*.out`).
Batch scripts are recoverable code and normally tracked. Preserve job logs and their matching
source records with the project evidence; follow the project's deliberate Git/ignore choice rather
than forcing every scheduler log into Git. See the `hpc` skill for batch templates and resource tables.

**Analysis and scheduler setup.** Keep scientific logic in the chosen analysis file and
site-specific job setup in a thin `batch/` wrapper. Use configurable or project-relative paths;
Git-based root discovery is one option, not a launch requirement. The wrapper requests resources,
activates the environment and invokes the analysis. `batch/` is flat and shared across sections,
so it has its own numbering — make the link
obvious in the name (`batch/11a_trinity_genome_mapping.sh` calls
`scripts/annotation/05a_trinity_genome_mapping.py`).

**Preserve the committed producing state.** Before a retained run, name the producer, batch wrapper,
project-local helpers and small configuration it will use. Ensure those files are in a focused commit
and match that commit at execution and completion; unrelated dirty work does not block the run. A
new commit is needed only when a relevant file changed. Do not commit large inputs merely to satisfy
provenance: identify them through their path plus the project's checksum, manifest, upstream
BUILD_INFO or other adequate source record.

### Choosing a Subdirectory

1. Check the project's native instructions or registered active-file record for a **Script Subdirectories** table listing each section's scope
2. If the task clearly fits one, use it
3. If genuinely ambiguous, say which one you're using and why rather than guessing silently
4. If none fit, propose a new section

### A Section Is One Coherent Pipeline

A section is a single coherent analysis pipeline. Its numbering should read as *steps of that
pipeline*. **Keep a sub-project together no matter how many scripts it takes** — a 15-script
sub-project is fine. There is no count threshold that forces a split.

**A genuinely distinct analysis thread gets a NEW section** (`scripts/<section>/` +
`outs/<section>/`, numbered from `01_`) rather than being appended to an existing one. Appending
unrelated threads is what makes numbers run ahead — a deep-research pipeline landing as
`atlas/08–11,19` when it belongs in `deep_research/01–05` — and the number stops meaning "step N of
this pipeline."

**Only when a section has clearly diverged** into unrelated areas should you suggest regrouping —
and **propose it; never split or renumber automatically.** Coherence, not size, decides.

---

## `data/` vs `outs/`

| Folder | Contains | Written by |
|--------|----------|------------|
| `data/` | External/immutable inputs: raw data, collaborator files, annotations, database exports | Nothing in this project — files arrive from outside |
| `outs/<script_name>/` | Everything a script produces: data files, plots, rendered HTML, BUILD_INFO.txt | That script only |

**Rule:** if your code produced it, it goes in `outs/`. If it came from anywhere else, it goes in
`data/`. Scripts never write to `data/` — including decompressing an archive; decompress to
`outs/<script>/` and record the original compressed source in the inputs section.

---

## Script Numbering

Scripts are numbered per-section so `ls` shows them in a sensible order. **Numbers are labels, not
dependency order** — dependencies are encoded entirely by the input paths inside each script.

- Assign the next available number *within the script's own section*
- Never renumber existing scripts when one is archived or deleted
- Numbering restarts at `01_` in each section

### Letter Suffixes

Use letters when a **single topic** needs several scripts: user review is needed between steps,
output types differ (analysis `.qmd` plus a plotting `.R`), or R and Python steps can't share one
file.

1. **Same topic, same number.** A new topic gets a new number, not a new letter.
2. **Shared topic root, separate stage directories.** Keep the set together under
   `outs/XX_topic_name/`; each producer writes only to its own child directory, with its own
   `BUILD_INFO.txt`. Later stages read upstream files from the appropriate sibling directory.
3. **The `a` script runs first.** Letters imply execution order within the set.
4. **Name the set consistently:** `15a_wgcna_threshold.qmd`, `15b_wgcna_modules.qmd`,
   `15c_wgcna_plots.R`, with outputs grouped as:

   ```text
   outs/15_wgcna_platynereis/
     15a_threshold/       # threshold results and this stage's BUILD_INFO.txt
     15b_modules/         # module results and this stage's BUILD_INFO.txt
     15c_plots/           # figures and this stage's BUILD_INFO.txt
   ```

This is the default for new lettered workflows. Do not move existing project files or rewrite
registered paths merely to adopt it. A separately scoped adoption must preserve results and update
affected producers, consumers and records together. Until then, a legacy flat shared directory
needs its existing explicit per-stage file ownership and distinct completion evidence; do not
apply the generic whole-directory guard or cleanup to that shared root.

---

## Active and superseded scripts

Do not require a lifecycle field in every script. Use the project's registered active-file or
scientific/data authority to distinguish current producers from superseded ones. When retaining an
old script, put it under the project's established `old/` location or add a clear replacement note
where a future reader will encounter it. Harmless historical `status` fields may remain; they are
not execution or acceptance gates.

---

## Exploratory Directory

`scripts/exploratory/` (or `scripts/<section>/exploratory/`) is for one-off analyses, quick tests,
and feasibility checks. No number prefixes or BUILD_INFO.txt are required merely because a file is
exploratory. The directory name does not make its contents disposable and does not prohibit a real
dependency. Before cleanup, inspect actual consumers. If retained work depends on an exploratory
producer or output, preserve and register that dependency or promote the producer into the
numbered workflow when doing so improves discovery.

---

## Input/Output Tracking

Group all input reads at the top of each script (or in the setup chunk), commented to distinguish
external data from other scripts' outputs:

```python
# --- Inputs (from other scripts) ---
modules = pd.read_csv(PROJECT_ROOT / "outs/phosphoproteomics/02_module_lists/modules.tsv", sep="\t")

# --- Inputs (external data) ---
gene_names = pd.read_csv(PROJECT_ROOT / "data/gene_naming/organism_gene_names.tsv", sep="\t")
```

R is the same shape, using `here()`. Reading the top of any script then shows exactly what it
depends on and which upstream script produced each file. No separate DAG documentation needed.

---

## Provenance

### Committed producing state and BUILD_INFO.txt

Before a retained scientific run, ensure one focused commit contains the producer, wrapper, local
helpers, small non-secret configuration and environment lock used by the run. The lead or assigned
worker may inspect and checkpoint those task-owned files according to the current user and project
authority. Commit or push only when that authority covers the exact repository and operation. Make a new commit only when those relevant files changed. The
analysis script must never add, commit or push files itself.

At execution, confirm every declared relevant file is tracked and matches the named commit; unrelated
dirty work does not block the run. Write `BUILD_INFO.txt` into the output folder as the last action:

```
completion: complete
script: scripts/01_analysis.qmd
date: 2026-02-14 15:30:00
commit: <full git rev-parse HEAD value>
seed: 42
slurm_job_id: 6380027
input: data/input.tsv | sha256 from INPUTS.tsv: ...
source: scripts/01_analysis.qmd | content verified against commit
output: outs/01_analysis/result.tsv
```

The `seed` line is included when the run uses randomness. The `slurm_job_id` line is written only
when `$SLURM_JOB_ID` is set. It links the output folder to its log file
(`logs/slurm-*-<job_id>.out`), which matters when reruns produce several logs.

The commit identifies the declared producing files. Recheck them before writing completion so a
mid-run edit cannot leave a successful record. Record the invocation, required inputs,
environment/versions and explicit random seed in the run's ordinary log or BUILD_INFO. Do not
serialize credentials or commit large inputs merely to satisfy provenance.

Dirty or untracked code may produce only an explicitly provisional, isolated debugging or
equivalence check. Save its actual source state with that temporary check, keep its output separate,
and do not write a completion record, use it in ordinary downstream production, interpret it as a
scientific result, or share it as one. Commit and rerun before any such reliance.

Follow the project's deliberate tracking and backup choice for `outs/` and `BUILD_INFO.txt`.
Neither Git tracking nor ignore status establishes output ownership or disposability.

Before ordinary downstream production uses an upstream output, verify that the producing script
completed on the intended inputs, created the expected outputs and completion evidence, passed
basic sanity checks, and has no unresolved anomaly that could affect the dependent step. Use the
producer's established completion evidence rather than requiring one universal marker. This is an
execution gate between dependent steps, not a user-review stop after every numbered script.

### Preserve outputs that still matter

Before rerunning a script, determine whether its existing outputs are still being interpreted,
used downstream, or shared. If so, move that producer's output directory aside under a clear date
and source/run label before recreating its output path. For lettered stages, this is the stage's
child directory, never the topic root or an upstream/sibling directory. Explicitly disposable producer-owned
destinations may be regenerated across sessions after confirming their current use. Being generated
or Git-ignored does not make an output disposable. Do not infer preservation from the commit: the same
code can produce different outputs when its inputs change.

The templates refuse a nonempty producer-owned output directory. Set `OUT_DIR`/`out_dir` to the
stage's child directory for a lettered workflow; existing sibling outputs do not block it. Use a
fresh destination, preserve that stage's current directory, or clear it only after confirming its
specific contents are disposable. Git status does not affect this protection.

### Rendered HTML

Rendered `.html` goes into `outs/<script_name>/` alongside data outputs, keeping `scripts/` clean.
See the `quarto-docs` skill for QMD templates.

### `.py` analysis script template

```python
#!/usr/bin/env python3
"""Short description of what this script does.

Input:  data/... (external), outs/.../file.tsv (from script XX)
Output: outs/section/XX_script_name/

"""

import os
import random
import shlex
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import matplotlib
matplotlib.use("Agg")            # headless — saves to files, no display server
import matplotlib.pyplot as plt
import pandas as pd

# ── Setup ────────────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(
    subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
)
sys.path.insert(0, str(PROJECT_ROOT / "python"))

# Add every project-local code file used by this run, including its wrapper, helpers,
# small non-secret configuration, and environment lock when relevant. List files, not directories.
SCRIPT_PATH = Path(__file__).resolve().relative_to(PROJECT_ROOT)
RELEVANT_CODE_PATHS = [SCRIPT_PATH]
INPUT_IDENTITIES = [
    "data/.../file.tsv | external input; checksum/manifest: <identity>",
    "outs/.../file.tsv | producer completion record: <path and identity>",
]
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

# This producer's directory; for a lettered stage, e.g. outs/15_topic/15b_modules/.
# Do not point the nonempty-directory guard at the shared topic root.
OUT_DIR = PROJECT_ROOT / "outs" / "section" / "XX_script_name"
if OUT_DIR.exists() and any(OUT_DIR.iterdir()):
    raise RuntimeError(
        "Output destination is not empty; use a fresh path or preserve/clear it only after "
        "confirming the existing producer-owned outputs are disposable"
    )
OUT_DIR.mkdir(parents=True, exist_ok=True)
BUILD_INFO_PATH = OUT_DIR / "BUILD_INFO.txt"

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

# ── Inputs ───────────────────────────────────────────────────────────────────
# --- Inputs (from other scripts) ---
# upstream = pd.read_csv(PROJECT_ROOT / "outs/.../file.tsv", sep="\t")

# --- Inputs (external data) ---
# raw = pd.read_csv(PROJECT_ROOT / "data/.../file.tsv", sep="\t")

# Verify required upstream outputs and their established completion evidence before reading them.
# Do not rely on file existence alone, and do not commit large inputs as producing code.

# ── Analysis step 1 ──────────────────────────────────────────────────────────
# Describe WHAT this step does and WHY — the analytical reasoning, not the code
# mechanics. What question does it answer, and what should the reader look for in
# the output? This replaces the markdown narrative a .qmd would carry. Every major
# section gets a block comment like this; also annotate thresholds, assumptions,
# and any code that would surprise a reader.

# ── BUILD_INFO (last action after output checks) ─────────────────────────────
EXPECTED_OUTPUTS = [OUT_DIR / "result.tsv"]  # replace with this script's outputs
missing_outputs = [path for path in EXPECTED_OUTPUTS if not path.is_file()]
if missing_outputs:
    raise RuntimeError(f"Expected outputs are missing: {missing_outputs}")
try:
    _, FINAL_WORKING_BLOBS = relevant_blob_ids()
except subprocess.CalledProcessError as error:
    raise RuntimeError("Relevant producing files changed during execution") from error
if FINAL_WORKING_BLOBS != COMMITTED_BLOBS:
    raise RuntimeError("Relevant producing files changed during execution")

lines = [
    "completion: complete",
    f"script: {SCRIPT_PATH}",
    f"date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
    f"commit: {GIT_COMMIT}",
    f"environment: {sys.version.splitlines()[0]}",
    f"invocation: {shlex.join([sys.executable, *sys.argv])}",
    f"seed: {RANDOM_SEED}",
]
slurm_job_id = os.environ.get("SLURM_JOB_ID")
if slurm_job_id:
    lines.append(f"slurm_job_id: {slurm_job_id}")
lines.extend(f"input: {identity}" for identity in INPUT_IDENTITIES)
lines.extend(f"source: {relative} | content verified against commit" for relative in RELEVANT_CODE_PATHS)
lines.extend(f"output: {path.relative_to(PROJECT_ROOT)}" for path in EXPECTED_OUTPUTS)
BUILD_INFO_PATH.write_text("\n".join(lines) + "\n")
print("BUILD_INFO.txt written")
```

Stdout is the execution log — redirect with `python script.py | tee log.txt` when running outside
SLURM.

---

## Helper Functions

Shared helpers live in `R/` and `python/` at the project root, loaded with
`source(here("R/gene_name_helpers.R"))` or `sys.path.insert` plus a normal import.

- **Do not version function names** (`make_gene_short`, not `make_gene_short_v2`). Fix functions in
  place; git tracks the history. If the interface genuinely changes, give it a descriptive name
  reflecting what it does, not when it was written.
- **Do not duplicate the same function in both R and Python** within a project. Each function lives
  in one language. If a script in the other language needs that logic, rewrite it once and retire
  the old one.

Helpers stay project-local. A helper in a home directory makes scripts unrunnable for a
collaborator who clones the repo, and the producing commit cannot cover it. When the
same function is genuinely needed across projects, copy it and accept the duplication, or graduate
it into an installable package.

---

## Cross-Language Data Interchange

For R/Python interchange, prefer an established project format that preserves the actual schema.
**Parquet** is useful when compatible Arrow support is already available in both environments;
check round-trip types, missing values and identifiers. A TSV with explicit schema/read options
can be sufficient for a small simple table without adding dependencies. Avoid `.rds` and `.pkl`
across the language boundary; within one language, native formats are fine.

**Prefer single-language scripts.** When a topic needs both, split into lettered scripts
(`XXa_` in Python, `XXb_` in R) communicating through files in their separate stage directories
under `outs/XX_topic/`. A single mixed
`.qmd` is acceptable only when both languages work on the same data in a tight pipeline — and even
then data passes via files on disk, not `reticulate` object passing.
