<!-- project-type: general -->
<!-- slack-channel: #code:C04LBQ8LZTQ -->
<!-- slack-post-criteria: Skill, hook, or security changes that affect students; documentation updates (README, SECURITY.md). NOT internal tooling changes (sync-plugin, version stamps, planning docs). -->
# Lab Claude Skills

Shared Claude Code skills repository for the lab. Contains standardized conventions for data handling, plotting, script organization, reproducibility, and more.

**Skill and hook changes must flow through `/sync-plugin`.** Develop and test skills in `~/.claude/skills/`, then run `/sync-plugin` when ready to publish — it keeps README tables, CHANGELOG, templates, and CLAUDE.md skill tables in sync and notifies Slack. Documentation-only changes (README rewrites, SECURITY.md, templates) can be committed directly, but post a Slack update to `#code` after pushing.

---

## Repository Layout

```
lab-claude-skills/
  skills/                    # Shareable skills (one folder per skill)
    data-handling/SKILL.md
    r-plotting-style/SKILL.md
    ...
  .claude-plugin/            # Plugin distribution metadata
    plugin.json
  templates/                 # Starter files for new users/projects
    user-claude-md.md
    project-claude-md.md
  README.md
```

---

## Project Document Registry

### Planning Documents

| Document | Topic | Has status table? |
|----------|-------|:-:|
| [LAB_CLAUDE_SKILLS_PLAN.md](.claude/LAB_CLAUDE_SKILLS_PLAN.md) | Repo setup, distribution, and onboarding | Yes |

### Convention/Reference

| Document | Topic |
|----------|-------|
| [CLAUDE.md](.claude/CLAUDE.md) | This file — project overview and registry |

---

## Session Log
<!-- Maintained by /done. Most recent first. Keep last 5 entries. -->

### 2026-06-29 — Audit subagent execution-model overhaul + hpc Positron Tier 1/2 + weekly-audit job (dev, pending sync)
- **Plans:** None
- **Work:** Developed in `~/.claude/skills/` (NOT yet published). **Fresh-context subagent execution model across the three audit skills:** single-skill audits → a fresh **Auditor subagent** (escapes authoring-chat contamination; fat prompt); full-library/cross-doc reads stay **solo**, only *verification* fans out (gated Workflow); **never agent teams**. `audit-skills`: Execution Model section + 3 templates (auditor/refuter/completeness) + `verify-fanout.workflow.js`. `audit-script`: **read-vs-do split** (cold read delegable to a fresh Auditor; diagnostics/interaction/report-saving stay with the orchestrator) + auditor template. `audit-project`: mechanical bash pre-pass + report-only/scheduled mode. **hpc:** `positron-ssh-setup.md` restructured into **Tier 1 (basic) + Tier 2 (disconnect-proof:** salloc-in-tmux on login node, ControlPersist, round-robin, hardened ProxyCommand) + `scripts/` (cp-from-bundled install) + 5 audit fixes. **New `~/.claude/jobs/` env-aware weekly-audit job** (cluster cron auditing cluster project copies; work-since-audit trigger; report-only digest). settings.json: 3 docs domains allowlisted. All four skills verified by fresh-context subagents (dogfooded).
- **Next:**
  - **`/sync-plugin`** to publish the hpc + audit-skills + audit-script + audit-project updates to the lab repo.
  - **`/sync-cluster`** + Bouchet setup for the weekly-audit job: update the Bouchet Claude CLI, `~/.claude/jobs/weekly-audit.sh --dry-run`, confirm cluster ROOTS, install the cron (`jobs/weekly-audit.cron`).
  - Carry-over: 10 held-back new skills still pending; presentations; cell-type-* fine-tuning.

### 2026-06-15 — Sync plugin v1.9.1
- **Plans:** None
- **Work:** Published 2 skill refinements about `environment.yml` pip handling. `conda-env`: record pip-installed packages under a `pip:` subsection (`--from-history` omits them), detect via `conda list ... pypi`, reconcile rather than overwrite (copied wholesale). `done`: renamed "Conda environment export" → "drift check"; reconcile `environment.yml` against both conda + pip instead of blind overwrite — **selective merge** kept Slack/STATUS_SUMMARY/SLURM-3b content out (PI-only). CHANGELOG + plugin.json (1.9.0→1.9.1). Cluster cross-check passed (cluster just behind on the same edit). Posted to #code. Earlier same session: `/sync-cluster` pushed the same conda-env/done/sync-project + settings.json refinements to canonical `~/.claude`. Deferred per user: all 10 held-back new skills, `presentations` (separate wrap-up pending), `sync-cluster` (PI-specific repos).
- **Next:**
  - Held-back new skills still pending publish: annotation-pipeline, busco, eggnog-mapper\*, fcs-gx\*, handoff, hmmer, prost-annotation\*, sync-project, tabula-muris-gene-survey, tf-list-generation (\* = scrub `jacob.musser@yale.edu` → `<your email>` first)
  - `presentations`: finish its separate chat first, then publish — gitignore its 13 MB `_preview/` scratch dir (generated decks + external `node_modules` symlink)
  - `sync-cluster`: PI-specific (hardcoded GitHub repos) — likely never publish, or generalize first
  - cell-type-families/-tree, wgcna-cell-type pending fine-tuning; prost-gene-naming remains PI-only

### 2026-05-07 — Sync plugin v1.9.0
- **Plans:** None
- **Work:** Synced 10 updated skills + 1 updated hook + 3 new hooks. Updated skills: audit-script (Outputs trustworthy? assessment), audit-skills (single-skill mode + save-report path), cleanup-scripts (cluster `# allow-py:` override), deep-research-reports (family report type, ChatGPT Pro detection, fix_flat_yaml), done (push automatically — selective merge), hpc (Positron SSH + shared databases + Claude Code session recommendations), new-project (selective merge — no Slack), new-skill (templates/scripts/references roles), quarto-docs (cluster-aware script format), script-organization (Script Format by Environment section). Updated hook: protect-data-dir.sh (data/processed/ + provenance file allowlist). New hooks: enforce-qmd-scripts.sh (blocks numbered non-.qmd in scripts/ on local), commit-before-execute.sh (suggests commit before sbatch/quarto render), suggest-new-plan.sh (recommends /new-plan before plan mode). New EnterPlanMode hook event. New hpc/references/positron-ssh-setup.md. Held back new skills (annotation-pipeline, busco, eggnog-mapper, fcs-gx, handoff, prost-annotation, sync-cluster, sync-project, tabula-muris-gene-survey, tf-list-generation) per user decision.
- **Next:**
  - Consider publishing held-back new skills in next sync (HPC pipelines and cross-machine workflow are mature)
  - cell-type-families, cell-type-tree, wgcna-cell-type still pending fine-tuning
  - prost-gene-naming remains PI-only

### 2026-03-29 — Sync plugin v1.8.0
- **Plans:** None
- **Work:** Synced 1 new skill + 12 updated skills + cluster config templates. New: audit-skills, templates/settings-cluster.json, templates/user-claude-md-cluster.md. Renamed audit → audit-project. Updated: audit-script (simplicity philosophy), done (description only), expression-report (bundled templates/helpers), hpc (genericized + reference files), new-project (cluster/SLURM expansion, externalized templates), quarto-docs (IPython troubleshooting), script-organization (.py+.sh pairing), security-setup (HPC auto-detection), tree-formatting (accession filtering), cleanup-scripts, new-plan. Selective merges for done (no Slack/STATUS_SUMMARY) and new-project (no Slack). Added cluster cross-check step (1b) to sync-plugin. README updated with cluster setup instructions. Posted to #code.
- **Next:**
  - Publish cell-type-families, cell-type-tree, wgcna-cell-type when fine-tuning complete
  - prost-gene-naming remains PI-only (held back for improvement)
  - tabula-muris-gene-survey and prost-annotation held for next sync

### 2026-03-23 — Sync plugin v1.7.0
- **Plans:** None
- **Work:** Synced 5 updated skills to lab repo: audit-script (domain verification phase), conda-env (cluster activation, post-export hygiene), done (session numbering, sync reminder, conda export), hpc (full content sync — provenance, dual-env, interactive commands), script-organization (cluster .py format + template). Fixed README `/quarto-publish` → `/publish`. Updated README, CHANGELOG, plugin.json. Posted to #code.
- **Next:**
  - Publish cell-type-families, cell-type-tree, wgcna-cell-type when fine-tuning complete
  - prost-gene-naming remains PI-only (held back for improvement)
  - Consider publishing eggnog-mapper, prost-annotation, sync-cluster, sync-project

