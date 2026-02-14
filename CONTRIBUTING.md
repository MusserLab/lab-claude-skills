# Contributing to Lab Claude Skills

This repo is collaboratively maintained by the lab. Everyone is encouraged to propose new skills, improve existing ones, and share what they've learned about working with Claude Code.

## How skills work

A skill is a folder containing a `SKILL.md` file (and optionally reference files). The `SKILL.md` has:

1. **YAML frontmatter** — metadata that controls when Claude loads the skill
2. **Markdown body** — instructions, examples, and conventions

```yaml
---
name: my-skill
description: Brief description. Use when [trigger conditions].
user-invocable: false    # true if it's a slash command like /done
---

# Skill Title

Instructions for Claude go here...
```

### Key fields

- **`name`**: Short identifier (matches folder name)
- **`description`**: Tells Claude WHEN to load this skill. Be specific about trigger conditions.
- **`user-invocable`**: Set to `true` if the skill is triggered by typing `/skill-name` (a slash command). Set to `false` if it should load automatically based on context.

### Auto-loading vs slash commands

- **Auto-loading skills** (`user-invocable: false`): Claude reads the `description` field and loads the skill when the conversation matches. Example: `data-handling` loads when writing analysis code.
- **Slash commands** (`user-invocable: true`): The user explicitly types `/skill-name` to invoke it. Example: `/done` triggers end-of-session wrap-up.

## Proposing changes

### Adding a new skill

1. **Create a branch**: `git checkout -b add-skill-name`
2. **Create the folder**: `skills/skill-name/SKILL.md`
3. **Write the skill** following the format above
4. **Test it**: Install with `./install.sh skill-name` and try it in a real conversation
5. **Open a PR** with:
   - What the skill does
   - When it triggers
   - Example of Claude using it correctly

### Improving an existing skill

1. **Create a branch**: `git checkout -b improve-skill-name`
2. **Edit the SKILL.md**
3. **Test the change** in a real conversation
4. **Open a PR** describing what changed and why

### Reporting issues

If a skill gives Claude bad instructions or doesn't trigger when it should:

1. Open a GitHub Issue
2. Include: which skill, what happened, what you expected
3. If possible, paste the relevant part of your Claude Code conversation

## Writing good skills

### Do

- **Be specific** — Concrete examples are better than abstract rules
- **Show both right and wrong** — `# CORRECT` and `# WRONG` patterns help Claude distinguish
- **Include code examples** — In both R and Python if the skill applies to both
- **Keep it focused** — One skill per topic. If it's getting long, split it.
- **Test with Claude** — The real test is whether Claude follows the instructions correctly

### Don't

- **Don't duplicate** — Check if an existing skill already covers your topic
- **Don't include personal paths** — Use `~/miniconda3` not `/Users/yourname/miniconda3`
- **Don't add project-specific content** — Project-specific skills belong in the project's `.claude/skills/`, not here
- **Don't make it too long** — Claude has limited context. Be concise.

## Skill ideas we'd love

If you find yourself repeatedly correcting Claude about something, that's a skill waiting to be written. Some ideas:

- Specific statistical methods (DESeq2 workflow, limma best practices)
- Lab-specific data formats or naming conventions
- Bioinformatics tool usage patterns
- Paper writing conventions beyond the existing manuscript skill
- Presentation or poster design conventions

## Testing your changes

After editing a skill:

1. Make sure it's installed: `./install.sh --status`
2. Start a new Claude Code conversation (skills load at conversation start)
3. Do something that should trigger the skill
4. Check that Claude follows the updated instructions

Since skills are symlinked, your edits are immediately live — no reinstall needed.