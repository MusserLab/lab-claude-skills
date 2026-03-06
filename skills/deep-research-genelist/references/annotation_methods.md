# Annotation Method Library

Reference descriptions for gene annotation methods used in scRNAseq gene lists.
The deep-research-genelist skill consults this file when generating prompts.

**Usage:** The skill should try to detect which methods are present in the data
(from column names, data patterns, suffixes), then ALWAYS ask the user to
confirm before using any of these descriptions. Never silently assume the format.

---

## Known Methods

### phylome

**Full name:** PhylomeDB sequence orthology
**Projects using it:** chitons (Acanthochitona), spongilla (Spongilla)
**Reliability:** High
**How to recognize:** Column names containing `phylome`; gene names without `*` suffix that include recognized gene symbols (e.g., `DISP1`, `CAH1`); presence of text like "1-to-7" indicating orthology counts.

**Interpretation guidance for deep research:**
> Gene names derived from PhylomeDB are based on phylogenetic tree reconstruction.
> These are sequence-based orthologs. When a 1-to-1 ortholog is identified, the
> gene name represents a likely functional equivalent. When 1-to-many orthologs
> are listed (e.g., "1-to-7 Ca1, Ca13, Ca2..."), all listed genes are co-orthologs
> and should be considered as potential functional matches. The notation "1-to-N"
> indicates the chiton gene has N human/Drosophila co-orthologs in that phylome tree.

---

### eggnog

**Full name:** eggNOG mapper orthology
**Projects using it:** Most projects (sponges, Platynereis, Acropora, etc.)
**Reliability:** High (orthology group membership is well-established)
**How to recognize:** Column names containing `eggnog`, `emapper`, `OG`, or `orthology_group`; n-to-n notation; human gene symbols listed as comma-separated groups.

**IMPORTANT:** The actual column format varies substantially between projects.
Always ask the user to describe their specific eggNOG-derived columns.

**Interpretation guidance for deep research:**
> Gene names are assigned based on orthology groups (OGs) from eggNOG mapper,
> typically at the metazoan level. These are true orthologs. When multiple human
> genes are listed, it indicates n-to-n orthology — the gene is orthologous to all
> listed human genes, but the specific closest functional match among them is
> unresolved. In some cases the relationship may be 1-to-1. Consider all listed
> orthologs when discussing potential function. The more human genes listed in the
> orthology group, the larger and more ancient the gene family — very large groups
> (10+ human genes) may indicate a superfamily where functional specificity is harder
> to infer.

---

### prost

**Full name:** PROST structural homology (protein language model)
**Projects using it:** chitons, Platynereis, potentially others
**Reliability:** Moderate (gene family level, not orthology)
**How to recognize:** Column names containing `prost`; `*` suffix on gene names (display_name); columns like `prost_top1`, `prost_human`, `prost_fly`; `name_type` column with values like `symbol`.

**Interpretation guidance for deep research:**
> Names marked with `*` (asterisk suffix) are derived from PROST, which uses
> protein language model embeddings (ESM-2) to find structurally similar proteins
> across species. PROST identifies proteins with similar predicted 3D structure,
> which indicates membership in the same protein superfamily. This is NOT sequence
> orthology — a PROST hit to human "GeneX" means the protein has similar structure
> to GeneX and likely belongs to the same gene family, but it may not be the
> functional equivalent. When multiple PROST hits are available (e.g., top-1 hit
> from any species, plus specific human and Drosophila hits), the top-1 hit is the
> most structurally similar protein found across all species in the database.

---

### orthofinder

**Full name:** OrthoFinder orthology inference
**Projects using it:** (planned — no standardized format yet)
**Reliability:** High (phylogenetic orthology with gene tree reconciliation)
**How to recognize:** TBD — format not yet standardized.

**Interpretation guidance for deep research:**
> Gene names derived from OrthoFinder are based on phylogenetic gene tree
> inference and species tree reconciliation. These are true orthologs with
> well-resolved orthology/paralogy relationships. OrthoFinder distinguishes
> orthologs from paralogs more rigorously than simple sequence similarity methods.
> Treat these names with high confidence for functional inference.

**NOTE:** This method's format and integration are pending. Update this entry
when the first project uses OrthoFinder results.

---

### manual

**Full name:** Manual expert curation
**Projects using it:** All projects (selective)
**Reliability:** Highest
**How to recognize:** No systematic marker — these are hand-curated names typically for well-known genes. May be indicated by absence of method-specific markers, or by a `name_type` column value like `manual` or `existing`.

**Interpretation guidance for deep research:**
> Manually curated gene names assigned by domain experts based on published
> literature and experimental evidence. These are the most reliable annotations.
> Treat with full confidence for functional inference.

---

## How the Skill Should Use This File

1. **Detect:** Read the gene list header and sample rows. Look for column names
   and data patterns matching the "How to recognize" field for each method.

2. **Infer:** Propose which methods are present: "This gene list appears to use
   [method A] (detected from columns X, Y) and [method B] (detected from * suffix
   on display names)."

3. **Confirm:** Ask the user to verify:
   - Are these the right methods?
   - Is the column format as expected?
   - Any additional methods or caveats?

4. **Assemble:** Combine the relevant interpretation guidance blocks into the
   `ORTHOLOGY_METHOD` and add method-specific guidance to the prompt.

5. **Handle unknowns:** If columns/patterns don't match any known method, tell the
   user: "I don't recognize the annotation format in columns [X, Y]. Please describe
   how gene names were assigned and how to interpret them."
