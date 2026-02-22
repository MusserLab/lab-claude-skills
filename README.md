# Lab Claude Skills

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills and conventions for the lab. These skills teach Claude Code our lab's standards for data handling, plotting, script organization, reproducibility, and more.

## What are skills?

Claude Code skills are markdown files that automatically load into Claude's context when relevant. For example, when you ask Claude to create a plot, the `r-plotting-style` skill loads and Claude follows our lab's ggplot2 conventions.

## Install

```bash
# 1. Add the lab marketplace (one-time)
/plugin marketplace add MusserLab/lab-claude-skills

# 2. Install the plugin
/plugin install lab-skills
```

All skills are available as `/lab-skills:skill-name` (e.g., `/lab-skills:done`, `/lab-skills:data-handling`).

## Updating

```bash
# Check for updates from the lab marketplace
/plugin marketplace update musser-lab
```

You can also enable auto-updates: `/plugin` > **Marketplaces** tab > select `musser-lab` > **Enable auto-update**.

## Customizing skills

You can override any lab skill with your own version. This is useful for experimenting or adapting a skill to your machine.

1. Copy the skill you want to customize to your personal skills directory:
   ```bash
   mkdir -p ~/.claude/skills/data-handling
   # Copy SKILL.md from the plugin's installed location, or from GitHub
   ```
2. Edit `~/.claude/skills/data-handling/SKILL.md` as you like
3. Your personal version (`/data-handling`) takes effect alongside the lab version (`/lab-skills:data-handling`)

Skills that reference machine-specific paths (like `conda-env`) use `~/miniconda3` as the default. If your conda is installed elsewhere, make a local copy and edit the path.

## Managing your installation

```bash
# See installed plugins
/plugin
```

## Templates

The `templates/` directory contains starter files:

- **`user-claude-md.md`** — Copy to `~/.claude/CLAUDE.md` as your user-level configuration. Customize the troubleshooting section for your machine.
- **`project-claude-md.md`** — Copy to `.claude/CLAUDE.md` in new projects. Fill in project-specific details.
- **`settings-example.json`** — Example `~/.claude/settings.json` with pre-approved permissions for common lab tools. See below.

### Settings (permissions)

Claude Code asks for permission each time it wants to fetch a website, run a bash command, etc. You can pre-approve common actions in `~/.claude/settings.json` so you don't get prompted repeatedly.

The example file includes:
- **Bash commands** for common tools (`git`, `conda`, `Rscript`, `quarto`, `python`, `mafft`, `iqtree`, etc.)
- **WebFetch domains** for databases we use regularly (NCBI, Ensembl, UniProt, OrthoDB, etc.)
- **MCP tools** for literature search (bioRxiv, PubMed, Scholar Gateway)
- **Deny rules** to block destructive commands (`sudo`, `git push --force`, `git reset --hard`)

To use it:

```bash
# If you don't have a settings.json yet, copy the example
cp templates/settings-example.json ~/.claude/settings.json

# If you already have one, merge in the parts you want manually
```

### What's not in the example (and what you might add)

The example is intentionally conservative. Here are things you may want to add based on your workflow:

**Bash commands.** The example pre-approves common tools individually (`git`, `conda`, `Rscript`, etc.). If you find yourself approving the same commands repeatedly, you can allow all bash commands at once:

```json
"Bash(*)"
```

This is convenient but means Claude won't ask before running anything. The deny rules still apply, so `sudo` and force-push are always blocked regardless.

**File operations.** The example pre-approves `Read`, `Edit`, `Write`, `Glob`, `Grep`, and `WebSearch` so Claude can work with files and search the web without prompting. Remove any of these if you want Claude to ask first.

**Additional directories.** If you work across multiple repos or need Claude to access data outside the current project, add `additionalDirectories`:

```json
"additionalDirectories": [
  "/path/to/your/shared/data",
  "/path/to/another/repo"
]
```

**Environment variables.** You can set variables that apply to all Claude sessions:

```json
"env": {
  "MY_VAR": "value"
}
```

**Adding new entries.** Permissions go in the `allow` array as strings. The format depends on the tool:
- Bash: `"Bash(command pattern *)"` — wildcards match anything
- WebFetch: `"WebFetch(domain:example.com)"` — one entry per domain
- MCP tools: `"mcp__server__tool_name"` or `"mcp__server__*"` for all tools on a server

If Claude asks for permission and you click "Always allow", it adds the entry to your settings automatically.

## Feedback and suggestions

If a skill gives Claude bad instructions, doesn't trigger when it should, or you have an idea for a new skill:

1. Open a [GitHub Issue](https://github.com/MusserLab/lab-claude-skills/issues)
2. Include: which skill, what happened, what you expected
3. If possible, paste the relevant part of your Claude Code conversation

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
| `gene-lookup` | Look up gene/protein info from database IDs (UniProt, Ensembl, FlyBase, etc.) |
| `tree-formatting` | Phylogenetic tree visualization with ggtree or iTOL |

---

## Hooks

The plugin includes hooks that automatically enforce lab conventions. These activate when the plugin is installed — no manual configuration needed.

| Hook | Event | What it does |
|------|-------|-------------|
| `protect-data-dir.sh` | PreToolUse (Edit/Write) | Blocks writes to `data/` directories — outputs go to `outs/` instead |
| `require-conda.sh` | PreToolUse (Bash) | Blocks bare `pip install` — requires conda env activation first |
| `project-reminders.sh` | SessionStart | Injects project-specific reminders from `.claude/project-reminders.txt` if the file exists |

### Project reminders

To use the `project-reminders` hook, create a `.claude/project-reminders.txt` file in your project root with critical rules Claude should always remember:

```
1. Gene level = automated_name, NEVER bare Trinity IDs
2. All heatmaps MUST use per-timepoint DMSO normalization
3. Check PLOTTING_PLAN.md before modifying any plotting script
```

These are injected into Claude's context at every session start, so important project rules survive context compaction.

### Optional hooks (not in plugin)

These hooks are useful but not included in the plugin by default. Add them to your `~/.claude/settings.json` manually:

**macOS notification** — Alerts you when Claude needs attention:
```json
"Notification": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "osascript -e 'display notification \"Claude needs your attention\" with title \"Claude Code\"'"
      }
    ]
  }
]
```
