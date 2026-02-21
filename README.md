# Lab Claude Skills

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills and conventions for the lab. These skills teach Claude Code our lab's standards for data handling, plotting, script organization, reproducibility, and more.

## What are skills?

Claude Code skills are markdown files that automatically load into Claude's context when relevant. For example, when you ask Claude to create a plot, the `r-plotting-style` skill loads and Claude follows our lab's ggplot2 conventions. Skills live in `~/.claude/skills/` (user-level, apply to all projects) or `.claude/skills/` (project-level, apply to one repo).

## Quick start

There are two ways to install: as a **plugin** (recommended) or via **symlinks** (legacy).

### Option A: Plugin install (recommended)

```bash
# 1. Add the lab marketplace (one-time)
/plugin marketplace add MusserLab/lab-claude-skills

# 2. Install the plugin
/plugin install lab-skills
```

All skills are available as `/lab-skills:skill-name` (e.g., `/lab-skills:done`, `/lab-skills:data-handling`).

### Option B: Symlink install (legacy)

```bash
# 1. Clone this repo
git clone git@github.com:MusserLab/lab-claude-skills.git
cd lab-claude-skills

# 2. Install all skills (creates symlinks in ~/.claude/skills/)
./install.sh

# 3. Or install specific skills only
./install.sh data-handling r-plotting-style quarto-docs
```

Skills are available by short name (e.g., `/done`, `/data-handling`).

## Updating

### Plugin users

```bash
# Check for updates from the lab marketplace
/plugin marketplace update musser-lab
```

You can also enable auto-updates: `/plugin` > **Marketplaces** tab > select `musser-lab` > **Enable auto-update**.

### Symlink users

```bash
cd lab-claude-skills
./install.sh --update
```

This pulls the latest changes, installs any new skills, and flags local copies that differ from the repo.

If you installed via symlink (the default), updates to existing skills take effect immediately after `git pull`.

## Customizing skills

You can override any lab skill with your own version. This is useful for experimenting with changes before proposing them back to the lab.

### Plugin users

1. Copy the skill you want to customize to your personal skills directory:
   ```bash
   cp -r skills/data-handling ~/.claude/skills/data-handling
   ```
2. Edit `~/.claude/skills/data-handling/SKILL.md` as you like
3. Your personal version (`/data-handling`) takes effect alongside the lab version (`/lab-skills:data-handling`)
4. When you're happy with your changes, PR them back to this repo

### Symlink users

1. Replace the symlink with a local copy:
   ```bash
   rm ~/.claude/skills/data-handling
   cp -r skills/data-handling ~/.claude/skills/data-handling
   ```
2. Edit the local copy
3. When ready, PR your changes back

Skills that reference machine-specific paths (like `conda-env`) use `~/miniconda3` as the default. If your conda is installed elsewhere, make a local copy and edit the path.

## Managing your installation

```bash
# Plugin: see installed plugins
/plugin

# Symlink: see what's installed and what's available
./install.sh --status

# Symlink: install additional skills later
./install.sh conda-env r-renv

# Symlink: remove a skill
rm ~/.claude/skills/skill-name
```

## Templates

The `templates/` directory contains starter files:

- **`user-claude-md.md`** — Copy to `~/.claude/CLAUDE.md` as your user-level configuration. Customize the troubleshooting section for your machine.
- **`project-claude-md.md`** — Copy to `.claude/CLAUDE.md` in new projects. Fill in project-specific details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose new skills or changes.

---

## Skill reference

### Workflows (slash commands)

Invoke these directly to run a workflow.

| Skill | Description |
|-------|-------------|
| `/done` | End-of-session wrap-up — summarize work, update docs, and commit |
| `/new-project` | Scaffold a new project (data science, docs, or general) |
| `/new-plan` | Create a planning document for multi-session work |
| `/audit` | Project health check — cross-check docs, prune conventions, find drift |
| `/quarto-book-setup` | Initialize a new Quarto book with GitHub Pages |
| `/quarto-publish` | Commit and publish a Quarto project to GitHub Pages |

### Data science conventions

Auto-load in projects with `project-type: data-science` (numbered scripts, `data/`+`outs/` directories).

| Skill | Description |
|-------|-------------|
| `data-handling` | Data validation, summaries, surfacing analytical decisions |
| `script-organization` | Directory structure, numbering, lifecycle, provenance |
| `quarto-docs` | QMD analysis scripts with status fields and reproducibility metadata |
| `r-plotting-style` | ggplot2 theme and conventions |
| `figure-export` | PDF/PNG/SVG export for publication and Inkscape editing |
| `r-renv` | R package management with renv |

### General conventions

Auto-load in all projects when relevant.

| Skill | Description |
|-------|-------------|
| `git-conventions` | Commit practices and conventions |
| `file-safety` | Rules for not overwriting important files |
| `conda-env` | Conda activation patterns for Python commands |
| `debugging-before-patching` | Diagnose before fixing — never blind-patch |
| `new-skill` | Create a new skill with proper structure |

### Domain skills

Auto-load for specific research tasks.

| Skill | Description |
|-------|-------------|
| `scientific-manuscript` | High-impact manuscript development for top-tier journals |
| `protein-phylogeny` | Phylogeny inference: alignment, trimming, tree building |
| `tree-formatting` | Phylogenetic tree visualization with ETE4 |
