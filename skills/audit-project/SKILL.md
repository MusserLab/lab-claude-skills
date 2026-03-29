---
name: audit-project
description: >
  Periodic project health check - cross-check docs, prune conventions, find drift. Use when
  project documentation feels stale, before milestones, or when CLAUDE.md is getting long.
  Do NOT load for auditing skills (use /audit-skills) or data analysis scripts (use /audit-script).
user-invocable: true
---

# Project Audit

When the user invokes `/audit-project`, perform a thorough health check of project documentation and conventions. This is a periodic maintenance task — not needed every session, but valuable before milestones, after intensive work periods, or when things feel out of sync.

---

## 0. Detect Project Type

Check the project's `.claude/CLAUDE.md` for a `project-type:` field:

- **`data-science`** — Full audit including all steps
- **`general`** (or no field found) — Skip steps marked **[Data Science only]**

---

## 1. Cross-Check CLAUDE.md Against Planning Documents

The main project CLAUDE.md should not maintain script or file lists that duplicate planning documents. Check for staleness:

1. Read the Project Document Registry in the project CLAUDE.md
2. For each registered planning document, read it and compare against the main CLAUDE.md:
   - Are any scripts referenced in CLAUDE.md marked as legacy/inactive in planning docs?
   - Does CLAUDE.md have stale lists that duplicate planning doc tables?
3. For stale/duplicated lists, propose:
   - **Replace** with a pointer to the planning document (preferred — avoids future drift)
   - **Update** to match (only if a summary is genuinely useful in CLAUDE.md)

---

## 2. Planning Document Health (Interactive)

For each registered planning document, perform both **automated checks** and an **interactive review with the user**.

### Automated checks

1. **Uncollapsed completed phases** — Are there completed phases with detailed content (>10 lines) that should be collapsed to 3-5 line summaries? Report line counts per phase.
2. **Stale "Next Session" sections** — Does a "Next Session" or "Open Tasks" section contain items that appear to have been done already (based on status tables or completed phases)?
3. **Status table accuracy** — Are phases marked "Not started" that have actually been worked on, or "In progress" for work that's clearly complete?
4. **Overall size** — Report line count and KB for each planning doc. Flag any over 300 lines as candidates for collapsing.

### Interactive review

After automated checks, walk through each planning document with the user:

5. **Relevance check** — "Is [document] still relevant, or should we close/archive it?" Propose closing planning docs whose work is complete or permanently parked.
6. **Priority review** — For each active work stream or phase, confirm the current priority is still accurate. Update priorities based on user answers.
7. **Cleanup** — Mark completed phases, close out TODO items that are no longer planned, update status tables to reflect reality.

---

## 2b. Rebuild STATUS_SUMMARY.md

Check if `STATUS_SUMMARY.md` exists at the repo root.

STATUS_SUMMARY.md uses a **unified format** shared between Claude Code (`/done`) and Cowork (`wrapup`), so executive-assistant skills can scan all projects uniformly. See the `/done` skill's Step 2b for the exact format template.

### If it doesn't exist — offer to create one

1. Ask: "This project doesn't have a STATUS_SUMMARY.md yet. Want me to create one?"
2. If yes, follow the **initial creation workflow**:
   - Scan all planning documents registered in the Project Document Registry
   - Build the Active Plans table interactively — walk through each registered plan with the user, confirm status (Active/Blocked/Paused/Complete) and next action
   - Populate People section (obligations in both directions) — ask the user
   - Populate Upcoming Tasks (NOW/THIS WEEK/SOON) from plans and user input
   - Populate Flags for Executive Assistant — ask the user
   - Start Recent Activity fresh (one entry for this audit)
   - Write the **Current state** as one specific sentence about where the project stands right now
3. If no, skip this step

### If it exists — rebuild from scratch

1. **Full scan** of all planning documents registered in the Project Document Registry
2. **Rebuild all sections** based on the planning documents and the interactive review from Step 2
3. **Flag drift** — report any discrepancies found:
   - Plans marked "Active" that haven't been touched in weeks
   - Plans marked "Paused" that have new activity
   - Planning docs whose internal status disagrees with the STATUS_SUMMARY
4. **Ask the user about ambiguous items** before assigning statuses — "Is [plan] still Active, or should we mark it Paused?"
5. **Preserve Recent Activity entries** — don't overwrite historical entries. Add a new entry for this audit, trim to last 5.
6. **Regenerate all other sections** (Current state, Active Plans, People, Upcoming Tasks, Flags) from scratch based on current state

---

## 2c. Check Session Log Health

Check the **Session Log** section at the bottom of the project's `.claude/CLAUDE.md`:

1. **Missing section** — If no Session Log exists, flag it and offer to create one with a single entry summarizing the current audit session.
2. **Stale "Next" items** — Look at the "Next" bullets from recent entries. Are any clearly done already (based on planning docs, completed phases, or files that now exist)? Flag these as candidates for removal or note that they've been addressed.
3. **Entry count** — If more than 5 entries, trim the oldest. If fewer than 2, note that the log is thin (not an error, just informational).
4. **Stale dates** — If the most recent entry is more than 4 weeks old and the project is supposedly active, flag the gap.

---

## 3. Check for Unregistered Documents and Scripts

### Documents

Scan `.claude/` for `.md` files not listed in the Project Document Registry. Propose adding any missing ones to the appropriate category table.

### Scripts

Check if any scripts in `scripts/` are not tracked in any planning document. For untracked scripts that relate to ongoing work, suggest either:
- Adding them to an existing planning document
- Creating a new planning document with `/new-plan`

### Data files [Data Science only]

Check if any significant data files were created but not added to the Canonical Data Files Registry.

---

## 4. Script Lifecycle Status [Data Science only]

For projects using the script organization conventions:

1. **Missing status fields**: Check `.qmd` scripts for missing `status:` YAML frontmatter
2. **Status/reality mismatch**: Flag scripts marked `finalized` that have been modified since their last commit, or `development` scripts that appear complete
3. **Planning doc sync**: Verify YAML frontmatter status matches the relevant planning document's tracking table

---

## 4b. Script Convention Compliance [Data Science only]

Check the `scripts/` directory for structural convention violations:

### Numbered non-`.qmd` files

Scan `scripts/` (not subdirectories) for files matching `[0-9]*_*` that are NOT `.qmd`:
- `.R`, `.py`, `.Rmd` files with number prefixes are violations
- **Skip:** `scripts/old/`, `scripts/scratch/`, `scripts/exploratory/`, unnumbered files (legacy)
- For each violation, report it and suggest: convert to `.qmd`, move to `R/`/`python/` as helper, or archive to `scripts/old/`

### Scratch folder

Check if `scripts/scratch/` exists and has files:
- If non-empty, warn — these are working files that should have been consolidated
- List the files and suggest consolidation targets

### Letter suffix consistency

For scripts with letter suffixes (e.g., `15a_`, `15b_`, `15c_`):
- Verify all scripts in a lettered set share a single output directory (`outs/XX_topic/`, not `outs/XXa_topic/`)
- Check that the `a` script exists (letters imply sequence)

### Script-output directory correspondence

For each numbered `.qmd`:
- Extract the number prefix
- Verify `outs/{number}_{topic}/` exists (lettered scripts share one dir by number)
- Flag scripts with no output dir (may be unrun `status: development` — note, don't error)

For each output directory in `outs/` with a number prefix:
- Verify a corresponding script exists
- Flag orphaned output directories

---

## 5. Prune Self-Evident Conventions

Review existing convention entries in the project's `.claude/CLAUDE.md`. For each, ask: **Is this now self-evident from the codebase?**

A convention is self-evident when:
- The pattern is consistently established across the project's files
- Claude would infer it from reading any few files
- Removing the entry wouldn't cause Claude to do the wrong thing

Propose removing redundant entries. Show which entries would be pruned and why.

**Be conservative** — only prune conventions that are truly obvious from the code. When in doubt, keep the entry.

---

## 6. Project CLAUDE.md Size Check

Report the current size of the project CLAUDE.md (line count, approximate KB). If it's growing large (>300 lines), suggest:
- Moving detailed sections into planning documents
- Extracting complex conventions into skills
- Replacing inline tables with pointers to planning docs

---

## 7. User-Level Health Check

Quick checks on user-level configuration (lightweight — skip silently if everything is fine):

1. **MEMORY.md size** — Check `~/.claude/projects/*/memory/MEMORY.md` for the current project. If over 200 lines, flag for pruning.
2. **User CLAUDE.md size** — Check `~/.claude/CLAUDE.md` line count. If over 150 lines, suggest extracting content into skills.
3. **Skills audit** — For a deep review of skill quality, structure, and redundancy, run `/audit-skills`. Skip skill-level checks here.

---

## 8. Summary

Report findings organized as:
- **Issues found** — things that need fixing (stale references, unregistered files, uncollapsed phases, etc.)
- **Suggestions** — optional improvements (convention pruning, size reduction)
- **All clear** — areas that checked out fine

Ask the user which findings they'd like to act on before making any changes.
