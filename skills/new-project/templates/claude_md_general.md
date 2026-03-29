<!-- project-type: general -->
# {Project Name}

{Brief description from step 1}

---

## Environment

- **Python/Conda**: Shared `lab-general` environment
  ```bash
  source ~/miniconda3/etc/profile.d/conda.sh && conda activate lab-general
  ```

{If project-specific environment was chosen instead, replace the above with:}
- **Python/Conda**: `{project_name}` environment
  ```bash
  source ~/miniconda3/etc/profile.d/conda.sh && conda activate {project_name}
  ```

---

## Repository Layout

```
{Describe the actual directory structure as it develops}
```

---

## Key Files

(Add important files here as the project develops)

---

## Workflows

(Document how to run things as the project develops)

---

<!-- IF CLUSTER: include this section when user selects cluster = Yes -->

## Dual Environment: Local + Cluster

This project is worked on both locally and on Yale HPC ({CLUSTER_NAME}). The same git repo
is cloned in both places. Key conventions:

- **Git syncs scripts and docs.** Always `git pull` before starting work in either environment.
- **Data syncs via Globus.** Large files (`data/`, tool outputs) are gitignored and
  transferred manually. Not all data exists in both places.
- **Batch scripts** (`batch/`) use `BASEDIR=$(git rev-parse --show-toplevel)` — no hardcoded
  paths. They run on the cluster only.
- **Logs** (`logs/`) are tracked in git. The cluster commits logs after jobs complete; pull
  locally to review.
- **Cluster-only directories** (gitignored): (list project-specific directories as they arise)
- **Cluster location**: `{CLUSTER_PATH}`

---

<!-- /IF CLUSTER -->

## Project Document Registry

### Planning Documents

| Document | Topic | Has status table? |
|----------|-------|:-:|
| (add as work develops) | | |

### Convention/Reference

| Document | Topic |
|----------|-------|
| [CLAUDE.md](.claude/CLAUDE.md) | Project conventions |

---

## Session Log
<!-- Maintained by /done. Most recent first. Keep last 5 entries. -->

### {today's date} — Initial project setup
- **Plans:** None
- **Work:** Scaffolded project with /new-project
- **Next:** Start adding code and documentation
