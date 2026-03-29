---
name: hpc
description: >
  Yale YCRC HPC cluster reference for the Musser Lab. Use when writing SLURM
  batch scripts, configuring job resources, managing cluster storage, running
  bioinformatics tools on HPC, or setting up Snakemake pipelines. Covers
  McCleary, Bouchet, and Misha clusters with lab-specific storage paths,
  partition tables, and tool resource templates.
user-invocable: false
---

# Musser Lab HPC Reference

Yale Center for Research Computing (YCRC) cluster conventions for the Musser Lab.
Full YCRC documentation: <https://docs.ycrc.yale.edu/>

---

## 1. Getting Started

### Account setup

Request an account at <https://research.computing.yale.edu/account-request>. You need a
Yale NetID and PI approval (Jacob Musser).

### SSH access

```bash
ssh <netid>@mccleary.ycrc.yale.edu
ssh <netid>@bouchet.ycrc.yale.edu
ssh <netid>@misha.ycrc.yale.edu
```

Use SSH keys for passwordless access. Add to `~/.ssh/config`:

```
Host mccleary
    HostName mccleary.ycrc.yale.edu
    User <netid>

Host bouchet
    HostName bouchet.ycrc.yale.edu
    User <netid>

Host misha
    HostName misha.ycrc.yale.edu
    User <netid>
```

### First job

After logging in, test with a minimal job:

```bash
sbatch <<'EOF'
#!/bin/bash
#SBATCH --job-name=test
#SBATCH --partition=devel
#SBATCH --time=0:05:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
echo "Hello from $(hostname) at $(date)"
EOF
```

Check status with `squeue --me`, view output in `slurm-<jobid>.out`.

---

## 2. Cluster Overview

| Cluster | Primary use | Status |
|---------|------------|--------|
| **McCleary** | Life sciences, YCGA data analysis | **Decommissioning 2026** — but has YCGA partition (free compute for YCGA data) |
| **Bouchet** | General HPC, GPU workloads | Active — primary cluster going forward |
| **Misha** | Wu Tsai Institute | Active |

### Which cluster to use

- **YCGA sequencing data analysis** → McCleary (while available) — the `ycga` partition is exempt from compute charges
- **GPU jobs** (training, PROST structure search) → Bouchet (H200, RTX Pro 6000 Blackwell, RTX 5000 Ada)
- **General compute** (phylogenetics, alignment, mapping) → McCleary or Bouchet
- **Wu Tsai affiliated work** → Misha

### Open OnDemand (web portal)

Each cluster has a web portal for Jupyter, RStudio, VSCode, and Remote Desktop:
- McCleary: `https://ood-mccleary.ycrc.yale.edu`
- Bouchet: `https://ood-bouchet.ycrc.yale.edu`
- Misha: `https://ood-misha.ycrc.yale.edu`

Max 4 interactive app instances per user simultaneously. Yale VPN required off-campus.

### Login node policy

**Never run heavy computation on login nodes.** Acceptable login-node activities:

- Snakemake orchestration (dispatching jobs to SLURM)
- Git operations
- Conda/mamba environment management
- File inspection, editing scripts
- Small interactive commands (`wc`, `head`, `ls`, etc.)

Everything else must be submitted as a SLURM job.

### Transfer nodes

Transfer nodes (e.g., `transfer1.bouchet`) are for data transfer only (rsync, Globus,
scp). **Do not use them to run tools** — they often have older CPUs that cause
"Illegal instruction" errors with compiled binaries. If you need to run `module load`,
`prefetch`, `fasterq-dump`, or any analysis tool, use an interactive compute node instead
(see Interactive jobs below).

---

## 3. Storage

### Lab storage paths

| Cluster | PI storage | Scratch |
|---------|-----------|---------|
| **McCleary** | `/vast/palmer/pi/<pi_netid>` | `/vast/palmer/scratch/<pi_netid>/` |
| **Bouchet** | `/nfs/roberts/project/<pi_netid>/` | `/nfs/roberts/scratch/<pi_netid>` |
| **Misha** | `/gpfs/radev/project/<pi_netid>` | `/gpfs/radev/scratch` |

### Storage policies

| Type | Backed up? | Purge policy | Use for |
|------|-----------|-------------|---------|
| **Home** (`~/`) | Yes (snapshots) | None | Scripts, configs, small files. 125 GiB quota. |
| **PI storage** | Yes (snapshots) | None | Raw data, important results, conda environments |
| **Project** | Yes (snapshots) | None | Active project directories |
| **Scratch** | No | **60-day purge** | Temporary/intermediate files, large job outputs |

**Important:**
- **Never store conda environments on scratch** — they will be purged after 60 days
- **Never store raw data only on scratch** — keep originals in PI storage
- You will receive email notification one week before scratch files are purged
- Do not artificially modify file timestamps to circumvent the purge policy
- Check quotas: `getquota` (McCleary) | List paths: `mydirectories`

### Project organization on the cluster

Mirror the local project structure in PI storage or project space:

```
/nfs/roberts/project/<pi_netid>/<project_name>/
  .git/              # Same repo as local — sync via git push/pull
  .claude/           # Project docs, plans, findings
  batch/             # SLURM batch scripts (tracked in git)
  logs/              # SLURM output files (tracked in git)
  scripts/           # Analysis scripts
  data/              # External/immutable inputs (gitignored, sync via Globus)
  outs/              # Script-produced outputs (gitignored)
  environment.yml    # Conda environment specification
```

Use scratch only for large temporary files (sort buffers, intermediate alignments) that
can be regenerated. Never store the project itself on scratch — use PI storage.

### Dual-environment projects (local + cluster)

When a project is worked on both locally and on the cluster, the **same git repo** is
cloned in both places. Conventions:

- **Git syncs scripts, docs, logs, and batch files.** Always `git pull` before starting
  work in either environment.
- **Data syncs via Globus.** Large files (`data/`, tool outputs) are gitignored and
  transferred manually. Not all data exists in both places.
- **Batch scripts use `BASEDIR=$(git rev-parse --show-toplevel)`** — no hardcoded paths.
  This makes scripts work regardless of where the repo is cloned.
- **Logs are tracked in git.** The cluster session commits logs after jobs complete; pull
  locally to review results.
- **Cluster-only directories** (e.g., `cellranger_refs/`, raw FASTQ staging directories)
  are added to `.gitignore` on a per-project basis.
- **The project CLAUDE.md documents the dual-environment setup**, including the cluster
  path and which directories are cluster-only.

---

## 4. SLURM Job Scheduling

Full docs: <https://docs.ycrc.yale.edu/clusters-at-yale/job-scheduling/>

### Lab default batch script template

Every batch script starts from these defaults. Override per-job as needed.

```bash
#!/bin/bash
#SBATCH --job-name=<tool>_<brief_description>
#SBATCH --partition=day
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=5G
#SBATCH --output=logs/slurm-%j.out
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=<your email>

# ── Provenance ────────────────────────────────────────
BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

echo "=== PROVENANCE ==="
echo "Job ID:      $SLURM_JOB_ID"
echo "Script:      $0"
echo "Git hash:    $(git rev-parse HEAD)"
echo "Git dirty:   $(git status --porcelain | head -5)"
echo "Date:        $(date -Iseconds)"
echo "Node:        $(hostname)"

# Modules (cluster-only tools — always pin versions)
module purge
module load Tool/1.2.3

module list 2>&1

# Conda (project environment)
module load miniconda
conda activate myenv
echo "Conda env:   $CONDA_DEFAULT_ENV"

# Log versions of key tools used in this script
echo "tool:        $(tool --version | head -1)"
echo "=== END PROVENANCE ==="
# ──────────────────────────────────────────────────────

# ── Main ──────────────────────────────────────────────
# Your commands here
```

The provenance block prints to stdout, which SLURM captures in the log file. Since logs
are tracked in git, the full record (script version, tool versions, environment state) is
version-controlled alongside the code that produced the results.

**Provenance block requirements:**
- `BASEDIR` + `cd` — ensures git commands and relative paths work
- `git rev-parse HEAD` — which version of the code ran
- `git status --porcelain` — catches uncommitted changes (scripts called by the batch job
  are covered by the git hash only if the tree is clean)
- `module list` — all loaded modules and their exact versions
- `conda activate` + env name — which conda environment was used
- Tool version lines — one per tool actually invoked in the script

**File organization:**
- Batch scripts → `batch/` subdirectory
- Log files → `logs/` subdirectory (create with `mkdir -p logs` before first submit)
- `batch/` is tracked in git (scripts are code)
- `logs/` is tracked in git (logs are the reproducibility record — commit after jobs
  complete so provenance is preserved)

**Critical**: No space between `#` and `SBATCH` — otherwise the directive is ignored.

### Common directives

| Directive | Short | Lab default | Purpose |
|-----------|-------|------------|---------|
| `--job-name` | `-J` | `<tool>_<desc>` | Job identification (shows in `squeue`) |
| `--time` | `-t` | varies by tool | Walltime (`D-HH:MM:SS`) |
| `--partition` | `-p` | `day` | Target partition |
| `--cpus-per-task` | `-c` | varies by tool | Cores per task (for threading) |
| `--mem-per-cpu` | — | `5G` | RAM per CPU (use for most jobs) |
| `--mem` | — | — | Total RAM (use instead of `--mem-per-cpu` for memory-hungry tools like PROST, Cell Ranger) |
| `--gpus` | `-G` | 0 | GPU count (must be explicit) |
| `--output` | `-o` | `logs/slurm-%j.out` | Combined stdout+stderr |
| `--error` | `-e` | (not set) | Separate stderr file (use when debugging with split output) |
| `--mail-type` | — | `BEGIN,END,FAIL` | Notifications (see below) |
| `--mail-user` | — | `<your email>` | Notification email |
| `--nodes` | `-N` | 1 | Compute nodes (rarely >1 except MPI) |
| `--ntasks` | `-n` | 1 | MPI task count |

### Notification options

| `--mail-type` value | When to use |
|---------------------|-------------|
| `BEGIN,END,FAIL` | **Lab default** for single jobs |
| `BEGIN,END,FAIL,ARRAY_TASKS` | **Lab default** for array jobs — sends per-task emails so individual failures are visible |
| `FAIL` | Very high-volume array jobs (hundreds of tasks) to reduce email flood |

For array jobs, always include `ARRAY_TASKS`. Without it, individual task failures within
a running array don't trigger emails — you only find out when the whole array finishes.

### GPU jobs

GPUs must be explicitly requested with `--gpus`. Key GPU partitions:

| Cluster | Partition | GPU | VRAM |
|---------|-----------|-----|------|
| Bouchet | `gpu` | RTX 5000 Ada | 32 GB |
| Bouchet | `gpu_rtx6000` | RTX Pro 6000 Blackwell | 96 GB |
| Bouchet | `gpu_h200` | H200 | 141 GB |
| McCleary | `gpu` | A5000/A100/RTX 3090 | 24-80 GB |
| Misha | `gpu` | H100/H200/A100/A40/L40S | 48-141 GB |

For GPU jobs, also `module load CUDA` before conda activation.

### Interactive jobs

```bash
salloc -p devel -t 2:00:00 --mem=8G
```

Interactive jobs are typically only allowed on `devel` partitions. Add `--x11` for
graphical forwarding (requires X11 setup).

### Job monitoring

| Command | Purpose |
|---------|---------|
| `squeue --me` | List your running/pending jobs |
| `sacct -j <id>` | Job status and resource usage |
| `jobstats <id>` | Efficiency metrics (CPU/memory utilization) |
| `scancel <id>` | Cancel a job |
| `sbatch --test-only script.sh` | Estimate queue start time without submitting |

### Resource efficiency

Always check resource usage with `jobstats` after jobs complete. Request only what you
need — wasteful allocations slow scheduling for everyone.

### Job arrays

For many similar jobs (e.g., processing multiple samples), use job arrays or Dead Simple
Queue (dsq) rather than submitting hundreds of individual jobs. Rate limit: **200 job
submissions per hour**.

```bash
#!/bin/bash
#SBATCH --array=1-50
#SBATCH --partition=day
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --output=logs/slurm-%A_%a.out
#SBATCH --mail-type=BEGIN,END,FAIL,ARRAY_TASKS
#SBATCH --mail-user=<your email>

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
# Process $SAMPLE
```

---

## 5. Partition Quick-Reference

See `references/partitions.md` for full partition tables (McCleary, Bouchet, Misha) with
time limits, per-user resource limits, GPU types, and node counts.

**Quick summary for partition selection:**
- **General compute** → `day` (1-day limit, generous CPU/memory)
- **Long jobs** → `week` (7-day) or `long` (28-day, McCleary only)
- **GPU** → `gpu` (RTX 5000 Ada on Bouchet), `gpu_h200` (H200), `gpu_rtx6000` (RTX Pro 6000 Blackwell)
- **Interactive/testing** → `devel` (6-hour limit, strict per-user caps)
- **YCGA data** → `ycga` on McCleary (exempt from compute charges)
- **Big memory** → `bigmem` (up to 4 TiB/node on Bouchet)
- **Preemptable** → `scavenge` (free idle resources, may be killed)

---

## 6. Tool Resource Profiles

See `references/tool_profiles.md` for SLURM resource recommendations per bioinformatics
tool (CPUs, memory, time, partition, GPU). Always check `jobstats` after initial runs
and adjust.

---

## 7. Environment Management

### Modules vs conda: the hybrid rule

For any given tool, use **one or the other** — never both. If a tool is available via both
module and conda, choose one and stick with it. Having the same tool in both creates PATH
conflicts where the activation order silently determines which version runs.

| Use **conda** (project env) for | Use **modules** for |
|--------------------------------|---------------------|
| Tools used in both local and cluster environments | Cluster-only heavy tools unlikely to run locally |
| Python/R packages | Tools with complex cluster-specific dependencies |
| Lightweight bioinformatics (samtools, MAFFT, DIAMOND) | Cell Ranger, STAR, PROST, EggNOG-mapper |
| Anything tracked in `environment.yml` | GPU-dependent tools requiring CUDA |

**Always pin module versions** — use `module load CellRanger/9.0.1`, never bare
`module load CellRanger`. Unpinned modules silently change when the cluster updates
defaults. The provenance block in the batch template logs loaded versions, but pinning
prevents the drift in the first place.

### Conda (Python + bioinformatics tools)

```bash
module purge
module load miniconda

# Create environment
conda create -n myenv -c conda-forge -c bioconda python=3.11 <packages>

# From file
conda env create -f environment.yml

# Activate
conda activate myenv
```

- Use **conda-forge** as the primary channel, add **bioconda** for bioinformatics tools
- **Store environments in PI storage or home** — never in scratch (60-day purge)
- Use `pip` only as a fallback when a package is not available in conda-forge

### Tools environment (recommended)

A shared `tools` conda env for general-purpose cluster utilities (not project-specific):

```bash
conda create -n tools -c conda-forge gh git
conda activate tools
gh auth login   # one-time setup: authenticate with GitHub
```

Activate `tools` at the start of sessions that need `gh`, `git`, or other general CLI
tools. Project-specific envs (Python analysis, bioinformatics pipelines) remain separate.

### R (rig + renv)

Use rig to manage R versions and renv for project-level package management, matching the
local development workflow.

```bash
# Check available R versions via module system
module avail R

# Or install rig in userspace if not available as a module
# (check YCRC docs for current guidance)

# For renv projects, set cache to PI storage to avoid filling home quota:
export RENV_PATHS_CACHE="/vast/palmer/pi/<pi_netid>/renv_cache"  # McCleary
# export RENV_PATHS_CACHE="/nfs/roberts/project/<pi_netid>/renv_cache"  # Bouchet

# Then restore packages as usual
Rscript -e 'renv::restore()'
```

**HPC-specific R notes:**
- Some R packages need system libraries loaded via `module load` (e.g., HDF5, GDAL, PROJ)
  before `renv::restore()` will succeed
- Set `RENV_PATHS_CACHE` to PI storage so the package cache persists and doesn't eat home quota
- If using a different R version than local, renv will re-install packages for that version
  (the cache is version-specific)

---

## 8. Batch Processing with Snakemake

See `references/snakemake.md` for full Snakemake setup, SLURM executor configuration,
per-rule resource specification, profile setup, and tmux usage.

**When to use Snakemake:** Fan-out/fan-in workflows (many samples through same steps) or
complex dependency graphs. For linear pipelines (A → B → C), a simple bash script with
checkpointing is fine.

**Checkpointing principle:** All orchestrators must check for existing output before
re-running a stage. The output file itself is the checkpoint — no sentinel files.

---

## 9. Data Transfer

### rsync (preferred for large transfers)

```bash
# Local to cluster
rsync -avz --progress local_dir/ <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/<pi_netid>/project/

# Cluster to local
rsync -avz --progress <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/<pi_netid>/project/results/ local_results/
```

### scp (simple single-file transfers)

```bash
scp file.fasta <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/<pi_netid>/project/data/raw/
```

### Globus (very large datasets)

For multi-GB transfers, use Globus (<https://docs.ycrc.yale.edu/data/transfer/globus/>).
YCRC maintains Globus endpoints for each cluster.

### Between clusters

Use Globus or direct transfer between cluster login nodes (they can reach each other).

---

## 10. YCGA Sequencing Data

Yale Center for Genome Analysis (YCGA) data is stored at `/gpfs/ycga/sequencers` on McCleary.

### Accessing current data

YCGA sends an email with a URL when data is ready. Use the `ycgaFastq` utility:

```bash
module load ycga-public

# From the URL in YCGA's notification email
ycgaFastq fcb.ycga.yale.edu:3010/randomstring/sample

# By netid and flowcell
ycgaFastq <netid> AHFH66DSXX
```

For 10x and PacBio data, use `URLFetch`:

```bash
module load ycga-public
URLFetch http://fcb.ycga.yale.edu:3010/randomstring/folder
```

### Data retention

- ~45 days post-sequencing: raw files deleted
- ~60 days: fastq files moved to archive
- ~180 days: data removed from main storage (archive persists indefinitely)
- **As of March 31, 2026**: retention reduced to 6 months

### Archived data retrieval

Archives are in AWS Deep Glacier. Retrieval via web browser (`http://archive.ycga.yale.edu`)
or `ycgaFastq`. Normal retrieval: 48 hours. Expedited: 12 hours (8x more expensive).

### YCGA partition

Submit YCGA-related analysis jobs with `-p ycga` on McCleary to avoid compute charges.
Eligible users: Yale PIs using YCGA for sequencing and their authorized lab members.

---

## 11. Interactive Command Conventions

When giving the user commands to run on the cluster (not batch scripts), follow these
conventions:

### Always background long-running commands

Append `&` to any command that will take more than a few seconds:

```bash
pigz -p 8 *.fastq &
fasterq-dump --split-files --threads 8 SRR123456 &
```

This lets the user keep working in the same shell. Mention `jobs` and `fg` for checking
or re-attaching.

### Prefer parallel tools

| Slow tool | Fast alternative | Notes |
|-----------|-----------------|-------|
| `gzip` | `pigz -p N` | `module load pigz`. N = number of cores |
| `bzip2` | `pbzip2 -p N` | |
| `samtools sort` | `samtools sort -@ N` | Built-in threading |
| `samtools index` | `samtools index -@ N` | Built-in threading |

### Parallel processing of many files

When operating on many independent files, use `xargs -P`:

```bash
ls *.fastq | xargs -P 8 -I {} gzip {} &
```

### Always show full paths or clear context

Commands should be unambiguous — include `cd` to the working directory or use absolute
paths so the user can copy-paste without guessing context.

---

## 12. Job Script Generation

When asked to create a SLURM job, Claude operates in one of two modes depending on where
it is running.

### Local mode (Claude Code on laptop)

1. Generate the batch script (`.sh`) in the project directory
2. Show the full script for review
3. Provide the transfer and submit commands:
   ```bash
   rsync -avz batch/my_job.sh <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/<pi_netid>/project/batch/
   ssh mccleary "sbatch /vast/palmer/pi/<pi_netid>/project/batch/my_job.sh"
   ```
4. Also transfer any required input data or scripts referenced by the batch script

### Cluster mode (Claude Code on compute node via interactive session)

1. Generate the batch script in the project's `batch/` directory
2. **Always show the full script and ask for confirmation before submitting**
3. On approval, submit with `sbatch batch/my_job.sh`
4. Report the job ID and monitoring command (`squeue --me`, `jobstats <id>`)

### The `.py` + `.sh` pattern

In data science projects, batch scripts are **thin SLURM wrappers** that call `.py` analysis
scripts. The analysis logic lives entirely in the `.py` file; the `.sh` file handles only
SLURM directives, environment activation, and the `python` invocation.

**Batch script template** (calling a `.py` script):

```bash
#!/bin/bash
#SBATCH --job-name=<brief_name>
#SBATCH --partition=day
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=<your email>
#SBATCH --output=logs/slurm-<brief_name>-%j.out

# <One-line description of what this job does>

set -euo pipefail

BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

echo "=== Job info ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "Git hash: $(git rev-parse --short HEAD)"
echo ""

module load miniconda
source $(conda info --base)/etc/profile.d/conda.sh
conda activate <env-name>

echo "Python: $(which python)"
# echo "tool: $(tool --version)"   # Log versions of tools used by the .py script
echo ""

SECONDS=0
python scripts/<section>/XX_script.py
echo ""
echo "=== Completed in ${SECONDS}s ($(date)) ==="
```

This pattern keeps analysis code portable (runnable locally or interactively) while
SLURM configuration stays separate. See the `script-organization` skill for the full
convention including numbering.

### Commit before submit

**Always commit scripts before submitting batch jobs.** The git hash in BUILD_INFO.txt and
the SLURM log must reflect the code that actually ran. If you've been editing a `.py` script,
commit it (and the `.sh` wrapper) before `sbatch`. The provenance block logs
`git status --porcelain` as a safety net, but the intent is a clean tree at submit time.

This is the cluster-specific case of a general rule — see the `script-organization` skill
for the broader "commit before execute" convention that also covers `.qmd` rendering.

### Script generation rules

- Use the lab default batch script template from Section 4, including the provenance block
- Use the tool resource templates from Section 6 for SLURM directives
- Always include: `--job-name`, `--partition`, `--time`, `--cpus-per-task`, memory, `--output`
- Always `module purge` before loading modules (omit `module purge` when the only module is miniconda for conda-only jobs)
- Always pin module versions (e.g., `module load CellRanger/9.0.1`, never bare `module load CellRanger`)
- Follow the hybrid rule from Section 7: conda for portable tools, modules for cluster-only tools — never both for the same tool
- Always set `--mail-type=BEGIN,END,FAIL` and `--mail-user=<your email>`
- Log files go to `logs/` subdirectory
- For YCGA data analysis on McCleary, use `--partition=ycga`
- Add comments explaining non-obvious resource choices (e.g., "128G needed for PROST structure DB")
- Log version strings for every tool actually invoked in the script (in the provenance block)
- If unsure about resources, start conservative and note "check with jobstats after first run"

---

## 13. Policies

- **Scratch purge**: Files older than 60 days are automatically deleted. Email notification
  one week before. Do not artificially modify timestamps to circumvent.
- **Job rate limit**: 200 submissions per hour.
- **Max interactive apps**: 4 concurrent OOD interactive instances per user.
- **Module system**: Use `module load` for software. Run `module avail` to list available
  packages. Always `module purge` before loading to avoid conflicts.
- **McCleary decommission**: McCleary will be retired in 2026. Plan new long-term projects
  on Bouchet. McCleary remains useful for YCGA partition access.
- **YCGA partition**: Jobs on the `ycga` partition (McCleary) analyzing YCGA sequencing
  data are exempt from compute charges.
