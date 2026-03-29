# Expression Report — Script Body Template
# These are inserted as code chunks in the generated .qmd script.
# The skill reads this file during script generation.
# Chunks are separated by labeled sections matching .qmd chunk labels.

# ============================================================
# Configuration chunk (fill in from discussion)
# ============================================================
# Chunk label: config

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


# ============================================================
# Normalization detection
# ============================================================
# Chunk label: normalize

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


# ============================================================
# Gene ID matching
# ============================================================
# Chunk label: gene-id-mapping

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


# ============================================================
# Cell type setup
# ============================================================
# Chunk label: cell-type-setup

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


# ============================================================
# Expression computation (both log and linear)
# ============================================================
# Chunk label: compute-expression

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


# ============================================================
# Combined all-genes heatmap (when ≤100 genes)
# ============================================================
# Chunk label: all-genes-heatmap

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


# ============================================================
# Report generation loop
# ============================================================
# Chunk label: generate-reports

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


# ============================================================
# Cross-analysis: expression summary
# ============================================================
# Chunk label: fig-expression-summary

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


# ============================================================
# Cross-analysis: group × cell type heatmap (three-panel)
# ============================================================
# Chunk label: fig-group-celltype-heatmap

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


# ============================================================
# Archive pattern (include in setup chunk)
# ============================================================
# Chunk label: setup (archive section)

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
