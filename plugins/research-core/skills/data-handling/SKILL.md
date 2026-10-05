---
name: data-handling
description: >
  What to tell the user while working with their data: reporting as you go, verifying join keys,
  surfacing ambiguities, and which analytical choices to bring them before writing the analysis.
  Use when writing or editing code that filters, joins, merges, normalizes, subsets or aggregates
  a dataset, and when diagnosing a data problem. Do NOT load for general Python scripting or
  infrastructure code.
---

# Data Handling

This skill is about **what you tell the user** while working with their data. It is not a guide to
writing R or Python. File layout, script numbering and output conventions belong to the
`script-organization` skill.

## Report as you go

**Every significant operation prints its numbers into the script's output** — dimensions, coverage,
join results, filter impact. That is the complete record, and it is not optional. Silently writing
code that produces plausible-looking output is how wrong join keys and column collisions survive
into published results.

- **Dimensions** — "Loaded 39,562 genes × 18 samples"
- **Coverage** — "29,753 genes matched (75%), 9,809 unmatched"
- **Join results** — "Left join added annotations; 18,943 with real names, 20,619 with Trinity ID fallback"
- **Filter impact** — "After quality filter: 5,335 of 7,943 genes retained (67%)"

**What enters the conversation is a subset.** Replaying every diagnostic buries the one number that
matters under nineteen that behaved. Bring the user:

1. **The headline figures** that establish scale — what went in, what came out.
2. **Anything that could affect validity or interpretation, suggest data loss or mismatched inputs,
   or remain unexplained after initial investigation — surface it immediately.** Investigate
   routine discrepancies yourself; do not ask permission merely to check why. If dependent work
   could be affected, pause after characterizing what is known and unknown and give a recommendation.
   - "I expected ~18,000 annotated genes but only see 3,940. I'm checking the inputs and join keys
     before proceeding."
   - "This join dropped 50 rows, more than expected. I'm checking why before relying on it."
   - "The `seurat_name` column is mostly bare Trinity IDs. The key formats match, but the low
     annotation coverage is still unexplained, so I'm stopping before using it downstream."

Everything else is summarised at the review stop, where the user decides how deeply to look.
Resolved data problems belong in that summary: state what was wrong, what was corrected, the
evidence for the correction and how many cases were affected. Resolution does not make the
problem disappear from the report; it need not interrupt work when the correction is straightforward.

## Check join keys before joining

Verify the key *values*, not just that both tables have a column with the right name.

- `head()` alone misleads when the early rows are unrepresentative — unannotated entries often sort
  first. Sample instead, or check the distribution.
- Confirm the format matches on both sides: hyphen vs underscore, bare ID vs annotated string,
  string vs integer, trailing whitespace.
- Count the prospective matches before committing to the join:

```r
sum(table_a$key %in% table_b$key)
```

```python
table_a["key"].isin(table_b["key"]).sum()
```

- Report what you find: "Join key `Geneid` is `c12345-g1` for 30k genes but `c12345-g1 Annotation…`
  for 10k — those won't match `Trinity_geneID`."

## Surface ambiguities — report, or ask

Two different obligations with very different costs. Do not collapse them.

**Report it and keep working.** Visible in the output and raised at the review, but not a stop:

- Straightforward, documented corrections that preserve the agreed scientific meaning, such as
  applying an established identifier alias without excluding or reclassifying cases
- Rows that don't join, on both sides — how many, with examples
- Values matching no known category — list them, label them `"unmatched"` or `NA`
- What lands in the catch-all / `else` branch of any conditional logic
- Assumptions about data structure that aren't documented anywhere

**Investigate, then stop and ask** — only when continuing would cross the attention threshold:

- The correction is not straightforward or its scientific consequences are uncertain
- Resolving it requires a scientific or analytical choice that is not already settled
- An unexplained discrepancy could affect validity, results, or interpretation
- Continuing would conceal uncertainty, risk data loss, or make unmatched cases disappear into a
  real category
- Group independent related choices for discussion; resolve dependent choices in order

**Never use a silent catch-all default.** A safe-looking default is the most common way a real data
problem gets masked.

## Bring the user the choices that change the answer

The shared Research Core agent collaboration instructions keep consequential scientific choices
with the researcher and routine implementation with the agent. This section is the working list.

Before writing the analysis, identify which of these choices remain unresolved. If a project plan
or genuinely comparable prior analysis already records a choice, check that the scientific question
and data are sufficiently similar, briefly remind the user in plain language how it was handled,
and ask whether to reuse that approach instead of reopening every technical detail. Bring unresolved
choices before the work that depends on them — a different answer changes the result or how it
should be read. Exploratory choices that need future evidence may remain open while agreed
investigations proceed:

- **Normalization method** — TMM vs RLE vs quantile vs none; when multiple valid options exist
- **Background/reference sets** — which gene universe for GO/pathway analysis
- **Design matrix structure** — how to model experimental factors, interactions
- **Comparisons to run** — which contrasts for differential analysis
- **Filtering thresholds** — expression cutoffs, quality filters
- **Statistical tests** — parametric vs non-parametric, paired vs unpaired
- **Multiple testing correction** — FDR method, significance thresholds
- **Scaling/transformation** — log2, z-score, VSN; pseudocount values
- **Batch correction** — whether to apply, which method
- **Missing data handling** — imputation method, exclusion criteria
- **Clustering parameters** — distance metric, linkage method, number of clusters

**How to ask:** actively elicit the scientist's vision and reasoning, then follow the phase's
consequential decision branches with detailed follow-up questions. A proposed solution and an
"okay" do not replace alignment through discussion. Give context, concrete options and trade-offs,
your recommendation where useful and why.
Group independent related choices; ask dependent questions sequentially, and defer those that
need later evidence. Use representative input-to-interpretation examples when they expose a
consequential assumption. Aim for as much autonomous scientific work as the agreed approach permits,
while identifying where the user's intellectual contribution is useful. Agree anticipated
discussions and return with evidence when discoveries create a new need for joint scientific
thinking; update the affected approach and clarify what may continue afterward.
Wait for unresolved consequential answers before dependent implementation; routine diagnostics
and reversible work within the agreed approach remain the agent's responsibility.

**Everything else you decide yourself**, then list those decisions at the review so the user can
push back if you called one wrong. "Routine" means a different answer would not change the result
or how it is read — not that the code change was small.

## Operations that lose data silently

These produce a confidently wrong number with no error and no warning. Check for them by name.

**R**

- `lm()` / `glm()` — the usual `na.action = na.omit` omits observations missing variables in the
  model; the configured action can differ. Check actual omissions, not NAs in unrelated columns.
- `limma::lmFit()` — accepts missing expression values and fits each gene with its available
  observations; it does not discard every gene row containing an NA. Check per-gene missingness
  and estimability before interpreting the fit.
- `cor(use = "complete.obs")` — excludes incomplete cases
- Many functions default to `na.action = na.omit`
- `as.numeric()` on character — introduces NAs
- Factor subsetting retains unused levels by default (`drop = FALSE`). Explicit `drop = TRUE`,
  `droplevels()` or re-factoring can remove them; check the intended categories before dropping levels.

**Python**

- `pd.merge(how="inner")` — drops unmatched rows on both sides
- `df.groupby()` — excludes NA keys unless `dropna=False`
- `.value_counts()` — excludes NaN unless `dropna=False`
- `pd.to_numeric(errors="coerce")` — silently manufactures NaN
- `df.dropna()` on a wide frame — removes far more rows than expected
- Chained indexing (`df[cond]["col"] = val`) — may fail silently; use `.loc[]`

**Both**

- `na.rm = TRUE` / `skipna=True` on `mean`, `sum`, `sd` — report how many were ignored
- ggplot2 and matplotlib drop NA rows and clip data outside axis limits without saying so
- Faceting and subplotting hide groups that have no data
- limma, DESeq2 and edgeR apply their own default filters

## Two traps that have actually bitten

**Column collisions from repeated joins.** Joining the same annotation table at two points in one
script — `gene_names[, c("id", "name", "label")]` in section 3 and again in section 8 — silently
produces `label.x` and `label.y`. Join once and carry the result forward, or join only the columns
needed at each point.

**Bioconductor masking dplyr.** Loading DESeq2, edgeR or AnnotationDbi imports S4 generics that mask
`rename()`, `select()`, `filter()`, `count()`, `slice()`. Use `dplyr::` explicitly whenever both are
loaded in the same session.

## What belongs in the script

- Group all input reads at the top, commented to distinguish external data from another script's
  outputs. See `script-organization` for the convention.
- Print a summary wherever a dataset is created or substantially changed: after loading, after
  filtering, after joins, after aggregation, after normalization, before plotting.
- Comment the *reasoning*, not the mechanics — why this threshold, why this normalization, why this
  test, what is being assumed, where a default was deviated from.
- Assert what must be true: required columns exist, the result is not empty, key columns have no
  unexpected NAs.
- Never decompress into `data/`. Decompress to `outs/<script>/` and record the original compressed
  source in the inputs section.
