---
name: sync-project
description: >
  Synchronize an established project's Git state and declared Conda or renv environment when
  arriving on another workstation or compute host. Use only when the researcher deliberately
  requests project synchronization or a cross-machine arrival check.
---

# Sync Project

Arrival-side synchronization for projects worked on across multiple machines. Reconcile Git
and the project's declared environments before starting dependent work.

**This skill is arrival-only.** Use the project's closeout procedure to preserve, commit, push,
or export departure-side state.

---

## Step 0: Resolve the project, host, and runtimes

Confirm the physical project root and identify the host for reporting:

```bash
git rev-parse --show-toplevel
hostname
```

Read the project's native instructions, environment specifications, and optional site execution
profile. Record:

- the declared Conda specification and environment identity;
- how this site exposes Conda;
- whether `renv.lock` is authoritative and which R runtime/setup command the project declares;
- any host-specific checkout, module, or runtime command explicitly declared by the selected profile.

Do not infer a site from the operating system, hostname pattern, or presence of an environment-
modules command, and do not invent a scheduler, module, installation path, environment name, or R
runtime. Keep setup, activation, and every dependent Conda or R command in the same shell invocation;
shell state does not persist between tool calls. If no declared route exists, report the gap.

---

## Step 1: Git Sync

### 1a. Check local state

```bash
git status --short --branch
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
```

If uncommitted changes exist, **stop and warn**:
> "You have uncommitted changes. Commit or stash before syncing?"

Do NOT proceed with Git integration if there are uncommitted changes — this risks conflicts that
could lose work.

Confirm that HEAD is on the intended project branch and record its configured upstream, remote, and
remote merge ref. These are project state; do not substitute `main` or `origin` from convention. If
HEAD is detached, the branch has no upstream, or the upstream is not the intended cross-machine
checkpoint, stop and resolve that choice before fetching or integrating.

### 1b. Fetch the resolved remote and classify divergence

```bash
git config --get "branch.<current-branch>.remote"
git config --get "branch.<current-branch>.merge"
git fetch <resolved-remote>
git rev-list --left-right --count <resolved-upstream>...HEAD   # → "<behind> <ahead>"
```

Branch on the counts. Do not use plain `git pull`: its integration method follows configuration and
may merge or rebase on divergence.

| behind / ahead | Meaning | Action |
|----------------|---------|--------|
| `0 / 0` | Up to date | Report "Already up to date." Done. |
| `N / 0` | Upstream ahead only | Fast-forward explicitly: `git merge --ff-only <resolved-upstream>`. No integration-method decision needed. |
| `0 / N` | Local ahead only | Nothing to pull. Note: "N local commit(s) not pushed — push via `/done`." |
| `N / M` | **Diverged** (both sides have commits) | Go to 1c. |

Report what was updated (files changed, new files, deletions).

### 1c. Diverged — choose explicit rebase or merge

Reached only when both sides have commits.

1. **Preview conflicts (non-destructive — changes nothing):**
   ```bash
   git merge-tree --write-tree HEAD <resolved-upstream>   # exit 0 = clean; exit 1 = conflicts
   ```
2. **Recommend an approach:**
   - Local commits verified **unpublished, unshared and not cited as producing retained results** → **rebase explicitly**:
     `git rebase <resolved-upstream>`. Before recommending this, inspect whether the local-only
     commits are reachable from any remote-tracking ref and ask about sharing not visible in Git.
   - Any local commit already published/shared, or uncertain sharing → **merge explicitly**:
     `git merge --no-edit <resolved-upstream>`. This preserves existing commit identities and does
     not depend on `pull.rebase` configuration.
3. Report the preview result + recommendation, then **proceed only on user confirmation**.
4. If the chosen integration hits conflicts, **report them and stop** — do NOT auto-resolve.

---

## Step 2: Conda Environment

### 2a. Resolve the specification and exact identity

Use the Conda specification declared by the project; otherwise check root `environment.yml` and
`environment.yaml`. If none exists, skip this step.

Read the file as structured YAML. Use the top-level `name` scalar as the named-environment identity;
do not take the first line or extract it with `grep`. A top-level `prefix` is a machine-specific exact
path: warn under the hygiene rules below and use it only when the project explicitly declares that
prefix for this host. If the identity is missing, malformed, ambiguous, or conflicts with project
instructions, stop before changing an environment.

### 2b. Check exact installed identity

Run the selected host setup and the machine-readable inventory in one shell:

```bash
<declared-conda-setup> && conda env list --json
```

For `name`, compare against complete environment names derived from the returned prefixes, exactly;
`analysis` must not match `analysis-old`. If the same name appears at multiple prefixes, select the
project-declared prefix rather than guessing. For a declared `prefix`, compare its normalized full
path exactly.

### 2c. Create or update deliberately

Use the same host setup in the mutation command and name the resolved target explicitly:

```bash
# Named target
<declared-conda-setup> && conda env create --name <exact-name> --file <spec>   # when absent
<declared-conda-setup> && conda env update --name <exact-name> --file <spec>  # when present

# Explicit-prefix target, only when the project declares it for this host
<declared-conda-setup> && conda env create --prefix <exact-prefix> --file <spec>
<declared-conda-setup> && conda env update --prefix <exact-prefix> --file <spec>
```

The default update does **not** prune. Add `--prune` only when the project declares this specification
complete for the selected host and removal of packages absent from it is intended. Otherwise retain
extras and report that choice; do not turn an arrival sync into an undeclared cleanup.

### 2d. Verify in the selected environment

```bash
<declared-conda-setup> && conda activate <exact-name-or-prefix> && python --version && conda list --json
```

Report the resolved prefix, Python version, and package count as a sanity check.

---

## Step 3: renv (if applicable)

Skip when the project does not declare `renv.lock` authoritative. Resolve the project's R runtime
and host setup first. If Conda supplies that R runtime, include the Conda setup and activation in the
same invocation. Do not use whichever `Rscript` happens to be on `PATH` without establishing that it
is the declared runtime.

### 3a. Check status

```bash
<declared-R-setup> && Rscript --version && Rscript -e "renv::status()"
```

### 3b. Restore if needed

If packages are out of sync:

```bash
<declared-R-setup> && Rscript -e "renv::restore()"
```

Report what was installed/updated or "renv is in sync."

---

## Step 4: Report

```
/sync-project complete

Git:    <branch> reconciled with <upstream> at <commit> by fast-forward, merge, rebase, or no-op
Conda:  <exact-name-or-prefix> created, updated, unchanged, or skipped; prune used/not used
renv:   <declared R runtime> restored, in sync, or skipped

Ready to work.
```

---

## environment.yml Hygiene

These checks run as part of Step 2 but are documented here for reference.

When this skill reads `environment.yml`, flag these issues:

| Issue | Action |
|-------|--------|
| `prefix:` line present | Warn — this is a machine-specific path that shouldn't be in git |
| Channel order differs from the project's declared environment | Warn — resolution and scientific software versions can change |
| A required channel is absent | Warn — name the dependency that requires it rather than imposing a universal channel set |
| A channel is present without a declared dependency or site reason | Note for review; do not remove it automatically |

These are warnings only — the skill does not auto-fix `environment.yml` during arrival.
Fix them deliberately in the dependency specification (see `conda-env`), not during arrival.

---

## What This Skill Does NOT Do

- Does not commit, push, or export environments; those are departure-side actions.
- Does not synchronize agent-client settings, credentials, account state, or user-level skill libraries.
- Does not invent or change scheduler settings from a generic arrival procedure.
- Does not auto-run; the researcher deliberately invokes the synchronization.
