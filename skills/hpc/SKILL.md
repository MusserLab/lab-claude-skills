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
| **McCleary** | `/vast/palmer/pi/musser` | `/vast/palmer/scratch/musser/` |
| **Bouchet** | `/nfs/roberts/project/pi_jm284/` | `/nfs/roberts/scratch/pi_jm284` |
| **Misha** | `/gpfs/radev/project/musser` | `/gpfs/radev/scratch` |

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
/nfs/roberts/project/pi_jm284/<project_name>/
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
#SBATCH --mail-user=<netid>@yale.edu

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
| `--mail-user` | — | `<netid>@yale.edu` | Notification email |
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
#SBATCH --mail-user=<netid>@yale.edu

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
# Process $SAMPLE
```

---

## 5. Partition Quick-Reference

### McCleary partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 256 CPUs, 3 TiB | — | Default. 26× (64 CPU, 983 GiB) + 5× (36 CPU, 180 GiB) |
| **devel** | 6 hours | 4 CPUs, 32 GiB | — | Max 1 job/user |
| **week** | 7 days | 192 CPUs | — | Extended runtime |
| **long** | 28 days | 36 CPUs | — | 3× (36 CPU, 180 GiB) |
| **gpu** | 2 days | 12 GPUs | A5000 (24 GB), A100 (80 GB), RTX 3090 (24 GB) | |
| **gpu_devel** | 6 hours | 2 GPUs | Mixed | Max 2 jobs/user |
| **bigmem** | 1 day | 32 CPUs | — | Up to 3,960 GiB/node |
| **scavenge** | 1 day | 1,000 CPUs | All idle GPUs | Preemptable |
| **ycga** | — | — | — | **YCGA data — exempt from compute charges** |

### Bouchet partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 1,200 CPUs, 18 TiB | — | 84 nodes (64 CPU, 990 GiB each) |
| **day_AMD** | 1 day | 1,200 CPUs, 18 TiB | — | 26 Turin nodes (128 CPU, 2,251 GiB each) |
| **devel** | 6 hours | 8 CPUs, 120 GiB | — | Max 2 jobs/user |
| **week** | 7 days | 64 CPUs, 1 TiB | — | 6 nodes |
| **gpu** | 2 days | 6 GPUs | RTX 5000 Ada (32 GB) | 9 nodes, 4 GPUs/node |
| **gpu_rtx6000** | 2 days | 6 GPUs | RTX Pro 6000 Blackwell (96 GB) | 8 Turin nodes, 8 GPUs/node |
| **gpu_h200** | 2 days | 16 GPUs | H200 (141 GB) | 9 nodes, 8 GPUs/node |
| **gpu_devel** | 6 hours | 2 GPUs | RTX 5000 Ada + H200 | Max 1 job/user |
| **bigmem** | 1 day | 128 CPUs, 8 TiB | — | 4 nodes (64 CPU, 4,014 GiB each) |
| **mpi** | 2 days | 32 nodes | — | 60 nodes, tightly-coupled parallel |
| **scavenge** | 1 day | — | L40S, RTX 5000 Ada, H200 | Preemptable idle nodes |

### Misha partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 512 CPUs, 20 TiB | — | 18× Intel 6458 (64 CPU, 479 GiB) |
| **devel** | 6 hours | — | — | 2 nodes, interactive |
| **week** | 7 days | 128 CPUs, 1,280 GiB | — | 6 nodes |
| **gpu** | 2 days | 192 CPUs, 18 GPUs | H100 (80 GB), H200 (141 GB), A100 (80 GB), A40 (48 GB), L40S (48 GB) | 32 nodes |
| **gpu_devel** | 6 hours | 2 GPUs | Mixed | 2 nodes |
| **bigmem** | 1 day | 64 CPUs, 2 TiB | — | 2× (64 CPU, 1,991 GiB) |

---

## 6. Tool Resource Profiles

SLURM resource recommendations only. Tool-specific skills handle how to invoke each
tool, generate batch scripts, and interpret output. This table just covers how much to
request from SLURM. **Always check `jobstats` after initial runs and adjust.**

**Tools with dedicated skills:** `eggnog-mapper` (eggNOG-mapper), `prost-annotation`
(PROST), `protein-phylogeny` (IQ-TREE, MAFFT), `expression-report` (scanpy/matplotlib).
Use those skills for batch script generation — this table is a quick resource reference.

| Tool | CPUs | Memory | Time | Partition | GPU | Notes |
|------|------|--------|------|-----------|-----|-------|
| **IQ-TREE — ModelFinder** | 8 | 4G/cpu | 2h | day | — | Quick model selection |
| **IQ-TREE — fast model** | 8 | 4G/cpu | 4h | day | — | Gene tree screening |
| **IQ-TREE — PMSF/C60** | 8 | 8G/cpu | 1 day | day/week | — | Use fixed `-T 8` not AUTO |
| **MAFFT — auto** | 4 | 4G/cpu | 1h | day | — | |
| **MAFFT — linsi** | 4 | 8G/cpu | 8h | day | — | >500 sequences |
| **Cell Ranger** | 16 | 64G total | 12h | day | — | Use `--mem=64G` |
| **STARsolo** | 16 | 64G total | 8h | day | — | Use `--mem=64G` |
| **DIAMOND** | 16 | 4G/cpu | 4h | day | — | Scales well with threads |
| **PROST** | 4 | 32G total | 4h | gpu | 1 | 22 min for 25K proteins (RTX 5000 Ada). Actual RAM ~6.5G. |
| **TransDecoder** | 4 | 4G/cpu | 2h | day | — | |
| **BUSCO** | 8 | 4G/cpu | 4h | day | — | Varies with lineage DB |
| **EggNOG-mapper** | 8 | 4G/cpu | 4h | day | — | |
| **Genome assembly** | 32 | 200G total | 2 days | week/bigmem | — | Highly variable; scale from jobstats |

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
export RENV_PATHS_CACHE="/vast/palmer/pi/musser/renv_cache"  # McCleary
# export RENV_PATHS_CACHE="/nfs/roberts/project/pi_jm284/renv_cache"  # Bouchet

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

### When to use Snakemake vs simple scripts

| Workflow pattern | Tool |
|-----------------|------|
| **Fan-out/fan-in** (many samples through same steps) | Snakemake |
| **Complex dependency graph** (multiple tools, conditional steps) | Snakemake |
| **Linear pipeline** (A → B → C, single sample) | Bash script or standalone Python |
| **Interactive/exploratory analysis** | `.qmd` script (local or cluster) |

Don't introduce Snakemake if it adds more complexity than it removes. A simple bash
script with checkpointing is fine for linear workflows.

### Checkpointing principle

All orchestrators (Snakemake, bash, Python) must implement checkpointing: **do not re-run
a stage if its output already exists.** The presence of the output file itself is the
checkpoint — never use sentinel files or hidden state.

- Snakemake gets this for free via output file tracking
- In bash: check with `[ -f output.fasta ] && echo "Skipping..." && exit 0`
- In Python: check with `if Path("output.fasta").exists(): ...`
- To re-run a specific stage: delete its output and re-launch

### Setup

```bash
module load miniconda
conda create -n snakemake -c conda-forge -c bioconda \
    snakemake snakemake-executor-plugin-slurm
conda activate snakemake
```

### Running

```bash
# Always dry-run first
snakemake -n --executor slurm

# Execute — Snakemake runs on the login node, each rule becomes a SLURM job
snakemake --executor slurm --jobs 50
```

### Per-rule resources in Snakefile

```python
rule align:
    input: "data/raw/{sample}.fasta"
    output: "results/alignments/{sample}.aln"
    log: "logs/align/{sample}.log"
    conda: "envs/phylo.yml"
    resources:
        slurm_partition="day",
        runtime=240,          # minutes
        mem_mb=20000,
        cpus_per_task=4,
        slurm_extra="'--mail-type=FAIL'"
    shell:
        "mafft --auto --thread {resources.cpus_per_task} {input} > {output} 2> {log}"
```

For GPU rules, add: `slurm_partition="gpu", slurm_extra="'--gpus=1'"`

### Snakemake profile (recommended)

Create `~/.config/snakemake/slurm/config.yaml` to set defaults:

```yaml
executor: slurm
jobs: 50
default-resources:
  slurm_partition: day
  runtime: 60
  mem_mb: 5000
  cpus_per_task: 1
latency-wait: 120
```

Then run: `snakemake --profile slurm`

### Use tmux for long-running orchestration

```bash
tmux new -s pipeline
module load miniconda
conda activate snakemake
snakemake --executor slurm --jobs 50
# Ctrl-b d to detach; tmux attach -t pipeline to reconnect
```

### Logging

Use Snakemake's `log:` directive to capture tool stdout/stderr. Follow the convention
`logs/{rule}/{sample}.log`. Exclude `logs/` from version control.

---

## 9. Data Transfer

### rsync (preferred for large transfers)

```bash
# Local to cluster
rsync -avz --progress local_dir/ <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/musser/project/

# Cluster to local
rsync -avz --progress <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/musser/project/results/ local_results/
```

### scp (simple single-file transfers)

```bash
scp file.fasta <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/musser/project/data/raw/
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
   rsync -avz batch/my_job.sh <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/musser/project/batch/
   ssh mccleary "sbatch /vast/palmer/pi/musser/project/batch/my_job.sh"
   ```
4. Also transfer any required input data or scripts referenced by the batch script

### Cluster mode (Claude Code on compute node via interactive session)

1. Generate the batch script in the project's `batch/` directory
2. **Always show the full script and ask for confirmation before submitting**
3. On approval, submit with `sbatch batch/my_job.sh`
4. Report the job ID and monitoring command (`squeue --me`, `jobstats <id>`)

### Script generation rules

- Use the lab default batch script template from Section 4, including the provenance block
- Use the tool resource templates from Section 6 for SLURM directives
- Always include: `--job-name`, `--partition`, `--time`, `--cpus-per-task`, memory, `--output`
- Always `module purge` before loading modules
- Always pin module versions (e.g., `module load CellRanger/9.0.1`, never bare `module load CellRanger`)
- Follow the hybrid rule from Section 7: conda for portable tools, modules for cluster-only tools — never both for the same tool
- Always set `--mail-type=BEGIN,END,FAIL` and `--mail-user=<netid>@yale.edu`
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