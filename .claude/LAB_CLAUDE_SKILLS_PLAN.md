# Lab Claude Skills Setup and Distribution Plan

## Overview

Setting up and distributing a shared Claude Code skills repository for the lab. Covers: extracting and generalizing skills from the PI's personal config, building a shared GitHub repo with install tooling, onboarding lab members, and iterating based on feedback.

## Goals

- [x] Create a shared, version-controlled repo of Claude Code skills
- [x] Generalize existing skills (remove machine-specific paths)
- [x] Provide an install script for easy adoption
- [ ] Push to GitHub and onboard lab members
- [ ] Establish contribution workflow (PRs, reviews)
- [ ] Iterate on skills based on lab member feedback

## Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Refactor user CLAUDE.md — extract principles into modular skills | Done |
| 2 | Scaffold repo structure, copy and generalize skills | Done |
| 3 | Write install.sh, README, CONTRIBUTING, templates | Done |
| 4 | Review, initial commit, push to GitHub | Not started |
| 5 | Onboard lab members — install, test, collect feedback | Not started |
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
- [ ] Review all generalized skills for accuracy
- [ ] Test `install.sh` on a clean `~/.claude/skills/` setup
- [ ] Create initial git commit
- [ ] Create GitHub repo (MusserLab org, private initially?)
- [ ] Push initial commit

### Phase 5: Onboard lab members
- [ ] Share repo link and installation instructions with lab
- [ ] Help first 1-2 members install and test
- [ ] Collect feedback on which skills are most/least useful
- [ ] Identify skills that need machine-specific customization guidance

### Phase 6: Iterate
- [ ] Add new skills based on lab member requests
- [ ] Refine existing skills based on real usage patterns
- [ ] Consider making repo public for broader community use

## Known Issues / Things to Address

- **Update workflow**: `./install.sh --update` pulls latest git changes, installs any new skills, and flags local copies that differ from repo. Symlinked skills update automatically on pull; local copies require manual action.
- `conda-env` and `quarto-docs` use `~/miniconda3` as default — members with different conda locations need to copy instead of symlink (documented in README)
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