# Changelog

All notable changes to lab-claude-skills are documented here.
Format: date-based entries (this isn't versioned software).

---

## 2026-02-22

### Added
- Security hooks: `protect-sensitive-reads.sh` and `protect-sensitive-bash.sh` — block reads to credential stores, password managers, browsers, and email; block dangerous bash patterns (credential extraction, pipe-to-execute, env dumping)
- `/security-setup` skill — interactive workflow to scan a machine for sensitive locations, choose allowlist or blocklist mode, and generate personalized hooks at `~/.claude/hooks/`
- Security-setup templates: configurable `protect-sensitive-reads.sh` and `protect-sensitive-bash.sh` with allowlist/blocklist modes, cloud storage exceptions, and always-block lists
- Deny rules in `settings-example.json` for `.ssh`, `.aws`, Keychains, Mail, Messages, Safari, 1Password, Chrome
- `SECURITY.md` — educational guide to Claude Code security for lab members
- README: expanded security section with summary and link to `SECURITY.md`
- Cross-platform support for security hooks — OS detection via `uname -s`, Linux paths, WSL detection with Windows-side path blocking
- Windows scan paths and deny rules in `/security-setup` skill and `settings-example.json` (AppData paths for Chrome, Firefox, Edge, 1Password, KeePassXC, Bitwarden)
- Platform support table in SECURITY.md (macOS, Linux, Windows — hooks vs deny rules)
- `<!-- slack-channel: -->` comment support in project CLAUDE.md template for Slack notifications

### Changed
- Plugin version bumped to 1.2.1; `hooks.json` now registers security hooks on Read and Bash events
- `/security-setup` skill: detects platform, skips hook generation on Windows, scans platform-appropriate paths
- `settings-example.json`: added Linux and Windows AppData deny rules alongside existing macOS rules
- README: hooks section notes Windows limitation; three-layer table links to SECURITY.md for Windows
- SECURITY.md: expanded from macOS-only to three-column platform coverage (macOS, Linux, Windows)
- `protein-phylogeny`: add MAFFT threading (`--thread 8`) and `--output-dir` in render command
- `quarto-docs`: enforce `--output-dir` for all renders; remove `mv` workaround
- `tree-formatting`: major update — .qmd templates (replacing .R), no-branch-capping rule, `collapse_groups` parameter, model species gene names on collapsed triangles, formula-based page sizing (`INCHES_PER_TIP`), 5 new gotchas

## 2026-02-21

### Changed
- README: added prerequisites section with lab handbook and Anthropic install links
- README: two install options — plugin (recommended) vs manual (customizable), with Positron-specific instructions
- README: expanded "What are skills?" — automatic vs user-invoked, activation via descriptions, bundled files
- README: promoted starter config to own section with templates, settings, and customization subsections
- README: expanded "Improving skills" — what to report, what makes a good skill, filing issues via Claude
- README: removed "auto-load" language from skill reference categories

### Added
- Plugin hooks: `protect-data-dir.sh`, `require-conda.sh`, `project-reminders.sh`
- `hooks/hooks.json` — hook event configuration for the plugin
- `gene-lookup` skill — look up gene/protein info from database IDs (UniProt, Ensembl, FlyBase, WormBase, NCBI)
- README: Hooks section documenting plugin hooks and project reminders
- `quarto-docs`: embedded PDF formatting guide as `references/pdf-formatting.md`
- `protein-phylogeny` skill — alignment, trimming, tree inference pipeline
- `new-project`: added "Project reminders file" section for project-reminders hook scaffolding
- Plugin manifest and marketplace for Claude Code plugin distribution
- Settings template and permissions guide in README
- `CHANGELOG.md` — backfilled from git history

### Changed
- Plugin version bumped to 1.1.0; `plugin.json` now declares hooks
- `/done`: expanded session file identification with parallel-conversation awareness
- `tree-formatting`: replaced ETE4 (Python) with ggtree/iTOL (R) including runnable templates
- `new-skill`: removed lab-repo push prompt — skills stay local
- Distribution simplified to plugin-only; feedback via GitHub Issues

### Removed
- `install.sh` — symlink install path removed in favor of plugin
- `CONTRIBUTING.md` — replaced by GitHub Issues workflow

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
