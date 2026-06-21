# STATUS_SUMMARY — Lab Claude Skills
<!-- Maintained by /done skill (Claude Code) and wrapup skill (Cowork).
     Executive-assistant skills scan this file. Do not edit manually. -->

**Last worked:** 2026-06-15
**Current state:** Plugin v1.9.1 published — conda-env + done refinements for `environment.yml` pip handling. A batch of 10 mature new skills (HPC pipelines + cross-machine workflow) remains held back pending a decision to publish.

## Active Plans
| Plan | Status | Last updated | Next action |
|------|--------|-------------|-------------|
| LAB_CLAUDE_SKILLS_PLAN.md | Active | 2026-06-15 | Decide whether to publish the 10 held-back new skills |

## People
- **Jacob owes:** Nothing outstanding
- **Waiting on:** Nothing outstanding

## Upcoming Tasks
### NOW
- Nothing urgent

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
- **2026-06-15 (Claude Code):** Synced plugin v1.9.1: conda-env + done refinements for `environment.yml` pip handling (record/reconcile pip installs; done renamed export→drift check via selective merge keeping PI-only Slack/STATUS_SUMMARY out). Same session: `/sync-cluster` pushed the same refinements to canonical `~/.claude`. Deferred 10 held-back new skills + presentations + sync-cluster. Posted to #code.
- **2026-03-23 (Claude Code):** Synced plugin v1.7.0: 5 updated skills (audit-script domain verification, conda-env cluster patterns, done session numbering, hpc full sync, script-organization .py templates). Fixed README skill name. Also simplified personal Bash permissions (Bash(*) — PI-only, not synced). Posted to #code.
- **2026-03-21 (Claude Code):** Synced plugin v1.6.0: 3 new skills (cleanup-scripts, expression-report, hpc), 11 updated skills. Selective merges for done and new-project (Slack excluded). Posted to #code.
- **2026-03-12 (Claude Code):** Synced plugin v1.5.0: added audit-script and learn-code skills, updated deep-research-genelist (family-aware mode) and deep-research-reports (family-aware support). Posted to #code.
- **2026-03-06 (Claude Code):** Synced plugin v1.4.0: added deep-research-genelist and deep-research-reports skills, updated git-conventions/new-plan/quarto-docs, removed scientific-manuscript (PI-only). Diagnosed Bash sandbox CWD restriction. Posted to #code.
