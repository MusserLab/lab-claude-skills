---
name: done
description: End of session wrap-up - summarize work, update docs, and commit
user-invocable: true
---

# End of Session Wrap-up

When the user invokes `/done`, perform these end-of-session tasks in order.

---

## 0. Detect Project Type

Check the project's `.claude/CLAUDE.md` for a `project-type:` field:

- **`data-science`** — Full wrap-up including all steps
- **`general`** (or no field found) — Skip steps marked **[Data Science only]**

If no field exists, infer: `renv.lock`, `outs/`, or numbered `XX_*.qmd` scripts → data science. Otherwise → general.

---

## 1. Summarize Work and Decisions

Briefly list what was completed this session:
- Scripts created or modified
- Data files created or modified
- Documentation changes
- Key analytical or design decisions made (data classification rules, filtering choices, naming conventions, thresholds, edge case handling)

These decisions will be recorded in planning documents in the next step.

---

## 2. Update Relevant Planning Documents

Only update planning documents **directly relevant to this session's work**. Do NOT read all registered documents — identify the 1-2 that matter from session context.

For each relevant planning document:

**a. Status tables** — Mark completed phases/tasks. Add new phases if needed.

**b. Decision logs** — Record analytical decisions from Step 1. Each entry: date, topic, issue, decision, rationale.

**c. Script and file tracking** — Add new scripts, mark replaced ones as legacy, update modified entries.

**d. Task lists** — Check/uncheck items as appropriate.

Show proposed changes before editing.

### Also check Claude Code plan files

If a plan file from plan mode exists in `~/.claude/plans/` and is relevant:
- Update status tables, file tracking, task checklists
- If it contains significant multi-session tracking, suggest promoting to a registered `.claude/` document

---

## 3. Update Project Documentation (if needed)

Only do these checks if the session actually changed something relevant. Skip silently otherwise.

### Canonical Data Files Registry [Data Science only]

If canonical data files were created, replaced, or had format changes:
- Update CURRENT/Legacy status entries
- Add new files that should be tracked
- Show proposed changes before editing

### Project CLAUDE.md

If new conventions, gotchas, or important patterns were discovered this session, propose additions. Only record things that are **surprising or counter-default** — skip anything Claude would infer from the codebase.

### MEMORY.md

If reusable lessons or gotchas were discovered, or existing entries proved wrong/outdated, propose updates. Keep under 200 lines.

### New `.claude/*.md` files

If new `.claude/*.md` files were created this session, add them to the Project Document Registry.

---

## 4. Git Commit

### Project repository

Run `git status` to check for uncommitted changes.

If there are changes:
- **CRITICAL: Only include files actually created or modified during THIS session**
- Cross-reference git status against what you did in the conversation
- Files already modified at session start (visible in initial gitStatus context) should NOT be included unless you worked on them
- Show the user session-relevant files and suggest a commit message
- If approved, commit only those files

### User config (`~/.claude`)

Check for uncommitted changes:
```bash
git -C ~/.claude status --short
```

If there are changes (skills, CLAUDE.md, etc.):
- Show what changed
- Ask if user wants to commit and push
- If yes: `git -C ~/.claude add -A && git -C ~/.claude commit -m "message" && git -C ~/.claude push`

### Conditional: renv snapshot [Data Science only]

Only if R packages were installed or updated during this session:
```bash
Rscript -e "renv::status()" 2>/dev/null
```
If out of sync, ask about `renv::snapshot()`. Include updated `renv.lock` in the commit.

### Conditional: Quarto publish

Check if this is a publishable Quarto project (all three must be true):
1. `_quarto.yml` exists
2. It's a book or website (`type: book` or `type: website`)
3. `gh-pages` branch exists

If yes, ask: "This is a Quarto book/website with GitHub Pages. Publish now?"

Do NOT offer for regular `.qmd` analysis scripts, projects without `gh-pages`, or `type: default`.

---

## 5. Final Summary

Brief "Session complete" message listing:
- Files created/modified
- Commits made
- Planning documents updated
- Any follow-up items for next session
