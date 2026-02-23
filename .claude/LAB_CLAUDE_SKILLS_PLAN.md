# Lab Claude Skills Setup and Distribution Plan

## Overview

Setting up and distributing a shared Claude Code skills repository for the lab. Covers: extracting and generalizing skills from the PI's personal config, building a shared GitHub repo with install tooling, onboarding lab members, and iterating based on feedback.

## Goals

- [x] Create a shared, version-controlled repo of Claude Code skills
- [x] Generalize existing skills (remove machine-specific paths)
- [x] ~~Provide an install script for easy adoption~~ → Replaced by plugin distribution
- [ ] Push to GitHub and onboard lab members
- [ ] Iterate on skills based on lab member feedback (via GitHub Issues)

## Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Refactor user CLAUDE.md — extract principles into modular skills | Done |
| 2 | Scaffold repo structure, copy and generalize skills | Done |
| 3 | Write install.sh, README, CONTRIBUTING, templates | Done |
| 4 | Review, initial commit, push to GitHub | Done |
| 4b | Add plugin distribution support | Done |
| 5 | Onboard lab members — install, test, collect feedback | In progress |
| 6 | Iterate — new skills, improvements based on usage | Not started |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-02-14 | Created planning document | Track setup progress and remaining work |
| 2026-02-14 | Skills over CLAUDE.md for shareable conventions | Skills are modular — lab members can adopt piecemeal. CLAUDE.md is all-or-nothing. |
| 2026-02-14 | Shared GitHub repo with PR-based contributions | Version control, lab members learn git/GitHub, PI approves PRs |
| 2026-02-14 | Symlinks (not copies) as default install mechanism | `git pull` instantly updates all installed skills. Copy instead of symlink for machine-specific customization. |
| 2026-02-14 | Extracted `debugging-before-patching` into standalone skill | Was embedded in user CLAUDE.md; now modular and shareable |
| 2026-02-14 | Merged `Surface Analysis Decisions` into `data-handling` skill | Eliminated duplication between CLAUDE.md and data-handling skill |
| 2026-02-14 | Generalized 3 skills: conda-env, quarto-docs, new-project | Replaced hardcoded paths and org names with generic placeholders + "Customize" callouts |
| 2026-02-14 | Binary project-type system (data-science vs general) | Skills now adapt behavior based on `<!-- project-type: ... -->` in project CLAUDE.md. Chose binary over tag-based for simplicity — all data-science skills split on same axis. |
| 2026-02-14 | Categorized all 16 skills as General or Data Science | 10 general, 6 data-science-specific. Updated YAML descriptions, README, templates, user CLAUDE.md. |
| 2026-02-14 | `/new-project` supports 3 project types | Data science (full scaffold), Documentation (hands off to `/quarto-book-setup`), General (minimal `.claude/` only). |
| 2026-02-14 | `/done` detects project type and skips data-science steps | Steps 4, 7, 9b marked `[Data Science only]`; Step 0 checks `project-type:` field or infers from signals. |
| 2026-02-14 | `file-safety` split into General + Data Science sections | General rules (all projects) + data-science rules (outs/ ownership, data/ read-only). |
| 2026-02-14 | `figure-export` gained YAML frontmatter | Was the only skill missing `---` frontmatter block. |
| 2026-02-21 | Added plugin distribution (`.claude-plugin/`) | Students can install via `/plugin install lab-skills`. Namespaced skills (`/lab-skills:*`) coexist with personal overrides in `~/.claude/skills/`. |
| 2026-02-21 | Added `templates/settings-example.json` | Pre-approved bash commands, WebFetch domains, MCP tools, and deny rules. Students copy to `~/.claude/settings.json`. |
| 2026-02-21 | CHANGELOG.md + GitHub Releases for change tracking | CHANGELOG.md as running record, GitHub Releases for milestone announcements. `/done` skill detects changelogs in any project. |
| 2026-02-21 | Plugin-only distribution; removed install.sh, CONTRIBUTING.md | Symlink install was legacy complexity. Students install via plugin, provide feedback via GitHub Issues (no PRs). PI handles all skill changes. |
| 2026-02-21 | Decoupled skill dev from publishing; created `/sync-skills` | Removed auto-prompt to push every skill change to lab repo. PI now uses `/sync-skills` to batch-review and selectively publish. Personal `~/.claude/skills/` serves as dev environment; no git branch needed. |
| 2026-02-21 | Expanded `/sync-skills` → `/sync-plugin` | Now syncs skills, hooks, and README. Updates skill reference tables and hooks section in README. Bumps plugin version. |
| 2026-02-21 | Added plugin hooks (protect-data-dir, require-conda, project-reminders) | Hooks enforce lab conventions automatically when plugin is installed. Project-specific hooks (protect-data-files) and OS-specific hooks (Notification) stay personal. |
| 2026-02-21 | Guides embedded as skill reference files | Standalone guides (e.g., quarto-pdf-formatting) moved into their related skill's `references/` directory. Distributes through normal skill sync. |
| 2026-02-21 | README rewritten for onboarding | Added prerequisites, two install paths (plugin vs manual), Positron-specific instructions, expanded skill overview and improving skills sections. First student tested install. |
| 2026-02-22 | Added security hooks, `/security-setup` skill, and SECURITY.md | Three-layer defense (hooks + deny rules + bash scoping). Plugin hooks auto-protect; `/security-setup` generates personalized hooks with allowlist/blocklist modes. Educational SECURITY.md for students. |
| 2026-02-22 | `/sync-plugin` as sole publish path with reconciliation | No direct commits to lab repo. `/sync-plugin` (Step 6) reconciles derived artifacts: README tables, user-claude-md.md skills table, settings-example.json deny rules, personal CLAUDE.md skills table. `/done` checks skill registration only. |
| 2026-02-22 | CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD env variable | Enables loading CLAUDE.md from additional directories. Added to personal settings and settings-example.json template. |
| 2026-02-22 | Cross-platform security hooks (macOS, Linux, WSL) | Students use macOS, Linux, and Windows. Hooks use `uname -s` for OS detection. Windows hooks skip gracefully — deny rules are primary protection. |
| 2026-02-22 | Windows onboarding checklist (student-facing) | Simplified to 4 steps: install, settings, `/security-setup`, report. Manual protection tests removed (Claude's model-level safety blocks them). `/security-setup`'s built-in verification is the reliable test. PI section documents confirmed Windows findings (v1.3.2 hooks fix, `$HOME` expansion, update workflow). |
| 2026-02-22 | `/done` posts to Slack via `<!-- slack-channel: -->` comment | One-liner + CHANGELOG link after committing. Personal-only for now — test before publishing to students. |
| 2026-02-22 | `/new-project` asks about CHANGELOG and Slack channel | CHANGELOG optional, auto-maintained by `/done`. Slack channel stored as HTML comment in project CLAUDE.md. |
| 2026-02-22 | README restructured: merged Security + Starter Config into Setup; condensed Security section | Security/Starter Config had duplicate instructions and conflicting framing (required vs optional). New structure: Install → Setup (numbered steps) → Security (summary + SECURITY.md link) → Skill reference → Hooks → Improving skills. SECURITY.md updated to match (three hooks, writes hook description, fixed anchor). |

## Completed Work

### Phase 1: Refactor user CLAUDE.md
- Created `~/.claude/skills/debugging-before-patching/SKILL.md` — new standalone skill
- Added "Surface Analysis Decisions" section to `data-handling` skill
- Slimmed user CLAUDE.md from 134 to 83 lines (4 verbose sections replaced by 4-line "Core Principles" block)
- Updated skills index table

### Phase 2-3: Scaffold and populate repo
- **Location**: `/Users/jm284/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/`
- **16 skills** copied: 13 unchanged, 3 generalized (conda-env, quarto-docs, new-project)
- **scientific-manuscript** skill copied with full `references/` subdirectory (10 reference files + 4 annotated examples)
- **install.sh** — supports `--list`, `--status`, all-at-once, or selective install; warns on conflicts
- **README.md** — quick start, skill catalog organized by category, management commands
- **CONTRIBUTING.md** — skill format guide, PR workflow, testing instructions, ideas for new skills
- **Templates**: `user-claude-md.md` and `project-claude-md.md`

## Remaining Work

### Phase 4: Review and publish
Repo created on GitHub (MusserLab/lab-claude-skills), pushed, and live. 20 skills total.

### Phase 4b: Plugin distribution
Added `.claude-plugin/plugin.json` (plugin name: `lab-skills`) and `marketplace.json` (marketplace name: `musser-lab`). Students can install via `/plugin marketplace add MusserLab/lab-claude-skills` + `/plugin install lab-skills`. Also added `templates/settings-example.json` with pre-approved permissions for common lab tools. README restructured with both install methods, customization workflow, and grouped skill reference.

### Phase 5: Onboard lab members
- [ ] Share repo link and installation instructions with lab
- [ ] Help first 1-2 members install and test
- [ ] Collect feedback on which skills are most/least useful
- [ ] Identify skills that need machine-specific customization guidance
- [x] Security documentation and hooks ready (SECURITY.md, plugin hooks, `/security-setup`, deny rules in settings template)

### Phase 6: Iterate
- [ ] Add new skills based on lab member requests
- [ ] Refine existing skills based on real usage patterns
- [ ] Consider making repo public for broader community use
- [ ] Create GitHub Releases for major batches of skill changes

## Windows Onboarding Checklist

Steps 1-4 are for a student to run independently in Positron on Windows. The PI section at the end documents known issues and fixes.

### For the student: Setting up security on Windows

This takes about 15 minutes. You'll install the lab plugin, copy a settings file, and run a setup wizard.

#### Step 1: Install the plugin

Open the Claude Code panel in Positron (click the Claude Code icon in the sidebar). Type `/plugins` in the chat to open the plugin manager.

1. Go to the **Marketplaces** tab
2. Add `MusserLab/lab-claude-skills`
3. Switch to the **Plugins** tab and install `lab-skills`

You should see a confirmation after installing. If you get an error, stop here and send a screenshot to the PI.

**To update an existing install:** The Positron plugin GUI may not have an update button. If not, open a terminal and run `claude`, then type `/plugin uninstall lab-skills` followed by `/plugin install lab-skills`.

#### Step 2: Copy the settings file

Open a **terminal** in Positron (Terminal menu at the top, not the Claude Code panel). It will open PowerShell. Run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MusserLab/lab-claude-skills/main/templates/settings-example.json" -OutFile "$HOME/.claude/settings.json"
```

If that gives an error, go back to the Claude Code panel and type:
> Download the settings-example.json template from the lab-claude-skills GitHub repo and save it to ~/.claude/settings.json

If you get an error saying `settings.json` already exists, stop here and ask the PI — they'll help you merge the files.

#### Step 3: Run security setup

Go to the **Claude Code panel** and type:

> /security-setup

Claude will walk you through a setup wizard. It will:
- Detect your operating system and shell
- Scan for sensitive locations on your machine (passwords, credentials, cloud storage, etc.)
- Ask which directories you work in
- Ask whether you want allowlist mode (most secure — blocks everything except your project directories) or blocklist mode (blocks only sensitive locations)
- Generate security hooks and deny rules
- Run verification tests to confirm everything works

Follow the prompts and answer its questions. **Blocklist mode** is a good choice if you're unsure — it's less restrictive and you won't get blocked from directories unexpectedly.

When it's done, it will show a summary of what it set up and how many verification tests passed.

#### Step 4: Send results to the PI

Copy this template, fill in the blanks, and send it:

```
## Windows Security Test Results

Shell Claude is using: ___
Protection mode chosen: allowlist / blocklist

/security-setup completed: yes / no
Verification tests: ___ / ___ passed

Any errors or anything unexpected (paste error messages here):

```

### For the PI: Known Windows issues and fixes

These are confirmed findings from the first Windows onboarding (2026-02-22).

#### Confirmed behavior

- **Positron terminal defaults to PowerShell.** Claude Code itself uses Git Bash (MSYS2). These are different shells — PowerShell commands and bash commands are not interchangeable.
- **Hooks work on Windows** when Git Bash is available (which it is in standard Positron installs). All three hooks (reads, writes, bash) fire correctly.
- **`$HOME` in deny rules does NOT expand on Windows.** The `settings-example.json` deny rules (which use `$HOME`) are ineffective as a baseline. `/security-setup` fixes this by generating deny rules with absolute paths.
- **Plugin update via GUI may not work.** Uninstall + reinstall via CLI (`claude` → `/plugin uninstall` → `/plugin install`) is the reliable path.
- **Claude's model-level safety refuses sensitive-file tests** before hooks fire. Manual "try to read ~/.ssh" tests don't work — Claude declines on principle. `/security-setup`'s built-in verification (which tests hooks directly) is the reliable way to confirm protections work.

#### v1.3.2 fix: duplicate hooks registration

Plugin versions ≤1.3.1 had `"hooks": "./hooks/hooks.json"` in `plugin.json`. Claude Code auto-loads `hooks/hooks.json`, so the explicit entry caused a duplicate detection error that silently (or loudly, on newer Claude Code versions) prevented all hooks from loading. Fixed in v1.3.2 by removing the redundant line.

#### Files to update if issues arise

| Problem | Files to fix |
|---------|-------------|
| `$HOME` doesn't expand in deny rules | `templates/settings-example.json` — consider documenting that Windows users should run `/security-setup` for working deny rules |
| Hooks don't run (bash unavailable) | No fix needed — expected on pure PowerShell/cmd. Deny rules (via `/security-setup`) are the primary protection. |
| Hooks don't run (bash available but hooks fail) | Check `hooks/hooks.json` — `${CLAUDE_PLUGIN_ROOT}` may not resolve on Windows. Check `scripts/protect-sensitive-*.sh` for path issues. |
| `/security-setup` fails on Windows | `skills/security-setup/SKILL.md` — fix platform detection (Step 1b) or scan paths (Step 2) |
| `curl\|bash` pattern not caught by bash hook | `scripts/protect-sensitive-bash.sh` — use `grep -qFi` (fixed string) instead of `grep -qi` (regex) for command patterns containing `\|` |

## Known Issues / Things to Address

- `conda-env` and `quarto-docs` use `~/miniconda3` as default — members with different conda locations need a local override copy in `~/.claude/skills/` (documented in README)
- `scientific-manuscript` references directory is large — consider whether all annotated examples should be in the shared repo
- `done` skill references `~/.claude` git tracking — may need adjustment for members who don't git-track their `.claude/` directory
- Template CLAUDE.md files use `{placeholder}` syntax — evaluate whether these need more guided setup
- **Windows security**: Hooks work when Git Bash is available (confirmed). `$HOME` in deny rules doesn't expand — `/security-setup` generates absolute paths as workaround. Plugin update requires CLI uninstall/reinstall. `curl|bash` grep pattern needs `grep -F` fix. See Windows Onboarding Checklist above.

## Key Files

### Inputs
- Original skills at `~/.claude/skills/` (source of truth during initial setup)
- User CLAUDE.md at `~/.claude/CLAUDE.md` (refactored as part of Phase 1)

### Outputs
- Lab repo at `/Users/jm284/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/`

### Scripts

N/A — this is a configuration repo, not an analysis project.