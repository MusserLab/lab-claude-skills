# Expression Report — Reusable Helper Functions
# These are inserted as code chunks in the generated .qmd script.
# The skill reads this file during script generation.

# ============================================================
# Two-panel heatmap function (linear + z-score)
# ============================================================
# Chunk label: helper-heatmap

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


# ============================================================
# Barplot function — Style A (family-colored, linear scale)
# ============================================================
# Chunk label: helper-barplots-style-a

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
