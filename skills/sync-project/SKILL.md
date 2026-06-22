---
name: sync-project
description: >
  Sync project state when arriving at a new machine (local or cluster). Pulls git,
  updates conda env from environment.yml, restores renv packages, checks for memory
  promotion. Use when switching between local and cluster work, starting a session on
  a different machine, or when the user invokes /sync-project.
  Do NOT auto-load — this is a deliberate, user-initiated workflow.
user-invocable: true
---

# Sync Project

Arrival-side sync for projects worked on across multiple machines (typically local macOS
and Yale HPC cluster). Ensures git, conda, and renv are current before starting work.

**This skill is arrival-only.** Departure-side tasks (env export, commit, push) are
handled by `/done`.

---

## Step 0: Detect Environment

Determine which machine we're on:

```bash
# Check for module command (cluster indicator)
type module &>/dev/null && echo "cluster" || echo "local"
hostname
```

Set the conda activation pattern based on environment:
- **Local (macOS):** `source ~/miniconda3/etc/profile.d/conda.sh`
- **Cluster (Bouchet):** `module load miniconda && source $(conda info --base)/etc/profile.d/conda.sh`

Read the project's `.claude/CLAUDE.md` to find:
- The conda environment name (from the Environment section)
- Whether renv is used

---

## Step 1: Git Sync

### 1a. Check local state

```bash
git status --short
```

If uncommitted changes exist, **stop and warn**:
> "You have uncommitted changes. Commit or stash before syncing?"

Do NOT proceed with `git pull` if there are uncommitted changes — this risks merge
conflicts that could lose work.

### 1b. Fetch and classify divergence

```bash
git fetch
git rev-list --left-right --count @{u}...HEAD   # → "<behind> <ahead>"
```

Branch on the counts (do NOT blindly `git pull` — it silently merges on divergence):

| behind / ahead | Meaning | Action |
|----------------|---------|--------|
| `0 / 0` | Up to date | Report "Already up to date." Done. |
| `N / 0` | Remote ahead only | Fast-forward: `git pull --ff-only`. No decision needed. |
| `0 / N` | Local ahead only | Nothing to pull. Note: "N local commit(s) not pushed — push via `/done`." |
| `N / M` | **Diverged** (both sides have commits) | Go to 1c. |

Report what was updated (files changed, new files, deletions).

### 1c. Diverged — choose integration (rebase vs merge)

Reached only when both sides have commits.

1. **Preview conflicts (non-destructive — changes nothing):**
   ```bash
   git merge-tree --write-tree @{u} HEAD   # exit 0 = clean; exit 1 = conflicts (lists files)
   ```
2. **Recommend an approach:**
   - Local commits **not yet pushed** → **rebase** (`git pull --rebase`): replays your commits on top of the remote → linear history. Safe because unshared commits can be rewritten. ← default recommendation.
   - Local commits **already pushed / shared** → **merge** (`git pull`): creates a merge commit; never rewrites shared history.
3. Report the preview result + recommendation, then **proceed only on user confirmation**.
4. If the chosen integration hits conflicts, **report them and stop** — do NOT auto-resolve.

---

## Step 2: Conda Environment

### 2a. Check if environment.yml exists

If no `environment.yml` in the project root, skip this step.

### 2b. Read env name from environment.yml

```bash
head -1 environment.yml  # name: my-env
```

### 2c. Check if environment exists

```bash
conda env list | grep -q "env-name"
```

- **Env doesn't exist:** Create it: `conda env create -f environment.yml`
- **Env exists:** Update it: `conda env update -f environment.yml --prune`

The `--prune` flag removes packages no longer in `environment.yml`.

### 2d. Verify

```bash
conda activate env-name && python --version
```

Report the Python version and package count as a sanity check.

---

## Step 3: renv (if applicable)

Skip if no `renv.lock` in the project root.

### 3a. Check status

```bash
Rscript -e "renv::status()"
```

### 3b. Restore if needed

If packages are out of sync:

```bash
Rscript -e "renv::restore()"
```

Report what was installed/updated or "renv is in sync."

---

## Step 4: Memory Promotion

Scan for project-relevant memory files:

```bash
ls ~/.claude/projects/*<project-name>*/memory/ 2>/dev/null
```

Where `<project-name>` is a fuzzy match on the project directory name.

If memory files exist:
1. Read each one
2. For each, assess: does this contain information that should be in a `.claude/` planning
   doc or CLAUDE.md so it's available on both machines?
3. If yes, show the memory content and suggest where to add it
4. Ask the user before making changes

If no memory directory exists or it's empty, skip silently.

---

## Step 5: Report

```
/sync-project complete

Git:    pulled 3 files (scripts/01_busco.qmd, batch/run_busco.sh, ...)
Conda:  spongilla-genome updated (2 packages added)
renv:   in sync
Memory: 1 memory promoted to .claude/STRESS_TEST_FINDINGS.md

Ready to work.
```

---

## environment.yml Hygiene

These checks run as part of Step 2 but are documented here for reference.

When this skill reads `environment.yml`, flag these issues:

| Issue | Action |
|-------|--------|
| `prefix:` line present | Warn — this is a machine-specific path that shouldn't be in git |
| `defaults` in channels | Warn — conflicts with bioconda strict channel priority |
| Missing `conda-forge` channel | Warn — needed for most scientific Python packages |
| Missing `bioconda` channel | Note — only needed if bioinformatics tools are in conda |

These are warnings only — the skill does not auto-fix `environment.yml` during arrival.
Fixes happen at departure time (in `/done`) when exporting the environment.

---

## What This Skill Does NOT Do

- Does not commit, push, or export environments (that's `/done`)
- Does not handle `~/.claude` sync (that's `/sync-cluster`)
- Does not check batch script provenance blocks (arrival is not the time for that)
- Does not auto-run — must be explicitly invoked with `/sync-project`
