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

### 2026-08-08 — Sync plugin v1.12.1: hpc Positron/devel repair (full 4-gate release)
- **Plans:** `LAB_CLAUDE_SKILLS_PLAN.md` (Phase 5 onboarding — README accuracy)
- **Work:** Shipped **v1.12.1** (commit `eae2194`, pushed) via the full `/sync-plugin` gate sequence — Gate 1 inventory → Gate 2 apply → Gate 3 staged preflight → Gate 4 push, with several bounded correction passes between gates. **Five real defects fixed, not just doc polish:** (1) every Tier 1 direct-`squeue` `ProxyCommand` shipped in v1.12.0 used an **unescaped `$(squeue …)`**, which the *laptop* expands — `squeue` doesn't exist there, so the remote command collapsed to `nc  22`; now `\$(squeue …)`. (2) `references/partitions.md` had the **wrong Bouchet `devel` limits** (claimed 8 CPUs/120 GiB → actually 4 CPUs/60 GiB, max 2 submitted jobs, aggregate per user). (3) `SKILL.md` recommended `salloc -p day -c 8` for IDE sessions — YCRC says VS Code jobs outside devel **may be terminated without notice**; now `devel`-only with a per-cluster limits table. (4) `scripts/hold-node.sh` could **double-allocate on reconnect** (only checked `-t RUNNING`, so a PENDING same-name job was invisible; `| head -1` also swallowed squeue's exit status) — now one lookup with explicit `PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING`, fail-closed on squeue error, rejects caller `-J`/`--job-name` overrides, and exits instead of opening a stale management shell. (5) reconnection advice assumed **one login node**; there are two and tmux is login-node-local — now one consolidated rule with all five reconnect outcomes. Also: `mccleary-devel` route (documented limits, **not live-tested**), Misha marked UNVERIFIED, `/tmp` server-install trick demoted to an optional Bouchet-only workaround behind a fail-closed preflight on a dedicated `bouchet-devel-tmp` target, and the **README's false "auto-updates on restart" claim** corrected. Two external test harnesses (ProxyCommand escaping, 12-case hold-node) were **run but deliberately not published** — kept in scratchpad.
- **Next:**
  - **Clean-student-profile Positron smoke test** — blocks publishing update instructions as tested and blocks the `#code` student announcement (the release itself is already live).
  - **`/sync-cluster`** — all five cluster HPC files are behind; cluster `SKILL.md` still has the wrong `-p day -c 8` guidance, the wrong devel limits, the unescaped ProxyCommands, and the cluster-only container/LibreOffice section (33 lines) deliberately deferred out of this release.
  - Carry-over: 10 held-back new skills; `presentations`; cell-type-* fine-tuning.

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
