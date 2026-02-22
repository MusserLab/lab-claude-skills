<!-- project-type: general -->
<!-- slack-channel: #code -->
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