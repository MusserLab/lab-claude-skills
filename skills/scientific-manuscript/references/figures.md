# Figures and Figure Legends Guide

## Figure Design Principles

### Visual Hierarchy
1. **Main finding** should be immediately apparent
2. **Supporting data** arranged to reinforce main message
3. **Controls** present but not dominant

### Panel Organization
- **Left to right, top to bottom** reading order
- **Group related panels** (e.g., all timepoints together)
- **Consistent sizing** for comparable data types
- **Logical flow** matching Results narrative

### Color Usage
- Use colorblind-friendly palettes (viridis, cividis)
- Consistent colors across figures (same gene = same color)
- Avoid red-green combinations without shape/pattern backup
- Use color purposefully—not decoratively

## Figure Types and When to Use Them

| Data Type | Best Figure Type | When to Use |
|-----------|------------------|-------------|
| Representative examples | Micrographs/images | Show qualitative patterns |
| Quantitative comparison | Bar/dot plots | Compare discrete groups |
| Change over time | Line graphs | Show temporal dynamics |
| Many comparisons | Heatmaps | Gene expression, clustering |
| Relationships | Scatter plots | Correlations, regressions |
| Process/model | Schematics | Summarize mechanisms |

## Multi-Panel Figure Structure

### Figure 1: The Overview Figure
Sets up the system and question. Typically includes:
- Schematic of system/approach
- Key phenotype or behavior
- Experimental design overview

### Middle Figures: Data Figures
Each addresses a specific question from Results.
- Lead panel shows main finding
- Supporting panels provide evidence/controls
- Build toward the conclusion

### Final Figure: The Model Figure
Synthesizes findings into a conceptual framework.
- Should be understandable without reading paper
- Shows mechanism or evolutionary implications
- Often becomes the "iconic" figure

## Figure Legends

### Structure
1. **Title**: One sentence stating the main conclusion
2. **Panel descriptions**: What each panel shows (not interprets)
3. **Technical details**: Scale bars, sample sizes, statistics
4. **Abbreviations**: Define all non-standard abbreviations

### Title Formats

**Conclusory (preferred for high-impact)**:
"Sponge deflation is driven by epithelial relaxation, not contraction."

**Descriptive (acceptable)**:
"Characterization of cellular dynamics during sponge deflation."

### Panel Description Format
"(A) [What is shown]. [Method/staining if relevant]. (B) [What is shown]. [Quantification details]. n = X, error bars = SEM, *p < 0.05 (test type)."

### Example Legend

**Figure 2. Contractile and secretory cells express distinct transcriptional programs.**
(A) UMAP projection of single-cell transcriptomes from whole sponge, colored by cell type. n = 12,847 cells from 3 individuals.
(B) Dot plot showing marker gene expression across cell types. Dot size indicates fraction of expressing cells; color indicates mean expression level.
(C) Heatmap of differentially expressed genes between contractile (left) and secretory (right) cells. Rows are genes; columns are cells. Color scale: z-scored expression.
(D) Gene Ontology enrichment analysis for genes upregulated in contractile cells. Bar length indicates -log10(adjusted p-value). Dashed line: significance threshold (p = 0.05).
Scale bars: 50 μm (A inset). Statistical comparisons: Wilcoxon rank-sum test with Benjamini-Hochberg correction.

## Common Problems

| Problem | Example | Fix |
|---------|---------|-----|
| Busy panels | Too much in one panel | Split into sub-panels |
| Missing scale bars | Images without reference | Add to all micrographs |
| Unclear statistics | "p < 0.05" | Report exact p, test type, n |
| Inconsistent formatting | Different axis styles | Standardize across figures |
| Decorative color | Rainbow heatmaps | Use perceptually uniform scales |
| Missing controls | Treatment only | Show controls in same figure |

## Supplementary Figures

Move to Supplements:
- Extended controls
- Replicate data
- Quality control metrics
- Alternative analyses
- Negative results that inform interpretation

Keep in Main Figures:
- Data essential to main conclusions
- Representative examples
- Key quantifications

## Journal-Specific Considerations

**Nature/Science**:
- Strict panel limits (often 4-6 main figures)
- Extended Data for additional panels
- High bar for visual clarity

**Cell**:
- Allows more comprehensive figures
- Graphical abstracts important
- Detailed legends expected

**Current Biology**:
- Balance of accessibility and detail
- Clear labeling essential
- Model figures highly valued
