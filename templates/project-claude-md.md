<!-- project-type: data-science -->
<!-- Change to "general" for non-data-science projects (infrastructure, tools, documentation) -->
<!-- slack-channel: #channel-name:CHANNEL_ID -->
<!-- slack-post-criteria: What kinds of changes to post, e.g. "new analyses and results" -->
<!-- Get channel ID: right-click channel in Slack → View channel details → scroll to bottom -->
<!-- Remove slack lines if you don't want Slack notifications from /done -->
# {Project Name}

{Brief description of what this project does}

---

## Environment

- **Python/Conda**: `{project_name}` environment
  ```bash
  source ~/miniconda3/etc/profile.d/conda.sh && conda activate {project_name}
  ```
  Packages: Python 3.11, pandas, numpy, matplotlib, ipykernel

- **R packages**: Managed with renv
  - R version: {version} (pinned in `.positron/settings.json`)

---

## Repository Layout

```
{project_name}/
  R/                          # Shared R helpers
  python/                     # Shared Python helpers
  scripts/
    exploratory/              # One-off analyses
  data/                       # External inputs only — scripts never write here
  outs/                       # All script outputs
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
- `.qmd` format for all data science scripts (both R and Python)

---

## Key Files

(Add important files here as the project develops)

---

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