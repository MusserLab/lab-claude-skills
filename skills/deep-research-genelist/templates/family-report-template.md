# Deep Research Prompt: Cell Type Family Program Analysis

## 1. Role and Objective

Act as an expert in molecular and cellular biology with specialized knowledge in {{CLADE}} biology, comparative genomics, and single-cell transcriptomics. Your task is to analyze a list of genes that define a **cell type family** in a single-cell RNA-seq experiment in {{ORGANISM}} and generate a research-level report for a biologist with a broad interdisciplinary background. The report should synthesize the potential functions of these genes to characterize the **shared biological program** that unifies the member cell types of this family.

## 2. Input Data

The gene list (included in Section 6 below) consists of {{MODULE_TYPE_DESCRIPTION}} identified in {{ORGANISM}} {{TISSUE_CONTEXT}}.

- **Biological Context:** {{BIOLOGICAL_CONTEXT}}
- **Family members:** This family contains {{N_MEMBER_CLUSTERS}} cell type clusters: {{MEMBER_CLUSTERS}}.
- **Gene selection:** {{FAMILY_MARKERS_DESCRIPTION}}
- **Gene List Format:** The gene list contains two columns:
  - `display_name`: the gene name (see Annotation Source Guide below for how to interpret different name formats)
  - `pct_nz_group`: the fraction of cells in the family-level group that express the gene
- **Gene List Filtering:** {{FILTERING_DESCRIPTION}}

### Annotation Source Guide

{{ANNOTATION_SOURCE_GUIDE}}

Genes whose display_name is a bare gene ID (e.g., `comp12345_c0`, `XLOC_012345`, `LOC12345`) have no identified homolog by any method — these are uncharacterized.

**Key analytical framing:** These genes define the **shared program** across {{N_MEMBER_CLUSTERS}} cell type clusters within this family. They are broadly expressed across the family members, not specific to any single cluster. Individual cluster-specific markers are analyzed in separate per-cluster reports. Your analysis should characterize what these cell types **have in common** — the core identity that makes them a family.

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
  report_type: "family"
  member_clusters:
    - "{{MEMBER_CLUSTER_1}}"
    - "{{MEMBER_CLUSTER_2}}"
  n_member_clusters: {{N_MEMBER_CLUSTERS}}
  source_object: "{{SOURCE_OBJECT}}"
  clustering_column: "{{CLUSTERING_COLUMN}}"
  marker_file: "{{MARKER_FILE}}"
  comparison_mode: "family_aware"
  biological_context: "<copy from input>"
  n_genes: <integer — count of genes in the input list>
  date_generated: "<YYYY-MM-DD>"

annotation:
  proposed_name: "<concise name for this cell type family>"
  alternative_names:
    - "<alternative name 1>"
    - "<alternative name 2>"
  confidence: "<high | medium | low>"
  confidence_rationale: "<1 sentence explaining the confidence level>"
  one_line: "<one-sentence description of this cell type family>"
  summary: >
    <2-3 sentence summary suitable for a supplementary table. Describe the shared
    functional program, key family-defining genes, and proposed family identity.>

  best_matches:
    - cell_type: "<name of the matching cell type family>"
      organism: "<species>"
      shared_tfs: ["<TF1>", "<TF2>"]
      shared_functional_genes: ["<gene1>", "<gene2>"]
      reference: "<Author et al. YYYY>"
      conservation: "<conserved pan-animal | conserved <clade-name> | lineage-specific | uncertain>"
    # Include ALL prominent matches — this family may correspond to
    # known cell type families in other species

  cell_type_family: "<broad family, e.g., neuron, muscle, epithelial, immune>"
  family_conservation: "<pan-animal | <clade>-specific | uncertain>"

markers:
  top_diagnostic:
    # 5-10 most informative genes for identifying this family
    - gene_id: "<original gene ID from input>"
      name: "<gene symbol>"
      role: "<brief functional role as a family marker>"
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

Since these are **family-level markers** (shared across {{N_MEMBER_CLUSTERS}} clusters), the modules you identify represent the **core functional programs** that define this family. These are not specific to any one cluster.

For each functional module:
- Briefly define the overall function of the module.
- Provide a **table** with the following columns: (1) display name from the input list, (2) a brief description of what each gene does within the module, summarizing the common function across all listed orthologs/homologs.
- State the **number of genes** from the input list that support this module and provide a qualitative **confidence assessment** (strong: 5+ genes with clear functional coherence; moderate: 3-4 genes; suggestive: 1-2 genes).

Do not simply list enriched terms. Synthesize the functional meaning of each module.

### B. Cell Surface & Receptors

Identify all genes in the list that encode:
- Receptors (GPCRs, receptor tyrosine kinases, nuclear receptors, ion channel receptors, etc.)
- Cell adhesion molecules (cadherins, integrins, IgSF, lectins, etc.)
- Ion channels and transporters
- Structural surface proteins and extracellular matrix components

For each, describe its known function and what it reveals about:
- How cells in this family physically interact with their environment and neighboring cells
- What signals cells in this family are competent to receive
- What tissues or structures this family may be associated with

Since these are family-level markers, these surface features are **shared across all member clusters** — they define the family's relationship to its environment.

### C. Secretory & Signaling Output

Identify all genes in the list related to what cells in this family **produce and release**:
- Neuropeptide processing (prohormone convertases, carboxypeptidases, amidating enzymes)
- Neurotransmitter synthesis pathways (monoamines: TH, DDC, TPH; acetylcholine: ChAT; GABA: GAD; glutamate, glycine, etc.)
- Secreted signaling ligands (Wnts, BMPs, FGFs, Hedgehog, Notch ligands, etc.)
- Exocytosis and secretory machinery (synaptotagmins, SNAREs, chromogranins, dense-core vesicle components)
- Other secreted products (mucins, toxins, venom components, ECM proteins, secreted enzymes, biomineralization proteins)

For each, describe its known function and what it reveals about:
- What signals or products this cell family sends to its environment
- What downstream targets or tissues this family may influence
- Whether the secretory profile suggests a specific family identity

### D. Metabolic Signatures

Identify metabolic enzymes, metabolite transporters, and cofactor biosynthesis genes in the list. Describe the metabolic profile they suggest:
- Is the family primarily oxidative, glycolytic, or mixed?
- Are there signatures of specific biosynthetic pathways (lipid, amino acid, nucleotide, etc.)?
- Are there metabolic features diagnostic of particular cell type families (e.g., melanin synthesis, chitin metabolism, heme biosynthesis)?

### E. Transcriptional Regulation

Based on the gene list:
1. Identify all transcription factors and transcription cofactors. Summarize their conserved functions and known target genes in animals, emphasizing functions congruent with the family identity emerging from Sections B–D.
2. Discuss to what extent these TFs (or their orthologs) are known to physically or cooperatively interact to regulate gene expression.
3. Propose a set of transcription factor regulatory complexes or circuits that may be driving the **family-level** expression program defined by the functional genes in this list.
4. Note any TFs that are known master regulators of specific cell type families in model organisms. These are the strongest candidates for **family-specifying TFs** — TFs that establish and maintain the shared identity across all member clusters.

### F. Synthesis of Cellular Functions

Integrate the results from Sections A–E into a synthetic narrative. This section should connect the transcriptional regulators (Section E) to the effector genes they likely control (Sections B–D). Specifically:

1. **What do these genes collectively tell us about what this cell type family does?** Describe the major functional signatures as a coherent family-level program.
2. **TF-effector links:** Where known TF-target relationships exist in model organisms, note them explicitly. Highlight where family-specifying TFs and shared effectors converge — this is the strongest evidence for a coherent family-level regulatory program.
3. **Protein complexes and molecular machinery:** Identify any conserved complexes or machinery suggested by co-expression (e.g., ribosomal subunits, proteasome, COPI/COPII/ESCRT, cytoskeletal assemblies).
4. **What diversification axes exist within this family?** Based on the shared program, speculate about what functional dimensions the {{N_MEMBER_CLUSTERS}} member clusters might diversify along. For example, a neuron family might share core neural machinery but diversify in neurotransmitter identity, receptor profiles, or axon guidance.

### G. Interpretation in the Context of {{COMMON_NAME}} Biology

Conduct a thorough literature search on cell type families and tissues in {{COMMON_NAME}}, closely related species within the {{CLADE_PLURAL}}, and the broader phylum. Specifically:

1. **This species:** Search for published transcriptomic, proteomic, histological, or ultrastructural studies on {{ORGANISM}} cell types. If any describe cell type families or tissue compartments, compare the gene expression profile directly.
2. **Close relatives:** Search for studies on cell type families in other {{CLADE_PLURAL}}, particularly single-cell or bulk RNA-seq datasets. Identify cell type families described in relatives that may correspond to this family based on shared markers, morphology, or anatomical position.
3. **Phylum-level context:** Search more broadly across the phylum for described cell type families, tissue functions, or developmental programs that match the functional profile from Sections B–F. {{CLADE_PLURAL}} may have cell type families with no vertebrate or *Drosophila* equivalent — look for these.
4. **Functional context:** Address why this specific combination of genes would be broadly shared across {{N_MEMBER_CLUSTERS}} related cell types. Propose explanations grounded in the organism's life history, anatomy, and ecology.

Do not rely solely on model organism extrapolation. Prioritize primary literature on {{CLADE_PLURAL}} and related phyla.

{{ORGANISM_SPECIFIC_CONTEXT}}

### H. Comparative Biological Analysis

Compare the inferred functional profile of this cell type family to well-characterized cell type families in other {{CLADE_PLURAL}} and in animal model organisms. This comparison should:

1. Identify **multiple candidate family matches** — different functional signatures in the data may resemble different known families. Do not force a single best match. Present each comparison separately.
2. For each comparison, explicitly list:
   - The shared transcription factors
   - The shared functional/effector genes
   - The key differences
3. **Prioritize comparisons where both TFs and functional genes are shared** — these represent the strongest evidence for homologous cell type family programs.
4. Compare at the **family level**: the question is not which specific cell type this matches, but which broad cell type family or lineage it belongs to.
5. Compare the transcriptional regulators specifically to those of other animal cell type families to identify potential conserved transcriptional circuits or modules.

### I. Evolutionary Interpretation

Based on the comparative analysis:
- Is this a **conserved pan-animal** cell type family (shared TFs + effectors across distant phyla)?
- Is it a **clade-specific** family (shared within {{CLADE_PLURAL}} but not broadly)?
- Is it a **lineage-specific innovation** (unique to {{COMMON_NAME}} or its close relatives)?
- Or a combination — a conserved core program with lineage-specific elaboration?

Discuss the evidence for each interpretation. Focus on the family-level conservation: even if the individual member clusters are lineage-specific, the underlying family program may be deeply conserved.

### J. Critical Evaluation

1. **Surprising absences:** Discuss any key genes whose absence from the family marker list is unexpected given the inferred functions. These genes may be present in some but not all member clusters (cluster-specific), or they may have been excluded by the filtering criteria.
2. **Ambiguous genes:** Identify genes that may be particularly important functionally but whose function is ambiguous because their ortholog/homolog list contains genes with divergent functions.
3. **Uncharacterized genes:** Report the number of genes in the list that have no identified orthologs or whose orthologs are uncharacterized. Note that these may represent lineage-specific innovations that are **shared across the family** — potentially the most biologically interesting genes.

### K. Family Program Summary

Provide a concise summary of the key findings:

1. **Proposed family identity:** Name and brief description of the cell type family.
2. **Core functional program:** The 3-5 most important functional modules that define this family (from Section A).
3. **Family-specifying TFs:** The top 3-5 transcription factors that likely establish and maintain the family identity (from Section E).
4. **Top diagnostic markers:** The 5-10 genes most informative for identifying cells belonging to this family.
5. **Best cross-species match:** The closest match to a known cell type family in other organisms (from Section H).
6. **Predicted diversification axes:** What functional dimensions do the {{N_MEMBER_CLUSTERS}} member clusters likely diversify along? (from Section F).
7. **Most notable unknowns:** Uncharacterized genes or surprising absences worth investigating.

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
