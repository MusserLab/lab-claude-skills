# Deep Research Prompt: Gene List Analysis for Cell Type Annotation

## 1. Role and Objective

Act as an expert in molecular and cellular biology with specialized knowledge in {{CLADE}} biology, comparative genomics, and single-cell transcriptomics. Your task is to analyze a list of genes from a single-cell RNA-seq experiment in {{ORGANISM}} and generate a research-level report for a biologist with a broad interdisciplinary background. The report should synthesize the potential functions of these genes to infer the biological identity and role of the cells in which they are expressed.

## 2. Input Data

The gene list (included in Section 6 below) is derived from {{MODULE_TYPE_DESCRIPTION}} identified in {{ORGANISM}} {{TISSUE_CONTEXT}}.

- **Biological Context:** {{BIOLOGICAL_CONTEXT}}
- **Gene List Format:** The gene list contains three columns:
  - `display_name`: the gene name (see Annotation Source Guide below for how to interpret different name formats)
  - `pct.1`: the fraction of cells in this cluster that express the gene (higher = more broadly expressed in this cluster)
  {{COMPARISON_TYPE_COLUMN_DESCRIPTION}}
- **Gene List Filtering:** {{FILTERING_DESCRIPTION}}

### Annotation Source Guide

{{ANNOTATION_SOURCE_GUIDE}}

Genes whose display_name is a bare gene ID (e.g., `comp12345_c0`, `XLOC_012345`, `LOC12345`) have no identified homolog by any method — these are uncharacterized.

{{MERGED_MODE_INPUT_GUIDANCE}}

{{FAMILY_CROSS_REFERENCE}}

When analyzing these genes, keep the following in mind:
- We do not know the function of the {{COMMON_NAME}} genes directly. The orthology and homology assignments are a guide to what proteins are most similar in sequence or structure.
- When a {{COMMON_NAME}} gene is orthologous or homologous to multiple genes in another species, we do not know which is the closest functional match. Consider all orthologs/homologs when discussing potential function.
- Analyze ALL genes in the list, not just the top-ranked ones. Lower-ranked genes may contribute to secondary functional signatures or reveal unexpected biology.

## 3. Machine-Readable Summary Header

**IMPORTANT:** Before the main report text, produce a YAML front matter block (delimited by `---`) that summarizes the key findings in a structured, machine-readable format. This block will be parsed programmatically to compile annotations across many gene lists. Follow this exact schema:

```yaml
---
query:
  organism: "{{ORGANISM}}"
  common_name: "{{COMMON_NAME}}"
  clade: "{{CLADE}}"
  dataset: "{{DATASET_DESCRIPTION}}"
  module_type: "{{MODULE_TYPE}}"
  module_id: "{{MODULE_ID}}"
  report_type: "{{REPORT_TYPE}}"
  source_object: "{{SOURCE_OBJECT}}"
  clustering_column: "{{CLUSTERING_COLUMN}}"
  marker_file: "{{MARKER_FILE}}"
  comparison_mode: "{{COMPARISON_MODE}}"
  clade_family: "{{CLADE_FAMILY}}"
  biological_context: "<copy from input>"
  n_genes: <integer — count of genes in the input list>
  date_generated: "<YYYY-MM-DD>"

annotation:
  proposed_name: "<concise cell type or module name>"
  alternative_names:
    - "<alternative name 1>"
    - "<alternative name 2>"
  confidence: "<high | medium | low>"
  confidence_rationale: "<1 sentence explaining the confidence level>"
  one_line: "<one-sentence description of this cell type or module>"
  summary: >
    <2-3 sentence summary suitable for a supplementary table. Describe the major
    functional signatures, key marker genes, and proposed identity.>

  best_matches:
    - cell_type: "<name of the matching cell type>"
      organism: "<species>"
      shared_tfs: ["<TF1>", "<TF2>"]
      shared_functional_genes: ["<gene1>", "<gene2>"]
      reference: "<Author et al. YYYY>"
      conservation: "<conserved pan-animal | conserved <clade-name> | lineage-specific | uncertain>"
    # Include ALL prominent matches — different signatures in the data
    # may resemble different known cell types. Prioritize matches that
    # share BOTH transcription factors AND functional/effector genes.

  cell_type_family: "<broad family, e.g., neuron, muscle, epithelial, immune>"
  family_conservation: "<pan-animal | <clade>-specific | uncertain>"

markers:
  top_diagnostic:
    # 5-10 most informative genes for identifying this cell type
    - gene_id: "<original gene ID from input>"
      name: "<gene symbol>"
      role: "<brief functional role in this context>"
  transcription_factors: ["<TF1>", "<TF2>"]
  receptors_channels: ["<gene1>", "<gene2>"]
  signaling_ligands: ["<gene1>", "<gene2>"]
  adhesion_molecules: ["<gene1>", "<gene2>"]
  secreted_products: ["<gene1>", "<gene2>"]
  key_pathways: ["<pathway1>", "<pathway2>"]
  metabolic_signature: "<brief description of metabolic profile>"
  n_uncharacterized_notable: <integer — count of uncharacterized genes worth further investigation>
---
```

Fill in every field based on your analysis. Use empty lists `[]` if a category has no members. Do not omit fields.

## 4. Analytical Workflow and Report Structure

Generate your report following this structure. Use the section letters (A–K) as headings.

### A. Functional Enrichment Summary

Based on the provided gene list and their orthologs/homologs, identify the distinct functional modules present in the data. A functional module is a coherent group of genes that participate in the same pathway, protein complex, or cellular process.

{{SECTION_A_COMPARISON_TYPE}}

For each functional module:
- Briefly define the overall function of the module.
- Provide a **table** with the following columns: (1) display name from the input list, {{SECTION_A_TABLE_COLUMNS}} (2) a brief description of what each gene does within the module, summarizing the common function across all listed orthologs/homologs.
- State the **number of genes** from the input list that support this module and provide a qualitative **confidence assessment** (strong: 5+ genes with clear functional coherence; moderate: 3-4 genes; suggestive: 1-2 genes).

Do not simply list enriched terms. Synthesize the functional meaning of each module.

### B. Cell Surface & Receptors

Identify all genes in the list that encode:
- Receptors (GPCRs, receptor tyrosine kinases, nuclear receptors, ion channel receptors, etc.)
- Cell adhesion molecules (cadherins, integrins, IgSF, lectins, etc.)
- Ion channels and transporters
- Structural surface proteins and extracellular matrix components

For each, describe its known function and what it reveals about:
- How this cell physically interacts with its environment and neighboring cells
- What signals this cell is competent to receive
- What tissues or structures this cell may be associated with

{{SECTION_BCD_COMPARISON_TYPE}}

### C. Secretory & Signaling Output

Identify all genes in the list related to what this cell **produces and releases**:
- Neuropeptide processing (prohormone convertases, carboxypeptidases, amidating enzymes)
- Neurotransmitter synthesis pathways (monoamines: TH, DDC, TPH; acetylcholine: ChAT; GABA: GAD; glutamate, glycine, etc.)
- Secreted signaling ligands (Wnts, BMPs, FGFs, Hedgehog, Notch ligands, etc.)
- Exocytosis and secretory machinery (synaptotagmins, SNAREs, chromogranins, dense-core vesicle components)
- Other secreted products (mucins, toxins, venom components, ECM proteins, secreted enzymes, biomineralization proteins)

For each, describe its known function and what it reveals about:
- What signals or products this cell sends to its environment
- What downstream targets or tissues this cell may influence
- Whether the secretory profile suggests a specific cell identity (e.g., neurotransmitter identity, biomineralizing cell, secretory epithelium)

{{SECTION_BCD_COMPARISON_TYPE}}

### D. Metabolic Signatures

Identify metabolic enzymes, metabolite transporters, and cofactor biosynthesis genes in the list. Describe the metabolic profile they suggest:
- Is the cell primarily oxidative, glycolytic, or mixed?
- Are there signatures of specific biosynthetic pathways (lipid, amino acid, nucleotide, etc.)?
- Are there metabolic features diagnostic of particular cell types (e.g., melanin synthesis, chitin metabolism, heme biosynthesis)?

{{SECTION_BCD_COMPARISON_TYPE}}

### E. Transcriptional Regulation

Based on the gene list:
1. Identify all transcription factors and transcription cofactors. Summarize their conserved functions and known target genes in animals, emphasizing functions congruent with the cellular identity emerging from Sections B–D.
2. Discuss to what extent these TFs (or their orthologs) are known to physically or cooperatively interact to regulate gene expression.
3. Propose a set of transcription factor regulatory complexes or circuits that may be driving the expression program defined by the functional genes in this list.
4. Note any TFs that are known master regulators of specific cell fates in model organisms.

{{SECTION_E_COMPARISON_TYPE}}

### F. Synthesis of Cellular Functions

Integrate the results from Sections A–E into a synthetic narrative. This section should connect the transcriptional regulators (Section E) to the effector genes they likely control (Sections B–D). Specifically:

1. **What do these genes collectively tell us about what this cell does?** Describe the major functional signatures as a coherent cellular program.
2. **TF-effector links:** Where known TF-target relationships exist in model organisms, note them explicitly. Highlight where TFs and effectors from the same {{COMPARISON_TYPE_OR_RANK}} converge — this is the strongest evidence for a coherent regulatory program.
3. **Protein complexes and molecular machinery:** Identify any conserved complexes or machinery suggested by co-expression (e.g., ribosomal subunits, proteasome, COPI/COPII/ESCRT, cytoskeletal assemblies).
4. **Convergent evidence:** Highlight where multiple lines of evidence (TFs, effectors, surface markers, metabolic profile) point to the same cell identity.

{{SECTION_F_COMPARISON_TYPE}}

{{FAMILY_AWARE_SYNTHESIS_NOTE}}

### G. Interpretation in the Context of {{COMMON_NAME}} Biology

Conduct a thorough literature search on cell types and tissues in {{COMMON_NAME}}, closely related species within the {{CLADE_PLURAL}}, and the broader phylum. Specifically:

1. **This species:** Search for published transcriptomic, proteomic, histological, or ultrastructural studies on {{ORGANISM}} cell types. If any exist, compare the gene expression profile directly.
2. **Close relatives:** Search for studies on cell types in other {{CLADE_PLURAL}}, particularly single-cell or bulk RNA-seq datasets. Identify cell populations described in relatives that may correspond to this cluster based on shared markers, morphology, or anatomical position.
3. **Phylum-level context:** Search more broadly across the phylum for described cell types, tissue functions, or developmental programs that match the functional profile from Sections B–F. {{CLADE_PLURAL}} may have cell types with no vertebrate or *Drosophila* equivalent — look for these.
4. **Functional context:** Address why this specific combination of genes would be expressed together in the biological context described in the input data. Propose explanations grounded in the organism's life history, anatomy, and ecology.

Do not rely solely on model organism extrapolation. Prioritize primary literature on {{CLADE_PLURAL}} and related phyla.

{{ORGANISM_SPECIFIC_CONTEXT}}

### H. Comparative Biological Analysis

Compare the inferred functional profile of this cell population to well-characterized cells in other {{CLADE_PLURAL}} and in animal model organisms. This comparison should:

1. Identify **multiple candidate cell type matches** — different functional signatures in the data may resemble different known cell types. Do not force a single best match. Present each comparison separately.
2. For each comparison, explicitly list:
   - The shared transcription factors
   - The shared functional/effector genes
   - The key differences
3. **Prioritize comparisons where both TFs and functional genes are shared** — these represent the strongest evidence for homologous cell type programs.
4. Identify the **cell type family or class** this population most likely belongs to (e.g., neuron, muscle, secretory epithelium, immune-like). A cell type may be a lineage-specific member of a conserved family without having a 1-to-1 homolog in other species.
5. Compare the transcriptional regulators specifically to those of other animal cell types to identify potential conserved transcriptional circuits or modules.
{{SECTION_H_COMPARISON_TYPE}}

### I. Evolutionary Interpretation

Based on the comparative analysis:
- Is this a **conserved pan-animal** cell type program (shared TFs + effectors across distant phyla)?
- Is it a **clade-specific** program (shared within {{CLADE_PLURAL}} but not broadly)?
- Is it a **lineage-specific innovation** (unique to {{COMMON_NAME}} or its close relatives)?
- Or a **lineage-specific variant** of a conserved cell type family (e.g., a {{COMMON_NAME}}-specific type of neuron, muscle, or secretory cell)?

Discuss the evidence for each interpretation. Note that 1-to-1 cell type homology across phyla is the exception, not the rule — most cell types belong to conserved families but have lineage-specific features.

{{SECTION_I_COMPARISON_TYPE}}

### J. Critical Evaluation

1. **Surprising absences:** Discuss any key genes whose absence from the list is unexpected given the inferred functions. What would you expect to see if the cell type interpretation is correct?
2. **Ambiguous genes:** Identify genes that may be particularly important functionally but whose function is ambiguous because their ortholog/homolog list contains genes with divergent functions. These are priority candidates for further investigation (e.g., protein domain analysis, structural prediction).
3. **Uncharacterized genes:** Report the number of genes in the list that have no identified orthologs or whose orthologs are uncharacterized. Note that these may represent lineage-specific innovations and could be among the most biologically interesting genes in the list.
{{SECTION_J_COMPARISON_TYPE}}

### K. Comparison Type Summary

{{SECTION_K}}

{{SECTION_K_FAMILY_AWARE}}

## 5. Citation and Formatting Requirements

- Use in-line citations [1, 2] within the text.
- Provide a full, numbered **References** section at the end.
- Order references by first appearance in the text.
- Format in Trends journal style: `Author, A.B. et al. (YYYY) Title of paper. J. Abbrev. vol, pages.`
- **Reference accuracy is critical:**
  - Always provide author(s) and year.
  - Provide a DOI link **only** if you can verify it is correct. It is far better to cite a real paper without a link than to provide a hallucinated or incorrect link.
  - If you are uncertain whether a reference is real or whether the details (authors, title, journal, year) are correct, **flag it explicitly** with a note such as "[verification needed]" so the reader knows to check it.
  - Do not fabricate references. If you cannot find a specific citation for a claim, state the claim without a citation and note that it is based on general knowledge of the field.
