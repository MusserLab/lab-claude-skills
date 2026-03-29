---
name: audit-script
description: >
  Systematic audit of data analysis scripts for bugs, analytical reasoning, data handling, style,
  and reproducibility. Includes domain verification phase that researches tools, file formats, and
  methods to catch domain-specific errors (not just code bugs). Use when auditing a script,
  reviewing code for correctness, checking for bugs, preparing a script for publication, or when
  the user says "audit this script", "review this code", "check this for bugs", or "is this
  script correct". Three modes: thorough (collaborative section-by-section), fast (Claude-driven
  with discussion), and report-only. Do NOT load for quick one-off questions about a single line
  or function.
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

### Core Philosophy: Simplicity First

**The goal of an audit is NOT to make scripts handle every possible edge case.** Data science
scripts should be simple, clean, easy to read, and well-annotated. Adding defensive code for
hypothetical problems makes scripts harder to read, which is the opposite of what we want.

The audit should:
- **Flag real bugs** that produce wrong results in the script's actual use case
- **Flag analytical decisions** that affect interpretation (undocumented, questionable, or missing)
- **Flag clarity problems** — code that's hard to follow, poorly annotated, or unnecessarily complex
- **Note theoretical issues as awareness items**, not action items — "be aware that `get(load(f))`
  is fragile if files contain multiple objects" is useful context; "rewrite to use `new.env()`"
  is over-engineering a one-time script
- **Actively flag over-engineering** — unnecessary validation, defensive code for impossible cases,
  and abstraction-for-its-own-sake are style findings, not good practices

**Context matters.** A one-time conversion script that processes a known, fixed dataset needs
different treatment than a reusable pipeline that will see unknown inputs. The audit must
calibrate its recommendations to the script's actual role.

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

## Domain Verification Phase

**This phase runs in all modes** (thorough, fast, report-only) before the code audit begins.
Its purpose is to close the gap between code-level review and domain-specific correctness by
researching the actual tools, file formats, and analytical methods the script uses — then
auditing the code against that verified knowledge rather than relying on background familiarity.

### Why This Matters

The most dangerous bugs in bioinformatics and data science aren't code bugs — they're
**misunderstandings of what the tools and data actually do.** A script can be syntactically
correct, logically clean, and still produce wrong results because the author (or reviewer)
didn't know that:
- BAM files store each alignment as a separate record (naive iteration overcounts multimappers)
- Cell Ranger uses MAPQ 255 for unique mapping (non-standard; SAM spec uses ≤60)
- `inner_join` silently drops unmatched rows
- GFF3 coordinates are 1-based inclusive, BED is 0-based half-open

These are **domain assumptions** — facts about tools, formats, and methods that the code
depends on but doesn't state. The domain verification phase makes them explicit and checks them.

### How It Works

#### 1. Inventory Tools, Formats, and Methods

After reading the script, identify every external dependency the code relies on:

- **File formats** being read or written (BAM/SAM, BED, GFF3, VCF, FASTA, CSV, H5AD, etc.)
- **Bioinformatics tools** called via subprocess or library (minimap2, STAR, Cell Ranger,
  BLAST, samtools, pysam, scanpy, Seurat, etc.)
- **Statistical methods** or analytical approaches (normalization, clustering, differential
  expression, multiple testing correction, etc.)
- **Library-specific behaviors** (how pysam iterates BAM records, how pandas handles NAs in
  groupby, how ggplot2 drops NAs in aesthetics, etc.)

#### 2. Research Critical Assumptions

For each tool/format/method, use **WebSearch and WebFetch** to pull the relevant documentation
and identify the critical behaviors the code must handle correctly. Focus on:

- **Record structure:** What does one "row" or "record" represent? (A read? An alignment?
  A gene? A transcript?)
- **Coordinate systems:** 0-based vs 1-based? Half-open vs closed? Does the code convert
  correctly?
- **Default behaviors:** What does the tool do silently? (Drop unmapped reads? Merge
  overlapping features? Sort output?)
- **Flag/field semantics:** What do specific values mean? (MAPQ 255, SAM flags, GFF3
  attribute encoding)
- **Edge cases:** What happens with empty input, missing values, duplicate keys, very long
  sequences, special characters?
- **Known gotchas:** What do people commonly get wrong with this tool/format? (Community
  forums, GitHub issues, tool FAQs)

Produce a **Domain Assumptions Checklist** — a concrete list of facts that the code depends on,
each verified against documentation. Format:

```
DOMAIN ASSUMPTIONS CHECKLIST
─────────────────────────────
Tool/Format: pysam + BAM
  ✓ Each multimapped read appears as multiple records (primary + secondary)
  ✓ Iterating bam.fetch() yields alignments, not reads — must deduplicate by query_name
  ✓ MAPQ 255 = uniquely mapped (Cell Ranger convention; standard SAM caps at 60)
  ✓ is_secondary (flag 0x100) vs is_supplementary (flag 0x800) are different categories
  ? PCR duplicate marking in Cell Ranger BAMs — need to verify

Tool/Format: BED
  ✓ 0-based, half-open coordinates (start inclusive, end exclusive)
  ✓ Converting from GFF3 (1-based inclusive): subtract 1 from start, keep end as-is

Method: minimap2 cross-species mapping
  ✓ -k 10 appropriate for short ncRNAs (default k=15 misses tRNAs)
  ✓ --secondary=yes needed for multi-copy genes (rRNA arrays)
  ? Alignment quality thresholds for cross-species mapping — worth checking
```

Mark each assumption: ✓ (verified against docs), ✗ (contradicted by docs — potential BUG),
? (couldn't verify — flag for manual review).

#### 3. Audit Code Against Checklist

With the checklist in hand, trace through the code and verify that each assumption is handled
correctly. This is where domain verification feeds into the standard audit:

- An assumption marked ✗ becomes a **BUG** or **CONCERN** finding
- An assumption marked ? becomes a **WARNING** with "needs manual domain review"
- An assumption marked ✓ that the code handles incorrectly becomes a **BUG**
- An assumption marked ✓ that the code handles correctly is noted as a **Good Practice**

#### 4. Recommend Assumption Blocks

After the audit, recommend that the script include an explicit **ASSUMPTIONS block** documenting
the critical domain assumptions the code depends on. This makes future audits faster and helps
students understand what the code takes for granted:

```python
# ASSUMPTIONS (verified against Cell Ranger 9.0 docs, SAM spec v1.6):
# - BAM iteration yields alignments, not reads; we deduplicate via seen_reads set
# - MAPQ 255 = uniquely mapped (Cell Ranger convention, not standard SAM)
# - PCR duplicates are NOT marked in possorted_genome_bam.bam
# - is_secondary and is_supplementary alignments are skipped (primary only)
# - GFF3 coordinates are 1-based inclusive; converted to 0-based for pysam fetch
```

### Depth Scaling

The depth of domain verification scales with audit mode and script complexity:

- **Report-only:** Quick checklist from background knowledge + targeted web searches for
  unfamiliar tools. Flag unknowns as ? rather than spending time researching deeply.
- **Fast:** Full research phase with web searches. Produce verified checklist. Flag remaining
  unknowns for discussion.
- **Thorough:** Full research phase, then walk through the checklist with the user before
  starting the code audit. The user adds domain knowledge ("we verified this threshold
  experimentally"), resolves ? items, and may flag additional assumptions the checklist missed.

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
- **Over-engineering** — unnecessary defensive code, validation for impossible cases,
  abstractions that add complexity without benefit. Simple, readable code is a feature.

### 5. Reproducibility
- Hardcoded paths or values
- Missing seed setting for random operations
- Environment dependencies (packages not loaded, conda env not specified)
- Missing input file documentation
- Output not clearly tied to input versions
- Platform-specific code without fallbacks

---

## Severity Levels

- **BUG** — Incorrect behavior; produces wrong results *in the script's actual use case*. Must fix.
- **CONCERN** — Analytically questionable; may produce misleading results. Should investigate.
- **WARNING** — Not wrong, but fragile or risky. Should address.
- **NOTE** — Style, clarity, or minor improvement. Nice to fix.
- **FYI** — A pattern or assumption worth being aware of, but not something to change. Used for
  theoretical fragilities that don't apply to the script's actual context (e.g., a function that
  would break with different input, but the input is known and fixed). These are informational —
  the author should understand them but not act on them.

### Severity Calibration

Before assigning severity, consider:
- **Is this a real problem or a theoretical one?** If the script processes a known, fixed dataset
  and the "issue" only manifests with different input, it's FYI, not BUG.
- **Would the fix make the script simpler or more complex?** If more complex, the cure may be
  worse than the disease. Defensive code that handles impossible cases is a style problem.
- **Is this a one-time script or a reusable pipeline?** One-time scripts should be simple and
  correct for their specific task. Reusable pipelines need more robustness.

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

### 2. Domain Verification (collaborative)

Run the full Domain Verification Phase (see above). In thorough mode:
- Research tools and formats, produce the Domain Assumptions Checklist
- Present the checklist to the user before starting the code walk-through
- Walk through each assumption: "I found that Cell Ranger uses MAPQ 255 for unique mapping —
  does that match your understanding?"
- The user adds domain knowledge, resolves ? items, and may flag assumptions the checklist missed
- This step builds shared understanding of what the code *should* do before examining whether
  it actually does

### 3. Section-by-Section Audit

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

### 4. Cross-Section Analysis

After all individual sections:
- Trace data flow across the full script together
- Check: do transformations in section A affect correctness in section D?
- Look for cascading issues (e.g., silent drop early → wrong denominator later)
- Verify the overall analytical argument holds together
- Look for things the script should be doing but isn't (missing validation, missing checks)

### 5. Produce and Save Audit Report

Compile findings documented throughout into the structured report format (see below).
Save the report to `.claude/audit_reports/` (see "Audit Report Format" for details).

### Pacing

Every 2-3 sections, briefly check in: "How's the depth? Want to go faster or deeper?"

---

## Fast Mode: Claude-Driven Audit with Discussion

Claude works through the script independently, then discusses findings with the user.

### 1. Full Script Read

Read the entire script.

### 2. Domain Verification

Run the full Domain Verification Phase (see above). In fast mode:
- Research tools and formats via web searches
- Produce verified Domain Assumptions Checklist
- Flag remaining unknowns (?) for discussion with the user
- Audit code against the checklist as part of the systematic analysis

### 3. Systematic Analysis

Apply the 5-category checklist across all sections:
- Trace data flow from input to output
- Check analytical reasoning and statistical assumptions
- Look for silent data loss, unvalidated joins, missing checks
- Evaluate style, organization, and reproducibility
- Run diagnostics where possible (dimension checks, NA counts, join validation)
- **Check code against the Domain Assumptions Checklist** — verify each assumption is handled

### 4. Produce and Save Audit Report

Full structured report with all findings, including Domain Assumptions Checklist.
Save the report to `.claude/audit_reports/` (see "Audit Report Format" for details).

### 5. Collaborative Review of Findings

Present findings to the user, ordered by severity (BUG first):
- For each finding: show the code, explain the issue, discuss implications
- **Present unresolved domain assumptions (? items)** for the user's domain input
- User adds context, agrees/disagrees, reclassifies severity
- Together decide: fix now, defer, mark as acceptable
- New issues can surface during discussion
- Report updated with collaborative decisions and final dispositions

---

## Report-Only Mode

Same as fast mode steps 1-4. No collaborative review. Produces the report and saves it
to `.claude/audit_reports/`. Findings are marked as "Unreviewed" in the status column.

In report-only mode, domain verification uses background knowledge + targeted web searches.
Unknown assumptions are flagged as ? in the checklist for the user to review independently.

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
- **By severity:** {N} BUG, {N} CONCERN, {N} WARNING, {N} NOTE, {N} FYI
- **By category:** {N} Correctness, {N} Analytical, {N} Data Handling, {N} Style, {N} Reproducibility
- **Overall assessment:** {1-2 sentence summary of script quality and most critical issues}

## Domain Assumptions Checklist

| Tool/Format | Assumption | Verified? | Code Handles? | Finding |
|-------------|-----------|:---------:|:-------------:|---------|
| {tool} | {assumption} | ✓ / ✗ / ? | Yes / No / N/A | {ref or "OK"} |

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

### FYI-1: {Short description}
- **Category:** {category}
- **Lines:** {line range}
- **Description:** {What the pattern is and why it's worth knowing about}
- **Why not an action item:** {Why this doesn't need to change in this script's context}

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

**Always save the report** to `.claude/audit_reports/{script_name}_audit_report.md` in the
project root. Create the `.claude/audit_reports/` directory if it doesn't exist. Every audit
must produce a saved report file — this is not optional.

---

## Audit Principles

1. **Trace the data, not just the code.** The most important bugs in data science are data flow bugs — silent drops, wrong joins, incorrect baselines. Follow the data from input to output.
2. **Question analytical defaults.** Just because `method = "BH"` is common doesn't mean it's right for this data. Every default is a choice.
3. **Check what's NOT in the script.** Missing validation, missing checks, missing documentation are findings too.
4. **Severity is about impact, not aesthetics.** A confusing variable name is a NOTE. A confusing variable name that leads someone to use the wrong column is a BUG.
5. **Be specific.** "This join might lose rows" is not helpful. "This inner_join on line 47 drops 23 rows because gene_names has entries not in mdata" is actionable.
6. **Run diagnostics, don't guess.** When something looks suspicious, actually run the code to verify before reporting it as a finding.
7. **Credit good practices.** Note when the script does something well — especially clean structure, good documentation, or thoughtful analytical choices.
8. **Verify domain assumptions, don't assume.** When the code depends on tool/format behavior, look it up rather than relying on background knowledge. A verified assumption is worth ten educated guesses.
9. **Simplicity is a virtue, not a gap.** A script that does its job cleanly without handling every edge case is well-written, not incomplete. Recommend adding code only when it solves a real problem. If a finding's recommended fix would make the script longer and harder to read, reconsider whether it's worth reporting as an action item — it may be better as an FYI.
10. **Calibrate to the script's role.** A one-time conversion script on a known dataset needs different rigor than a reusable pipeline. Don't treat every script as if it will be rerun on unknown inputs.

---

## Claude Code Behavior

When this skill is active:

- **Be direct, not hedging.** "This join silently drops 50 rows" not "This join might potentially have some issues with row counts."
- **Show evidence.** When flagging an issue, show the specific code and explain exactly what goes wrong. Run diagnostics where possible.
- **Distinguish fact from opinion.** "This uses an inner join that drops rows" (fact) vs. "I think a left join would be better here" (opinion/recommendation). Both are valid but should be clearly distinguished.
- **Don't over-report.** Not every line needs a finding. If a section is clean, say so and move on. Audit fatigue from low-severity noise degrades the value of real findings.
- **Protect simplicity.** The audit should never push scripts toward unnecessary complexity. If a recommendation would make the code longer and harder to read to handle a theoretical edge case, use FYI severity instead. Actively flag existing over-engineering as a style finding — unnecessary defensive code is clutter.
- **Respect the author's context.** In collaborative mode, the author may have reasons for choices that aren't documented. Ask before assuming something is wrong.
- **Track uncertainty.** If you're not sure whether something is a bug or intentional, say so. "This might be intentional, but if not, it would cause..." is better than a false positive or a missed bug.
- **In thorough mode: don't pre-digest.** Let the user read and run the code first. Ask questions, don't give answers. The user finding issues themselves is the point.
- **In fast mode: be comprehensive.** You're working alone — don't skip sections or categories. The user is counting on your thoroughness because they're not reading every line.
- **Do not use subagents for audits.** Run the audit directly in the current conversation. Subagents may lack tool permissions and cannot reliably save reports or verify scripts. For independent audits, use a separate Claude Code session instead.
