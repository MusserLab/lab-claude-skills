# Changelog

All notable changes to lab-claude-skills are documented here.
Format: date-based entries (this isn't versioned software).

---

## 2026-08-07 (v1.12.1)

### Fixed
- `hpc`: **the Tier 1 direct-`squeue` `ProxyCommand`s in the previous release could not work.**
  They used an unescaped `$(squeue …)`, which your **laptop** expands — and laptops have no
  `squeue`, so the remote command collapsed to `nc  22` and failed with no useful message. Now
  escaped as `\$(squeue …)` in **every direct-`squeue` entry**, with a note that `ssh -G` cannot
  detect this because it never runs the command
- `hpc`: **wrong Bouchet `devel` limits** in `references/partitions.md` (claimed 8 CPUs /
  120 GiB). Corrected to **4 CPUs, 60 GiB, max 2 submitted jobs per user**, and the table now
  says explicitly that per-user limits are **aggregate across all your jobs**, not per job
- `hpc`: **`SKILL.md` told you to run Claude Code / Positron sessions on `day` with 8 CPUs.**
  Interactive work belongs on `devel`: YCRC makes `devel` the default partition for `salloc`,
  and VS Code jobs found outside the devel partitions **may be terminated without notice** (this
  skill infers the same applies to Positron Remote-SSH). The example is now
  `salloc -p devel -c 4 --mem=32G -t 6:00:00 --job-name=positron-devel`, with per-cluster limits
  (Bouchet 4 CPUs / 60G / max 2 jobs; McCleary 4 CPUs / 32G / max 1 job)
- `hpc`: **`scripts/hold-node.sh` could submit a second allocation on reconnect.** It only looked
  for **RUNNING** jobs, so a same-name job that was still **PENDING** was invisible and re-running
  the alias queued another one; piping `squeue` into `head` also discarded its exit status, so a
  scheduler failure looked identical to "no job". It now does one cluster-wide lookup with an
  **explicit state filter** -- `PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING` (Slurm's
  no-state default omits SUSPENDED) -- captured without a pipeline. If a job is found it prints
  each id/state/node-or-reason and **exits without submitting**; if the lookup **fails it refuses
  and exits nonzero**, leaving the allocation state explicitly unknown. It also now **rejects a
  caller-supplied job name** in every spelling (`-J`, `-Jname`, `--job-name`, `--job-name=`), so
  the name looked up and the name submitted cannot drift. The existing-job branch no longer opens
  a shell: that shell could become the root of a fresh tmux session, outlive the allocation, and
  make a later alias run reattach a stale shell instead of re-checking. Tier 2's
  `ControlPersist 30m` keeps the SSH master alive without it. This protects against an extra
  submission on a normal reconnect; it is **not** an atomic lock -- two *simultaneous first*
  starts can still both allocate
- `hpc`: **reconnection advice assumed one login node per cluster.** There are two, and tmux
  sessions are login-node-local, so a reconnect behaves differently depending on where you land:
  on the **same** login node tmux reattaches your original `salloc` shell and the helper is not
  invoked at all; on the **other** one a temporary tmux runs the helper, which finds the existing
  job, submits nothing and exits. The guide now spells out all four reconnect outcomes --
  reattached, existing RUNNING job, existing PENDING job (wait; nothing can connect without a
  node), and a genuinely new allocation (which requires redoing the `/tmp` preflight if you use
  the optional target) -- plus lookup failure, where you stop and investigate. **After an
  uncertain reconnect, `scancel -n positron-devel` is what reliably releases the node** (`exit`
  only works from the original `salloc` shell)
- `hpc`: bundled `scripts/hold-node.sh` and `scripts/positron-node.sh` had stale examples showing
  `--partition=day`, 8 CPUs, and the old `positron` job name. Both now show the supported
  `positron-devel` / `devel` / 4 CPUs / 6 h form. `positron-node.sh` keeps `positron` as its
  runtime default so already-copied SSH configs keep working; it is now labelled a legacy default

### Changed
- `hpc`: `devel` is now the default throughout `references/positron-ssh-setup.md` — Tier 1 and
  Tier 2 sessions, reconnection, cheat sheet, shutdown, and the batch-placeholder variant. Any
  `day` / `ycga` / non-`devel` / >6 h example is kept only inside a labelled **UNVERIFIED** block
- `hpc`: Tier 2 steps no longer mix clusters — they are written as `<cluster>-devel` and say to
  stay on the cluster you allocated on
- `hpc`: the cheat sheet and shutdown steps separate **laptop-side** from **cluster-side**
  commands, with laptop-safe forms (`ssh <cluster>.ycrc.yale.edu "squeue --me"`,
  `ssh <cluster>.ycrc.yale.edu "scancel -n positron-devel"`) for Bouchet and McCleary
- `hpc`: the two-concurrent-IDE-session recipe is **removed** — it exceeded Bouchet's aggregate
  4-CPU `devel` allowance and McCleary allows only one submitted `devel` job. Open a second
  window against the *same* allocation instead
- `hpc`: adds a `mccleary-devel` route at McCleary's documented limits, noting it has **not been
  live-tested**; **Misha** is marked UNVERIFIED rather than "works identically"
- `hpc`: SSH-key setup corrected — one upload to YCRC's key uploader reaches every cluster, so
  the old per-cluster `ssh-copy-id` step is gone. The Windows/WSL section drops the incorrect
  `remote.SSH.path` advice (Positron does not expose that setting) and is labelled UNVERIFIED
- `hpc`: installing the Positron server on **NFS home is the supported default**, and the
  node-local `/tmp` trick is now an **optional, advanced, Bouchet-only** workaround for repeated
  install failures, collapsed behind a details block. It uses its own `bouchet-devel-tmp` SSH
  target keyed exactly (never a `bouchet-*` glob), and requires a fail-closed preflight — run on
  a shell you have positively confirmed is the allocated compute node — before connecting
  Positron. If the preflight refuses, or the hostname can't be matched, use ordinary
  `bouchet-devel` on NFS. The manual-seed recipe is labelled macOS-only
- README: **corrects the claim that the plugin auto-updates on restart.** `musser-lab` does not
  auto-update by default, and restarting Positron alone does not guarantee a new release. Exact
  Positron update instructions are still being validated on a clean student profile; until they
  are published, students are told to ask Jacob

## 2026-07-04 (v1.12.0)

### Added
- `plugin-feedback` skill — file a lab-skill bug, improvement, or new-skill idea as a GitHub issue on `MusserLab/lab-claude-skills`, drafted from the conversation and confirmed before filing; uses the `gh` CLI when authenticated, otherwise hands back a pre-filled issue URL (no auth needed). Ships with a **Skill feedback** GitHub issue template
- `general-reminders.txt` now also prompts Claude to offer `/plugin-feedback` — once per session, unobtrusively — when the user hits genuine friction with a skill
- `audit-script`, `audit-skills`: bundled subagent-prompt `templates/` (a fresh **Auditor** for the cold read; **refuter** + **completeness critic** for the gated verification fan-out), plus a `verify-fanout.workflow.js` for `audit-skills`
- `hpc`: `scripts/hold-node.sh` + `scripts/positron-node.sh` — a persistent salloc-in-tmux allocation and a ProxyCommand node resolver for disconnect-proof Positron / Remote-SSH (Tier 2)

### Changed
- `audit-project`: new mechanical bash pre-pass (§0b) that feeds the interactive review, plus a report-only / scheduled mode (§0c) that runs detection only and writes a report without changing anything
- `audit-script`, `audit-skills`: new **"Execution Model"** section — when the current chat authored the target, delegate the cold read to a fresh **Auditor subagent** (escapes authoring-chat blind spots); diagnostics, interaction, and report-saving stay with the orchestrator; verification may fan out (gated), never the initial read, and never as agent teams. `audit-skills` also flags bundled `scripts/` that contain real logic for a separate `/audit-script` pass
- `hpc`: `references/positron-ssh-setup.md` restructured into **Tier 1 (basic) + Tier 2 (disconnect-proof)** with the two bundled helper scripts; `gpu-partition-tactics.md` and `tool_profiles.md` updated (prefer `scontrol update Partition` over cancel+resubmit, IsoSeq memory scaling, new barrnap row)
- `deep-research-genelist`: exclude unannotated bare-ID markers from the embedded gene list and report their counts instead, so downstream research isn't seeded with uninformative IDs
- `script-organization`: **"a section is one coherent pipeline"** — no count threshold forces a split; a distinct thread starts a new numbered section; regrouping is only ever suggested, never automatic

## 2026-06-24 (v1.11.1)

### Changed
- `audit-project`, `audit-script`, `audit-skills`: new optional, **gated "Adversarial Verification & Completeness" phase** — when the Workflow tool is available *and* an opt-in signal is present (ultracode on, an explicit thorough/adversarial/"double-check" request, or a saved handoff report), fan out a read-only pass that adversarially verifies each already-formed finding (verifiers may downgrade/reject, not just confirm) plus a completeness critic. Fully gated: skips silently with no behavior change for users without the Workflow tool (e.g. standard plugin installs). Behavior notes updated to allow fan-out only for this verification pass — never for the initial read/walk-through or for running user code
- `hpc`: refactor for clarity and single-source-of-truth — added a Duo 2FA + SSH ControlMaster note (Positron/Remote-SSH can't answer Duo non-interactively), moved GPU-partition selection/ETA tactics into a new `references/gpu-partition-tactics.md`, and converted the policy section into an index pointing to each policy's topical home. `references/positron-ssh-setup.md` substantially expanded (Duo/ControlMaster walkthrough, platform notes, troubleshooting); `tool_profiles.md` gains busco/hmmer/transdecoder rows

## 2026-06-23 (v1.11.0)

### Added
- Hook: `done-reminder.sh` (UserPromptSubmit) — detects end-of-session / wrap-up phrasing and injects a non-blocking nudge telling Claude to run the `/done` skill rather than hand-rolling the summary, doc updates, and commit. Holds even when the message also includes a specific sub-task or context is nearly full
- `general-reminders.txt` now ships with the plugin (the `&&`-chaining permission gotcha) and is injected at every session start — no longer requires each user to create the file by hand

### Changed
- `project-reminders.sh`: resolve `general-reminders.txt` from the plugin root (`${CLAUDE_PLUGIN_ROOT}/scripts/`) when no personal `~/.claude/hooks/general-reminders.txt` exists, so the shipped default actually reaches plugin users; a personal copy still takes precedence
- `deep-research-reports`: fix the artifact-stripping regex — the bundled snippet had literal Unicode private-use-area characters baked into `re.sub(...)` (the very junk it strips); replaced them with the proper regex escape sequence so the source stays clean ASCII

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
