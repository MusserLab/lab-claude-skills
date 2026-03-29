---
name: expression-report
description: >
  Generate single-cell gene expression report scripts (.qmd) with barplots, heatmaps,
  and cross-analysis. Use when creating expression reports for gene sets across cell types,
  visualizing gene expression patterns in single-cell data, or when the user says
  "expression report", "gene expression barplots", "expression heatmap", or wants to
  visualize how a gene list is expressed across cell types. Covers both categorical
  gene groupings (pathway components, functional categories) and data-driven groupings
  (taxonomy, coexpression modules). Currently Python/scanpy/matplotlib only.
  Do NOT load for differential expression testing, marker gene discovery, or
  clustering — those are upstream analyses that produce gene lists this skill consumes.
user-invocable: false
---

# Expression Report Skill

Generate reproducible `.qmd` scripts for single-cell gene expression reports. The skill
discusses setup with the user, then writes a complete Python/scanpy/matplotlib `.qmd`
template encoding all decisions as configuration variables.

**Reference implementations:**
- Python: `exploration/scripts/scmicrobiome/spongilla/02_nonmetazoan_expression.qmd`
- R: `TiHKAL/scripts/signaling_pathway_reports/generate_pathway_reports.qmd`

**Bundled resources:**
- `templates/report_template.py` — script body chunks (config, normalization, gene matching,
  expression computation, combined heatmap, report loop, cross-analysis, archive)
- `templates/helpers.py` — reusable plotting functions (two-panel heatmap, barplot Style A)
- `references/species_notes.md` — species-specific cell type configurations and quirks

---

## Overview: Two-Phase Workflow

1. **Discuss** — Resolve all setup decisions with the user (inputs, cell types, gene
   labels, barplot style, cross-analysis)
2. **Generate** — Write a complete `.qmd` script following quarto-docs and
   script-organization conventions
3. **Render** — User renders with `quarto render`, producing all outputs in
   `outs/<subdirectory>/XX_script_name/`

---

## Phase 1: Discussion

Resolve these questions **before generating the script**. Present recommendations where
possible; don't just list options.

### 1. Inputs

| Input | What to ask | Notes |
|-------|-------------|-------|
| Single-cell object | File path (`.h5ad`) | Check it exists; report shape |
| Gene list | File path (TSV with `gene_id` + grouping columns) | Read and show column names, row count |
| Primary group column | Which column defines the main grouping | e.g., `"kingdom"`, `"pathway"`, `"module"` |

**Validation steps:**
- Load the h5ad, report `n_obs` x `n_vars`, check if counts are raw (max > 20) or
  log-normalized (max < 20)
- Load the gene list TSV, show columns and first few rows
- Test gene ID matching: how many gene list IDs match h5ad var_names? Report match rate.
  If < 80%, investigate ID format mismatch (underscores vs dashes, prefix differences)

### 2. Gene labeling

**Default: use the full gene name from the single-cell object's var_names.** Do not parse
or abbreviate — show what's in the object. This ensures labels match the authoritative
gene naming in the dataset.

- The gene list's `h5ad_name` column (populated during gene ID matching) contains the full
  var_name from the object. Use this directly as the plot label.
- **Do NOT parse gene symbols out of var_names.** The full annotation is the label.
- **Deduplication**: append `#2`, `#3` for duplicate display names if needed.

### 3. Cell type setup

**Check `references/species_notes.md` for known species-specific quirks before proposing
defaults.** If the species has an entry, pre-populate family assignments, ordering, and
colors from it.

**Default: named cell types only.** Numbered/transitional clusters are excluded unless the
user specifically requests them.

Read cell type info directly from the h5ad `.obs`:

1. **Detect columns** — scan `.obs` for likely cell type columns (look for "cell_type",
   "cluster", "annotation", "celltype" in column names). Show the user what you find.
2. **Detect family column** — look for a family/group column. If found, propose
   family-based ordering and coloring.
3. **Ask which clusters are transitional** — not all transitional clusters are just numbers.
   Some datasets have named transitional types. Ask the user to mark exclusions.
4. **Named vs all** — Recommend **named cell types only**. Offer "all clusters" and "both
   (two versions of every plot)" as alternatives.
5. **Propose ordering** — present cell types grouped by family, ask user to confirm or
   reorder.
6. **Assign colors** — auto-assign from Nature palette by family. User can override.

### 4. Cell type ordering

**Ordering is family-grouped, user-confirmed.** The skill proposes an order, the user
adjusts if needed. The final order must be explicitly confirmed by the user. Store it as
a list in the configuration chunk so it can be edited later.

### 5. Barplot style

**All barplots use linear scale (mean CPT).** Present the two styles:

**Style A: Cell type family coloring** (recommended for exploratory / large gene sets)
- Bars colored by cell type family (Nature palette)
- 2 columns x 6 rows grid, portrait orientation
- Gene ordering by hierarchical clustering of expression profiles
- Dashed family separators + family legend on page 1
- X-axis labels on every subplot

**Style B: Gene category coloring** (recommended for curated functional categories)
- Bars colored by gene's functional category
- `facet_wrap` style with 4 columns
- Gene ordering by category, then alphabetical

**Recommendation logic:** If the gene list has a functional category column with <=8
categories, recommend Style B. Otherwise recommend Style A.

### 6. Sub-grouping

- Ask if there's a secondary column for splitting within primary groups
- Sub-group threshold: minimum 5 genes for own plots; smaller groups lumped into "Other"

### 7. Cross-analysis

- **Expression summary** — bar chart: genes per group, fraction expressed (always include)
- **Cell type enrichment** — fraction of top-expressed genes per cell type vs genome-wide
  base rate. Only meaningful when the gene set is a defined fraction of the genome.
- **Group x cell type heatmap** — mean expression per group, two panels: linear + z-score.
  Useful when there are >=4 groups.

### 8. Integration markers (optional)

Ask if other datasets should be intersected with the gene list to add markers (e.g.,
`*` for phosphoproteomics hits). This is optional and project-specific.

---

## Phase 2: Template Generation

Once all decisions are resolved, generate a `.qmd` script.

### Naming and placement

Follow the script-organization skill:
- Script: `scripts/<subdirectory>/XX_name.qmd` (next available number — **always `ls` first**)
- Outputs: `outs/<subdirectory>/XX_name/`
- Register in project CLAUDE.md script table

### .qmd structure

Generate a Python `.qmd` with these sections in order. Read `templates/report_template.py`
and `templates/helpers.py` for the code patterns to insert into each chunk:

1. **YAML frontmatter** (standard quarto-docs Python template)
2. **Setup chunk** (PROJECT_ROOT, out_dir, git_hash, imports, archive logic)
3. **Configuration chunk** — all user decisions as named variables
4. **Inputs chunk** (load h5ad + gene list, validate)
5. **Gene ID mapping chunk** (match gene list IDs to h5ad var_names)
6. **Cell type setup chunk** (ordering, families, colors, boundaries)
7. **Expression computation chunk** (normalize, compute mean per cell type)
8. **Helper functions chunk** (heatmap + barplot functions from `templates/helpers.py`)
9. **Combined all-genes heatmap** (if <=100 genes — with category color sidebar)
10. **Report generation loop** (per-group, per-sub-group)
11. **Cross-analysis chunk** (summary, enrichment, group x cell type heatmap)
12. **Build info chunk** (standard BUILD_INFO.txt)

---

## Color Palettes

### Nature palette (cell type families and categories)

```python
NATURE_PALETTE = [
    "#BC3C29",  # Brick red
    "#0072B5",  # Steel blue
    "#20854E",  # Forest green
    "#E18727",  # Amber
    "#7876B1",  # Muted purple
    "#6F99AD",  # Slate blue
    "#EE4C97",  # Rose
    "#868686",  # Gray
]
```

### Expression heatmap colormap

White -> steel blue -> navy (`#FFFFFF` -> `#3182BD` -> `#08306B`)

### Z-score heatmap

Diverging `RdBu_r` with `TwoSlopeNorm` centered at 0.

---

## Anti-Patterns (MUST AVOID)

These were learned through iterative development. Do not repeat them.

### Data handling
- **NEVER apply `expm1()` without checking** — if `X.max() > 20`, it's raw counts
- **NEVER parse or abbreviate gene names** — use the full var_name from the h5ad object
- **NEVER trust a single best hit** — require hits from >=3 species for kingdom signals

### Visualization
- **NEVER omit x-axis labels on barplots** — every subplot must show rotated cell type names
- **NEVER use garish primary colors** — use Nature-style muted palette
- **NEVER use 3x4 landscape barplots** — portrait 2x6 is more readable
- **NEVER save individual page PDFs** — combine into single multi-page PDF
- **NEVER sort barplots by max expression** — hierarchical clustering is more informative
- **NEVER show only top-N genes** — show all expressed genes (up to max_pages)
- **NEVER show all clusters by default** — recommend named cell types only

### Analytical
- **NEVER assume DE testing filters pre-selected gene sets** — it's overpowered (~75-85% pass)
- **NEVER show only z-scored heatmaps** — show linear + z-score side by side
- **NEVER show only family-level averages** — cell-type-level is the primary view
- **NEVER leave stale outputs** — archive must capture files AND subdirectories

---

## Output Structure

```
outs/<subdirectory>/XX_name/
  all_genes_heatmap.pdf/.png      # Combined heatmap if <=100 genes
  expression_summary.pdf/.png     # Genes per group, fraction expressed
  group_celltype_heatmap.pdf/.png # Group x cell type (linear + z-score)
  gene_summary.tsv                # All genes with expression info
  BUILD_INFO.txt                  # Provenance
  _archive/                       # Previous runs
  group_slug_1/                   # Per-group subdirectory
    gene_list.tsv
    heatmap.pdf/.png
    barplots.pdf/.png
  group_slug_2/
    ...
```

### Combined all-genes heatmap layout

When <=100 expressed genes, the combined heatmap uses:
- **Category color sidebar on the RIGHT side** (not left) to avoid overlapping gene labels
- Two heatmap panels: linear (mean CPT) + z-score
- Category legend at bottom

---

## Future: R/Seurat Template

Not yet implemented. When added, the R template will use:
- Seurat `DotPlot` for dotplots
- `pheatmap` with category row annotations for heatmaps
- `ggplot2` + `facet_wrap` for Style B barplots
- Same configuration-at-top pattern, adapted to R syntax
