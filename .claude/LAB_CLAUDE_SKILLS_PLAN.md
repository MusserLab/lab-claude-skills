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
| 2026-02-22 | Windows onboarding checklist (student-facing) | Hooks may not work on Windows PowerShell/cmd. Student runs steps 1-5 to test, reports findings. PI fixes issues in Step 6. |
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

Steps 1-5 are designed for a student to run independently in Positron on Windows. Step 6 is for the PI to act on the results. Send this checklist to the first Windows student and ask them to report back their findings from Step 5.

### For the student: Testing security on Windows

Open the Claude Code panel in Positron and work through these steps. Copy/paste the prompts directly into the chat.

#### Step 1: Identify your environment

Type this into Claude Code:

> "What shell are you using? Run `echo $SHELL` or `echo %COMSPEC%` and tell me what OS and shell you detect."

Write down the answer (PowerShell, cmd.exe, Git Bash, etc.) — it determines which protections are available.

#### Step 2: Test deny rules

The settings template uses `$HOME` in deny rules. We need to verify these actually block on Windows.

1. Make sure you've copied `settings-example.json` to `~/.claude/settings.json` (from the install instructions)
2. Type: "Try to read `~/.ssh/id_rsa`" — should be blocked by a deny rule
3. Type: "Try to read `~/.aws/credentials`" — should also be blocked
4. If blocked: great, deny rules work. Ask Claude what exact path it tried to read and write it down.
5. If NOT blocked: ask Claude to try reading the same file using your full home path (e.g., `C:/Users/YourName/.ssh/id_rsa`). Write down which path format works.

#### Step 3: Test hooks

1. Type: "Read `~/.claude/settings.json` and show me the hooks section" — verify hooks are registered
2. Type: "Try to read a file at `~/.gnupg/`" — if hooks work, you'll see a "BLOCKED" message mentioning a hook script
3. If you see "BLOCKED" from a hook: hooks work on your shell (likely Git Bash is available)
4. If no hook message appears: that's expected on PowerShell/cmd. The deny rules from Step 2 are your primary protection.

#### Step 4: Test /security-setup

1. Type `/security-setup` in the Claude Code panel (or `/lab-skills:security-setup` if using the plugin)
2. The skill should detect Windows and adapt:
   - It should scan Windows-specific paths (`AppData/`, etc.)
   - If hooks can't run on your shell, it should skip hook generation and focus on deny rules
   - If hooks can run, it should generate hooks as normal
3. Check that the deny rules it generates use path formats that actually match what you found in Step 2

#### Step 5: Report findings

Send these results back to the PI:
- Shell detected: ___
- `$HOME` expansion format (the exact path Claude tried in Step 2): ___
- Deny rules work: yes / no / with modified paths
- Hooks work: yes / no
- `/security-setup` completed successfully: yes / no
- Path format needed for Windows deny rules: ___
- Any errors or unexpected behavior: ___

### For the PI: Fix what's broken (Step 6)

Based on the student's findings, update:
- `settings-example.json` deny rules (if path format needs adjusting)
- `/security-setup` skill (if Windows scan or deny rule generation needs fixes)
- `SECURITY.md` (update Windows section with confirmed behavior)

## Known Issues / Things to Address

- `conda-env` and `quarto-docs` use `~/miniconda3` as default — members with different conda locations need a local override copy in `~/.claude/skills/` (documented in README)
- `scientific-manuscript` references directory is large — consider whether all annotated examples should be in the shared repo
- `done` skill references `~/.claude` git tracking — may need adjustment for members who don't git-track their `.claude/` directory
- Template CLAUDE.md files use `{placeholder}` syntax — evaluate whether these need more guided setup
- **Windows security**: Hooks (Layer 1) may not work on Windows — depends on shell. Deny rules (Layer 2) and bash scoping (Layer 3) are the primary protection. See Windows Onboarding Checklist above.

## Key Files

### Inputs
- Original skills at `~/.claude/skills/` (source of truth during initial setup)
- User CLAUDE.md at `~/.claude/CLAUDE.md` (refactored as part of Phase 1)

### Outputs
- Lab repo at `/Users/jm284/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/`

### Scripts

N/A — this is a configuration repo, not an analysis project.