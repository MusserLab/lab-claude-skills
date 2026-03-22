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
- Load the h5ad, report `n_obs` × `n_vars`, check if counts are raw (max > 20) or
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
- When the naming pipeline is complete, var_names will contain curated names that reflect
  the best understanding of orthology/homology. No conflict between gene finding and display.
- **Do NOT parse gene symbols out of var_names.** The full annotation is the label.
- **Deduplication**: append `#2`, `#3` for duplicate display names if needed.

### 3. Cell type setup

**Default: named cell types only.** Numbered/transitional clusters are excluded unless the
user specifically requests them.

Read cell type info directly from the h5ad `.obs`:

1. **Detect columns** — scan `.obs` for likely cell type columns (look for "cell_type",
   "cluster", "annotation", "celltype" in column names). Show the user what you find.
2. **Detect family column** — look for a family/group column. If found, propose
   family-based ordering and coloring.
3. **Ask which clusters are transitional** — not all transitional clusters are just numbers.
   Some datasets have named transitional types (e.g., "transitional archaeocyte"). Ask the
   user: "Which of these cell types are transitional or should be excluded from the
   named-only view?" Show the full list and let them mark exclusions.
4. **Named vs all** — Recommend **named cell types only**. Offer "all clusters" and "both
   (two versions of every plot)" as alternatives. If the user wants both, numbered clusters
   are appended after named clusters, grouped by family where possible.
5. **Propose ordering** — present cell types grouped by family, ask user to confirm or
   reorder. See "Cell Type Ordering" section below for details.
6. **Assign colors** — auto-assign from Nature palette by family (see Color Palettes below).
   User can override.

### 4. Cell type ordering

**Ordering is family-grouped, user-confirmed.** The skill proposes an order, the user
adjusts if needed.

**For named cell types only (default):**
- Group by family
- Within each family, order alphabetically (or by a biological progression if the user
  provides one)
- Present the proposed order to the user for confirmation

**For all clusters (when requested):**
- Named clusters first, grouped by family in the same order as above
- Numbered/transitional clusters after, interleaved into their respective family positions
  if family assignments exist, otherwise appended at the end
- Present the proposed order to the user for confirmation

**The final order must be explicitly confirmed by the user.** Store it as a list in the
configuration chunk so it can be edited later.

### 5. Barplot style

**All barplots use linear scale (mean CPT).** This matches the heatmap default and shows
true expression magnitudes.

Present the two styles and recommend based on context:

**Style A: Cell type family coloring** (recommended for exploratory / large gene sets)
- Bars colored by cell type family (Nature palette)
- 2 columns × 6 rows grid, portrait orientation
- Gene ordering by hierarchical clustering of expression profiles
- Dashed family separators + family legend on page 1
- **X-axis labels on every subplot** — rotated cell type names

**Style B: Gene category coloring** (recommended for curated functional categories)
- Bars colored by gene's functional category
- `facet_wrap` style with 4 columns
- Gene ordering by category, then alphabetical
- Best when genes have meaningful functional labels (Ligand/Receptor/etc.)

**Recommendation logic:** If the gene list has a functional category column with ≤8
categories, recommend Style B. Otherwise recommend Style A.

### 6. Sub-grouping

- Ask if there's a secondary column for splitting within primary groups (e.g., phylum
  within kingdom, subcategory within pathway)
- Sub-group threshold: minimum 5 genes for own plots; smaller groups lumped into "Other"

### 7. Cross-analysis

Present options based on context:
- **Expression summary** — bar chart: genes per group, fraction expressed (always include)
- **Cell type enrichment** — fraction of top-expressed genes per cell type in each group vs
  genome-wide base rate. Only meaningful when the gene set is a defined fraction of the
  genome (e.g., "all non-metazoan genes" but not "curated Wnt pathway genes")
- **Group × cell type heatmap** — mean expression per group, groups vs cell types. Two
  panels: linear (mean CPT) + z-score. Useful when there are ≥4 groups.

### 8. Integration markers (optional)

Ask if other datasets should be intersected with the gene list to add markers (e.g.,
`*` for phosphoproteomics hits, `+` for transcriptomics DE hits). This is optional and
project-specific.

---

## Phase 2: Template Generation

Once all decisions are resolved, generate a `.qmd` script.

### Naming and placement

Follow the script-organization skill:
- Script: `scripts/<subdirectory>/XX_name.qmd` (next available number — **always `ls` first**)
- Outputs: `outs/<subdirectory>/XX_name/`
- Register in project CLAUDE.md script table

### .qmd structure

Generate a Python `.qmd` with these sections in order:

1. **YAML frontmatter** (standard quarto-docs Python template)
2. **Setup chunk** (PROJECT_ROOT, out_dir, git_hash, imports, archive logic)
3. **Configuration chunk** — all user decisions as named variables
4. **Inputs chunk** (load h5ad + gene list, validate)
5. **Gene ID mapping chunk** (match gene list IDs to h5ad var_names)
6. **Cell type setup chunk** (ordering, families, colors, boundaries)
7. **Expression computation chunk** (normalize, compute mean per cell type — both log and linear)
8. **Helper functions chunk** (three-panel heatmap + barplot functions)
9. **Combined all-genes heatmap** (if ≤100 genes — with category color sidebar)
10. **Report generation loop** (per-group, per-sub-group)
11. **Cross-analysis chunk** (summary, enrichment, group × cell type heatmap)
12. **Build info chunk** (standard BUILD_INFO.txt)

---

## Template Code Patterns

### Configuration chunk

```python
#| label: config

# ---- Report Configuration ----
# Resolved during setup discussion; change here to re-run with different options.

# Gene list
GENE_LIST_PATH = PROJECT_ROOT / "path/to/gene_list.tsv"
GENE_ID_COL = "gene_id"                    # Column with gene IDs matching h5ad
GROUP_COL = "kingdom"                       # Primary grouping column
SUBGROUP_COL = "phylum"                     # Secondary grouping (None if not used)
LABEL_COL = "plot_label"                    # Column for display labels (or None to construct)
SUBGROUP_THRESHOLD = 5                      # Min genes for own plots; rest → "Other"

# Single-cell data
H5AD_PATH = PROJECT_ROOT / "path/to/data.h5ad"
CELLTYPE_COL = "cell_type_abbreviation"     # Column in .obs for cell type labels
FAMILY_COL = "cell_type_family"             # Column in .obs for family grouping (or None)

# Cell type selection
SHOW_CELL_TYPES = "named"                   # "named" (default), "all", or "both"
TRANSITIONAL_CLUSTERS = []                  # Cluster names to exclude from named-only view

# Visualization
BARPLOT_STYLE = "A"                         # "A" (family-colored) or "B" (category-colored)
EXPRESSION_THRESHOLD = 0.03                 # Min log(CPT+1) to count as "expressed"
MAX_BARPLOT_PAGES = 4                       # Max pages per barplot PDF

# Cross-analysis
RUN_ENRICHMENT = True                       # Cell type enrichment analysis
RUN_GROUP_HEATMAP = True                    # Group × cell type heatmap
```

### Normalization detection

```python
#| label: normalize

# Detect if data is raw counts or already normalized
max_val = adata.X.max() if not hasattr(adata.X, 'toarray') else adata.X.toarray().max()

if max_val > 20:
    print(f"Data appears to be raw counts (max = {max_val:.0f})")
    print("Normalizing to CPT (counts per 10,000) + log1p...")
    sc.pp.normalize_total(adata, target_sum=1e4)
    sc.pp.log1p(adata)
else:
    print(f"Data appears to be log-normalized (max = {max_val:.2f})")
    print("Using as-is.")
```

**CRITICAL: Never apply `expm1()` without checking.** If max > 20, it's raw counts, not
log-transformed. Applying `expm1()` to raw counts produces absurd values.

### Gene ID matching

```python
#| label: gene-id-mapping

h5ad_names = set(adata.var_names)
gene_list = pd.read_csv(GENE_LIST_PATH, sep="\t")

# Try exact match first
gene_list["h5ad_match"] = gene_list[GENE_ID_COL].isin(h5ad_names)
n_exact = gene_list["h5ad_match"].sum()
print(f"Exact match: {n_exact}/{len(gene_list)} ({n_exact/len(gene_list)*100:.1f}%)")

# If low match rate, try prefix matching (e.g., PROST IDs use dashes, h5ad uses underscores)
if n_exact / len(gene_list) < 0.8:
    print("Low match rate — trying prefix matching...")
    # Build prefix lookup from h5ad var_names
    prefix_to_full = {}
    for name in adata.var_names:
        prefix = name.split()[0]  # First token before space
        prefix_to_full[prefix] = name
        # Also try dash→underscore conversion
        prefix_to_full[prefix.replace("-", "_")] = name
        prefix_to_full[prefix.replace("_", "-")] = name

    gene_list["h5ad_name"] = gene_list[GENE_ID_COL].map(prefix_to_full)
    n_matched = gene_list["h5ad_name"].notna().sum()
    print(f"Prefix match: {n_matched}/{len(gene_list)} ({n_matched/len(gene_list)*100:.1f}%)")
```

### Cell type setup

```python
#| label: cell-type-setup

# Cell type ordering — user-confirmed, grouped by family
# Named cell types only (default). Transitional clusters excluded.

# Full ordering for named cell types (confirmed by user during setup)
CELL_TYPE_ORDER = [
    # Family 1
    "CellType1", "CellType2", "CellType3",
    # Family 2
    "CellType4", "CellType5",
    # ... etc — user confirms this list
]

# If SHOW_CELL_TYPES == "all", append numbered/transitional clusters:
# CELL_TYPE_ORDER_ALL = CELL_TYPE_ORDER + ["12", "13", "14", ...]

# Family assignments and colors (Nature palette)
FAMILY_PALETTE = {
    "Family1": "#BC3C29",   # Brick red
    "Family2": "#0072B5",   # Steel blue
    "Family3": "#20854E",   # Forest green
    "Family4": "#E18727",   # Amber
    # Extended palette if needed:
    # "#7876B1" (muted purple), "#6F99AD" (slate blue),
    # "#EE4C97" (rose), "#868686" (gray)
}

CELLTYPE_TO_FAMILY = {
    "CellType1": "Family1",
    "CellType2": "Family1",
    # ... populated from discussion
}

# Compute family boundaries for axis separators
family_boundaries = []
current_family = None
for i, ct in enumerate(CELL_TYPE_ORDER):
    fam = CELLTYPE_TO_FAMILY.get(ct, "Unknown")
    if fam != current_family and current_family is not None:
        family_boundaries.append(i - 0.5)
    current_family = fam
```

### Expression computation (both log and linear)

```python
#| label: compute-expression

import numpy as np

# Compute mean expression per cell type for matched genes
# Two versions: log-scale (from normalized adata) and linear-scale (expm1 back to CPT)
matched_genes = gene_list.dropna(subset=["h5ad_name"])
gene_names = matched_genes["h5ad_name"].tolist()

expr_log = {}    # log(CPT + 1)
expr_linear = {} # CPT (linear scale, for side-by-side comparison)

for ct in CELL_TYPE_ORDER:
    mask = adata.obs[CELLTYPE_COL] == ct
    if mask.sum() == 0:
        continue
    subset = adata[mask, gene_names]
    if hasattr(subset.X, 'toarray'):
        log_vals = subset.X.toarray()
    else:
        log_vals = np.array(subset.X)

    expr_log[ct] = np.mean(log_vals, axis=0)
    # Convert log(CPT+1) back to CPT for linear-scale heatmap
    expr_linear[ct] = np.mean(np.expm1(log_vals), axis=0)

expr_log_df = pd.DataFrame(expr_log, index=gene_names).T.reindex(CELL_TYPE_ORDER).fillna(0)
expr_linear_df = pd.DataFrame(expr_linear, index=gene_names).T.reindex(CELL_TYPE_ORDER).fillna(0)

# Flag expressed genes (using log scale)
max_expr = expr_log_df.max(axis=0)
expressed_genes = set(max_expr[max_expr >= EXPRESSION_THRESHOLD].index)
print(f"Expressed genes: {len(expressed_genes)}/{len(gene_names)}")
```

### Two-panel heatmap function (linear + z-score)

```python
#| label: helper-heatmap

from scipy.cluster.hierarchy import linkage, leaves_list
from matplotlib.colors import LinearSegmentedColormap, TwoSlopeNorm
import matplotlib.pyplot as plt

BLUE_CMAP = LinearSegmentedColormap.from_list(
    "expression", ["#FFFFFF", "#3182BD", "#08306B"]
)

def plot_expression_heatmap(linear_data, labels, title, out_path,
                            family_boundaries=family_boundaries,
                            cell_types=CELL_TYPE_ORDER):
    """Two-panel heatmap: linear scale (mean CPT) + z-score.

    Parameters
    ----------
    linear_data : DataFrame
        Genes (rows) × cell types (columns), linear CPT values.
    labels : list
        Gene display labels (full var_names from the object).
    """
    if len(linear_data) == 0:
        return

    # Cluster genes
    if len(linear_data) > 1:
        Z = linkage(linear_data.values, method="ward")
        order = leaves_list(Z)
        linear_data = linear_data.iloc[order]
        labels = [labels[i] for i in order]

    # Z-score (row-normalized)
    z_data = linear_data.subtract(linear_data.mean(axis=1), axis=0).divide(
        linear_data.std(axis=1).replace(0, 1), axis=0
    )

    gene_fontsize = max(5, min(9, 180 / max(len(labels), 1)))
    ct_fontsize = max(4, min(7, 200 / len(cell_types)))
    fig_height = max(4, len(labels) * 0.3 + 2)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, fig_height))

    # Panel 1: linear scale
    im1 = ax1.imshow(linear_data.values, aspect="auto", cmap=BLUE_CMAP,
                     vmin=0, vmax=linear_data.values.max())
    ax1.set_title("Mean CPT (linear)", fontsize=10)
    fig.colorbar(im1, ax=ax1, shrink=0.4, pad=0.02)

    # Panel 2: z-score
    vmax = max(abs(z_data.values.min()), abs(z_data.values.max()), 0.01)
    im2 = ax2.imshow(z_data.values, aspect="auto", cmap="RdBu_r",
                     norm=TwoSlopeNorm(0, vmin=-vmax, vmax=vmax))
    ax2.set_title("Row-normalized (z-score)", fontsize=10)
    fig.colorbar(im2, ax=ax2, shrink=0.4, pad=0.02)

    for ax in [ax1, ax2]:
        ax.set_yticks(range(len(labels)))
        ax.set_xticks(range(len(cell_types)))
        ax.set_xticklabels(cell_types, rotation=90, fontsize=ct_fontsize, ha="center")
        for b in family_boundaries:
            ax.axvline(x=b, color="black", linewidth=0.8)

    ax1.set_yticklabels(labels, fontsize=gene_fontsize)
    ax2.set_yticklabels([])

    fig.suptitle(title, fontsize=12, y=1.01)
    plt.tight_layout()

    out_path = Path(out_path)
    fig.savefig(str(out_path) + ".pdf", bbox_inches="tight")
    fig.savefig(str(out_path) + ".png", dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {out_path.name}.pdf/.png")
```

### Barplot function — Style A (family-colored, linear scale)

```python
#| label: helper-barplots-style-a

from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.patches import Patch

def plot_expression_barplots(linear_data, labels, title, out_path,
                             cell_types=CELL_TYPE_ORDER,
                             celltype_colors=None,
                             family_boundaries=family_boundaries,
                             max_pages=MAX_BARPLOT_PAGES):
    """Multi-page barplots (linear scale: mean CPT), 2 cols × 6 rows,
    bars colored by cell type family. X-axis labels on EVERY subplot.
    """
    if len(expr_subset) == 0:
        return

    genes_per_page = 12  # 2 × 6
    n_genes = len(expr_subset)
    n_pages = min(max_pages, (n_genes + genes_per_page - 1) // genes_per_page)

    # Cluster genes by expression pattern
    if n_genes > 1:
        Z = linkage(expr_subset.values, method="ward")
        order = leaves_list(Z)
        expr_subset = expr_subset.iloc[order]
        labels = [labels[i] for i in order]

    # Bar colors per cell type
    bar_colors = [celltype_colors.get(ct, "#888888") for ct in cell_types]
    ct_fontsize = max(3, min(5, 150 / len(cell_types)))

    out_path = Path(out_path)
    with PdfPages(str(out_path) + ".pdf") as pdf:
        for page in range(n_pages):
            start = page * genes_per_page
            end = min(start + genes_per_page, n_genes)
            page_genes = list(range(start, end))

            n_rows = 6
            n_cols = 2
            fig, axes = plt.subplots(n_rows, n_cols, figsize=(8.5, 13))
            axes = axes.flatten()

            for idx, gene_idx in enumerate(page_genes):
                ax = axes[idx]
                vals = expr_subset.iloc[gene_idx].values
                ax.bar(range(len(cell_types)), vals, color=bar_colors, width=0.8)
                ax.set_title(labels[gene_idx], fontsize=7, pad=2)
                ax.set_xlim(-0.5, len(cell_types) - 0.5)
                ax.tick_params(axis="y", labelsize=5)

                # X-axis: cell type labels on every subplot
                ax.set_xticks(range(len(cell_types)))
                ax.set_xticklabels(cell_types, rotation=90, fontsize=ct_fontsize,
                                   ha="center")

                # Family separators
                for b in family_boundaries:
                    ax.axvline(x=b, color="gray", linewidth=0.5, linestyle="--")

            # Hide unused axes
            for idx in range(len(page_genes), len(axes)):
                axes[idx].set_visible(False)

            # Add family legend on page 1
            if page == 0:
                legend_elements = [
                    Patch(facecolor=color, label=family)
                    for family, color in FAMILY_PALETTE.items()
                ]
                fig.legend(handles=legend_elements, loc="lower center",
                          ncol=len(FAMILY_PALETTE), fontsize=7,
                          bbox_to_anchor=(0.5, 0.002))

            fig.suptitle(f"{title} (page {page+1}/{n_pages})", fontsize=10, y=0.998)
            plt.tight_layout(rect=[0, 0.02, 1, 0.99])
            pdf.savefig(fig)

            # Save page 1 as PNG for HTML embedding
            if page == 0:
                fig.savefig(str(out_path) + ".png", dpi=200, bbox_inches="tight")

            plt.close(fig)

    print(f"  Saved: {out_path.name}.pdf ({n_pages} pages)")
```

### Combined all-genes heatmap (when ≤100 genes)

```python
#| label: all-genes-heatmap

# If total expressed gene count is ≤100, show one combined heatmap
# with category color sidebar
n_total_expressed = len([g for g in gene_names if g in expressed_genes])

if n_total_expressed <= 100 and n_total_expressed > 0:
    # Build combined data with category assignments
    combined_genes = matched[matched["h5ad_name"].isin(expressed_genes)].copy()
    combined_genes = combined_genes.sort_values(GROUP_COL)

    h5ad_list = combined_genes["h5ad_name"].tolist()
    label_list = combined_genes[LABEL_COL].tolist()
    category_list = combined_genes[GROUP_COL].tolist()

    combined_log = expr_log_df[h5ad_list].T
    combined_linear = expr_linear_df[h5ad_list].T

    # Category color sidebar
    CATEGORY_COLORS = {}
    unique_cats = combined_genes[GROUP_COL].unique()
    for i, cat in enumerate(unique_cats):
        CATEGORY_COLORS[cat] = NATURE_PALETTE[i % len(NATURE_PALETTE)]

    # Plot three-panel heatmap with category sidebar
    # (same as plot_expression_heatmap but with added annotation column)

    gene_fontsize = max(3, min(6, 100 / len(label_list)))
    ct_fontsize = max(4, min(6, 200 / len(CELL_TYPE_ORDER)))
    fig_height = max(5, len(label_list) * 0.2 + 2)

    fig = plt.figure(figsize=(22, fig_height))
    gs = fig.add_gridspec(1, 4, width_ratios=[0.3, 6, 6, 6], wspace=0.05)

    # Category sidebar
    ax_cat = fig.add_subplot(gs[0])
    cat_colors = [CATEGORY_COLORS[c] for c in category_list]
    for i, color in enumerate(cat_colors):
        ax_cat.add_patch(plt.Rectangle((0, i - 0.5), 1, 1, color=color))
    ax_cat.set_xlim(0, 1)
    ax_cat.set_ylim(-0.5, len(category_list) - 0.5)
    ax_cat.set_yticks([])
    ax_cat.set_xticks([])
    ax_cat.invert_yaxis()
    ax_cat.set_title("Category", fontsize=7, rotation=90, pad=10)

    # Three heatmap panels
    panels = [
        (fig.add_subplot(gs[1]), combined_log, BLUE_CMAP, "log(mean CPT + 1)", None),
        (fig.add_subplot(gs[2]), combined_linear, BLUE_CMAP, "Mean CPT (linear)", None),
    ]

    # Z-score
    z_data = combined_log.subtract(combined_log.mean(axis=1), axis=0).divide(
        combined_log.std(axis=1).replace(0, 1), axis=0
    )
    vmax_z = max(abs(z_data.values.min()), abs(z_data.values.max()), 0.01)
    panels.append(
        (fig.add_subplot(gs[3]), z_data, "RdBu_r", "z-score",
         TwoSlopeNorm(0, vmin=-vmax_z, vmax=vmax_z))
    )

    for i, (ax, data, cmap, panel_title, norm) in enumerate(panels):
        kwargs = {"aspect": "auto", "cmap": cmap}
        if norm is not None:
            kwargs["norm"] = norm
        else:
            kwargs["vmin"] = 0
            kwargs["vmax"] = data.values.max()
        im = ax.imshow(data.values, **kwargs)
        ax.set_title(panel_title, fontsize=9)
        ax.set_xticks(range(len(CELL_TYPE_ORDER)))
        ax.set_xticklabels(CELL_TYPE_ORDER, rotation=90, fontsize=ct_fontsize)
        for b in family_boundaries:
            ax.axvline(x=b, color="black", linewidth=0.8)
        fig.colorbar(im, ax=ax, shrink=0.3, pad=0.02)

        if i == 0:
            ax.set_yticks(range(len(label_list)))
            ax.set_yticklabels(label_list, fontsize=gene_fontsize)
        else:
            ax.set_yticks([])

    # Category legend
    legend_elements = [Patch(facecolor=c, label=cat) for cat, c in CATEGORY_COLORS.items()]
    fig.legend(handles=legend_elements, loc="lower center",
              ncol=min(len(CATEGORY_COLORS), 6), fontsize=7,
              bbox_to_anchor=(0.5, -0.02))

    fig.suptitle("All genes — expression overview", fontsize=11, y=1.01)
    plt.tight_layout()
    fig.savefig(out_dir / "all_genes_heatmap.pdf", bbox_inches="tight")
    fig.savefig(out_dir / "all_genes_heatmap.png", dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved all_genes_heatmap.pdf/.png ({n_total_expressed} genes)")
```

### Report generation loop

```python
#| label: generate-reports

from pathlib import Path

groups = gene_list[GROUP_COL].dropna().unique()

for group in sorted(groups):
    group_genes = matched[matched[GROUP_COL] == group].copy()
    group_expressed = group_genes[group_genes["h5ad_name"].isin(expressed_genes)].copy()
    group_slug = group.lower().replace(" ", "_").replace("—", "").replace("-", "_").strip("_")
    group_dir = out_dir / group_slug
    group_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"{group}: {len(group_genes)} genes total, {len(group_expressed)} expressed")

    # Save gene list for this group
    group_genes.to_csv(group_dir / "gene_list.tsv", sep="\t", index=False)

    if len(group_expressed) == 0:
        print("  No expressed genes — skipping visualizations")
        continue

    h5ad_names = group_expressed["h5ad_name"].tolist()
    plot_labels = group_expressed[LABEL_COL].tolist()

    if SUBGROUP_COL is not None:
        # Split by sub-group
        subgroups = group_expressed[SUBGROUP_COL].value_counts()
        major = subgroups[subgroups >= SUBGROUP_THRESHOLD].index.tolist()
        minor = subgroups[subgroups < SUBGROUP_THRESHOLD].index.tolist()

        for sg in major:
            sg_mask = group_expressed[SUBGROUP_COL] == sg
            sg_genes = group_expressed[sg_mask]["h5ad_name"].tolist()
            sg_labels = group_expressed[sg_mask][LABEL_COL].tolist()
            sg_slug = sg.lower().replace(" ", "_")
            sg_log = expr_log_df[sg_genes].T
            sg_linear = expr_linear_df[sg_genes].T

            print(f"  {sg}: {len(sg_genes)} genes")
            plot_expression_heatmap(sg_log, sg_linear, sg_labels,
                                    f"{group} — {sg}", group_dir / f"heatmap_{sg_slug}")
            plot_expression_barplots(sg_log, sg_labels, f"{group} — {sg}",
                                    group_dir / f"barplots_{sg_slug}",
                                    celltype_colors=celltype_colors)

        if minor:
            other_mask = group_expressed[SUBGROUP_COL].isin(minor)
            other_genes = group_expressed[other_mask]["h5ad_name"].tolist()
            other_labels = group_expressed[other_mask][LABEL_COL].tolist()
            other_log = expr_log_df[other_genes].T
            other_linear = expr_linear_df[other_genes].T
            print(f"  Other ({len(minor)} sub-groups, {len(other_genes)} genes)")
            plot_expression_heatmap(other_log, other_linear, other_labels,
                                    f"{group} — Other", group_dir / "heatmap_other")
            plot_expression_barplots(other_log, other_labels, f"{group} — Other",
                                    group_dir / "barplots_other",
                                    celltype_colors=celltype_colors)
    else:
        # No sub-grouping — single heatmap + barplot per group
        grp_log = expr_log_df[h5ad_names].T
        grp_linear = expr_linear_df[h5ad_names].T
        plot_expression_heatmap(grp_log, grp_linear, plot_labels, group,
                                group_dir / "heatmap")
        plot_expression_barplots(grp_log, plot_labels, group,
                                group_dir / "barplots",
                                celltype_colors=celltype_colors)
```

### Cross-analysis: expression summary

```python
#| label: fig-expression-summary

# Bar chart: genes per group, colored by fraction expressed
summary = []
for group in sorted(groups):
    g = matched[matched[GROUP_COL] == group]
    n_total = len(g)
    n_expressed = g["h5ad_name"].isin(expressed_genes).sum()
    summary.append({"group": group, "total": n_total, "expressed": n_expressed,
                    "fraction": n_expressed / n_total if n_total > 0 else 0})

summary_df = pd.DataFrame(summary)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.barh(summary_df["group"], summary_df["total"], color="#888888", label="Total")
ax1.barh(summary_df["group"], summary_df["expressed"], color="#BC3C29", label="Expressed")
ax1.set_xlabel("Number of genes")
ax1.legend()
ax1.set_title("Genes per group")

ax2.barh(summary_df["group"], summary_df["fraction"], color="#0072B5")
ax2.set_xlabel("Fraction expressed")
ax2.set_xlim(0, 1)
ax2.set_title("Expression rate per group")

plt.tight_layout()
fig.savefig(out_dir / "expression_summary.pdf", bbox_inches="tight")
fig.savefig(out_dir / "expression_summary.png", dpi=200, bbox_inches="tight")
plt.close(fig)
```

### Cross-analysis: group × cell type heatmap (three-panel)

```python
#| label: fig-group-celltype-heatmap

# Mean expression per group × cell type — three panels: log, linear, z-score
# The mean here is the average of per-cell-type means across genes in the group
# (each cell type weighted equally)

hm_log = {}
hm_linear = {}
level = SUBGROUP_COL if SUBGROUP_COL else GROUP_COL

for label in gene_list[level].dropna().unique():
    mask = matched[level] == label
    genes = matched[mask].dropna(subset=["h5ad_name"])
    expr_genes = [g for g in genes["h5ad_name"] if g in expressed_genes]
    if len(expr_genes) < 1:
        continue
    hm_log[label] = expr_log_df[expr_genes].mean(axis=1)
    hm_linear[label] = expr_linear_df[expr_genes].mean(axis=1)

if hm_log:
    hm_log_df = pd.DataFrame(hm_log).T
    hm_linear_df = pd.DataFrame(hm_linear).T

    # Cluster rows
    if len(hm_log_df) > 2:
        Z = linkage(hm_log_df.values, method="ward")
        order = leaves_list(Z)
        hm_log_df = hm_log_df.iloc[order]
        hm_linear_df = hm_linear_df.iloc[order]

    # Z-score
    hm_z = hm_log_df.subtract(hm_log_df.mean(axis=1), axis=0).divide(
        hm_log_df.std(axis=1).replace(0, 1), axis=0
    )

    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(22, max(4, len(hm_log_df) * 0.5)))

    im1 = ax1.imshow(hm_log_df.values, aspect="auto", cmap=BLUE_CMAP)
    ax1.set_title("log(mean CPT + 1)", fontsize=9)
    fig.colorbar(im1, ax=ax1, shrink=0.5)

    im2 = ax2.imshow(hm_linear_df.values, aspect="auto", cmap=BLUE_CMAP)
    ax2.set_title("Mean CPT (linear)", fontsize=9)
    fig.colorbar(im2, ax=ax2, shrink=0.5)

    vmax = max(abs(hm_z.values.min()), abs(hm_z.values.max()), 0.01)
    im3 = ax3.imshow(hm_z.values, aspect="auto", cmap="RdBu_r",
                     norm=TwoSlopeNorm(0, vmin=-vmax, vmax=vmax))
    ax3.set_title("Row-normalized (z-score)", fontsize=9)
    fig.colorbar(im3, ax=ax3, shrink=0.5)

    for ax in [ax1, ax2, ax3]:
        ax.set_xticks(range(len(CELL_TYPE_ORDER)))
        ax.set_xticklabels(CELL_TYPE_ORDER, rotation=90, fontsize=5)
        for b in family_boundaries:
            ax.axvline(x=b, color="black", linewidth=0.8)

    ax1.set_yticks(range(len(hm_log_df)))
    ax1.set_yticklabels(hm_log_df.index, fontsize=8)
    ax2.set_yticks([])
    ax3.set_yticks([])

    plt.tight_layout()
    fig.savefig(out_dir / "group_celltype_heatmap.pdf", bbox_inches="tight")
    fig.savefig(out_dir / "group_celltype_heatmap.png", dpi=200, bbox_inches="tight")
    plt.close(fig)
```

### Archive pattern

```python
#| label: setup
# (include in setup chunk)

import shutil
from datetime import datetime

# Archive previous outputs
if out_dir.exists() and any(out_dir.iterdir()):
    build_info = out_dir / "BUILD_INFO.txt"
    if build_info.exists():
        ts = datetime.fromtimestamp(build_info.stat().st_mtime).strftime("%Y%m%d_%H%M%S")
    else:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")

    archive_dir = out_dir / "_archive" / ts
    archive_dir.mkdir(parents=True, exist_ok=True)

    for item in out_dir.iterdir():
        if item.name == "_archive":
            continue
        shutil.move(str(item), str(archive_dir / item.name))
    print(f"Archived previous outputs to _archive/{ts}/")
```

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

White → steel blue → navy (`#FFFFFF` → `#3182BD` → `#08306B`)

### Z-score heatmap

Diverging `RdBu_r` with `TwoSlopeNorm` centered at 0.

---

## Anti-Patterns (MUST AVOID)

These were learned through iterative development. Do not repeat them.

### Data handling
- **NEVER apply `expm1()` without checking** — if `X.max() > 20`, it's raw counts
- **NEVER parse or abbreviate gene names** — use the full var_name from the h5ad object
  as the display label. The object's gene names are authoritative.
- **NEVER trust a single best hit** — require hits from ≥3 species for kingdom signals

### Visualization
- **NEVER omit x-axis labels on barplots** — every subplot must show rotated cell type names
- **NEVER use garish primary colors** — use Nature-style muted palette
- **NEVER use 3×4 landscape barplots** — portrait 2×6 is more readable
- **NEVER save individual page PDFs** — combine into single multi-page PDF
- **NEVER sort barplots by max expression** — hierarchical clustering is more informative
- **NEVER show only top-N genes** — show all expressed genes (up to max_pages)
- **NEVER show all clusters by default** — recommend named cell types only, ask the user
  which clusters are transitional (they may have names, not just numbers)

### Analytical
- **NEVER assume DE testing filters pre-selected gene sets** — it's overpowered (~75-85% pass).
  Use hierarchical clustering instead.
- **NEVER show only z-scored heatmaps** — show linear + z-score side by side
- **NEVER show only family-level averages** — cell-type-level is the primary view
- **NEVER leave stale outputs** — archive must capture files AND subdirectories

---

## Output Structure

```
outs/<subdirectory>/XX_name/
  all_genes_heatmap.pdf/.png      # Combined heatmap if ≤100 genes (2-panel + category sidebar on right)
  expression_summary.pdf/.png     # Genes per group, fraction expressed
  group_celltype_heatmap.pdf/.png # Group × cell type (2-panel: linear + z-score)
  gene_summary.tsv                # All genes with expression info
  BUILD_INFO.txt                  # Provenance
  _archive/                       # Previous runs
    20260315_143022/
  group_slug_1/                   # Per-group subdirectory
    gene_list.tsv                 # All genes in this group
    heatmap.pdf/.png              # Per-group heatmap (2-panel: linear + z-score)
    barplots.pdf/.png             # Per-group barplots (linear scale, with x-axis labels)
  group_slug_2/
    ...
```

### Combined all-genes heatmap layout

When ≤100 expressed genes, the combined heatmap uses:
- **Category color sidebar on the RIGHT side** (not left) to avoid overlapping with gene
  name labels on the y-axis
- Two heatmap panels: linear (mean CPT) + z-score
- Category legend at bottom

---

## Species-Specific Cell Type Configurations

### Spongilla lacustris (Musser et al. 2021)

**Note:** The h5ad object stores the family name as `"Archeocytes and relatives"` (missing
'a'). Map this to the correct spelling `"Archaeocytes and relatives"` in display/palette
code.

**Family order for named cell types only (default):**

| Family | Color | Cell types (in order) |
|--------|-------|----------------------|
| Endymocytes | `#20854E` (forest green) | incPin1, incPin2, apnPin1, apnPin2, Lph, Scp, basPin, Met1, Met2 |
| Peptidocytes | `#0072B5` (steel blue) | Chb1, Chb2, Cho, Apo, Myp1, Myp2 |
| Amoeboid-Neuroid | `#E18727` (amber) | Amb, Grl, Nrd |
| Archaeocytes and relatives | `#BC3C29` (brick red) | Arc, Scl, Mes1, Mes2, Mes3 |

**Family order for all clusters:**

| Family | Cell types (in order) |
|--------|----------------------|
| transitional | 12, 14, 16, 19, 20, 13, 15, 17, 26, 23, 6, 7, 2, 3, 32, 29, 34, 38, 42 |
| Endymocytes | (same as above) |
| Peptidocytes | (same as above) |
| Amoeboid-Neuroid | (same as above) |
| Archaeocytes and relatives | (same as above) |

**Notes:**
- Transitional clusters are numbered only — exclude from named-only view
- The ordering within families reflects biological relationships (e.g., pinacocyte subtypes
  grouped together in Endymocytes; choanocyte lineage before myocytes in Peptidocytes)
- This ordering is interim — will be updated when the curated single-cell object is finalized

---

## Future: R/Seurat Template

Not yet implemented. When added, the R template will use:
- Seurat `DotPlot` for dotplots
- `pheatmap` with category row annotations for heatmaps
- `ggplot2` + `facet_wrap` for Style B barplots
- `ggh4x` for x-axis labels on every facet panel
- Same configuration-at-top pattern, adapted to R syntax
