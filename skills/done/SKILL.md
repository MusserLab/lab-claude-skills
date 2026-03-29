---
name: done
description: >
  Use when ending a session, wrapping up work, or when the user says "done", "wrap up",
  "let's commit", or "end of session". Summarizes work, updates docs, and commits.
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

## 0b. Load Project Extensions

Check if `.claude/done_extensions.md` exists in the project root. If it does, read it
and incorporate its steps into the wrap-up at the points it specifies (e.g., "run after
Step 2" or "run before Step 4"). Extension steps are additional — they never replace
core steps.

If no extension file exists, skip silently.

---

## 1. Summarize Work and Decisions

Briefly list what was completed this session:
- Scripts created or modified
- Data files created or modified
- Documentation changes
- Key analytical or design decisions made

---

## 1b. Update Session Log in Project CLAUDE.md

Append a new entry to the **Session Log** section at the bottom of the project's `.claude/CLAUDE.md`. This is a rolling log of the last 5 sessions — it's the primary place future sessions look for "what to do next."

### Format

```markdown
## Session Log
<!-- Maintained by /done. Most recent first. Keep last 5 entries. -->

### YYYY-MM-DD — Short title
- **Plans:** [plan name(s) worked on, or "None"]
- **Work:** [1-2 sentences on what was done]
- **Next:** [bullet list of follow-up items for future sessions]
```

### Rules

- **Most recent first** — new entry goes at the top of the list
- **Same-day updates** — if an entry for today's date already exists (from an earlier `/done` run in this session), **replace it** rather than adding a duplicate. Merge the work descriptions and update the Next items. This allows `/done` to be run multiple times per session without cluttering the log.
- **Trim to 5 entries** — delete the oldest entry if there are more than 5
- **Short title** should disambiguate from parallel sessions (e.g., "Metadata exploration", "WGCNA figures", "Environment setup")
- **Same-day session numbering** — when multiple sessions occur on the same date, number them: `### 2026-03-22 (session 1) — Title`, `### 2026-03-22 (session 2) — Title`, etc. This makes the log scannable when intensive work produces multiple sessions per day. The number reflects chronological order within that day.
- **Plans line** — list which planning documents were worked on (e.g., "`figure_plan.md`"). Write "None" if no plans were involved. This helps track work that falls outside of plans.
- **Next items** — these are the main value. Be specific and actionable. They accumulate across sessions until actually done — don't repeat items already listed in a recent entry unless context changed.
- If the Session Log section doesn't exist yet, create it at the bottom of the file (before any closing comments).

---

## 2. Update Relevant Planning Documents

Only update planning documents **directly relevant to this session's work**. Do NOT read all registered documents — identify the 1-2 that matter from session context.

For each relevant planning document:

**a. Status tables** — Mark completed phases/tasks. Add new phases if needed. When a phase is marked complete, collapse its detailed content to a 3-5 line summary (what was done, key outcomes). Before collapsing, ensure any forward-looking information needed by future phases is already captured elsewhere in the plan.

**b. Script and file tracking** — Add new scripts, mark replaced ones as legacy, update modified entries.

**c. Task lists** — Check/uncheck items as appropriate.

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

### CHANGELOG.md

If the project has a `CHANGELOG.md` in its root directory:
- Review what was done this session
- Propose a changelog entry under today's date, using the existing format (Added/Changed/Fixed/Removed sections as appropriate)
- If today's date already has an entry, append to it rather than creating a duplicate
- Show proposed changes before editing
- If no `CHANGELOG.md` exists, skip silently — do not suggest creating one

---

## 4. Git Commit

### Project repository

Run `git status` to check for uncommitted changes.

If there are changes:
- **CRITICAL: Always stage specific files by name (`git add file1 file2`), NEVER use `git add .` or `git add -A` for the project repo** — broad staging will pick up changes from parallel Claude Code sessions
- **CRITICAL: Only include files actually created or modified during THIS session**
- **Identifying session files** — use multiple sources, not just git diff:
  1. **Conversation context** is the primary record of what you did — including
     compacted/summarized earlier portions of the conversation
  2. **Git diff** (initial gitStatus vs current `git status`) is a cross-check — files
     appearing in current but not initial are *candidates* but not certainties
  3. **Parallel conversations can create files** — another Claude Code session running
     simultaneously may have added files that show up in your git diff but were NOT
     created by this conversation
  4. **When uncertain about a file's origin, ask the user** — do not silently include
     or exclude files you can't account for from conversation context
- Files already in initial gitStatus should NOT be included unless you worked on them
- Show the user session-relevant files and suggest a commit message
- If approved, commit only those files
- After committing, offer to push to remote (check `git remote -v` to confirm a remote exists)

### User config (`~/.claude`)

Check for uncommitted changes:
```bash
git -C ~/.claude status --short
```

If there are changes (skills, CLAUDE.md, etc.):
- Show what changed
- Ask if user wants to commit and push
- If yes, run these as separate sequential Bash calls (do NOT chain with `&&`):
  1. `git -C ~/.claude add -A`
  2. `git -C ~/.claude commit -m "Title" -m "Co-Authored-By: Claude <noreply@anthropic.com>"` (use multiple `-m` flags, NOT heredocs)
  3. `git -C ~/.claude push`

**Skill registration check:** If new skills were created in `~/.claude/skills/` this session, verify each appears in the Available Skills table in `~/.claude/CLAUDE.md`. If any are missing, add them before committing.

**Sync reminder:** After committing, check if `~/.claude/.sync-canonical/` exists (indicates a two-repo sync setup). If it does, compare the cluster repo HEAD against the canonical staging HEAD. If they differ:
> "You have changes in `~/.claude` that haven't been synced to canonical. Run `/sync-cluster` now to review and push them."
If on the cluster, offer to run it immediately. If on macOS (canonical machine), remind the user to run `/sync-cluster` on the cluster next time they're there — macOS mode only pulls, it can't push cluster changes to canonical.
Do NOT run `/sync-cluster` automatically — it's an interactive skill that requires decisions about what to push/modify/skip.

### Conditional: Conda environment export [Data Science only]

Only if conda packages were installed or updated during this session:

1. Check if the active conda env matches `environment.yml`:
   ```bash
   conda env export --from-history
   ```
2. Compare against the current `environment.yml`. If they differ (new packages, removed
   packages, version changes), ask: "Conda environment has changed. Export to
   environment.yml?"
3. If yes, export and clean up:
   ```bash
   conda env export --from-history > environment.yml
   ```
4. **Post-export hygiene** — automatically fix these in the exported file:
   - **Remove `prefix:` line** — machine-specific absolute path, not portable
   - **Remove `defaults` from channels** — conflicts with bioconda strict channel priority
   - Verify `conda-forge` is listed as a channel
5. Include updated `environment.yml` in the commit.

Use `--from-history` (not bare `conda env export`) so only explicitly installed packages
are recorded, not platform-specific transitive dependencies.

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
