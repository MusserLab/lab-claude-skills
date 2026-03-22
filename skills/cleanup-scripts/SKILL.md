---
name: cleanup-scripts
description: >
  Session-scoped script cleanup for data science projects. Checks scripts/scratch/
  for working files that need consolidation into .qmd scripts, flags numbered non-.qmd
  files in scripts/, and verifies script-output directory correspondence. Use when
  finishing a coding session, when scripts/scratch/ has accumulated files, or when
  the user says "clean up scripts", "consolidate scratch", or "check script conventions".
  Lightweight and fast — reads files, no expensive computation.
user-invocable: true
---

# Script Cleanup (Session Scope)

Check and consolidate working scripts from the current session. This skill focuses
on the **current session's work** — for project-wide script health, use `/audit`.

---

## When to Run

- Before `/done` at the end of a coding session
- When `scripts/scratch/` has accumulated working files
- When the user asks to clean up or consolidate scripts
- After a long iterative development session with lots of file creation

---

## Steps

### 1. Check `scripts/scratch/`

List all files in `scripts/scratch/`. For each file:

- **Identify the target script:** Based on the filename and conversation context, determine which numbered `.qmd` script this code belongs to. If no matching script exists, it may need a new numbered `.qmd`.
- **Report to user:** Show each scratch file, its proposed destination, and ask for confirmation before consolidating.
- **Consolidate:** Wrap the code in a proper `.qmd` chunk (using the `quarto-docs` skill template) and add it to the target script. Or create a new numbered `.qmd` if needed.
- **Clean up:** Delete the scratch file after successful consolidation.

If `scripts/scratch/` is empty or doesn't exist, report "No scratch files" and move on.

### 2. Check for Convention Violations

Scan `scripts/` (not subdirectories) for files that violate conventions:

- **Numbered non-`.qmd` files:** Files matching `[0-9]*_*.R`, `[0-9]*_*.py`, `[0-9]*_*.Rmd` in `scripts/`. These should be `.qmd` (or moved to `R/`/`python/` if they're helpers, or `scripts/old/` if superseded).
- **Skip these:** `scripts/old/`, `scripts/scratch/`, `scripts/exploratory/`, unnumbered files (legacy).

For each violation:
- Ask the user: convert to `.qmd`, move to helper dir (`R/` or `python/`), or archive to `scripts/old/`?
- Execute the chosen action.

### 3. Verify Script-Output Correspondence

For each numbered `.qmd` in `scripts/`:

- Extract the number prefix (e.g., `15` from `15a_threshold.qmd`).
- Check that `outs/{number}_{topic}/` exists (using the lettered script convention — all scripts with the same number share one output dir).
- Flag scripts with no output directory (may indicate the script hasn't been run yet, which is fine for `status: development`).

For each output directory in `outs/`:
- Check that a corresponding numbered script exists in `scripts/`.
- Flag orphaned output directories (output dir exists but no script — may be from a deleted/archived script).

### 4. Report

Summarize:
- Scratch files consolidated (count)
- Convention violations found and fixed (count)
- Script-output mismatches (list)

---

## Important Notes

- **This is session-scoped.** It uses conversation context to understand what files belong where. For project-wide structural audits, use `/audit`.
- **Never delete without asking.** Always show what will be moved/deleted and get user confirmation.
- **Respect legacy scripts.** Unnumbered `.Rmd` files in `scripts/` are legacy — do not flag them as violations.
- **The hook should prevent most violations.** The `enforce-qmd-scripts.sh` hook blocks creation of numbered non-`.qmd` files. This skill catches anything that slipped through or pre-dates the hook.
