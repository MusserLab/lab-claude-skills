# STATUS_SUMMARY — Lab Claude Skills
<!-- Maintained by /done skill (Claude Code) and wrapup skill (Cowork).
     Chief-of-staff skills scan this file. Do not edit manually. -->

**Last worked:** 2026-03-06
**Current state:** Plugin v1.4.0 published with 2 new scRNAseq annotation skills, 3 convention updates, and scientific-manuscript removed (PI-only). Marketplace auto-update should remove scientific-manuscript from student installs on restart.

## Active Plans
| Plan | Status | Last updated | Next action |
|------|--------|-------------|-------------|
| LAB_CLAUDE_SKILLS_PLAN.md | Active | 2026-03-06 | Verify marketplace auto-update removes scientific-manuscript and delivers new skills |

## People
- **Jacob owes:** Nothing outstanding
- **Waiting on:** Student confirmation that v1.4.0 auto-update works (new skills appear, scientific-manuscript removed)

## Upcoming Tasks
### NOW
- Nothing urgent

### THIS WEEK
- Verify marketplace auto-update delivers v1.4.0 correctly

### SOON
- Publish `prost-gene-naming` skill (held back for improvement)
- Update sync-plugin skill to use Read+Write instead of cp for cross-directory copies
- Consider adding Slack integration to student-facing plugin (currently PI-only)

## Flags for Executive Assistant
No flags.

## Recent Activity
- **2026-03-06 (Claude Code):** Synced plugin v1.4.0: added deep-research-genelist and deep-research-reports skills, updated git-conventions/new-plan/quarto-docs, removed scientific-manuscript (PI-only). Diagnosed Bash sandbox CWD restriction. Posted to #code.
- **2026-02-28 (Claude Code):** Updated README plugin update instructions to note marketplace auto-updates. Posted proper security follow-up to #code for v1.3.2. Established Slack message format templates in MEMORY.md.
- **2026-02-28 (Claude Code):** Fixed bash hook grep for pipe patterns, simplified Windows checklist from 6 to 4 steps, fixed duplicate hooks registration in plugin.json (v1.3.2).
