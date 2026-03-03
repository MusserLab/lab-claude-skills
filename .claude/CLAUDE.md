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

### 2026-02-28 — README update instructions, Slack format
- **Plans:** None
- **Work:** Updated README plugin update section to note marketplace auto-updates on restart (manual CLI as fallback). Posted proper v1.3.2 security follow-up to #code. Established two Slack message format templates (security vs normal) in MEMORY.md.
- **Next:**
  - Verify marketplace auto-update actually works for students on next plugin version bump
  - Consider whether Windows plugin update path (no GUI update button) needs separate documentation