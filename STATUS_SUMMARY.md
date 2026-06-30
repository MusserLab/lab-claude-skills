# STATUS_SUMMARY — Lab Claude Skills
<!-- Maintained by /done skill (Claude Code) and wrapup skill (Cowork).
     Executive-assistant skills scan this file. Do not edit manually. -->

**Last worked:** 2026-06-29
**Current state:** Dev complete in `~/.claude/skills/` (pending `/sync-plugin`): fresh-context subagent execution-model overhaul across audit-skills/-script/-project, hpc Tier 1/2 Positron restructure + scripts, and a new env-aware weekly-audit cron job. 10 mature new skills still held back.

## Active Plans
| Plan | Status | Last updated | Next action |
|------|--------|-------------|-------------|
| LAB_CLAUDE_SKILLS_PLAN.md | Active | 2026-06-29 | /sync-plugin the hpc + 3 audit-skill updates; then decide on the 10 held-back skills |

## People
- **Jacob owes:** Nothing outstanding
- **Waiting on:** Nothing outstanding

## Upcoming Tasks
### NOW
- `/sync-plugin` the hpc + audit-skills/-script/-project updates (dev done this session)

### THIS WEEK
- Nothing urgent

### SOON
- Publish held-back new skills: annotation-pipeline, busco, eggnog-mapper, fcs-gx, handoff, hmmer, prost-annotation, sync-project, tabula-muris-gene-survey, tf-list-generation (scrub PI email from the 3 SLURM-template skills first)
- Finish presentations skill's separate chat, then publish (gitignore its 13 MB `_preview/` scratch dir)
- Publish cell-type-families, cell-type-tree, wgcna-cell-type when fine-tuning complete
- sync-cluster: PI-specific (hardcoded GitHub repos) — generalize or keep PI-only; prost-gene-naming remains PI-only

## Flags for Executive Assistant
No flags.

## Recent Activity
- **2026-06-29 (Claude Code):** Built the fresh-context subagent execution model across the three audit skills (single-skill → fresh Auditor subagent; cross-doc → solo read + gated verification fan-out; never agent teams) with auditor/refuter/completeness templates + a verify-fanout workflow. Restructured hpc Positron setup into Tier 1/2 (disconnect-proof salloc-in-tmux) + helper scripts; 5 audit fixes. Built an env-aware weekly-audit cron job (cluster-side, work-since-audit, report-only digest). All dev in `~/.claude`, pending `/sync-plugin` + `/sync-cluster`.
- **2026-06-15 (Claude Code):** Synced plugin v1.9.1: conda-env + done refinements for `environment.yml` pip handling (record/reconcile pip installs; done renamed export→drift check via selective merge keeping PI-only Slack/STATUS_SUMMARY out). Same session: `/sync-cluster` pushed the same refinements to canonical `~/.claude`. Deferred 10 held-back new skills + presentations + sync-cluster. Posted to #code.
- **2026-03-23 (Claude Code):** Synced plugin v1.7.0: 5 updated skills (audit-script domain verification, conda-env cluster patterns, done session numbering, hpc full sync, script-organization .py templates). Fixed README skill name. Also simplified personal Bash permissions (Bash(*) — PI-only, not synced). Posted to #code.
- **2026-03-21 (Claude Code):** Synced plugin v1.6.0: 3 new skills (cleanup-scripts, expression-report, hpc), 11 updated skills. Selective merges for done and new-project (Slack excluded). Posted to #code.
- **2026-03-12 (Claude Code):** Synced plugin v1.5.0: added audit-script and learn-code skills, updated deep-research-genelist (family-aware mode) and deep-research-reports (family-aware support). Posted to #code.