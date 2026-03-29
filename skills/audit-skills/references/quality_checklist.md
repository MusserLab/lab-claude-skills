# Skill Quality Checklist

Detailed criteria for each audit category. Loaded by the audit workflow during Phase 2.
Each item is a concrete check — not every item applies to every skill.

---

## 1. Size & Structure

- [ ] SKILL.md is under 500 lines
- [ ] If over 500 lines: does the skill use bundled resources (`references/`, `templates/`,
  `scripts/`) for heavy content? If not, it should.
- [ ] Code blocks over ~50 lines are candidates for extraction to `scripts/` or `templates/`
- [ ] Accessory files are organized by type:
  - `references/` — knowledge docs, checklists, detailed specs
  - `templates/` — boilerplate files deployed to projects
  - `scripts/` — helper code deployed to project `python/` or `R/`
  - `assets/` — static files used in output (icons, HTML templates)
- [ ] No loose files in the skill root (everything except SKILL.md goes in a subdirectory)
- [ ] SKILL.md covers workflow and decision points; reference files cover details
- [ ] Someone reading just SKILL.md gets the full workflow without drowning in specifics

**Size guidelines by skill type:**
- Simple convention/reference: under 100 lines
- Single-phase workflow: 100-300 lines
- Multi-phase workflow: 300-500 lines
- Complex domain reference (e.g., HPC): may exceed 500 if it's genuinely a reference doc,
  but should still use bundled resources for tables, examples, and templates

---

## 2. Description & Triggering

- [ ] First sentence says WHEN to use, not just WHAT it does
  - Bad: "R ggplot2 plotting conventions and theme."
  - Good: "Use when creating, modifying, or styling ggplot2 plots in R..."
- [ ] Lists 2+ specific trigger verbs/contexts
  - Bad: "Use when working with files."
  - Good: "Use when overwriting existing files, deleting files, or writing to directories..."
- [ ] Includes DO NOT load exclusions if similar skills exist
  - Example: "Do NOT load for Quarto books, websites, or documentation projects."
- [ ] Covers edge-case triggers (variations of the core task)
  - "creating plots" should also trigger on "modifying, styling, fixing, adjusting themes"
- [ ] For user-invocable skills: lists common user phrasings in quotes
  - Example: "or when the user says 'audit this script', 'review this code'"
- [ ] Description is 1-4 sentences (not a paragraph)
- [ ] Most important trigger is first

**Test:** Mentally simulate Claude seeing this description alongside 30+ other skill
descriptions. Would it pick this one for the target use case? Would it incorrectly pick
this one for an unrelated task?

---

## 3. Content Quality

- [ ] Skill covers one coherent topic — not a grab-bag of loosely related conventions
- [ ] No unnecessary repetition within the skill
- [ ] Explains WHY conventions matter, not just WHAT to do (appeals to reasoning)
- [ ] Examples are clear, minimal, and illustrate the point
- [ ] Sections flow logically: entry/setup → workflow → output → behavior notes
- [ ] No orphaned sections that don't connect to the main workflow
- [ ] No sections that are just "rules lists" without context
- [ ] Behavior notes at the end are genuinely useful guidance, not filler
- [ ] No over-use of MUST/NEVER/CRITICAL/IMPORTANT — these lose impact when overused.
  Reserve for things that genuinely cause problems if violated.

**Key test:** Could you remove any section without the skill producing worse results?
If yes, consider removing it.

---

## 4. Redundancy & Overlap

### Within the skill library
- [ ] No two skills cover the same core topic
- [ ] Related skills have clear boundaries (e.g., `figure-export` vs `r-plotting-style`)
- [ ] Shared conventions appear in ONE skill, not copied across several
- [ ] If two skills always load together, consider merging

### Against CLAUDE.md
- [ ] Conventions fully covered by a skill are NOT also spelled out in CLAUDE.md
- [ ] CLAUDE.md should *point to* skills, not *repeat* them
- [ ] User CLAUDE.md skills table accurately lists all skills with correct names

### Against memory
- [ ] Learned preferences in memory are not also hardcoded in skills
- [ ] If a memory entry captures a convention that belongs in a skill, promote it;
  don't maintain both

### Merge candidates
Look for these patterns:
- Two skills that handle different phases of the same workflow
- A "conventions" skill and a "workflow" skill for the same domain
- Skills under 50 lines that could be a section of a related larger skill

---

## 5. Staleness & Accuracy

- [ ] File paths in the skill still exist on disk (spot-check, not exhaustive)
- [ ] Package/function/column names are still current
- [ ] Tool versions assumed are still installed
- [ ] Workflow steps match how the user actually works (not how they used to work)
- [ ] Any referenced planning documents or data files still exist
- [ ] Default values and thresholds are still appropriate

**Priority for checking:** Focus on skills that are actively used in the current project.
Don't chase every reference in rarely-used skills.

---

## 6. Portability

### Absolute paths
- [ ] No `/Users/<username>/` — use `~/` instead
- [ ] No `/Library/Frameworks/R.framework/...` without noting it's macOS-specific
- [ ] No project-specific absolute paths in user-level skills

### Platform assumptions
- [ ] Skills used on both local and cluster don't assume macOS-only paths
- [ ] Conda activation patterns work on both platforms (or note platform-specific variants)
- [ ] Any `brew`/`port` references are marked as macOS-only

### Scope leakage
- [ ] User-level skills don't hardcode project-specific details (dataset names, cell type
  lists, file paths from one project)
- [ ] If a user-level skill has project-specific content, it should be parameterized or
  the content should move to a project-level skill

### Lab repo sync
- [ ] Personal skill matches lab repo copy (if lab repo exists at
  `~/Dropbox/Documents-Db-Work/Research/lab_software/lab-claude-skills/skills/`)
- [ ] Path differences (absolute vs `~/`) between personal and lab copies are sync issues
- [ ] Skills modified since last `/sync-plugin` are flagged for review
