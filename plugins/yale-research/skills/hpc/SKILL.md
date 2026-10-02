---
name: hpc
description: >
  Use for Yale YCRC HPC clusters (McCleary, Bouchet, Misha), including
  first-time cluster setup or adding another cluster,
  when writing SLURM batch scripts, configuring job resources, or for ANY
  question about cluster storage — quotas, PI/project/scratch/home space,
  shared data or database folders, Palmer vs Gibbs, /vast vs /gpfs vs /nfs,
  or purge policy. Use it whenever someone is out of space or trying to make
  space — a full or nearly-full quota, a getquota warning, a YCRC storage
  notice, "cleaning up", "freeing up space", deciding what is safe to delete,
  or archiving data off the cluster to the lab NAS (Globus transfer, verifying
  a transfer completed, then deleting the cluster copy). Also use when running
  bioinformatics tools on HPC, setting
  up Snakemake pipelines, managing the cluster software environment (module
  load vs conda, conda envs, renv on HPC), transferring data to or from the
  cluster (rsync, scp, Globus, between-cluster transfer), or retrieving YCGA
  sequencing data (ycgaFastq, URLFetch, archived/Glacier fastq retrieval,
  the -p ycga partition). Also use when connecting to the cluster remotely or
  running Claude Code on a compute node (SSH setup, Positron/VS Code Remote
  SSH, interactive sessions, "Claude Code on the cluster", Duo 2FA +
  ControlMaster connection multiplexing, Windows/WSL vs macOS/Linux remote
  setup). Covers lab-specific storage paths, partition tables, and tool
  resource templates.
---

# Musser Lab HPC Reference

Yale Center for Research Computing (YCRC) guidance, with configurable Musser Lab defaults.
Full YCRC documentation: <https://docs.ycrc.yale.edu/>

For first-time setup or adding a cluster, begin with the guided
[student cluster setup](references/student-setup.md). It resolves the account, client, execution
host and lab/project settings, preserves completed setup, and reports pending steps honestly.
Lab paths below are useful defaults, not proof of access. Confirm the researcher's own NetID,
chosen cluster, project/environment and archive policy before adopting them.

---

## 1. Getting Started

### Account setup

Request an account at <https://research.computing.yale.edu/account-request>. You need a
Yale NetID and approval from the responsible PI.

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

**Note on "passwordless":** SSH keys get you past the *password*, but YCRC still requires
**Duo 2FA** (a `keyboard-interactive` passcode) on every login-node connection. For
interactive terminal use that's just one extra prompt. For **Positron / VS Code Remote-SSH**,
the non-interactive ProxyCommand can't answer Duo — you must use SSH `ControlMaster`
multiplexing so one interactive login is reused. See `references/positron-ssh-setup.md` for
the full template and setup order — it covers two tiers: a **basic** session, and a
**persistent** one that survives VPN/laptop disconnects (the allocation is held in `tmux` on
the login node, so a dropped connection no longer kills it).

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
| **McCleary** | YCGA-affiliated workloads during the transition | Being reduced to YCGA-only service; check the current migration notice |
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

| Cluster | PI storage (canonical) | Home symlink (lab convention) | Scratch |
|---------|-----------|-------------------------------|---------|
| **McCleary** | `/vast/palmer/pi/musser` | — | `/vast/palmer/scratch/musser/` |
| **Bouchet** | `/nfs/roberts/project/pi_jm284/` | `~/project_pi_jm284/` (= `/home/<netid>/project_pi_jm284/`) | `/nfs/roberts/scratch/pi_jm284` |
| **Misha** | `/gpfs/radev/project/musser` | — | `/gpfs/radev/scratch` |

> **McCleary has two lab storage roots — check access and quotas before choosing:**
> `/vast/palmer/pi/musser` (Palmer VAST) is the lab default for bulky raw/shared data.
> `/gpfs/gibbs/project/musser` is a separate Gibbs allocation. Do not assume their quotas,
> free space or permissions are interchangeable. Check `getquota` and project guidance;
> confirm a different root when the project or tool needs it.

### Shared lab data folder (raw sequencing data, cross-cluster)

Raw sequencing deliveries shared across projects/people live in a shared data folder under PI
storage. **The intermediate folder name differs between clusters** — Bouchet uses `shared/`,
McCleary uses `Data/` — so it is NOT a clean root-prefix swap; use the per-cluster path below:

| Cluster | Shared data root | YCGA deliveries land at |
|---------|------------------|-------------------------|
| **Bouchet** | `/nfs/roberts/project/pi_jm284/shared/` (= `~/project_pi_jm284/shared/`) | `…/shared/YCGA_DATA_POSTED/` |
| **McCleary** | `/vast/palmer/pi/musser/Data/` (Palmer — NOT Gibbs) | `/vast/palmer/pi/musser/Data/YCGA_DATA_POSTED/` |

Under either root the internal layout may include `…/YCGA_DATA_POSTED/PACBIO/...` and
`…/YCGA_DATA_POSTED/SingleCell/...`; inspect the actual intended delivery. Stage from the
confirmed archive via Globus. Resolve any symlinks explicitly rather than inferring custody.
In scripts, parameterize the root (note the differing folder name per cluster):

```bash
SHARED_DATA="${SHARED_DATA:-$HOME/project_pi_jm284/shared}"   # Bouchet; McCleary: /vast/palmer/pi/musser/Data
```

On Bouchet, lab members typically work via the home symlink `~/project_pi_jm284/` and
keep their projects under a per-user subdirectory:
`~/project_pi_jm284/<netid>/projects/<project_name>/`. This resolves to
`/nfs/roberts/project/pi_jm284/<netid>/projects/<project_name>/` underneath. Both
forms work for shell and filesystem operations; the home-symlink form is more
discoverable and matches `cd` history.

**Codex Desktop path-matching issue (observed 2026-08-24):** When adding a Bouchet
SSH project, use the canonical `/nfs/...` path. Desktop may compare the project root
and chat working directory as literal paths, so registering through
`~/project_pi_jm284/...` can make intact chats disappear from the project view.
Re-add the project with its canonical path; do not move or copy files or chats.

### Shared lab databases on Bouchet

Reference databases that are reusable across projects (BUSCO lineages, eggNOG DB,
DIAMOND-formatted UniProt, sponge mitochondrial reference sets, etc.) live at:

```
~/project_pi_jm284/shared/databases/
  busco_lineages/      # check installed lineage identity/version (metazoa, eukaryota, etc.)
  ...                  # other shared DBs as they're added
```

Resolves to `/nfs/roberts/project/pi_jm284/shared/databases/` under the symlink.

When writing batch or setup scripts that reference these shared DBs, use a parameter
that defaults to this location and can be overridden via env var:

```bash
SHARED_DBS="${SHARED_DBS:-$HOME/project_pi_jm284/shared/databases}"
```

This way the script picks up the lab default automatically but can be redirected
on a non-Bouchet machine, or to a different location for testing, without editing.

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

> **Verify the current purge window before relying on it.** Read `getquota` and current
> YCRC storage notices for the selected filesystem. Do not assume the bundled summary is live
> state; remove temporary files deliberately only within an approved cleanup scope.

### Archiving to the lab NAS to free cluster space

**Do not suggest this unprompted.** Project files belong together on the cluster, and archiving
fragments a project. Raise it only when the user is **actually trying to free space** — they mention a
full quota, a `getquota` warning, a YCRC storage notice, or ask how to clean up.

**Recommended lab model:** use the lab NAS as the durable authoritative archive, with its
backup arrangement confirmed during setup. A project may document a different archive policy.
The cluster copy becomes disposable only after the entire intended archive is verified and the
researcher explicitly authorizes removal of the exact host-local paths. Confirm access, archive
root and relative-path mapping; no private NAS endpoint or account inventory ships here.
NAS↔cluster transfers use **Globus**; do not assume a NAS mount on the cluster.

Mirror the project layout under its confirmed archive root where practical so archived paths
remain understandable. Use the project's existing custody record when one is required.

#### The procedure

1. **Define the complete source universe before transfer.** Use the owning project's manifest or
   a scoped listing of every intended relative path and size, including an explicit disposition
   for symlinks and exclusions. Directory counts and aggregate bytes are useful summaries but
   cannot prove that the right files were selected or that a matching subset is a complete archive.
2. **Use the included `globus-transfer` workflow** for the exact approved source, destination,
   selection and overwrite behavior. Agent writes use literal direct CLI commands. Keep encryption
   and checksum verification enabled; authentication/MFA remain the researcher's actions.
3. **Verify integrity and completeness separately.** A successful task establishes the outcome of
   that submitted task, not the unsubmitted universe. Follow `globus-transfer` through terminal
   status/options/faults/skips and a full mapped destination path-and-size comparison against every
   intended file. Content verification of transferred files does not verify existing files skipped
   by `exists`; establish their checksum equivalence separately or report them unverified.
4. **Hold removal until verification and separate authority are complete.** Confirm that the source
   universe has not changed and preserve required evidence promptly in the owning record. No Globus
   deletion or purge is permitted. Host-local removal needs explicit exact-path approval and the
   project's custody/retention requirements. If a specialized owner workflow is required, including
   a YCGA intake/archive-removal workflow, hold that removal until it is available and completed;
   this package does not substitute for it.

GNU and BSD `find` differ (`-printf` is GNU-only); on a Mac use the appropriate `stat` syntax.
Report Finder metadata (`.DS_Store`, `._*`) separately from the intended scientific file universe;
never silently change the approved selection to make summaries match.

When freeing space, consider large regenerable intermediates before small or curated material.
A copy on another cluster also needs complete identity/integrity evidence and retention authority;
its mere existence does not authorize removal. Preserve the archive path, mapped comparison,
request and task evidence in the existing project record when custody or later removal relies on it.

### Project organization on the cluster

Mirror the local project structure in PI storage or project space:

```
/nfs/roberts/project/pi_jm284/<project_name>/
  .git/              # Same repo as local — sync via git push/pull
  .claude/           # Project docs, plans, findings
  batch/             # SLURM batch scripts (tracked in git)
  logs/              # SLURM output evidence (retain; Git policy is project-specific)
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

- **Git syncs scripts, docs, logs, and batch files.** Before pulling, use the guarded branch,
  upstream, worktree and incoming-history checks in `git-conventions`; pull only when they
  are compatible.
- **Data syncs via Globus.** Large files (`data/`, tool outputs) are gitignored and
  transferred manually. Not all data exists in both places.
- **Batch scripts use `BASEDIR=$(git rev-parse --show-toplevel)`** — no hardcoded paths.
  This makes scripts work regardless of where the repo is cloned.
- **Logs are retained as project evidence.** Track them in Git or keep them ignored according to
  the project's declared custody; do not force one global choice.
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
#SBATCH --mail-user=<your-email>

set -euo pipefail

# ── Provenance ────────────────────────────────────────
BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

# EDIT: declare the committed project-relative wrapper, producer, helpers and small config.
RELEVANT_CODE_PATHS=(
  "batch/my_job.sh"
  "scripts/my_analysis.py"
  "config/my_analysis.yaml"
)
GIT_COMMIT="${EXPECTED_COMMIT:?submit with EXPECTED_COMMIT set to the producing commit}"
git cat-file -e "${GIT_COMMIT}^{commit}"
for relative in "${RELEVANT_CODE_PATHS[@]}"; do
  committed_blob=$(git rev-parse "${GIT_COMMIT}:${relative}")
  working_blob=$(git hash-object "$relative")
  [[ "$working_blob" == "$committed_blob" ]] || {
    echo "ERROR: relevant producing file does not match $GIT_COMMIT: $relative" >&2
    exit 1
  }
done

# SLURM executes a queued copy. Verify that copy is the committed wrapper named first above.
submitted_wrapper_blob=$(git hash-object "${BASH_SOURCE[0]}")
[[ "$submitted_wrapper_blob" == "$(git rev-parse "${GIT_COMMIT}:${RELEVANT_CODE_PATHS[0]}")" ]] || {
  echo "ERROR: queued wrapper does not match $GIT_COMMIT" >&2
  exit 1
}

echo "=== PROVENANCE ==="
echo "Job ID:      $SLURM_JOB_ID"
echo "Script:      \$0"
echo "Commit:      $GIT_COMMIT"
echo "Date:        $(date -Iseconds)"
echo "Node:        $(hostname)"

# Modules (cluster-only tools — always pin versions)
module purge
module load Tool/1.2.3

module list 2>&1

# Conda (project environment)
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate myenv
echo "Conda env:   $CONDA_DEFAULT_ENV"

# Log versions of key tools used in this script
echo "tool:        $(tool --version | head -1)"
echo "=== END PROVENANCE ==="
# ──────────────────────────────────────────────────────

# ── Main ──────────────────────────────────────────────
# Your commands here

# Refuse successful completion if a relevant project file changed while the job ran.
for relative in "${RELEVANT_CODE_PATHS[@]}"; do
  [[ "$(git hash-object "$relative")" == "$(git rev-parse "${GIT_COMMIT}:${relative}")" ]] || {
    echo "ERROR: relevant producing file changed during execution: $relative" >&2
    exit 1
  }
done
```

Before submission, the lead or assigned worker makes a focused commit containing the wrapper,
producer, local helpers and configuration, and pushes when the task and project authority permit.
Follow the project's Git/publication boundaries; a private maintainer's authority does not grant
students permission to push another repository. The batch script never adds, commits or pushes. Pass that exact commit when submitting:

```bash
EXPECTED_COMMIT=$(git rev-parse HEAD)
sbatch --export=ALL,EXPECTED_COMMIT="$EXPECTED_COMMIT" batch/my_job.sh
```

The job verifies its queued wrapper and the current relevant project files against that commit at
execution. Unrelated dirty files do not block it. Its provenance block prints the commit, job ID,
environment and tool versions to the SLURM log.

**Provenance block requirements:**
- `BASEDIR` + `cd` — ensures git commands and relative paths work
- named commit plus relevant-file checks — the queued wrapper, producer, helpers and configuration
  must match the commit at execution and completion
- `module list` — all loaded modules and their exact versions
- `conda activate` + env name — which conda environment was used
- Tool version lines — one per tool actually invoked in the script

**File organization:**
- Batch scripts → `batch/` subdirectory
- Log files → `logs/` subdirectory (create with `mkdir -p logs` before first submit)
- `batch/` is tracked in git (scripts are code)
- Retain the job log according to project custody; scheduler logs may be tracked or ignored.

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
| `--mail-user` | — | `<your-email>` | Confirm the researcher's notification email |
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
| Bouchet | `gpu` | RTX 5000 Ada / L40S / A40 / A5000 | 24–48 GB; specify required type |
| Bouchet | `gpu_rtx6000` | RTX Pro 6000 Blackwell | 96 GB |
| Bouchet | `gpu_h100` | H100 | 80 GB |
| Bouchet | `gpu_h200` | H200 | 141 GB |
| Bouchet | `gpu_b200` | B200 | 193 GB |
| McCleary | `gpu` | A5000 / A100 / RTX 3090 / RTX 5000 | 16–80 GB; specify required type |
| Misha | `gpu` | H100/H200/A100/A40/L40S | 48-141 GB |

GPU profile checked against [YCRC Bouchet](https://docs.ycrc.yale.edu/clusters/bouchet/),
[McCleary](https://docs.ycrc.yale.edu/clusters/mccleary/) and
[Misha](https://docs.ycrc.yale.edu/clusters/misha/) on 2026-10-01; no scheduler query was run.
Confirm available GPU types/limits before submission. Load the pinned CUDA version required by
this tool's declared environment before activation when that environment needs a CUDA module.

For choosing the least-congested GPU partition before submitting, and for switching a
pending job's partition to a faster queue, see `references/gpu-partition-tactics.md`.

### Interactive jobs

**Interactive work belongs in `devel`.** YCRC makes `devel` the **default partition for
`salloc`**, and interactive jobs are normally permitted on `devel` (or `gpu_devel` for a GPU) or
on a private partition you have been explicitly authorized to use — **not** generally on the
other public partitions. Do not reach for `day` just because an interactive job wants more time
or more cores; that is a signal to write a batch script.

**IDE sessions — Positron or VS Code, including Claude Code running inside them — are covered by
a stricter, explicit rule.** YCRC states that VS Code jobs found outside the devel partitions
**may be terminated without notice**; this skill treats Positron Remote-SSH as the same kind of
IDE workload, so the same rule is assumed to apply to it.

```bash
# Quick interactive session (testing, short tasks)
salloc -p devel -c 4 --mem=16G -t 2:00:00

# Claude Code / Positron working session (writing scripts, running them, submitting batch jobs)
salloc -p devel -c 4 --mem=32G -t 6:00:00 --job-name=positron-devel
```

**Sizing an interactive session: 4 CPUs, up to 32 GB RAM.** Most interactive work (writing
scripts, parsing TSVs/GFFs, pandas, matplotlib) needs <4 GB; the extra memory is headroom for
occasional spikes (loading large SQLite DBs, sorting big BLAST outputs, multi-panel figures).

**`devel` per-user limits are aggregate across all of your `devel` jobs, not per job** (see
`references/partitions.md`):

| Cluster | Max time | Aggregate per user | Submitted jobs |
|---------|----------|--------------------|----------------|
| Bouchet `devel` | 6 hours | 4 CPUs, 60G | max 2 |
| McCleary `devel` | 6 hours | 4 CPUs, 32G | max 1 |

A single 4-CPU session therefore consumes your entire `devel` CPU allowance on either cluster,
and McCleary permits only one submitted `devel` job at a time.

Heavy compute (DIAMOND, Cell Ranger, STAR, BRAKER, eggNOG-mapper, PROST) should always
be submitted as batch jobs — never run on the interactive node. Rule of thumb: if it takes
>5 minutes or needs >4 CPUs, write a batch script.

Add `--x11` for graphical forwarding (requires X11 setup).

For setting up Positron (VS Code) to connect to an interactive session via SSH, see
`references/positron-ssh-setup.md`. It documents two tiers — a **basic** session (quick to set
up; a laptop/VPN drop kills the allocation) and a **persistent** session (a bit more setup; the
allocation survives disconnects via a `tmux`-held `salloc` + helper scripts, with reconnect
instructions). The persistent tier buys **no extra time and no extra resources** — it is the same
6-hour `devel` job inside the same caps. What it buys is that a laptop sleep, VPN drop, or closed
lid no longer forfeits the rest of that session and sends you back to the queue.

**If Claude Code / Codex ask to be reinstalled on every new session**, you are on the optional
node-local `/tmp` server route and landing on a different compute node each allocation. Set
`remoteSSH.defaultExtensions` — see the "Pin your own extensions" subsection in
`references/positron-ssh-setup.md`.

**If an extension breaks the moment you reconnect** (e.g. Codex showing only "Oops, an error has
occurred"), **reload the webview before you touch versions** — Developer: Reload Window, then
Developer: Reload Webviews, then a full quit, which is the first step that clears the client-side
asset cache. A webview asset failure is one possible cause; the request happens in the laptop renderer, so
inspect the client Network panel as well as cluster logs before assigning cause. See "reload the webview before you touch
versions" in `references/positron-ssh-setup.md` for the fix ladder, the log lines that are
permanent background noise, and why the obvious version-rollback diagnosis was wrong.

### Job monitoring

| Command | Purpose |
|---------|---------|
| `squeue --me` | List your running/pending jobs |
| `sacct -j <id>` | Job status and resource usage |
| `jobstats <id>` | Efficiency metrics (CPU/memory utilization) |
| `scancel <id>` | Cancel a job |
| `sbatch --test-only script.sh` | Estimate queue start time without submitting |

### Resource efficiency

Check resource usage after completed or failed jobs using the
[active-session resource learning procedure](references/resource-learning.md). Record observations
with existing project run evidence and use comparable private profiles for later requests.
Unknown metrics and failed/OOM jobs do not prove an allocation was adequate. Request resources
that the workload needs; wasteful allocations slow scheduling for everyone.

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
#SBATCH --mail-user=<your-email>

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
# Process $SAMPLE
```

---

## 5. Partition Quick-Reference

See `references/partitions.md` for full partition tables (McCleary, Bouchet, Misha) with
dated time limits, aggregate per-user resource limits, GPU types and current-verification commands.

**Quick summary for partition selection:**
- **General compute** → `day` (1-day limit, generous CPU/memory)
- **Long jobs** → `week` (7-day) or `long` (28-day, McCleary only)
- **GPU** → choose the documented hardware/VRAM requirement in `references/partitions.md`; Bouchet has mixed `gpu`, `gpu_h100`, `gpu_h200`, `gpu_rtx6000` and `gpu_b200`
- **Interactive/testing** → `devel` (6-hour limit, strict per-user caps)
- **YCGA data** → `ycga` on McCleary (exempt from compute charges)
- **Big memory** → `bigmem` (up to 4 TiB/node on Bouchet)
- **Preemptable** → `scavenge` (free idle resources, may be killed)

---

## 6. Tool Resource Profiles

See `references/tool_profiles.md` for SLURM resource recommendations per bioinformatics
tool (CPUs, memory, time, partition, GPU). They are starting estimates, not workload guarantees.
Use [resource learning](references/resource-learning.md) to retain observed usage privately and
refine comparable requests without changing scientific methods.

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
| Lightweight bioinformatics (samtools, MAFFT, DIAMOND) | Cell Ranger, STAR, PROST, eggNOG-mapper |
| Anything tracked in `environment.yml` | GPU-dependent tools requiring CUDA |

**Always pin module versions** — use `module load CellRanger/9.0.1`, never bare
`module load CellRanger`. Unpinned modules silently change when the cluster updates
defaults. The provenance block in the batch template logs loaded versions, but pinning
prevents the drift in the first place.

### Container-backed modules may silently swallow your arguments

Some Bouchet modules are not real binaries but **one-line shell wrappers around an Apptainer
container**, and several of them **do not forward arguments** (no `"$@"`). The command then
appears to run, exits 0, and produces nothing — because every flag you passed was dropped and
the tool launched in its default interactive mode.

Confirmed case: `LibreOffice/25.2.5`. Its `libreoffice` wrapper is literally

```sh
#!/bin/sh
apptainer exec --env DISPLAY=$DISPLAY /apps/.../LibreOffice-25.2.5.sif libreoffice
```

so `libreoffice --headless --convert-to pdf deck.pptx` silently becomes a bare interactive
`libreoffice`, which hangs until it is killed. It cost a long debugging detour once.

**How to spot it:** the command hangs or exits 0 with no output file, and there is no error.
**How to check:** `cat $(which <tool>)` — or `cat $EBROOT<TOOL>/<tool>` — and look for a
wrapper that ends in the tool name with no `"$@"`.
**How to fix:** skip the wrapper and call the container directly, appending your arguments.

```bash
module load LibreOffice/25.2.5           # only to resolve $EBROOTLIBREOFFICE / the .sif path
apptainer exec /apps/software/system/software/LibreOffice/25.2.5/LibreOffice-25.2.5.sif \
  libreoffice --headless --norestore -env:UserInstallation=file:///tmp/lo_$USER \
  --convert-to pdf --outdir . mydeck.pptx
```

`-env:UserInstallation=file:///tmp/...` gives LibreOffice a writable private profile, which
avoids a second class of hang when `$HOME` is shared or read-only. The same "call the `.sif`
directly" pattern applies to any other container-backed module that ignores its arguments.

### Conda (Python + bioinformatics tools)

```bash
module purge
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"

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
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
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
export RENV_PATHS_CACHE="/vast/palmer/pi/musser/<netid>/renv_cache"  # McCleary: confirm writable root
# export RENV_PATHS_CACHE="/nfs/roberts/project/pi_jm284/<netid>/renv_cache"  # Bouchet

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

**Resume principle:** Reuse a stage only when its expected outputs are complete for the intended
inputs, code and configuration. File existence alone does not establish completion. Use the workflow's
existing completion evidence; do not add a cache or checkpoint framework without a concrete need.

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

For multi-GB transfers, use the included `globus-transfer` skill and current
[YCRC Globus guidance](https://docs.ycrc.yale.edu/data/transfer/globus/).
Discover the selected cluster collection by name and verify its ID/access; do not infer an endpoint.

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

- Retention is **6 months** post-sequencing (policy effective 2026-03-31). The previous
  staged schedule — raw files ~45 days, fastq moved to archive ~60 days, removed from main
  storage ~180 days — no longer applies. Archived data persists indefinitely.

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

When asked to create a SLURM job, the agent operates in one of two modes depending on where
it is running.

### Local mode (agent on laptop)

1. Generate the batch script (`.sh`) in the project directory
2. Show the full script for review
3. Provide the transfer and submit commands:
   ```bash
   rsync -avz batch/my_job.sh <netid>@mccleary.ycrc.yale.edu:/vast/palmer/pi/musser/project/batch/
   ssh mccleary "sbatch /vast/palmer/pi/musser/project/batch/my_job.sh"
   ```
4. Also transfer any required input data or scripts referenced by the batch script

### Cluster mode (agent on compute node via interactive session)

1. Generate the batch script in the project's `batch/` directory
2. Check that the method, inputs, outputs and resource scale are within the agreed work. Discuss
   potentially large aggregate CPU/GPU, memory, concurrency, storage/I/O or arrays before launch.
3. Preserve the actual producing state and submit an ordinary job or retry with
   `sbatch batch/my_job.sh` without another permission request.
4. Report the job ID and monitoring command (`squeue --me`, `jobstats <id>`)

### Analysis and scheduler setup

Batch scripts are **thin SLURM wrappers**: scheduler directives, environment or module setup,
logging and invocation of the chosen analysis file. Scientific logic stays in that file.
Use the project's R, Python or Quarto workflow; the host supplies resources, not a format mandate.
Keep `set -euo pipefail`, a named log and appropriate version reporting in shell wrappers.
See **`script-organization`** when the project uses its numbered analysis layout.

### Producing state before submit

Before submitting a retained scientific analysis job, use one focused commit containing the actual
submitted wrapper, analysis file, configuration and every project-local helper it uses. Reuse a
suitable existing commit when those relevant files are unchanged. Otherwise, within the agreed
scope, the lead or assigned worker inspects the relevant diff and makes the checkpoint, pushing
only within the task's Git authority; the job itself never stages, commits or pushes. Pass the fixed commit as
`EXPECTED_COMMIT`, verify the queued wrapper and declared relevant files against it at execution,
and verify the relevant files again at completion. Unrelated dirty work does not block the job.
Record the invocation, inputs, environment/tool versions, scheduler resources, job ID and outputs;
retain useful logs and job history according to project custody and preserve any specialized custody
record. Uncommitted source is limited to explicitly provisional development checks with isolated
outputs; rerun from committed source before retained scientific or ordinary downstream use. Keep
retained outputs protected independently of Git state, and verify upstream completion before a
dependent job starts.

### Script generation rules

- Use the lab default batch script template from Section 4, including the provenance block
- Use the tool resource templates from Section 6 for SLURM directives
- Always include: `--job-name`, `--partition`, `--time`, `--cpus-per-task`, memory, `--output`
- Always `module purge` before loading modules (omit `module purge` when the only module is miniconda for conda-only jobs)
- Always pin module versions (e.g., `module load CellRanger/9.0.1`, never bare `module load CellRanger`)
- Follow the hybrid rule from Section 7: conda for portable tools, modules for cluster-only tools — never both for the same tool
- Set `--mail-type=BEGIN,END,FAIL` and the researcher's confirmed `--mail-user=<your-email>`
- Log files go to `logs/` subdirectory
- For YCGA data analysis on McCleary, use `--partition=ycga`
- Add comments explaining non-obvious resource choices (e.g., "128G needed for PROST structure DB")
- Log version strings for every tool actually invoked in the script (in the provenance block)
- If unsure about resources, start conservative and note "check with jobstats after first run"

---

## 13. Policies

YCRC policy hard-values live at their topical homes; this index points to them so the
numbers have a single source of truth (update them there, not here):

- **Scratch 60-day purge** (+ no conda envs / no sole-copy raw data on scratch, email one
  week before, no timestamp-gaming) — see §3 Storage policies.
- **Job rate limit — 200 submissions/hour** — see §4 Job arrays.
- **Max 4 concurrent OOD interactive apps per user** — see §2 Open OnDemand.
- **McCleary transition to YCGA-only / Bouchet primary for general work** — see §2 and current [YCRC migration guidance](https://docs.ycrc.yale.edu/clusters/grace-mccleary-decommission/).
- **`ycga` partition compute-charge exemption** (`-p ycga`, McCleary, YCGA data) — see §2 and §10.
- **Module system** (`module load` / `module avail` / always `module purge` first) — see §7/§12.
