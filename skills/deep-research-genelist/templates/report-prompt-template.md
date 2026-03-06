# Deep Research Prompt: Gene List Analysis for Cell Type Annotation

## 1. Role and Objective

Act as an expert in molecular and cellular biology with specialized knowledge in {{CLADE}} biology, comparative genomics, and single-cell transcriptomics. Your task is to analyze a list of genes from a single-cell RNA-seq experiment in {{ORGANISM}} and generate a research-level report for a biologist with a broad interdisciplinary background. The report should synthesize the potential functions of these genes to infer the biological identity and role of the cells in which they are expressed.

## 2. Input Data

The gene list (included in Section 6 below) is derived from {{MODULE_TYPE_DESCRIPTION}} identified in {{ORGANISM}} {{TISSUE_CONTEXT}}.

- **Biological Context:** {{BIOLOGICAL_CONTEXT}}
- **Data Format:** {{DATA_FORMAT_DESCRIPTION}}
- **Orthology/Homology Method:** {{ORTHOLOGY_METHOD}}
- **Gene Weighting:** {{WEIGHTING_GUIDANCE}}
{{MERGED_MODE_INPUT_GUIDANCE}}

When analyzing these genes, keep the following in mind:
- We do not know the function of the {{COMMON_NAME}} genes directly. The orthology and homology assignments are a guide to what proteins are most similar in sequence or language-model embedding space.
- When a {{COMMON_NAME}} gene is orthologous or homologous to multiple genes in another species, we do not know which is the closest functional match. Consider all orthologs/homologs when discussing potential function.
- Genes ranked higher in the list (by statistical significance or effect size) are more likely to be biologically meaningful for defining this cell population. Weight your interpretation accordingly, but do not ignore lower-ranked genes — they may contribute to secondary functional signatures.

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
  key_pathways: ["<pathway1>", "<pathway2>"]
  metabolic_signature: "<brief description of metabolic profile>"
  n_uncharacterized_notable: <integer — count of uncharacterized genes worth further investigation>
---
```

Fill in every field based on your analysis. Use empty lists `[]` if a category has no members. Do not omit fields.

## 4. Analytical Workflow and Report Structure

Generate your report following this structure. Use the section letters (A–I) as headings.

### A. Functional Enrichment Summary

Based on the provided gene list and their orthologs/homologs, identify the distinct functional modules present in the data. A functional module is a coherent group of genes that participate in the same pathway, protein complex, or cellular process.

For each functional module:
- Briefly define the overall function of the module.
- Provide a **table** with the following columns: (1) gene ID from the input list, (2) full list of orthologs/homologs, (3) a brief description of what each gene does within the module, summarizing the common function across all listed orthologs/homologs.
- State the **number of genes** from the input list that support this module and provide a qualitative **confidence assessment** (strong: 5+ genes with clear functional coherence; moderate: 3-4 genes; suggestive: 1-2 genes).
{{MERGED_MODE_SECTION_A}}

Do not simply list enriched terms. Synthesize the functional meaning of each module.

### B. Cell Surface Markers, Receptors, and Signaling

Identify all genes in the list that encode:
- Receptors (GPCRs, receptor tyrosine kinases, nuclear receptors, ion channel receptors, etc.)
- Signaling ligands and secreted proteins
- Ion channels and transporters
- Cell adhesion molecules (cadherins, integrins, IgSF, lectins, etc.)

For each, describe its known function and what it reveals about:
- How this cell communicates with neighboring cells and its environment
- What signals this cell is competent to send and receive
- What tissues or structures this cell may physically interact with

### C. Metabolic Signatures

Identify metabolic enzymes, metabolite transporters, and cofactor biosynthesis genes in the list. Describe the metabolic profile they suggest:
- Is the cell primarily oxidative, glycolytic, or mixed?
- Are there signatures of specific biosynthetic pathways (lipid, amino acid, nucleotide, etc.)?
- Are there metabolic features diagnostic of particular cell types (e.g., melanin synthesis, chitin metabolism, neurotransmitter synthesis)?

### D. Synthesis of Cellular Functions

Integrate the results from sections A–C into a synthetic narrative. Describe the major functional signatures of this gene module as a coherent cellular program. Specifically:
- What do these genes collectively tell us about what this cell does?
- Identify any protein complexes or conserved molecular machinery suggested by co-expression (e.g., ribosomal subunits, proteasome components, endomembrane trafficking systems like COPI/COPII/ESCRT, cytoskeletal assemblies).
- Highlight where multiple lines of evidence converge on the same functional interpretation (e.g., TFs, effectors, and surface markers all pointing to the same cell identity).
{{MERGED_MODE_SECTION_D}}

### E. Transcriptional Regulation

Based on the gene list:
1. Identify all transcription factors and transcription cofactors. Summarize their conserved functions and known target genes in animals, emphasizing functions congruent with the cellular identity described in section D.
2. Discuss to what extent these TFs (or their orthologs) are known to physically or cooperatively interact to regulate gene expression.
3. Propose a set of transcription factor regulatory complexes or circuits that may be driving the expression program defined by the functional genes in this list.
4. Note any TFs that are known master regulators of specific cell fates in model organisms.

### F. Interpretation in the Context of {{COMMON_NAME}} Biology

Discuss the synthesized functions in the specific context of {{COMMON_NAME}} cell types and biology.
{{ORGANISM_SPECIFIC_CONTEXT}}

Address why this functional program would be expressed in the biological context described in the input data. Propose explanations grounded in the organism's biology.

### G. Comparative Biological Analysis

Compare the inferred functional profile of this cell population to well-characterized cells in other {{CLADE_PLURAL}} and in animal model organisms. This comparison should:

1. Identify **multiple candidate cell type matches** — different functional signatures in the data may resemble different known cell types. Do not force a single best match. Present each comparison separately.
2. For each comparison, explicitly list:
   - The shared transcription factors
   - The shared functional/effector genes
   - The key differences
3. **Prioritize comparisons where both TFs and functional genes are shared** — these represent the strongest evidence for homologous cell type programs.
4. Identify the **cell type family or class** this population most likely belongs to (e.g., neuron, muscle, secretory epithelium, immune-like). A cell type may be a lineage-specific member of a conserved family without having a 1-to-1 homolog in other species.
5. Compare the transcriptional regulators specifically to those of other animal cell types to identify potential conserved transcriptional circuits or modules.
{{MERGED_MODE_SECTION_G}}

### H. Evolutionary Interpretation

Based on the comparative analysis:
- Is this a **conserved pan-animal** cell type program (shared TFs + effectors across distant phyla)?
- Is it a **clade-specific** program (shared within {{CLADE_PLURAL}} but not broadly)?
- Is it a **lineage-specific innovation** (unique to {{COMMON_NAME}} or its close relatives)?
- Or is it a **lineage-specific variant** of a conserved cell type family (e.g., a {{COMMON_NAME}}-specific type of neuron, muscle, or secretory cell)?

Discuss the evidence for each interpretation. Note that 1-to-1 cell type homology across phyla is the exception, not the rule — most cell types belong to conserved families but have lineage-specific features.

### I. Critical Evaluation

1. **Surprising absences:** Discuss any key genes whose absence from the list is unexpected given the inferred functions. What would you expect to see if the cell type interpretation is correct?
2. **Ambiguous genes:** Identify genes that may be particularly important functionally but whose function is ambiguous because their ortholog/homolog list contains genes with divergent functions. These are priority candidates for further investigation (e.g., protein domain analysis, structural prediction).
3. **Uncharacterized genes:** Report the number of genes in the list that have no identified orthologs or whose orthologs are uncharacterized. Note that these may represent lineage-specific innovations and could be among the most biologically interesting genes in the list.
{{MERGED_MODE_SECTION_I}}

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
