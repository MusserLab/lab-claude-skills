# STATUS_SUMMARY — Lab Claude Skills
<!-- Maintained by /done skill (Claude Code) and wrapup skill (Cowork).
     Executive-assistant skills scan this file. Do not edit manually. -->

**Last worked:** 2026-08-08
**Current state:** v1.12.1 released and pushed (commit `eae2194`) — repairs five real defects in the `hpc` Positron workflow (broken ProxyCommand escaping, wrong Bouchet devel limits, `day`-partition IDE guidance, a double-allocation bug in `hold-node.sh`, single-login-node reconnect advice) plus a false README auto-update claim. Live for anyone who reinstalls; **no student announcement yet** — blocked on a clean-profile Positron update smoke test.

## Active Plans
| Plan | Status | Last updated | Next action |
|------|--------|-------------|-------------|
| LAB_CLAUDE_SKILLS_PLAN.md | Active | 2026-08-08 | Run the clean-student-profile Positron update smoke test (Phase 5 blocker), then publish update steps + announce v1.12.1 |

## People
- **Jacob owes:** Students an announcement of v1.12.1 and a working update procedure — deliberately held until the Positron smoke test passes (announcing an update people can't perform would generate support load, not fix it).
- **Waiting on:** Nothing outstanding.

## Upcoming Tasks
### NOW
- Clean-student-profile Positron update smoke test — record Positron version, OS, surface (GUI `/plugins` vs terminal), install scope, and host; blocks publishing update steps and the `#code` announcement
- `/sync-cluster` — all five cluster HPC files are behind v1.12.1; the cluster copy still carries the wrong `-p day -c 8` guidance, wrong devel limits, and the unescaped ProxyCommands

### THIS WEEK
- Decide the fate of the cluster-only container/LibreOffice section in `hpc/SKILL.md` (33 lines, deliberately deferred out of v1.12.1) — backport to personal+lab, or keep cluster-only

### SOON
- Publish held-back new skills: annotation-pipeline, busco, eggnog-mapper, fcs-gx, handoff, hmmer, prost-annotation, sync-project, tabula-muris-gene-survey, tf-list-generation (scrub PI email from the 3 SLURM-template skills first)
- Finish presentations skill's separate chat, then publish (gitignore its 13 MB `_preview/` scratch dir)
- Publish cell-type-families, cell-type-tree, wgcna-cell-type when fine-tuning complete
- Live-test the `mccleary-devel` route (shipped from documented limits only, labelled not-live-tested); Misha remains UNVERIFIED
- sync-cluster: PI-specific (hardcoded GitHub repos) — generalize or keep PI-only; prost-gene-naming remains PI-only

## Flags for Executive Assistant
- **Students on v1.12.0 have a Positron setup that cannot work as documented** — the Tier 1 ProxyCommand was broken, and the guide pointed IDE sessions at `day`, which YCRC may terminate without notice. The fix is live but **not announced**, and there is no published update procedure. Anyone who asks should be walked through updating by hand.
- Two verification harnesses (ProxyCommand escaping; 12-case `hold-node.sh`) were written and run but **deliberately not shipped** — they live only in a session scratchpad, so they will not survive. If the helper is touched again, they need rebuilding or promoting somewhere durable.

## Recent Activity
- **2026-08-08 (Claude Code):** Shipped v1.12.1 (`eae2194`) through the full `/sync-plugin` gate sequence (Gate 1 inventory → 2 apply → 3 staged preflight → 4 push) with several bounded correction passes. Fixed five genuine defects — unescaped `$(squeue …)` in every Tier 1 ProxyCommand (expanded on the laptop, so the remote command became `nc  22`), wrong Bouchet `devel` limits, `day`-partition IDE guidance against YCRC policy, a `hold-node.sh` double-allocation bug (PENDING jobs invisible; `| head -1` swallowed squeue's exit status), and reconnect advice that assumed one login node — plus corrected the README's false auto-update claim. Added `mccleary-devel` (documented limits, not live-tested), marked Misha UNVERIFIED, and demoted the `/tmp` server-install trick to an optional Bouchet-only workaround behind a fail-closed preflight.
- **2026-06-29 (Claude Code):** Built the fresh-context subagent execution model across the three audit skills (single-skill → fresh Auditor subagent; cross-doc → solo read + gated verification fan-out; never agent teams) with auditor/refuter/completeness templates + a verify-fanout workflow. Restructured hpc Positron setup into Tier 1/2 (disconnect-proof salloc-in-tmux) + helper scripts; 5 audit fixes. Built an env-aware weekly-audit cron job (cluster-side, work-since-audit, report-only digest). All dev in `~/.claude`, pending `/sync-plugin` + `/sync-cluster`.
- **2026-06-15 (Claude Code):** Synced plugin v1.9.1: conda-env + done refinements for `environment.yml` pip handling (record/reconcile pip installs; done renamed export→drift check via selective merge keeping PI-only Slack/STATUS_SUMMARY out). Same session: `/sync-cluster` pushed the same refinements to canonical `~/.claude`. Deferred 10 held-back new skills + presentations + sync-cluster. Posted to #code.
- **2026-03-23 (Claude Code):** Synced plugin v1.7.0: 5 updated skills (audit-script domain verification, conda-env cluster patterns, done session numbering, hpc full sync, script-organization .py templates). Fixed README skill name. Also simplified personal Bash permissions (Bash(*) — PI-only, not synced). Posted to #code.
- **2026-03-21 (Claude Code):** Synced plugin v1.6.0: 3 new skills (cleanup-scripts, expression-report, hpc), 11 updated skills. Selective merges for done and new-project (Slack excluded). Posted to #code.
