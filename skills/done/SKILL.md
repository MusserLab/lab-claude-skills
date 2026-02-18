---
name: done
description: End of session wrap-up - summarize work, update docs, and commit
user-invocable: true
---

# End of Session Wrap-up

When the user invokes `/done`, perform these end-of-session tasks in order. Each step should be completed before moving to the next.

---

## 0. Detect Project Type

Before starting the wrap-up, determine the project type by checking the project's `.claude/CLAUDE.md` for a `project-type:` field:

- **`project-type: data-science`** — Full wrap-up including all steps
- **`project-type: general`** (or no field found) — Skip steps marked **[Data Science only]**

If no `project-type:` field exists, infer from signals:
- `renv.lock` exists, `outs/` directory exists, or numbered `XX_*.qmd` scripts → treat as data science
- Otherwise → treat as general

Steps marked **[Data Science only]** should be silently skipped for general projects.

---

## 1. Summarize What Was Accomplished

Briefly list what was completed this session, organized by category:
- Scripts created or modified
- Data files created or modified
- Documentation changes
- Analytical decisions made

---

## 2. Session Decision Summary

Before updating any documents, explicitly list all **analytical and design decisions** made during this session. These are decisions the user participated in or should have participated in (per the "Surface Analysis Decisions" rule in user CLAUDE.md).

Examples of decisions to capture:
- Data classification rules (e.g., "catch-all defaults assigned to category X")
- Filtering choices (e.g., "restricted to Plot_Module == TRUE")
- Naming conventions (e.g., "merged Exocytosis + Post-synaptic scaffold → Synaptic")
- Thresholds or cutoffs applied
- How edge cases or ambiguous data were handled

These decisions will be recorded in the appropriate planning document decision logs in the next step.

---

## 3. Check Registered Project Documents

The project's `.claude/CLAUDE.md` should contain a **Project Document Registry** section listing all `.claude/*.md` documents organized by category (planning, data, convention/reference).

### How to check

1. Read the project's `.claude/CLAUDE.md` and find the "Project Document Registry" section
2. For each **planning document** in the registry, determine if this session's work is relevant to that document's topic. If yes, read the document and check:

   **a. Status tables** — Mark phases/tasks as complete if they were finished this session. Add new phases if work was done that isn't covered by existing phases.

   **b. Decision logs** — Add entries for analytical decisions from Step 2 that belong in this planning document. Each entry should have: date, gene/topic, issue, decision, rationale.

   **c. Script and file tracking** — Planning documents are the **authoritative source** for which scripts and data files are active vs legacy. For each planning document relevant to this session's work:
   - **Add new scripts** created this session to the appropriate table (with status: Active)
   - **Mark replaced scripts as legacy/inactive** — if a new script supersedes an old one, update the old entry's status and note what replaced it
   - **Update existing entries** if scripts were modified (e.g., bug fixes, normalization changes)
   - Ensure the planning doc clearly distinguishes active scripts from inactive/legacy ones (e.g., via an "Active Scripts" table or status column)

   **d. Task lists** — Check/uncheck task items as appropriate.

   Show the user proposed changes before making edits.

3. For each **data document** in the registry:
   - If this session created new data files, added new columns, or changed data formats relevant to that document, flag it
   - Propose updates if needed (e.g., new column descriptions, updated file paths)

4. For the **convention/reference** document (CLAUDE.md itself):
   - If new conventions, gotchas, or important patterns were discovered, propose additions
   - Check if the Plotting Pipeline table, Repository Layout, or other reference sections need updating (e.g., new scripts not listed)

### If no registry exists

Fall back to scanning `.claude/` for any `.md` files and check them manually. Suggest to the user that they add a document registry to their project CLAUDE.md.

### Also check Claude Code plan files

Claude Code's plan mode creates plan files in `~/.claude/plans/`. These are **separate** from registered planning documents but may contain task lists, status tables, and open items relevant to the current project.

1. Check if any plan file was injected into the current session context (look for "plan file exists from plan mode" in the system prompt, or check `~/.claude/plans/` for `.md` files)
2. If a plan file exists and is relevant to this project:
   - Update status tables, file tracking, and task checklists the same way you would for registered documents
   - Mark completed items, update statuses, add open items
3. If a plan file contains significant multi-session tracking, suggest promoting it to a registered planning document in the project's `.claude/` directory

---

## 4. Check Canonical Data Files Registry [Data Science only]

The project's `.claude/CLAUDE.md` may contain a **Canonical Data Files Registry** section that tracks the current authoritative version of key data files.

### How to check

1. Find the "Canonical Data Files Registry" section in the project CLAUDE.md
2. For each data type in the registry, check whether this session:
   - **Created a new version** of a canonical file (e.g., regenerated module assignments, updated gene names) — update the CURRENT entry's description if the file changed format/columns
   - **Replaced a file** with an updated version — move the old entry to Legacy, add the new file as CURRENT
   - **Added new columns or changed format** of an existing canonical file — update the description (e.g., row count, column count, new column names)
   - **Created a new data file** that should be registered — add it as a new entry
3. **Stale reference check**: If a canonical file was updated or replaced, identify which existing scripts still reference the old/legacy version. List these for the user so they can decide whether to migrate them.
4. **New script check**: If new scripts were created this session, verify they reference CURRENT canonical files (not legacy ones). Flag any that use a legacy file.
5. Show the user what needs updating and get approval before editing.

### If no data files registry exists

Skip this step silently. Only flag if the session created or modified data files that seem like they should be tracked.

---

## 5. Cross-Check Main CLAUDE.md Against Planning Documents

The main project CLAUDE.md should **not** maintain its own script or file lists that duplicate planning documents. Check for staleness:

1. Find any script tables, file lists, or pipeline descriptions in the main CLAUDE.md
2. For each, check whether the planning document it relates to has more up-to-date information
3. If the main CLAUDE.md has a stale or duplicated list, propose one of:
   - **Replace** the list with a pointer to the planning document (preferred — avoids future drift)
   - **Update** the list to match the planning document (only if a summary is genuinely useful)
4. Flag any scripts referenced in the main CLAUDE.md that are marked as legacy/inactive in planning documents

---

## 6. Check for New Unregistered Documents, Scripts, and Files

- Check if any new `.claude/*.md` files were created this session that are not in the document registry. If so, add them to the appropriate category table.
- Check if any new scripts were created in `scripts/` this session. If they relate to a planning document, verify the planning doc lists them. If they don't relate to any existing planning document, **suggest `/new-plan`** to the user if the work is likely to span multiple sessions or scripts.
- Check if any new data files were created that should be in the canonical data files registry.

---

## 7. Check Script Lifecycle Status [Data Science only]

For projects using the script organization conventions (see `script-organization` skill):

1. **New scripts**: If any `.qmd` scripts were created this session, verify they have a `status:` field in their YAML frontmatter. If missing, suggest adding `status: development`.

2. **Finalized scripts modified**: If any script with `status: finalized` was modified this session, flag this to the user:
   > "Script X is marked as `finalized` but was modified this session. Is this intentional? Should the status change to `development` while changes are in progress?"

3. **Status promotions**: If a script's work was completed and verified this session, suggest promoting it from `development` to `finalized` if appropriate.

4. **Planning doc sync**: Verify that any status changes in YAML frontmatter are also reflected in the relevant planning document's script tracking table.

If the project doesn't use script lifecycle conventions (no `status:` fields found), skip this step silently.

---

## 8. Check Project Memory (MEMORY.md)

If a project memory file exists (check `~/.claude/projects/*/memory/MEMORY.md`):

- Did we discover any reusable lessons, gotchas, or patterns that future sessions should know about?
- Did any existing memory entries turn out to be wrong or outdated?
- If yes, propose additions or edits. Keep MEMORY.md concise (under 200 lines).

If no memory file exists, skip this step silently.

---

## 9. Review Project Conventions (CLAUDE.md)

Review the session for convention-related changes to the **project** CLAUDE.md. This step has three parts: adding, pruning, and checking gotchas.

**SCOPE: Project CLAUDE.md only.** Never automatically modify the user-level `~/.claude/CLAUDE.md` — a convention that's self-evident in one project may still be needed for other projects.

### 9a. Add new conventions

Did the user state or establish any new conventions during this session? A convention worth recording is one that is **surprising or counter-default** — something Claude wouldn't guess from reading the codebase alone.

**Good candidates** (record these):
- Non-obvious formatting rules (e.g., "use `{.text}` for terminal blocks, not `bash`")
- Project-specific naming patterns or style choices
- Tool usage rules that differ from defaults (e.g., "use built-in callout-warning, not custom CSS")
- Explicit user preferences stated during the session

**Not worth recording** (skip these):
- Conventions already visible from the codebase itself (e.g., if every code block already uses `{.text}`)
- Standard tool defaults that Claude would follow anyway
- One-time decisions that won't recur

If there are new conventions to add, propose them to the user before editing.

### 9b. Prune self-evident conventions

Check existing convention entries in the project's `.claude/CLAUDE.md`. For each one, ask: **Is this now self-evident from the codebase?**

A convention is self-evident when:
- The pattern is consistently established across the project's files (e.g., every terminal block uses `{.text}`)
- Claude would infer it from reading any few files in the project
- Removing the entry wouldn't cause Claude to do the wrong thing

If any entries are now redundant, propose removing them. Show the user which entries you'd prune and why.

**Be conservative** — only prune conventions that are truly obvious from the code. When in doubt, keep the entry.

### 9c. Check for new gotchas

Did we discover any bugs, gotchas, or important patterns that future sessions should know about?

If yes, propose adding them to the project's `.claude/CLAUDE.md` (get user approval first).

If no, skip silently.

---

## 9d. Propose New Skills

Review the session for patterns that might warrant creating a **new skill**. A skill is appropriate when a convention or workflow is:

- **Too detailed for CLAUDE.md** — needs code examples, decision trees, or multi-section documentation (like TiHKAL's `gene-naming` skill)
- **Reusable across sessions** — will be needed repeatedly, not a one-off decision
- **Complex enough to get wrong** — without the skill, Claude might make mistakes or ask the same clarifying questions every session

**Do NOT propose a skill for:**
- Simple one-liner conventions (those belong in CLAUDE.md)
- Patterns that are already covered by an existing skill
- Decisions that are unlikely to come up again

If a new skill seems appropriate, ask the user two questions:

1. **Should we create this skill?** — Briefly describe what it would cover and why it's worth extracting from CLAUDE.md.
2. **Project-level or user-level?**
   - **Project-level** (`{project}/.claude/skills/{name}/SKILL.md`) — Specific to this project. Example: gene naming conventions, project-specific data formats.
   - **User-level** (`~/.claude/skills/{name}/SKILL.md`) — Applies across multiple projects. Example: plotting conventions, environment management patterns.

If the user approves, create the skill with proper YAML frontmatter (`name`, `description`, `user-invocable: false`). Also check if any existing project-level skills need updating based on convention changes made this session.

If nothing warrants a new skill, skip this step silently.

---

## 9e. Check renv Lock File [Data Science only]

If an `renv.lock` file exists in the project:

1. Check if renv is out of sync:
   ```bash
   Rscript -e "renv::status()" 2>/dev/null
   ```

2. If there are packages used but not recorded in the lockfile, ask the user:
   > "renv detected packages not in lockfile. Run `renv::snapshot()` to update?"

3. If yes:
   ```bash
   Rscript -e "renv::snapshot()"
   ```

4. The updated `renv.lock` will then be included in the git commit step.

If no `renv.lock` exists, skip this step silently.

---

## 10. Git Status and Commit (Project)

Run `git status` to check for uncommitted changes in the current project.

If there are changes:
- **CRITICAL: Only include files that were actually created or modified during THIS chat session**
- Cross-reference the git status output against what you remember doing in the conversation
- Files that were already modified/untracked at the START of the session (visible in the initial gitStatus context) should NOT be included unless you actually worked on them
- Show the user ONLY the session-relevant files that would be committed
- Ask if they want to commit with a suggested message
- If yes, create the commit with only those files

If no changes from this session, skip this step.

---

## 10b. Publish Quarto Site (If Applicable)

After committing, check if this is a **publishable Quarto project**:

1. Check if `_quarto.yml` exists
2. Check if it's a book or website:
   ```bash
   grep -E "type:\s*(book|website)" _quarto.yml
   ```
3. Check if GitHub Pages is set up:
   ```bash
   git branch -r | grep gh-pages
   ```

**Only if ALL THREE conditions are met**, ask the user:
> "This is a Quarto book/website with GitHub Pages. Publish now?"

If yes:
```bash
quarto publish gh-pages --no-prompt
```

**Do NOT offer to publish for:**
- Regular `.qmd` scripts in analysis projects
- Quarto projects without `gh-pages` branch
- Projects where `_quarto.yml` has `type: default` or no type specified

---

## 11. Git Status and Commit (User Config)

Check for uncommitted changes in `~/.claude` (user-level Claude configuration):

```bash
git -C ~/.claude status --short
```

If there are changes:
- Show what changed (likely CLAUDE.md or skills/)
- Ask if user wants to commit and push
- If yes: `git -C ~/.claude add -A && git -C ~/.claude commit -m "message" && git -C ~/.claude push`

If no changes, skip this step silently.

---

## 12. Final Summary

End with a brief "Session complete" message listing:
- Files created/modified
- Commits made (if any)
- Planning documents updated (with what changed)
- Canonical data files updated in registry (if any)
- Decision log entries added (if any)
- Conventions added or pruned from project CLAUDE.md (if any)
- Skills created or updated (if any)
- Memory updates (if any)
- Any follow-up items for next session
