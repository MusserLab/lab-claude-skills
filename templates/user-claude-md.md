# User-Level Instructions for Claude Code

These instructions apply across all projects. Project-specific instructions should be in each project's `.claude/CLAUDE.md` file.

Detailed guidance for specific topics is in skills at `~/.claude/skills/` — these load automatically when relevant.

---

## Project-Specific Instructions

Each project should have its own `.claude/CLAUDE.md` with:

1. **Project overview** — what the project does
2. **Environment details** — specific conda env name, renv usage, etc.
3. **Key files and directories** — where important code/data lives
4. **Workflows** — how to run analyses, tests, builds
5. **Conventions** — coding style, commit practices, etc.

When starting work on a project, **read its `.claude/CLAUDE.md` first** to understand project-specific requirements.

---

## Check Planning Documents for Active Files (CRITICAL)

**Before modifying, reading, or referencing any script or data file**, check the project's planning documents to confirm you have the correct active version.

- **Planning documents (not the main CLAUDE.md) are the authoritative source** for which scripts and data files are current vs legacy. The main CLAUDE.md should point to planning docs, not maintain its own script lists.
- Check the project's **Project Document Registry** in `.claude/CLAUDE.md` to find the relevant planning document for the area you're working in.
- Look for **"Active Scripts"** or **"Active Figures"** tables in the planning doc — these identify the canonical scripts currently in use.
- If a script exists in both `scripts/` and `scripts/old/`, the planning doc determines which is active.
- **Do NOT assume** the first matching filename is the right one — there may be multiple versions.

When starting multi-script or multi-session work in an area that has no planning document, **suggest `/new-plan` to the user** before beginning implementation. This ensures scripts and decisions are tracked from the start.

---

## Project Types

Projects declare their type with a `<!-- project-type: data-science -->` or `<!-- project-type: general -->` comment at the top of their `.claude/CLAUDE.md`. This controls which skill behaviors are active:

- **`data-science`** — Analysis projects with numbered scripts, `data/`+`outs/` directories, renv/conda, Quarto analysis documents. All skills apply, including data-science-specific ones.
- **`general`** — Everything else (infrastructure, tools, documentation, Quarto books). Only general skills apply; data-science-specific conventions (numbered scripts, `outs/` ownership, `data/` read-only, script lifecycle status) are skipped.

The `/new-project` skill sets this automatically. The `/done` skill reads it to determine which wrap-up checks to perform.

---

## Core Principles

These are enforced through dedicated skills that load automatically when relevant. The skills contain full details, examples, and concrete rules.

### Universal (all projects)

- **Debugging before patching** — Diagnose first, share findings, propose don't patch, never force values. See `debugging-before-patching` skill.
- **Python environments** — Always use the project's conda env. Never bare `pip install`. See `conda-env` skill.

### Data Science projects only

These apply in projects with `project-type: data-science`:

- **Surface analysis decisions** — Never silently resolve ambiguities. Flag unmatched cases, show catch-all logic, report join mismatches, ask before defaulting. See `data-handling` skill.
- **Script organization** — `data/` read-only, `outs/` per-script, lifecycle status, provenance. See `script-organization` and `quarto-docs` skills.

---

## Troubleshooting

> Customize this section for your machine.

### "Command not found" for conda tools
> Source conda before activating: `source ~/miniconda3/etc/profile.d/conda.sh`

### "The project is out-of-sync" (renv)
> This is a warning, not an error. Run `renv::status()` to see details, `renv::restore()` to sync

### Quarto not found
> Use `/usr/local/bin/quarto` directly, or check if it's in a conda environment

### Permission denied
> Check if file is read-only or if you need sudo (rarely needed for project work)

---

## Available Skills

Skills are categorized by scope. **General** skills apply to all projects. **Data Science** skills apply only to analysis projects with `project-type: data-science` (numbered scripts, data/outs/ directories, reproducibility conventions).

### General (all project types)

| Skill | Purpose |
|-------|---------|
| `debugging-before-patching` | Diagnose before fixing; never blind-patch |
| `git-conventions` | Git commit practices |
| `conda-env` | Conda activation patterns |
| `file-safety` | Rules for not overwriting important files |
| `scientific-manuscript` | High-impact manuscript development |
| `new-skill` | Create a new skill with proper structure |
| `protein-phylogeny` | Protein phylogeny pipeline: alignment (MAFFT), trimming, tree inference (IQ-TREE 3) |
| `tree-formatting` | Phylogenetic tree visualization with ggtree: layout, coloring, collapsing, overlays |
| `gene-lookup` | Look up gene/protein info from database IDs (UniProt, Ensembl, FlyBase, WormBase, NCBI) |
| `/done` | End-of-session wrap-up and commit (adapts to project type) |
| `/new-project` | Scaffold a new project (data science, documentation, or general) |
| `/new-plan` | Create a planning document |
| `/audit` | Periodic project health check — cross-check docs, prune conventions, find drift |
| `/security-setup` | Configure personalized security protections for sensitive files and credentials |
| `/quarto-book-setup` | Initialize a new Quarto book with GitHub Pages |
| `/quarto-publish` | Commit and publish Quarto projects to GitHub Pages |

### Data Science (analysis projects with data/outs/scripts/ layout)

These auto-load only in data science projects. They assume numbered scripts, `data/` and `outs/` directories, and reproducibility conventions.

| Skill | Purpose |
|-------|---------|
| `data-handling` | Data validation, summaries, analytical decisions, surfacing ambiguities |
| `script-organization` | Directory structure, numbering, lifecycle, provenance |
| `quarto-docs` | QMD analysis scripts with status fields, git hash, BUILD_INFO.txt |
| `r-renv` | R package management with renv |
| `r-plotting-style` | ggplot2 theme and conventions |
| `figure-export` | Saving PDF/PNG/SVG for Inkscape editing (svglite, ggrastr, cairo_pdf) |