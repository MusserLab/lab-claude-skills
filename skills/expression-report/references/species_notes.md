# Species-Specific Notes

Species-specific cell type configurations, quirks, and defaults for the expression report
skill. Check this file during Phase 1 (cell type setup) to pre-populate known species info.

Add new species sections as you encounter them.

---

## Spongilla lacustris (Musser et al. 2021)

**h5ad file:** `sl.merged_geneID.tsne.h5ad`

**Data format quirks:**
- Contains **raw counts** (max ~12,299), NOT log-normalized — normalize to CPT + log1p
- DO NOT apply `expm1()` — the data is not log-transformed to begin with
- Gene names in `var_names` are "Automated name" format (e.g., `c100000-g1 1-to-1 MOSPD2 ...`)
- PROST gene IDs use dashes (`c100000-g1`), lookup table uses underscores (`c100000_g1`)
  — prefix matching handles this automatically

**Cell type columns:**
- `cell_type_abbreviation` — abbreviated cell type names
- `cell_type_family` — family grouping (note: stores `"Archeocytes and relatives"` with
  missing 'a' — map to correct spelling `"Archaeocytes and relatives"` in display/palette)

**Family order for named cell types (default):**

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
