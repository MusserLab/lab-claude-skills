---
name: audit-script
description: >
  Systematic audit of data analysis scripts for bugs, analytical reasoning, data handling, style,
  and reproducibility. Use when auditing a script, reviewing code for correctness, checking for
  bugs, preparing a script for publication, or when the user says "audit this script", "review
  this code", "check this for bugs", or "is this script correct". Three modes: thorough
  (collaborative section-by-section), fast (Claude-driven with discussion), and report-only.
  Do NOT load for quick one-off questions about a single line or function.
user-invocable: true
---

# Audit Script — Systematic Code Review for Data Science

This skill systematically evaluates data analysis scripts for correctness, analytical soundness,
and quality. It surfaces bugs, questionable analytical choices, data handling problems, style
issues, and reproducibility gaps — producing a structured audit report with severity levels and
action items.

Unlike `/learn-code` (which teaches students to understand code), this skill is for **critical
evaluation** — finding what's wrong, fragile, or misleading. The user is a collaborator, not a
student. The tone is direct and analytical.

---

## Entry Flow

When the skill is invoked (via `/audit-script` or auto-loaded from context):

### 1. Identify the Script

Check for:
- An IDE selection (highlighted code in the editor)
- A currently open file in the editor
- A file path mentioned in conversation

If none, ask: "Which script would you like to audit?"

Read the full script before proceeding.

### 2. Ask Mode

Use AskUserQuestion:

- **Thorough (default)** — Collaborative, section-by-section deep audit. You are a co-auditor: reading code, running chunks, inspecting data, catching issues yourself. I'll guide the systematic walk-through and add my own observations. This is pair code review.
- **Fast** — I'll read the whole script and identify issues independently, then we'll discuss my findings together.
- **Report only** — I'll audit independently and produce a report. You read it on your own time.

### 3. Ask for Specific Concerns

"Is there anything in particular you're worried about or want me to focus on?"

This lets the user flag known weak points, steer attention to a specific category, or provide
context about what the script is supposed to do.

---

## The 5 Audit Categories

Every section of the script is evaluated against these categories. Each finding is tagged with
its category and severity.

### 1. Correctness (bugs)
- Off-by-one errors, wrong variable references, typos in column names
- Logic errors (wrong condition, inverted filter, incorrect formula)
- Functions used incorrectly (wrong arguments, misunderstood return values)
- Race conditions or order dependencies
- Mismatches between what the code does and what the comments say

### 2. Analytical Reasoning
- Is the statistical test appropriate for this data and question?
- Are assumptions checked (normality, independence, homoscedasticity)?
- Are thresholds justified or arbitrary?
- Is the normalization/correction method appropriate for the experimental design?
- Are comparisons properly controlled?
- Could the analysis be misleading even if technically correct?
- Are there alternative approaches that would be more appropriate?

### 3. Data Handling
- Silent row/column drops (joins, filters, NA removal)
- Unvalidated assumptions about data structure
- Missing input validation (expected columns, types, ranges)
- Unchecked NAs propagating through calculations
- Joins that could introduce duplicates or lose rows
- Aggregation that hides important variation

### 4. Style & Organization
- Code clarity and readability
- Variable naming
- Comments (too few, misleading, or unnecessary)
- Function decomposition (repeated code that should be a function)
- Script flow (is the order logical?)
- Magic numbers without explanation

### 5. Reproducibility
- Hardcoded paths or values
- Missing seed setting for random operations
- Environment dependencies (packages not loaded, conda env not specified)
- Missing input file documentation
- Output not clearly tied to input versions
- Platform-specific code without fallbacks

---

## Severity Levels

- **BUG** — Incorrect behavior; produces wrong results. Must fix.
- **CONCERN** — Analytically questionable; may produce misleading results. Should investigate.
- **WARNING** — Not wrong, but fragile or risky. Should address.
- **NOTE** — Style, clarity, or minor improvement. Nice to fix.

---

## Thorough Mode: Collaborative Section-by-Section Audit

The user is a co-auditor. Claude does NOT pre-digest the script — both work through it together.
The process of finding issues is as valuable as the findings themselves.

### 1. Script Overview

Read the script and present:
- What it does (plain language)
- What data it processes and what it produces
- A numbered map of logical sections

Ask: "Does this match your understanding of what this script should do?" Mismatches between
intent and implementation are a finding category.

### 2. Section-by-Section Audit

For each logical section:

**a. Present the code chunk** (~15-20 lines max at a time)

**b. User reads and runs it.** Encourage the user to:
- Read the code before Claude explains anything
- Run the chunk in their console
- Inspect intermediate objects (`str()`, `dim()`, `head()`, `summary()` in R;
  `.info()`, `.head()`, `.shape`, `.describe()` in Python)
- Flag anything that looks off or that they don't understand

**c. Claude probes and suggests checks** — targeted to what's most likely to go wrong with
this specific type of code. Ask questions, suggest diagnostics, and raise concerns adapted to the
operation at hand. The user adds domain context and responds. Findings are documented as they
emerge.

**For data loading/input:**
- "Let's verify the dimensions — how many rows and columns did we get? Is that what you expect?"
- "Are there NAs in the key columns? Let's check before we go further"
- "Does the data structure match what the rest of the script assumes?"

**For joins/merges:**
- "This is an inner join — let's run `anti_join()` to see what gets dropped and whether that's acceptable"
- "Could this join introduce duplicates? Let's check `nrow()` before and after"
- "Are the join keys the right level of granularity?"

**For filtering/subsetting:**
- "How many rows survive this filter? Is that a reasonable fraction?"
- "Are we losing any categories entirely? Let's check what's left"
- "What happens to NAs — are they silently excluded?"

**For statistical tests/modeling:**
- "What assumptions does this test make about the data? Let's check if they hold"
- "Are there actually significant results? Let's look at the distribution of p-values"
- "Is the sample size sufficient for this test to have power?"
- "Why this test and not [alternative]? Is there a reason?"

**For normalization/transformation:**
- "Let's compare the distribution before and after — does the transformation do what we expect?"
- "Are there edge cases (zeros, negatives, NAs) that this transformation handles poorly?"
- "Is this the right normalization for this experimental design?"

**For plotting/output:**
- "Does this plot accurately represent the underlying data, or could it be misleading?"
- "Are the axis scales, labels, and legends correct?"
- "Is anything being visually hidden (e.g., overplotting, truncated axes)?"

The user adds their own observations and domain knowledge throughout. Their context may resolve
concerns ("this threshold was chosen because of the experimental design") or raise new ones.

**d. Run diagnostics together** when something is suspicious:
- "Let's check — run `anti_join()` on these two tables and see how many rows don't match"
- "Try `summary()` on this column — is the distribution what you'd expect?"
- "Comment out this filter and re-run — how does the downstream result change?"

**e. Document findings** — tag with category, severity, lines, and recommendation.

### 3. Cross-Section Analysis

After all individual sections:
- Trace data flow across the full script together
- Check: do transformations in section A affect correctness in section D?
- Look for cascading issues (e.g., silent drop early → wrong denominator later)
- Verify the overall analytical argument holds together
- Look for things the script should be doing but isn't (missing validation, missing checks)

### 4. Produce Audit Report

Compile findings documented throughout into the structured report format (see below).

### Pacing

Every 2-3 sections, briefly check in: "How's the depth? Want to go faster or deeper?"

---

## Fast Mode: Claude-Driven Audit with Discussion

Claude works through the script independently, then discusses findings with the user.

### 1. Full Script Read

Read the entire script.

### 2. Systematic Analysis

Apply the 5-category checklist across all sections:
- Trace data flow from input to output
- Check analytical reasoning and statistical assumptions
- Look for silent data loss, unvalidated joins, missing checks
- Evaluate style, organization, and reproducibility
- Run diagnostics where possible (dimension checks, NA counts, join validation)

### 3. Produce Audit Report

Full structured report with all findings.

### 4. Collaborative Review of Findings

Present findings to the user, ordered by severity (BUG first):
- For each finding: show the code, explain the issue, discuss implications
- User adds context, agrees/disagrees, reclassifies severity
- Together decide: fix now, defer, mark as acceptable
- New issues can surface during discussion
- Report updated with collaborative decisions and final dispositions

---

## Report-Only Mode

Same as fast mode steps 1-3. No collaborative review. Produces the report and saves it.
Findings are marked as "Unreviewed" in the status column.

Best for: batch auditing multiple scripts, quick quality snapshots, or when the user will
review the report in a separate session.

---

## Diagnostic Capabilities

When auditing, Claude should actively run diagnostics (in Claude-driven modes) or suggest them
(in collaborative mode):

- **Dimension checks:** `dim()`, `nrow()` before and after key operations
- **NA propagation:** Track where NAs enter and how they flow through the script
- **Join validation:** `anti_join()` to check unmatched rows on both sides
- **Distribution checks:** `summary()`, `hist()` for key variables, especially before statistical tests
- **Duplication checks:** Are there unexpected duplicates after joins or reshaping?
- **Edge case probing:** What happens with empty groups, single-observation groups, all-NA columns?

---

## Audit Report Format

```markdown
# Script Audit Report: {script_name}

**Date:** {date}
**Script:** {path/to/script}
**Auditor:** Claude Code {+ user name, if collaborative}
**Mode:** {Thorough / Fast / Report only}

## Summary

- **Total findings:** {N}
- **By severity:** {N} BUG, {N} CONCERN, {N} WARNING, {N} NOTE
- **By category:** {N} Correctness, {N} Analytical, {N} Data Handling, {N} Style, {N} Reproducibility
- **Overall assessment:** {1-2 sentence summary of script quality and most critical issues}

## Findings

### BUG-1: {Short description}
- **Category:** {Correctness / Analytical / Data Handling / Style / Reproducibility}
- **Section:** {section name}
- **Lines:** {line range}
- **Description:** {What the issue is}
- **Impact:** {What goes wrong because of this}
- **Recommendation:** {How to fix it}
- **Status:** {Open / Discussed — {outcome} / Fixed / Unreviewed}

### CONCERN-1: {Short description}
...

### WARNING-1: {Short description}
...

### NOTE-1: {Short description}
...

## Sections Reviewed

| Section | Lines | Issues Found | Notes |
|---------|-------|-------------|-------|
| {name} | {range} | BUG-1, WARN-2 | {brief note} |
| {name} | {range} | None | Clean |

## Analytical Decisions Inventory

| Section | Decision | Current Choice | Justification | Alternatives | Risk Level |
|---------|----------|---------------|---------------|-------------|------------|
| ... | ... | ... | ... | ... | ... |

## Action Items

| Priority | Finding | Action | Owner |
|----------|---------|--------|-------|
| 1 | BUG-1 | Fix immediately | {name} |
| 2 | CONCERN-1 | Investigate | {name} |
```

Save as `{script_name}_audit_report.md` alongside the script or in `outs/`.

---

## Audit Principles

1. **Trace the data, not just the code.** The most important bugs in data science are data flow bugs — silent drops, wrong joins, incorrect baselines. Follow the data from input to output.
2. **Question analytical defaults.** Just because `method = "BH"` is common doesn't mean it's right for this data. Every default is a choice.
3. **Check what's NOT in the script.** Missing validation, missing checks, missing documentation are findings too.
4. **Severity is about impact, not aesthetics.** A confusing variable name is a NOTE. A confusing variable name that leads someone to use the wrong column is a BUG.
5. **Be specific.** "This join might lose rows" is not helpful. "This inner_join on line 47 drops 23 rows because gene_names has entries not in mdata" is actionable.
6. **Run diagnostics, don't guess.** When something looks suspicious, actually run the code to verify before reporting it as a finding.
7. **Credit good practices.** Note when the script does something well — especially defensive coding, good documentation, or thoughtful analytical choices.

---

## Claude Code Behavior

When this skill is active:

- **Be direct, not hedging.** "This join silently drops 50 rows" not "This join might potentially have some issues with row counts."
- **Show evidence.** When flagging an issue, show the specific code and explain exactly what goes wrong. Run diagnostics where possible.
- **Distinguish fact from opinion.** "This uses an inner join that drops rows" (fact) vs. "I think a left join would be better here" (opinion/recommendation). Both are valid but should be clearly distinguished.
- **Don't over-report.** Not every line needs a finding. If a section is clean, say so and move on. Audit fatigue from low-severity noise degrades the value of real findings.
- **Respect the author's context.** In collaborative mode, the author may have reasons for choices that aren't documented. Ask before assuming something is wrong.
- **Track uncertainty.** If you're not sure whether something is a bug or intentional, say so. "This might be intentional, but if not, it would cause..." is better than a false positive or a missed bug.
- **In thorough mode: don't pre-digest.** Let the user read and run the code first. Ask questions, don't give answers. The user finding issues themselves is the point.
- **In fast mode: be comprehensive.** You're working alone — don't skip sections or categories. The user is counting on your thoroughness because they're not reading every line.
