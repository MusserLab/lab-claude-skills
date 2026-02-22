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

### Phase 6: Iterate
- [ ] Add new skills based on lab member requests
- [ ] Refine existing skills based on real usage patterns
- [ ] Consider making repo public for broader community use
- [ ] Create GitHub Releases for major batches of skill changes

## Known Issues / Things to Address

- `conda-env` and `quarto-docs` use `~/miniconda3` as default — members with different conda locations need a local override copy in `~/.claude/skills/` (documented in README)
- `scientific-manuscript` references directory is large — consider whether all annotated examples should be in the shared repo
- `done` skill references `~/.claude` git tracking — may need adjustment for members who don't git-track their `.claude/` directory
- Template CLAUDE.md files use `{placeholder}` syntax — evaluate whether these need more guided setup

## Key Files

### Inputs
- Original skills at `~/.claude/skills/` (source of truth during initial setup)
- User CLAUDE.md at `~/.claude/CLAUDE.md` (refactored as part of Phase 1)

### Outputs
- Lab repo at `/Users/jm284/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/`

### Scripts

N/A — this is a configuration repo, not an analysis project.