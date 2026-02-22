# Lab Claude Skills

Shared [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills and conventions for the lab. These skills teach Claude Code our lab's standards for data handling, plotting, script organization, reproducibility, and more.

## What are skills?

Claude Code skills are markdown files that give Claude specific instructions for particular tasks. They're how we teach Claude our lab's conventions.

**How they work:** Each skill has a short **description** that tells Claude when to activate it, and a **body** with the actual instructions. Some skills also include additional files in their folder — guides, templates, or reference material that Claude can use.

There are two kinds:

- **Automatic skills** load on their own when Claude detects a relevant task. For example, when you ask Claude to make a plot, `r-plotting-style` loads automatically and Claude follows our ggplot2 conventions. You don't need to do anything.
- **User-invoked skills** (slash commands) are triggered by typing a command like `/done` or `/new-project`. These run specific workflows on demand.

**These skills are under active development.** If Claude does something wrong, or you think a skill is missing guidance for a situation you ran into, or you have an idea for a new skill — open a GitHub issue. See [Improving skills](#improving-skills) below for details.

## Prerequisites

You need [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working before adding lab skills:

1. Install Claude Code — see our [lab compute handbook](https://musserlab.github.io/lab-compute/part1/installation.html) or [Anthropic's install guide](https://docs.anthropic.com/en/docs/claude-code/overview)
2. Open Claude Code — either in Positron (click the Claude Code icon in the sidebar) or in your terminal (run `claude`)

## Install

There are two ways to install. Choose whichever fits your needs.

### Option A: Plugin (recommended)

The simplest way to get all lab skills and keep them up to date.

**In Positron / VS Code:**

1. Type `/plugins` in the Claude Code chat panel to open the plugin manager
2. Go to the **Marketplaces** tab
3. Add `MusserLab/lab-claude-skills`
4. Switch to the **Plugins** tab and install `lab-skills`

**In the terminal CLI:**

```
/plugin marketplace add MusserLab/lab-claude-skills
/plugin install lab-skills
```

This installs all skills and hooks as a single package. Skills are available as `/lab-skills:skill-name` (e.g., `/lab-skills:done`). Security hooks activate automatically — see [Security](#security) below.

To update or manage plugins, type `/plugins` (Positron) or `/plugin` (CLI).

### Option B: Manual install (if you want to customize)

If you want to modify skills or pick only the ones you need, clone the repo and copy skills into your personal Claude Code directory instead.

```bash
# Clone the repo
git clone https://github.com/MusserLab/lab-claude-skills.git
cd lab-claude-skills

# Copy all skills to your personal skills directory
cp -r skills/* ~/.claude/skills/

# Or copy just the ones you want
cp -r skills/data-handling ~/.claude/skills/
cp -r skills/r-plotting-style ~/.claude/skills/
```

To update, pull the repo and re-copy the skills you want:

```bash
cd lab-claude-skills && git pull
cp -r skills/data-handling ~/.claude/skills/   # update specific skills
```

Skills that reference machine-specific paths (like `conda-env`) use `~/miniconda3` as the default. If your conda is installed elsewhere, edit your local copy.

## Security

Claude Code is an AI agent that can read any file on your machine and run any shell command. That includes saved passwords, SSH keys, API tokens, email, browser data, and cloud storage. The lab plugin sets up automatic protections so Claude can't access these things — even by accident.

**If you just installed the plugin, you already have baseline protections.** The plugin hooks block reads and bash commands that target credential stores, password managers, browsers, and email. No configuration needed.

For the full security guide, including how protection works and what's covered, see **[SECURITY.md](SECURITY.md)**.

### Quick setup

After installing the plugin, there are two more steps to complete your security setup:

1. **Copy the settings template** (adds deny rules and bash scoping):
   ```bash
   cp templates/settings-example.json ~/.claude/settings.json
   ```
   If you already have a `settings.json`, merge in the `deny` array — see [Settings](#settings-permissions) below.

2. **Run `/security-setup`** for personalized protections (recommended):
   This interactive skill scans your machine, finds sensitive locations specific to your setup (cloud storage mounts, installed password managers, scattered `.env` files), and generates customized hooks. It lets you choose between:
   - **Allowlist mode** — block everything except directories you explicitly permit (most secure)
   - **Blocklist mode** — block only sensitive locations, allow everything else (more permissive)

   You can re-run `/security-setup` at any time to adjust protections.

### Three layers of defense

| Layer | What it does | How you get it |
|-------|-------------|----------------|
| **Hooks** | Scripts that intercept file reads and bash commands, blocking access to sensitive locations | Automatic with plugin install (macOS/Linux; see [SECURITY.md](SECURITY.md) for Windows) |
| **Deny rules** | Settings-level blocks that work even if a hook has a bug | Copy `settings-example.json` |
| **Bash scoping** | Only pre-approved commands run without prompting; unlisted commands require approval | Copy `settings-example.json` |

See [SECURITY.md](SECURITY.md) for the full explanation of what each layer covers, what's always protected, and how to update your protections over time.

## Starter configuration

These files are **optional** but reduce permission prompts and give Claude more context about lab conventions. Copy them from the `templates/` directory in this repo:

```bash
# User-level instructions (if you don't have ~/.claude/CLAUDE.md yet)
cp templates/user-claude-md.md ~/.claude/CLAUDE.md

# Pre-approved permissions for common lab tools (if you don't have ~/.claude/settings.json yet)
cp templates/settings-example.json ~/.claude/settings.json
```

If you used Option A and don't have the repo cloned, download the files from [templates/ on GitHub](https://github.com/MusserLab/lab-claude-skills/tree/main/templates).

### Templates

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
- **Deny rules** to block destructive commands (`sudo`, `git push --force`, `git reset --hard`) and reads to sensitive directories (`.ssh`, `.aws`, Keychains, etc.)
- **Additional directories** — `~/.claude` and a placeholder for your research directory, so Claude can access your config and cross-project files
- **Environment variable** — `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` so CLAUDE.md files from additional directories are loaded into context

If you already have a `settings.json`, merge in the parts you want manually.

### What's not in the example (and what you might add)

The example is intentionally conservative. Here are things you may want to add based on your workflow:

**Bash commands.** The example pre-approves common tools individually (`git`, `conda`, `Rscript`, etc.). If you find yourself approving the same commands repeatedly, you can allow all bash commands at once:

```json
"Bash(*)"
```

This is convenient but means Claude won't ask before running anything. The deny rules still apply, so `sudo` and force-push are always blocked regardless.

**File operations.** The example pre-approves `Read`, `Edit`, `Write`, `Glob`, `Grep`, and `WebSearch` so Claude can work with files and search the web without prompting. Remove any of these if you want Claude to ask first.

**Additional directories.** The example includes `~/.claude` and a placeholder research path. Replace `/path/to/your/research` with the root directory of your research projects. Claude can access files outside additional directories if you ask, but additional directories are treated as part of your workspace — Claude proactively considers them in scope, and their CLAUDE.md files are loaded into context (thanks to the `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` env variable in the example).

**Environment variables.** You can set variables that apply to all Claude sessions in the `env` section. The example includes `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` — add your own as needed:

```json
"env": {
  "CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD": "1",
  "MY_VAR": "value"
}
```

**Adding new entries.** Permissions go in the `allow` array as strings. The format depends on the tool:
- Bash: `"Bash(command pattern *)"` — wildcards match anything
- WebFetch: `"WebFetch(domain:example.com)"` — one entry per domain
- MCP tools: `"mcp__server__tool_name"` or `"mcp__server__*"` for all tools on a server

If Claude asks for permission and you click "Always allow", it adds the entry to your settings automatically.

## Improving skills

Skills are only as good as their instructions, and they're under active development. If something isn't working well, that's worth reporting so everyone benefits.

### What to report

- **Wrong behavior** — a skill told Claude to do something incorrect or suboptimal
- **Missing cases** — a skill doesn't handle a situation you ran into (e.g., the data-handling skill didn't flag that a join dropped rows)
- **Activation problems** — a skill didn't load when it should have, or loaded when it shouldn't
- **New skill ideas** — a recurring task that Claude should handle consistently

### What makes a good skill

When thinking about whether something should be a skill, consider:

- **Repeatable conventions** — things Claude should do the same way every time (file naming, plot styling, commit messages, directory structure)
- **Guardrails** — mistakes Claude tends to make that a skill can prevent (overwriting data files, skipping diagnostics, using wrong normalization)
- **Multi-step workflows** — sequences of actions that should follow a specific order (session wrap-up, project scaffolding, publishing)
- **Domain knowledge** — lab-specific practices that Claude wouldn't know on its own (which databases to query, how we organize analyses)

The most impactful skill improvements are usually about **correctness** — making sure Claude handles edge cases, flags ambiguities, and follows the right conventions for our specific workflows.

### How to report

Open an issue on the [GitHub repo](https://github.com/MusserLab/lab-claude-skills/issues). You can do this on the website, or ask Claude to do it for you right in your conversation:

> "Open a GitHub issue on MusserLab/lab-claude-skills — the data-handling skill didn't flag that my join dropped 50 rows"

Include which skill was involved, what happened, and what you expected. Pasting the relevant part of your Claude Code conversation is especially helpful.

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
| `/security-setup` | Configure and manage Claude Code security protections for sensitive files and credentials |
| `/quarto-book-setup` | Initialize a new Quarto book with GitHub Pages |
| `/quarto-publish` | Commit and publish a Quarto project to GitHub Pages |

### Data science conventions

For analysis projects with numbered scripts, `data/`+`outs/` directories.

| Skill | Description |
|-------|-------------|
| `data-handling` | Data validation, summaries, surfacing analytical decisions |
| `script-organization` | Directory structure, numbering, lifecycle, provenance |
| `quarto-docs` | QMD analysis scripts with status fields and reproducibility metadata |
| `r-plotting-style` | ggplot2 theme and conventions |
| `figure-export` | PDF/PNG/SVG export for publication and Inkscape editing |
| `r-renv` | R package management with renv |

### General conventions

For all project types.

| Skill | Description |
|-------|-------------|
| `git-conventions` | Commit practices and conventions |
| `file-safety` | Rules for not overwriting important files |
| `conda-env` | Conda activation patterns for Python commands |
| `debugging-before-patching` | Diagnose before fixing — never blind-patch |
| `new-skill` | Create a new skill with proper structure |

### Domain skills

For specific research tasks.

| Skill | Description |
|-------|-------------|
| `scientific-manuscript` | High-impact manuscript development for top-tier journals |
| `protein-phylogeny` | Phylogeny inference: alignment, trimming, tree building |
| `gene-lookup` | Look up gene/protein info from database IDs (UniProt, Ensembl, FlyBase, etc.) |
| `tree-formatting` | Phylogenetic tree visualization with ggtree or iTOL |

---

## Hooks

The plugin includes hooks that automatically enforce lab conventions. These activate when the plugin is installed — no manual configuration needed. Hooks are bash scripts, so they run natively on macOS and Linux. On Windows, hooks may not fire (depends on shell) — deny rules in `settings.json` provide equivalent protection. See [SECURITY.md](SECURITY.md) for details.

| Hook | Event | What it does |
|------|-------|-------------|
| `protect-sensitive-reads.sh` | PreToolUse (Read) | Blocks reads to sensitive directories (credentials, passwords, browsers, email) |
| `protect-sensitive-bash.sh` | PreToolUse (Bash) | Blocks bash commands referencing sensitive paths or using dangerous patterns |
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

### Security hooks

The `protect-sensitive-reads.sh` and `protect-sensitive-bash.sh` hooks provide automatic security — see [Security](#security) above and [SECURITY.md](SECURITY.md) for details.

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
