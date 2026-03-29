<!-- project-type: data-science -->
# {Project Name}

{Brief description from step 1}

---

## Environment

{Include only the sections relevant to the chosen languages}

- **Python/Conda**: `{project_name}` environment
  ```bash
  source ~/miniconda3/etc/profile.d/conda.sh && conda activate {project_name}
  ```
  Packages: Python 3.11, pandas, numpy, matplotlib, ipykernel

- **R packages**: Managed with renv (see user CLAUDE.md for general renv instructions)
  - R version: {version} (pinned in `.positron/settings.json`)

---

## Repository Layout

```
{project_name}/
  R/                          # Shared R helpers
  python/                     # Shared Python helpers
  scripts/
    {section dirs or flat}
    exploratory/              # One-off analyses
  data/                       # External inputs only — scripts never write here
  outs/                       # All script outputs
    {section dirs or flat}
    exploratory/
  .claude/
    CLAUDE.md                 # This file
```

Scripts use `here::here()` (R) or `PROJECT_ROOT` (Python) — run from repository root.

---

## Script Conventions

This project follows the conventions in the user-level `script-organization` and `quarto-docs` skills:
- Numbered with `XX_` prefix, matching `outs/XX_script_name/` folder
- Include `status: development` in YAML frontmatter
- Git hash in setup chunk, BUILD_INFO.txt at end
- Inputs grouped at top with comments (external vs project outputs)
- Use `source(here("R/..."))` (R) or `sys.path.insert` (Python) for shared helpers
- `.qmd` format for all data science scripts (both R and Python)
- `.py` files only for standalone utilities or CLI tools

---

## Key Files

(Add important files here as the project develops)

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

## Workflows

(Document how to run the analysis as it develops)

---

## Conventions

See user-level skills for detailed conventions:
- `script-organization` — directory structure, numbering, lifecycle, provenance
- `quarto-docs` — QMD templates (R and Python), rendering
- `data-handling` — data validation, analytical decisions
- `r-plotting-style` — ggplot2 theme
- `conda-env` — conda activation patterns
- `r-renv` — R package management
- `file-safety` — output ownership, data/ protection

---

## Project Document Registry

### Planning Documents

| Document | Topic | Has status table? |
|----------|-------|:-:|
| (add planning documents as work develops) | | |

### Data Documents

| Document | Topic |
|----------|-------|
| (add data documents as datasets are documented) | |

### Convention/Reference

| Document | Topic |
|----------|-------|
| [CLAUDE.md](.claude/CLAUDE.md) | Project conventions, environment, pipelines |

---

## Session Log
<!-- Maintained by /done. Most recent first. Keep last 5 entries. -->

### {today's date} — Initial project setup
- **Plans:** None
- **Work:** Scaffolded project with /new-project
- **Next:** Add data files, create first analysis script
