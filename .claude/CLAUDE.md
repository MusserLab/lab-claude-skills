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

### 2026-03-12 — Sync plugin v1.5.0
- **Plans:** None
- **Work:** Synced 4 changes to lab repo: new `audit-script` and `learn-code` skills, updated `deep-research-genelist` (family-aware mode) and `deep-research-reports` (family-aware support). Updated README, user-claude-md template, CHANGELOG, plugin.json. Posted to #code.
- **Next:**
  - Publish `prost-gene-naming` when ready (held back for improvement)
  - Update sync-plugin skill to use Read+Write instead of cp for cross-directory copies

### 2026-03-06 — Sync plugin v1.4.0
- **Plans:** None
- **Work:** Synced 5 skill changes to lab repo: new `deep-research-genelist` and `deep-research-reports` skills, updated `git-conventions` (commit format), `new-plan` (Key Decisions/Working Notes), `quarto-docs` (AI Attribution + Troubleshooting). Removed `scientific-manuscript` (now PI-only). Updated README, templates, CHANGELOG, plugin.json. Diagnosed Bash sandbox behavior (file ops restricted to CWD; use Read/Write tools for cross-directory copies).
- **Next:**
  - Publish `prost-gene-naming` when ready (held back for improvement)
  - Verify marketplace auto-update removes scientific-manuscript for students
  - Update sync-plugin skill to use Read+Write instead of cp for cross-directory copies

### 2026-03-06 — Settings hardening from colleague comparison
- **Plans:** None
- **Work:** Compared colleague's McCleary HPC settings.json with personal config. Researched experimental env vars (agent teams, additional dirs CLAUDE.md, tool search). Added network/system deny rules (ssh, nc, nmap, telnet, crontab, nohup, dd, shutdown, reboot) and CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC env var to personal settings.json.
- **Next:**
  - Verify marketplace auto-update actually works for students on next plugin version bump
  - Consider whether Windows plugin update path (no GUI update button) needs separate documentation

### 2026-02-28 — README update instructions, Slack format
- **Plans:** None
- **Work:** Updated README plugin update section to note marketplace auto-updates on restart (manual CLI as fallback). Posted proper v1.3.2 security follow-up to #code. Established two Slack message format templates (security vs normal) in MEMORY.md.
- **Next:**
  - Verify marketplace auto-update actually works for students on next plugin version bump
  - Consider whether Windows plugin update path (no GUI update button) needs separate documentation