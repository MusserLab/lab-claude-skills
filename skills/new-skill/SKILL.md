---
name: new-skill
description: >
  Create a new Claude Code skill with proper structure and effective description.
  Use when creating a new skill, or when the /done skill proposes a new skill
  and the user approves. Also use when refactoring CLAUDE.md content into a skill.
user-invocable: false
---

# Creating a New Skill

Follow these steps when creating a new skill, whether proposed during `/done` or requested directly.

---

## 1. Confirm Scope

Before creating, verify the pattern actually warrants a skill (not just a CLAUDE.md entry):

- **Too detailed for CLAUDE.md** — needs code examples, decision trees, or multi-section docs
- **Reusable across sessions** — will be needed repeatedly
- **Complex enough to get wrong** — without it, Claude might make mistakes or ask the same questions each session

If it's a simple one-liner convention, put it in the project CLAUDE.md instead.

---

## 2. Determine Level

Ask the user if not already decided:

- **Project-level** (`{project}/.claude/skills/{name}/SKILL.md`) — Specific to one project. Examples: gene naming conventions, project-specific data formats, project-specific workflows.
- **User-level** (`~/.claude/skills/{name}/SKILL.md`) — Applies across multiple projects. Examples: plotting conventions, environment management, export formats.

---

## 3. Write an Effective Description

The `description` field in YAML frontmatter is the **single most important part** of a skill — it determines whether the skill gets activated. Follow these rules:

### Front-load trigger conditions
The first sentence should say WHEN to use the skill, not just WHAT it does.

```yaml
# BAD — describes what, not when:
description: R ggplot2 plotting conventions and theme.

# GOOD — front-loads triggers:
description: R ggplot2 plotting conventions and theme. Use when creating, modifying, or styling ggplot2 plots in R, or when adjusting plot themes, colors, labels, or formatting.
```

### List concrete triggers
Be specific about what actions or contexts should activate the skill. Use verbs: "creating", "modifying", "saving", "debugging", "exporting".

```yaml
# BAD — too vague:
description: Use when working with files.

# GOOD — specific actions:
description: Use when overwriting existing files, deleting files, or writing to directories that contain important data (data/, outs/).
```

### Add explicit exclusions when needed
If the skill could be confused with similar skills, add "Do NOT load for" clauses.

```yaml
description: >
  Quarto document conventions for data science analysis scripts (.qmd).
  Use when creating or rendering .qmd analysis scripts in data science projects.
  Do NOT load for Quarto books, websites, or documentation projects.
```

### Cover edge cases in triggers
Think about variations of the task that should also trigger the skill:

| Core trigger | Edge cases to include |
|---|---|
| "creating plots" | modifying, styling, fixing, adjusting themes |
| "saving figures" | choosing formats, setting DPI, export dimensions |
| "committing changes" | writing commit messages, creating branches, making PRs |

### Keep it scannable
The description should be 1-3 sentences. If it needs more, use the multi-line `>` YAML syntax. Put the most important trigger first.

---

## 4. YAML Frontmatter Template

```yaml
---
name: skill-name
description: >
  One-sentence summary of what the skill covers.
  Use when [specific trigger 1], [specific trigger 2], or [specific trigger 3].
  Do NOT load for [exclusion 1] or [exclusion 2].
user-invocable: false
---
```

**Fields:**
- `name` — kebab-case, matches the directory name
- `description` — trigger-focused (see rules above)
- `user-invocable` — `true` only if the user triggers it with `/name` (like `/done`, `/publish`). Most skills are `false` (auto-loaded based on context).

---

## 5. Skill Content Structure

After the frontmatter, organize the skill body:

1. **Title** — `# Skill Name`
2. **Context/purpose** — 1-2 sentences on why this skill exists
3. **Rules/conventions** — The actual content, organized with `##` sections
4. **Code examples** — When patterns need to be shown, include both R and Python if applicable
5. **Common mistakes** — What goes wrong without this skill (helps justify its existence)

Keep it focused. A skill should cover one coherent topic, not be a grab-bag.

---

## 6. File Workflow

1. Create/edit in `~/.claude/skills/{name}/SKILL.md`
2. Use generic paths (e.g., `~/miniconda3`, not `/Users/<username>/miniconda3`) so skills are portable
3. Do **not** automatically copy to the lab repo — skills are published through a separate sync workflow

### Skills with Bundled Resources

For skills that generate scripts (code-generating pipelines), use the Anthropic skill-creator
convention for bundled resources:

```
skill-name/
├── SKILL.md              # <500 lines — workflow, decision points
├── scripts/              # Helper code deployed to project python/ or R/
│   └── my_helpers.py
└── references/           # Detailed docs loaded as needed
    └── method_notes.md
```

**Helper deployment convention:** When the skill runs:
1. Check if `python/` or `R/` dir exists in the project, create if needed
2. Check if the helper file already exists in the project
3. If it exists and differs, warn the user and ask whether to overwrite
4. If it doesn't exist, copy from the skill's `scripts/` directory
5. The generated `.qmd` imports from the project-level location

This keeps helper code as real, testable files rather than code blocks in SKILL.md.
SKILL.md references the helpers and describes how the generated script uses them.

---

## 7. Register in User CLAUDE.md

After creating a new user-level skill, add it to the appropriate table in `~/.claude/CLAUDE.md` under "Available Skills":

- **General skills** table — if it applies to all project types
- **Data Science skills** table — if it only applies to data science projects

Project-level skills don't need registration in the user CLAUDE.md — they're discovered automatically from the project's `.claude/skills/` directory.
