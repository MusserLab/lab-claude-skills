# Lab Claude Skills

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills and conventions for the lab. These skills teach Claude Code our lab's standards for data handling, plotting, script organization, reproducibility, and more.

## What are skills?

Claude Code skills are markdown files that automatically load into Claude's context when relevant. For example, when you ask Claude to create a plot, the `r-plotting-style` skill loads and Claude follows our lab's ggplot2 conventions. Skills live in `~/.claude/skills/` (user-level, apply to all projects) or `.claude/skills/` (project-level, apply to one repo).

## Quick start

```bash
# 1. Clone this repo
git clone git@github.com:YOUR_ORG/lab-claude-skills.git
cd lab-claude-skills

# 2. Install all skills (creates symlinks in ~/.claude/skills/)
./install.sh

# 3. Or install specific skills only
./install.sh data-handling r-plotting-style quarto-docs
```

## Available skills

Skills are categorized by scope. **General** skills work in any project. **Data Science** skills apply only in analysis projects with `project-type: data-science` (numbered scripts, `data/`+`outs/` directories, reproducibility conventions).

### General (all project types)

| Skill | Description | Auto-triggers on |
|-------|-------------|-----------------|
| `debugging-before-patching` | Diagnose before fixing; never blind-patch | Debugging errors or bugs |
| `git-conventions` | Commit practices and conventions | Working with git |
| `file-safety` | File protection rules (adapts to project type) | Writing or modifying files |
| `conda-env` | Conda activation patterns | Running Python/conda commands |
| `scientific-manuscript` | High-impact manuscript development | Writing for top-tier journals |

### Data Science (analysis projects with data/outs/scripts/)

| Skill | Description | Auto-triggers on |
|-------|-------------|-----------------|
| `data-handling` | Data validation, summaries, surfacing analytical decisions | Writing analysis code |
| `script-organization` | Directory structure, numbering, lifecycle, provenance | Creating analysis scripts |
| `quarto-docs` | QMD analysis templates, rendering | Creating analysis .qmd files |
| `r-plotting-style` | ggplot2 theme and conventions | Creating R plots |
| `figure-export` | PDF/PNG/SVG export for Inkscape editing | Saving R figures |
| `r-renv` | R package management with renv | Working with renv |

### User-invocable (slash commands)

| Skill | Description | Scope |
|-------|-------------|-------|
| `/new-project` | Scaffold a new project (data science, docs, or general) | All |
| `/new-plan` | Create a planning document | All |
| `/done` | End-of-session wrap-up and commit (adapts to project type) | All |
| `/publish` | Publish Quarto project to GitHub Pages | All Quarto projects |
| `/quarto-book-setup` | Initialize a Quarto book with GitHub Pages | Documentation |

## Updating skills

When skills are updated or new ones are added to the repo, run:

```bash
cd lab-claude-skills
./install.sh --update
```

This does three things:
1. **Pulls** the latest changes from GitHub (`git pull`)
2. **Installs** any newly added skills that you don't have yet
3. **Flags** any local copies that now differ from the repo version

If you installed skills via symlink (the default), updates to existing skills take effect immediately after `git pull` — no reinstall needed.

## Managing your installation

```bash
# See what's installed and what's available
./install.sh --status

# Install additional skills later
./install.sh conda-env r-renv

# Remove a skill (just delete the symlink)
rm ~/.claude/skills/skill-name
```

## Templates

The `templates/` directory contains starter files:

- **`user-claude-md.md`** — Copy to `~/.claude/CLAUDE.md` as your user-level configuration. Customize the troubleshooting section for your machine.
- **`project-claude-md.md`** — Copy to `.claude/CLAUDE.md` in new projects. Fill in project-specific details.

## Customization

Skills that reference machine-specific paths (like `conda-env`) use `~/miniconda3` as the default. If your conda is installed elsewhere, you have two options:

1. **Edit after installing** — Modify your local `~/.claude/skills/conda-env/SKILL.md` (but this will be overwritten on next `git pull` since it's a symlink)
2. **Don't symlink it** — Copy instead of symlinking machine-specific skills, then customize the copy:
   ```bash
   cp -r skills/conda-env ~/.claude/skills/conda-env
   # Edit ~/.claude/skills/conda-env/SKILL.md with your paths
   ```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose new skills or changes.