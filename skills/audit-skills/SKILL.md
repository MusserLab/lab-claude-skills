---
name: audit-skills
description: >
  Audit Claude Code skills for bloat, trigger accuracy, structural quality, redundancy, and
  pruning opportunities. Use when skills feel bloated, before publishing to lab repo, after
  building several new skills, when reviewing a single newly-created skill before publishing,
  or when the user says "audit my skills", "review skills", "check skill quality", "audit this
  skill", or invokes /audit-skills. Covers both user-level (~/.claude/skills/) and project-level
  (.claude/skills/) skills, and supports both full-library scans and single-skill reviews.
  Do NOT load for auditing data analysis scripts (use /audit-script) or project documentation
  (use /audit-project).
user-invocable: true
---

# Skill Audit — Quality Review for Claude Code Skills

Systematically review skills for bloat, trigger accuracy, structural quality, redundancy, and
pruning opportunities. Produces a findings table with severity levels that the user works through
interactively.

This is the skill-level counterpart to `/audit-project` (documentation health) and `/audit-script`
(code correctness). Where those audit what skills *produce*, this audits the skills *themselves*.

---

## Entry Flow

### 1. Ask Scope

Use AskUserQuestion:

- **Specific skill(s)** — Ask which skill(s) by name. Common case: reviewing a newly-created skill before publishing.
- **All skills** — Full user-level (`~/.claude/skills/`) + project-level (`.claude/skills/`) scan. Common case: periodic library health check.
- **User-level only** — `~/.claude/skills/`
- **Project-level only** — `.claude/skills/` in current project

If the user's invocation already names a skill or scope (e.g., "audit just the busco skill"), skip this question and proceed.

### 2. Ask Focus

"Is there anything specific you're worried about? (e.g., 'my pipeline skills feel too long',
'I think some skills overlap')" — lets the user steer attention.

### 3. Ask Output Mode

Use AskUserQuestion:

- **Fix directly** — Work through findings interactively and apply fixes in this session
- **Save report** — Write a markdown audit report for another session to implement (useful when the skill was created in a different chat that has more context)
- **Both** — Fix what we can here, save a report for anything that needs the other chat's context

This matters because skills are sometimes created in a separate chat session that has deeper
context (e.g., the reference implementation). Quick fixes (path corrections, description
tweaks) can be done anywhere, but structural changes (adding code templates, reorganizing
sections) are better done where the full context lives.

**Default by scope:**

- **Single-skill scope** → recommend "Both" (fix the trivial REFINEs, write a report for anything structural). Single-skill audits are most often run in a chat that doesn't have the implementation context, so a handoff report is valuable even when some fixes can be done in-session.
- **Full-library scope** → recommend "Fix directly". When auditing the whole library, the user is already in the right context to apply edits.

---

## Phase 1: Inventory

**Skip this phase if scope is a single skill** — the inventory table exists to spot patterns across many skills (oversized files, missing accessory dirs, path issues at a glance). With N=1, just go straight to Phase 2 and read the skill thoroughly.

List all skills in scope. For each, report:

| Skill | Lines | Accessory Files | Quick Health |
|-------|------:|----------------|-------------|
| `expression-report` | 969 | none | OVER SIZE |
| `hpc` | 822 | none | OVER SIZE |
| `conda-env` | 45 | none | OK |

**Quick Health** indicators (computed automatically):
- **OK** — Under 500 lines, has accessory files if large, no obvious issues
- **OVER SIZE** — SKILL.md exceeds 500 lines without bundled resources
- **PATH ISSUE** — Contains absolute user paths (`/Users/...`)
- **NO TRIGGERS** — Description doesn't front-load when-to-use conditions

Present the inventory table and note any patterns before proceeding to detailed review.

---

## Phase 2: Systematic Review

Read each skill's SKILL.md (and accessory files if present). Evaluate against the 6 audit
categories below. Load `references/quality_checklist.md` for detailed per-category criteria.

### The 6 Audit Categories

#### 1. Size & Structure

Is the skill appropriately sized and organized?

- SKILL.md should be under 500 lines
- Heavy content (templates, reference docs, long code blocks) belongs in bundled resources
  (`references/`, `templates/`, `scripts/`)
- Code blocks over ~50 lines in SKILL.md are candidates for extraction
- Accessory files should be organized by type, not dumped loose in the skill directory

**Key question:** If someone reads just SKILL.md, do they get the workflow and decision points
without drowning in detail?

#### 2. Description & Triggering

Will this skill actually load when it should?

- Description must front-load WHEN to use (trigger conditions), not just WHAT it does
- Should list 2+ specific trigger verbs/contexts
- Should include DO NOT load exclusions if similar skills exist
- Should cover edge-case triggers (variations of the core task)
- Test mentally: "If I were Claude seeing this description, would I load it for [typical use case]?"

**Common problems:** Too generic ("Use when working with data"), too narrow (misses common
phrasings), missing exclusions (fires for wrong task).

#### 3. Content Quality

Is the content focused, clear, and well-structured?

- One coherent topic per skill — not a grab-bag
- No unnecessary repetition within the skill
- Explains WHY conventions matter, not just WHAT to do
- Examples are clear and minimal
- Sections flow logically (entry → workflow → output → behavior notes)
- No orphaned sections that don't connect to the workflow

**Key question:** Could you remove any section without losing something the skill needs to
function correctly?

#### 4. Redundancy & Overlap

Does this skill duplicate content found elsewhere?

- Check against other skills in the library — especially related ones
- Check against project and user CLAUDE.md — conventions shouldn't be in both places
- Check against memory files — learned preferences shouldn't also be hardcoded in skills
- Look for skills that could be merged (two skills doing essentially the same thing)
- Look for conventions in CLAUDE.md that are fully covered by a skill (prune from CLAUDE.md)

**Key question:** If this content disappeared, would something else already cover it?

#### 5. Staleness & Accuracy

Are references and assumptions still valid?

- File paths mentioned in the skill — do they still exist?
- Package names, function names, column names — still current?
- Tool versions or behaviors assumed — still accurate?
- Workflow steps — do they match how the user actually works now?

Only check references relevant to the current project context. Don't chase every path in
every skill — focus on skills that are actively used.

#### 6. Portability

Would this skill work in a different context?

- Absolute paths (`/Users/jm284/`) instead of `~/` — the #1 skill issue
- Project-specific details baked into a user-level skill (should be parameterized or
  moved to project-level)
- Platform-specific assumptions (macOS paths in a skill that should work on cluster)
- Lab repo sync: compare personal skill against `~/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/skills/` if that directory exists. Flag files that differ.

---

## Severity Levels

- **PRUNE** — Content that should be removed. Dead weight, redundant with another source,
  or self-evident from code. Removing it makes things cleaner.
- **RESTRUCTURE** — Content in the wrong place. Skill too long and needs splitting, content
  should move to references/, or two skills should merge.
- **FIX** — Something broken. Bad path, wrong trigger, stale reference that would cause
  incorrect behavior.
- **REFINE** — Could be better but isn't broken. Vague trigger, missing exclusion, unclear
  example, tone issue.
- **OK** — Skill checks out fine. Brief note on what's good.

### Calibration

- A 600-line skill with clear structure and good progressive disclosure is REFINE, not RESTRUCTURE
- A 300-line skill that's half redundant with another skill is PRUNE
- An absolute path is FIX (it will break on cluster), not REFINE
- A vague description on an otherwise good skill is REFINE
- Don't report OK findings for every skill — only note when something is notably well-done

---

## Phase 3: Cross-Skill Analysis

**Skip this phase if scope is a single skill.** Cross-skill observations may still surface naturally during Phase 2 (e.g., "this skill defers to `hpc` correctly" or "the description should add a `Do NOT load for X` exclusion mirroring skill Y") — note those inline as findings, but don't run a full library-wide pass.

After reviewing individual skills, step back and look at the full library:

1. **Overlap clusters** — Are there groups of skills covering adjacent territory that could
   be consolidated? (e.g., three skills that each handle a different aspect of the same workflow)
2. **Coverage gaps** — Are there common tasks that no skill covers? (informational only —
   don't create skills during an audit)
3. **CLAUDE.md duplication** — Are there conventions in the user or project CLAUDE.md that
   are fully covered by a skill and could be removed from CLAUDE.md?
4. **Naming consistency** — Do skill names follow a consistent pattern? (kebab-case,
   verb-noun vs noun-only, etc.)

---

## Phase 4: Interactive Report

Present all findings in a single table, ordered by severity (FIX first, then PRUNE,
RESTRUCTURE, REFINE):

```markdown
## Skill Audit Findings

| # | Severity | Skill | Category | Finding | Recommendation |
|---|----------|-------|----------|---------|----------------|
| 1 | FIX | hpc | Portability | Absolute path /Users/jm284/ on line 45 | Replace with ~/ |
| 2 | PRUNE | expression-report | Size | 969 lines, no bundled resources | Move palette + layout specs to references/ |
| 3 | RESTRUCTURE | deep-research-genelist | Redundancy | Template format duplicated in deep-research-reports | Consolidate shared format into one reference |
| 4 | REFINE | conda-env | Triggering | Description doesn't mention "pip" or "pip install" | Add pip to trigger list |
| 5 | OK | audit-script | — | Well-structured, good progressive disclosure | — |
```

**Summary line:** "Found N findings across M skills: X FIX, Y PRUNE, Z RESTRUCTURE, W REFINE"

Then ask: **"Which findings do you want to work through? (all / by severity / specific numbers)"**

---

## Phase 5: Execute Changes (adapts to output mode)

### If "Fix directly" or "Both":

For each finding the user wants to act on:

1. **Show the current state** — the specific lines or content being changed
2. **Propose the change** — what the edit looks like
3. **Get confirmation** — user approves, modifies, or skips
4. **Make the edit** — apply the change
5. **Move to next finding**

For RESTRUCTURE findings that involve moving content to reference files:
- Create the reference file with the extracted content
- Update SKILL.md to reference it ("See `references/X.md` for details")
- Verify the SKILL.md line count dropped

For PRUNE findings:
- Show what's being removed and why it's redundant
- Confirm with user before deleting

### If "Save report" or "Both":

Write a self-contained markdown report to `~/.claude/skills/{skill-name}-audit-report.md`
that another chat session can use to implement fixes. The report must include:

- **Skill path and line count** for orientation
- **Each finding** with: severity, line numbers, the problem, the concrete fix, and
  (for structural changes) pointers to reference implementations or source material
- **"Not Changed" section** confirming what's good — so the other chat doesn't
  second-guess working parts
- **Architecture notes** for any cross-skill design questions that came up

The report is a handoff artifact — tell the user they can delete it after fixes are applied.
It is NOT a skill or memory file.

---

## Behavior Notes

- **Read before judging.** Read the full SKILL.md before producing findings. Don't flag
  something as missing from section 2 if it's covered in section 5.
- **Context matters.** A 700-line skill that's the primary reference for a complex domain
  (like HPC cluster configuration) may be appropriately sized. A 700-line skill for a
  simple convention is bloated.
- **Don't over-report.** If a skill is fine, say OK and move on. Audit fatigue from
  low-severity noise makes real findings harder to spot.
- **Be specific.** "Description could be better" is not actionable. "Description says 'Use
  when working with plots' but should list specific triggers: 'creating, modifying, styling,
  or adjusting ggplot2 themes'" is actionable.
- **Respect the author's intent.** Skills encode accumulated experience. Before recommending
  removal, consider whether the content captures a hard-won lesson that isn't obvious.
- **Do not use subagents.** Run the audit directly in the current conversation. Skills need
  to be read carefully and cross-referenced — subagents can't maintain the full picture.
- **Cross-reference the `new-skill` skill** for best practices on structure, description
  writing, and organization. That skill defines the standards this audit checks against.