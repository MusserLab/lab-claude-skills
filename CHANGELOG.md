# Changelog

All notable changes to lab-claude-skills are documented here.
Format: date-based entries (this isn't versioned software).

---

## 2026-06-21 (v1.10.1)

### Changed
- `feedback-walkthrough`: switch to **GitHub-issue-based** delivery to match how advisors now send feedback — find rounds via `gh issue list --label feedback`, read with `gh issue view`, respond in **issue comments** and tick task-list checkboxes; `docs/feedback/*.md` is now a fallback. Issue comments are the canonical record (they notify the advisor; checkbox ticks don't); added a `gh auth login` pointer and a write-access note on checkbox ticking. (The advisor-authoring side, `student-feedback`, stays PI-only and is not shipped.)

## 2026-06-21 (v1.10.0)

### Added
- `pipeline-diagram` skill — generate publication-style processing-pipeline diagrams (flowing-backbone overview + optional per-step detail) from a small YAML spec; bundled generic renderer + annotated example spec
- `handoff` skill — coordinate local ↔ cluster Claude Code session handoffs with a strict departure → gate → arrival sequence and multi-chat safety; bundled divergence-recovery reference
- `sync-project` skill — arrival-side project sync (git pull with divergence classification, conda env update from `environment.yml`, renv restore, memory-promotion check)
- `feedback-walkthrough` skill — walk a student through advisor feedback pedagogically, one item at a time so they understand and act on it themselves (student side)

### Changed
- `audit-skills`: flag `$`-substitution in inline shell (`$N` / `$ARGUMENTS` get blanked when a skill loads with no args) as a FIX-severity check
- `new-skill`: new "Shell and `$`-tokens in SKILL.md bodies" section — escape positional args/awk fields, or move runnable shell to `templates/`
- `deep-research-reports`: add `family_report1` (WGCNA-module family pipeline) and `family_report2` (per-triage-group) report types with validation, summary tables, and titles — now five report types
- `hpc`: McCleary Palmer-vs-Gibbs storage guidance, cross-cluster shared data-folder paths, GPU-partition queue-depth/ETA selection workflow, escaped `\$0` in the provenance block; +2 tool_profiles rows (IsoSeq refine+cluster2, HMMER hmmscan 6-frame)
- `done`: collaborator mode (`<!-- done-mode: collaborator -->`) — keep session log and plans private to your clone and pre-triage push-vs-hold; new "Capture SLURM Resource Profiles" cluster-only step
- README + `user-claude-md` / `user-claude-md-cluster` templates: added the four new skills

## 2026-06-15 (v1.9.1)

### Changed
- `conda-env`: record pip-installed packages in `environment.yml` under a `pip:` subsection — `conda env export --from-history` omits them, so they get silently lost. Detect pip installs via `conda list ... pypi`; prefer reconciling the hand-curated file over overwriting it
- `done`: conda environment **drift check** (renamed from "export") — reconcile `environment.yml` against both conda *and* pip packages instead of blindly overwriting with a full export; show the diff and propose exact lines to add before editing

## 2026-05-07 (v1.9.0)

### Added
- Hook: `enforce-qmd-scripts.sh` — blocks numbered non-`.qmd` scripts in `scripts/` on local (auto-skips on cluster). Override with `# allow-py: <reason>` comment in the first 20 lines
- Hook: `commit-before-execute.sh` — suggests committing changes before `sbatch` or `quarto render` so BUILD_INFO git hash is accurate (suggestion, not block)
- Hook: `suggest-new-plan.sh` — prompts to ask the user before entering plan mode; recommends `/new-plan` for tracked planning documents
- New `EnterPlanMode` hook event matcher in `hooks/hooks.json`
- `hpc/references/positron-ssh-setup.md` — guide for connecting Positron / VS Code Remote SSH to a cluster interactive session

### Changed
- `audit-script`: added "Outputs trustworthy?" assessment (Yes / Yes with caveats / No) to audit report summary
- `audit-skills`: single-skill review mode (skip Phase 1 inventory and Phase 3 cross-skill pass for N=1), output mode question (fix directly / save report / both), save-report path for handoff between chats
- `cleanup-scripts`: cluster-aware `# allow-py:` override for numbered `.py`/`.R`/`.Rmd` files in `scripts/` (auto-skip on cluster)
- `deep-research-reports`: family report type support (WGCNA-module-organized), ChatGPT Pro / extended thinking detection, `fix_flat_yaml` for zero-indent YAML, dual quarto-path detection, family field mappings in summary table
- `done`: push to remote automatically after commit (only ask if push fails)
- `hpc`: Positron / VS Code Remote SSH setup section, shared lab databases (`~/project_pi_jm284/shared/databases/`), Claude Code interactive session recommendations (8 CPUs / 32 GB)
- `new-skill`: clarified `templates/` vs `scripts/` vs `references/` subdirectory roles in bundled resources, added "Examples in the wild" pointers
- `quarto-docs`: cluster-aware script format guidance (`.qmd` local default, `.py` cluster default, override marker for either)
- `script-organization`: new "Script Format by Environment" section with override marker convention
- Hook: `protect-data-dir.sh` — allowlist `data/processed/` (sanctioned target for derived analytical stores) and provenance files (CITATION/PROVENANCE/README/MANIFEST/CHANGELOG/LICENSE)
- README: added 3 new hooks to Hooks table; updated `protect-data-dir.sh` description; updated `hpc` description

## 2026-03-29 (v1.8.0)

### Added
- `audit-skills` skill — audit skills for bloat, trigger accuracy, structural quality, redundancy, and pruning opportunities
- Cluster config templates: `templates/settings-cluster.json` and `templates/user-claude-md-cluster.md` for HPC cluster setup
- `hpc` reference files: partitions.md, snakemake.md, tool_profiles.md
- `expression-report` bundled resources: report_template.py, helpers.py, species_notes.md
- `new-project` externalized CLAUDE.md templates: claude_md_data_science.md, claude_md_general.md

### Changed
- `audit` → `audit-project`: renamed, description updated to exclude skill auditing (use `/audit-skills`)
- `audit-script`: added "Simplicity First" philosophy, FYI severity level, calibration guidelines
- `done`: updated description triggers (selective merge — no Slack/STATUS_SUMMARY)
- `expression-report`: bundled templates and helpers, simplified configuration, species notes check
- `hpc`: genericized PI paths, added reference files for partitions, Snakemake, tool profiles
- `new-project`: expanded cluster/SLURM support, dual-environment setup, externalized templates (selective merge — no Slack)
- `quarto-docs`: added IPython magic troubleshooting entry
- `script-organization`: batch/logs now tracked in git, added .py+.sh pairing convention
- `security-setup`: HPC cluster auto-detection, cluster template selection, cluster-specific deny rules, skip bash scoping on HPC
- `tree-formatting`: added accession filtering for collapse labels (UniProt sp|/tr| patterns)
- README: added cluster template setup instructions, HPC auto-detection note in Security section

## 2026-03-23 (v1.7.0)

### Changed
- `audit-script`: added domain verification phase (researches tools, file formats, and methods before auditing code), domain assumptions checklist in audit reports, `.claude/audit_reports/` save location, "verify domain assumptions" and "track uncertainty" principles, subagent prohibition
- `conda-env`: added cluster (HPC) activation patterns with auto-detection, post-export hygiene (remove prefix line, remove defaults channel)
- `done`: added same-day session numbering, sync-canonical reminder, conda environment export with post-export hygiene
- `hpc`: full content sync — added transfer node warnings, dual-environment project conventions, provenance block in batch template, modules vs conda hybrid rule, tools environment, interactive command conventions, PROST benchmarks, job array mail-type guidance
- `script-organization`: added cluster `.py` script format guidance, full `.py` analysis script template with BUILD_INFO.txt and archive-before-overwrite, `slurm_job_id` in BUILD_INFO, `.py` status in module docstrings

### Fixed
- README: `/quarto-publish` → `/publish` (matching actual skill name)

## 2026-03-21 (v1.6.0)

### Added
- `/cleanup-scripts` skill — session-scoped script cleanup: consolidate scratch files, check conventions
- `expression-report` skill — single-cell expression reports: barplots, heatmaps, cross-analysis (Python/scanpy)
- `hpc` skill — Yale YCRC HPC/SLURM reference for batch scripts, job resources, cluster storage, and YCGA partition

### Changed
- `audit`: added interactive planning document review, STATUS_SUMMARY.md rebuild, session log health checks, script convention compliance checking
- `data-handling`: added compressed file handling section (.gz/.tar.gz/.zip), "show your work" communication directive, common data pitfalls (column collisions, namespace masking, join key verification)
- `deep-research-reports`: added nonmetazoan characterization report type with prokaryote/eukaryote variants, separate summary table
- `done`: added Session Log (rolling 5-entry log in project CLAUDE.md), done_extensions.md support, staging safety warning (`git add` by name only), push offer after commit, sequential bash for `~/.claude` commits
- `new-project`: added cluster/SLURM question and directories (batch/, logs/), Session Log template in scaffolded CLAUDE.md
- `new-skill`: added bundled resources convention for code-generating skills (scripts/ and references/ subdirectories)
- `protein-phylogeny`: added comprehensive FASTA validation chunk (duplicates, empty seqs, non-standard chars, internal stops) and IQ-TREE tier 1.5 (Q.pfam+F+R6 for batch screening)
- `quarto-book-setup`: added Session Log section reference in generated CLAUDE.md
- `quarto-docs`: added archive previous outputs code chunks for R and Python (moves existing files to _archive/ before re-render)
- `script-organization`: added cluster projects section (batch/logs/), letter suffix rules (shared output dirs, execution order), archive before overwrite convention, relaxed cross-language script rule (exception for tight pipelines)
- `tree-formatting`: added Newick tree file validation step with R (ape) and Python (ete3) code chunks

## 2026-03-13 (v1.5.1)

### Fixed
- Hook: `protect-sensitive-reads.sh` — added `.pem` to blocked filenames (was already present in `protect-sensitive-writes.sh`)

### Security
- Bumped SECURITY_VERSION to 4 — users with personal hooks should re-run `/security-setup`

## 2026-03-12 (v1.5.0)

### Added
- `/audit-script` skill — systematic audit of data analysis scripts for bugs, analytical reasoning, data handling, style, and reproducibility (3 modes: thorough, fast, report-only)
- `/learn-code` skill — interactive script walkthrough for teaching coding mechanics, script organization, and analytical reasoning to PhD students

### Changed
- `deep-research-genelist`: added family-aware mode — two-pass batch generation (family reports + cluster reports), family marker detection, family report template, cross-reference placeholders for cluster reports
- `deep-research-reports`: added family-aware support — `report_type`, `member_clusters`, `n_member_clusters` fields in YAML validation and summary table

## 2026-03-06 (v1.4.1)

### Changed
- `deep-research-genelist`: Refactored annotation workflow — annotation profile system replaces inline detection. Interactive discovery for new species/datasets, YAML profile caching for batch reuse. Added `annotation_profile_example.yaml` template.
- `deep-research-reports`: Improved YAML fixer — targeted line-by-line fix for ChatGPT 1-space indent (replaces global indentation doubling). Expanded summary table with complete field mapping from YAML (38 columns with explicit source→column mapping). Added heading normalization (removes redundant ChatGPT headings, shifts levels up) and LaTeX backslash escaping for gene names.

## 2026-03-06 (v1.4.0)

### Added
- `/gene-list-deep-research` skill — generate deep research prompts from scRNAseq marker gene lists for cell type annotation (with templates and annotation method reference library)
- `/process-deep-research` skill — process deep research report outputs: clean platform artifacts, generate PDF/HTML, parse YAML headers, maintain annotation summary table (with CSS and cleaning pattern templates)
- `git-conventions`: added "Commit Message Format" section — use multiple `-m` flags instead of heredocs (heredocs break permission allowlist glob matching)
- `new-plan`: added "Key Decisions" and "Working Notes" sections to all three plan templates (simple, multi-phase, multi-component)
- `quarto-docs`: added AI Attribution Block (callout note for Claude-generated scripts) and Troubleshooting section (common QMD rendering issues)

### Removed
- `scientific-manuscript` skill — removed from shared repo (PI-only)

## 2026-02-28

### Changed
- README: plugin update instructions now note marketplace auto-updates on restart; manual CLI uninstall/reinstall kept as fallback

## 2026-02-22

### Added
- Security-setup template: `protect-sensitive-writes.sh` — `/security-setup` now generates personalized write-protection hooks (previously only reads and bash were personalized)
- Hook: `protect-sensitive-writes.sh` — blocks Edit/Write to credential stores, password managers, LaunchAgents, and sensitive filenames (.env, .pem, keys)
- Write/Edit deny rules in `settings-example.json` for .ssh, .aws, Keychains, LaunchAgents, keyrings, 1Password
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
- `/security-setup`: generates personalized `protect-sensitive-writes.sh` (Step 6 for first-time, Step 4 upgrade path for returning users); registers Edit and Write hook matchers; returning-user flow detects missing writes hook and adds it
- `done`: added skill registration check — verifies new skills appear in `~/.claude/CLAUDE.md` before committing
- `new-project`: added CHANGELOG.md scaffolding question and Step 7b
- Hook: `project-reminders.sh` — now supports `~/.claude/hooks/general-reminders.txt` for cross-project reminders
- `hooks.json`: added `protect-sensitive-writes.sh` to Edit/Write event
- Plugin version bumped to 1.3.1; `hooks.json` now registers security hooks on Read, Edit/Write, and Bash events

### Fixed
- Plugin hooks not loading: removed duplicate `"hooks"` entry from `plugin.json` — `hooks/hooks.json` is auto-loaded by Claude Code, so the explicit manifest entry caused a duplicate detection error that silently prevented all hooks from firing (v1.3.2)
- `curl|bash` pipe-to-execute pattern not caught by bash hook on some platforms — changed `grep -qi` to `grep -qFi` (fixed string match) so the `|` character is treated literally

### Security
- Bumped SECURITY_VERSION to 3 — users with personal hooks should re-run `/security-setup`

### Previously in this date (v1.2.1)
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
