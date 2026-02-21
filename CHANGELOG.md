# Changelog

All notable changes to lab-claude-skills are documented here.
Format: date-based entries (this isn't versioned software).

---

## 2026-02-21

### Added
- `protein-phylogeny` skill — alignment, trimming, tree inference pipeline
- `tree-formatting` skill — ETE4 tree visualization and formatting
- Plugin manifest and marketplace for Claude Code plugin distribution
- Settings template and permissions guide in README
- `CHANGELOG.md` — backfilled from git history

### Changed
- `/done`: detect CHANGELOG.md and propose updates at session end

## 2026-02-20

### Changed
- `script-organization`: add subdirectory selection rule

## 2026-02-19

### Changed
- `/audit`: add path drift, lab sync, and stale reference checks

## 2026-02-18

### Added
- `/audit` skill — periodic project health check
- `new-skill` skill — create skills with proper structure

### Changed
- `/done`: slim down, add `.claude/plans/` scanning fallback, self-contained phase collapsing guidance
- `git-conventions`: add `.claude/worktrees/` and rendered HTML to gitignore conventions
- `/new-plan`: remove decision logs from templates, add phase collapsing guidance
- `/audit`: add planning doc health checks and user-level audit

## 2026-02-17

### Added
- Shared `lab-general` conda env for general projects
- `/new-plan`: support for general and data science project styles

### Changed
- `conda-env`: make `lab-general` the default for all general projects

## 2026-02-14

### Added
- Initial release: shared Claude Code skills with project-type categorization
- Skills: `data-handling`, `r-plotting-style`, `script-organization`, `quarto-docs`, `r-renv`, `figure-export`, `debugging-before-patching`, `git-conventions`, `conda-env`, `file-safety`, `done`, `new-plan`, `new-project`
- Templates: `user-claude-md.md`, `project-claude-md.md`
- Install script for symlink-based distribution
