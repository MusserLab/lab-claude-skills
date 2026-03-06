---
name: deep-research-genelist
description: >
  Generate deep research prompts from scRNAseq marker gene lists for cell type annotation.
  Use when the user invokes /gene-list-deep-research or asks to generate a deep research prompt
  from a gene list (cluster markers, WGCNA module, DE gene list). Produces a research-level
  prompt with structured YAML header for downstream compilation across clusters.
user-invocable: true
---

# Deep Research Gene List Prompt Generator

Generates a customized deep research prompt from a scRNAseq marker gene list. The prompt is designed to be pasted into a deep research tool (e.g., Claude) along with the gene list TSV to produce a research-level cell type annotation report.

The generated reports include a machine-readable YAML header that can be parsed to compile annotations across many gene lists.

---

## Workflow

### Step 1: Gather Basic Inputs

Ask the user for the following information. Use `AskUserQuestion` for structured choices and conversation for free-text inputs. If the user has already provided some of this information, skip those questions.

**Required:**

| Input | Description | Example |
|-------|-------------|---------|
| `ORGANISM` | Full species name (italicized) | *Acanthochitona crinata* |
| `COMMON_NAME` | Common name | chiton |
| `CLADE` | Broader taxonomic group | mollusc |
| `CLADE_PLURAL` | Plural form for comparative text | molluscs |
| `TISSUE_CONTEXT` | What tissue/stage the data comes from | larvae, polyps, adult brain |
| `DATASET_DESCRIPTION` | Brief dataset description | larval scRNAseq atlas |
| `MODULE_TYPE` | Type of gene list | cluster markers, WGCNA module, DE gene list |
| `MODULE_TYPE_DESCRIPTION` | Longer description for the prompt | "cluster markers for cluster 'nervous_3'" |
| `MODULE_ID` | Identifier for this specific module | nervous_3, module_blue, DE_treatmentA_vs_B |
| `BIOLOGICAL_CONTEXT` | What cells express these genes, what's known | "Markers of a neural cluster co-expressing neuropeptide processing genes" |

**Required for merged mode only:**

| Input | Description | Example |
|-------|-------------|---------|
| `CLADE_FAMILY` | Cell type clade/family for the within-clade comparison | shell, cerebral_neurons, sensory_motoneuron |

**Optional (ask if not provided):**

| Input | Description | Default |
|-------|-------------|---------|
| `SOURCE_OBJECT` | Path to source .rds/.h5ad file | *(empty)* |
| `CLUSTERING_COLUMN` | Metadata column used for clustering | *(empty)* |
| `ORGANISM_SPECIFIC_CONTEXT` | Specific biological questions to address | *(empty — section F will be generic)* |
| `COMPARATIVE_ORGANISMS` | Organisms to prioritize for comparison | *(model organisms + closest well-studied relatives)* |
| Output path | Where to save the prompt | `outs/deep_research/{MODULE_ID}/{MODULE_ID}_prompt.md` |

### Step 2: Read Gene List and Detect Format

1. Read the first 10–20 lines of the gene list file(s).
2. Count total genes per file.
3. **Detect annotation methods** by consulting `~/.claude/skills/deep-research-genelist/references/annotation_methods.md` and checking for:
   - Column names (e.g., `phylome_*`, `prost_*`, `eggnog_*`, `emapper_*`)
   - Data patterns (e.g., `*` suffix on display names = PROST; `1-to-N` notation = phylome)
   - Known column layouts from the method library

4. **Present inference to user — ALWAYS ASK FOR CONFIRMATION:**

   > "This gene list appears to use the following annotation methods:
   > - **[Method A]** (detected from columns: X, Y)
   > - **[Method B]** (detected from: `*` suffix on display names)
   >
   > Is this correct? Are there additional methods or caveats I should know about?"

5. If the format doesn't match any known method, ask the user to describe it:

   > "I don't recognize the annotation format in columns [X, Y]. Please describe
   > how gene names were assigned and how to interpret them."

**CRITICAL:** Never silently commit to a format interpretation. Always confirm.

### Step 2b: Determine Marker Comparison Type

Ask the user which marker list structure they're providing:

| Type | Description | Section 6 structure |
|------|-------------|---------------------|
| `single` | One gene list (e.g., vs all cells only) | Section 6: single list |
| `merged` | One list with `comparison_type` column (vs_all / within_clade / both) | Section 6: single merged list |

For `merged` mode:
- Ask which **cell type clade/family** is used for the within-clade comparison (e.g., "shell clade", "neuron clade", "sensory cell clade"). These are groups of related cell types on the cell type tree, not anatomical tissue regions.
- The merged list should have a `comparison_type` column with values:
  - `both` — gene is a marker in BOTH vs-all and within-clade comparisons (most diagnostic)
  - `vs_all` — gene is distinctive globally but not within the clade (reflects clade-level identity)
  - `within_clade` — gene distinguishes this cluster from its closest relatives but is not globally distinctive (subtype specialization)

### Step 3: Build Annotation Method Guidance

Based on the confirmed methods from Step 2, assemble three text blocks:

#### 3a. `DATA_FORMAT_DESCRIPTION`

Auto-generate column descriptions from the actual file header. For `merged` mode, describe the comparison_type column:

> The gene list contains markers from two complementary differential expression
> comparisons, merged into a single table with a `comparison_type` column:
>
> - **`both`** — Gene is a significant marker in BOTH comparisons. These are the
>   most diagnostic markers: globally distinctive AND locally distinctive within
>   the cell type clade.
> - **`vs_all`** — Gene is distinctive compared to all other cells in the dataset
>   but NOT compared to other clusters in the same cell type clade/family. These
>   genes often reflect the shared identity of the clade (e.g., "being a neuron")
>   rather than what makes this specific cluster unique.
> - **`within_clade`** — Gene distinguishes this cluster from its closest relatives
>   in the {{CLADE_FAMILY}} clade but is not globally distinctive. These genes
>   reveal subtype specialization — what makes this cell different from related
>   cell types on the cell type tree.
>
> Columns: [actual column descriptions from file header]

#### 3b. `ORTHOLOGY_METHOD`

Combine the interpretation guidance blocks from the annotation methods reference
file for each confirmed method. Example for phylome + PROST:

> Gene names in this list come from two annotation sources:
>
> 1. **Phylome sequence orthology** (names without `*` suffix): [guidance from reference]
> 2. **PROST structural homology** (names with `*` suffix): [guidance from reference]
>
> Genes with display_name equal to their raw gene ID (e.g., comp12345_c0) have
> no identified homolog by any method — these are uncharacterized.

#### 3c. `WEIGHTING_GUIDANCE`

Generate from the actual data columns:

> Genes are ranked by adjusted p-value (ascending). Top-ranked genes are most
> specific to this cluster. The avg_log2FC column indicates effect size. Genes
> with high pct.1 (expressed in this cluster) and low pct.2 (expressed elsewhere)
> are the most diagnostic markers.
>
> [For merged mode:] The `comparison_type` column indicates how a gene was
> identified. Prioritize genes marked `both` — these are distinctive both
> globally and within the cell type clade. Use `vs_all` genes for broad
> functional profiling and clade-level identity. Use `within_clade` genes
> to understand subtype specialization. When a gene appears only in one
> comparison, its p-value and log2FC come from that comparison.

### Step 4: Fill Template

1. Read the template at `~/.claude/skills/deep-research-genelist/templates/report-prompt-template.md`.
2. Replace all `{{PLACEHOLDER}}` tokens with the gathered and generated inputs.
3. For `{{ORGANISM_SPECIFIC_CONTEXT}}`:
   - If provided, insert the text as a bullet point or paragraph within section F.
   - If not provided, insert a generic prompt: "Consider the known biology of {{COMMON_NAME}} cell types and how the inferred functions relate to the organism's life history and ecology."
4. **Handle merged-mode conditional placeholders:**
   - **Single mode:** Remove all `{{MERGED_MODE_*}}` placeholders (replace with empty string).
   - **Merged mode:** Replace each placeholder with the corresponding guidance text:

   **`{{MERGED_MODE_INPUT_GUIDANCE}}`** (Section 2):
   > - **Comparison types:** Each gene has a `comparison_type` value indicating how it was identified as a marker. Genes marked `both` are the most diagnostic — they are distinctive both globally and within the cell type clade. Genes marked `vs_all` reflect the broader clade identity. Genes marked `within_clade` reveal what specifically distinguishes this cluster from its closest relatives in the {{CLADE_FAMILY}} clade.

   **`{{MERGED_MODE_SECTION_A}}`** (Functional Enrichment):
   > - For each functional module, note which `comparison_type` categories its member genes come from. Modules driven primarily by `both` genes represent the core identity of this cell type. Modules driven by `vs_all`-only genes likely reflect the shared clade-level program. Modules driven by `within_clade`-only genes reveal subtype-specific specialization.

   **`{{MERGED_MODE_SECTION_D}}`** (Synthesis):
   > - Explicitly address two questions: (1) What functional programs does this cell share with other members of its cell type clade? (These are reflected in `vs_all`-only markers.) (2) What makes this cell distinctive within its clade? (These are reflected in `within_clade` and `both` markers.) The interplay between shared and unique programs often reveals how a cell type diversified from its relatives.

   **`{{MERGED_MODE_SECTION_G}}`** (Comparative):
   > 6. When making cross-species comparisons, prioritize genes marked `both` — these provide the strongest evidence because they define this cell type at both the global and local level. Genes marked only `within_clade` may point to lineage-specific subtype diversification that is less likely to have direct cross-species homologs.

   **`{{MERGED_MODE_SECTION_I}}`** (Critical Evaluation):
   > 4. **Comparison type patterns:** Note any genes that are strong `within_clade` markers but absent from the `vs_all` list. These may represent genes that are broadly expressed across the dataset but specifically enriched in this subtype relative to its clade — potentially the most interesting candidates for understanding subtype identity and diversification.

5. **Embed the gene list** as Section 6 at the end of the prompt:
   - **Single mode:** One code block with the full gene list.
   - **Merged mode:** One code block with the merged gene list (includes `comparison_type` column). Add a brief header explaining the three comparison_type values.

6. **For merged mode**, also ask the user for `CLADE_FAMILY` — the name of the cell type clade used for the within-clade comparison (e.g., "shell", "cerebral_neurons", "sensory_motoneuron"). This is inserted into the template guidance to give the deep research tool specific context about what "within clade" means for this cluster.

### Step 5: Save Prompt

1. Create the output directory if needed (e.g., `outs/deep_research/{MODULE_ID}/`).
2. Write the completed prompt to the output path.
3. Report the file path to the user.

### Step 6: Instruct User

Tell the user:

> **Prompt saved to `{output_path}`.**
>
> To use it:
> 1. Open your deep research tool (e.g., Claude deep research).
> 2. Paste the contents of the prompt file. The gene list is already embedded in Section 6 — no attachment needed.
> 3. Run the query.
>
> The report will include a YAML header block at the top that can be parsed programmatically for compilation across clusters.

---

## Batch Mode

When generating prompts for multiple clusters from the same dataset, most inputs
are shared. The skill should:

1. Gather shared inputs once (organism, clade, dataset description, annotation methods, etc.)
2. Confirm the annotation method interpretation once for the whole batch.
3. Determine mode (single vs merged) once for the whole batch.
4. For each cluster:
   - Set `MODULE_ID`, `MODULE_TYPE_DESCRIPTION`, `BIOLOGICAL_CONTEXT`, and `CLADE_FAMILY`
   - Extract the cluster's genes from the marker table(s)
   - For merged mode: merge vs-all and within-clade lists, deduplicate genes,
     assign `comparison_type` (both/vs_all/within_clade), sort by significance
   - Fill template and save
5. Report all saved file paths at the end.

For batch mode, the `BIOLOGICAL_CONTEXT` can use a default based on the cluster
name (e.g., "Markers of cluster 'shell_14_1' in the shell cell type clade")
unless the user provides specific context for individual clusters.

The `CLADE_FAMILY` is set per-cluster from the clade lookup table (e.g., "shell"
for shell_14_1, "cerebral_neurons" for neurons_7).

---

## Annotation Method Library

The file `~/.claude/skills/deep-research-genelist/references/annotation_methods.md`
contains descriptions of known gene annotation methods (phylome, eggNOG, PROST,
OrthoFinder, manual). Each entry includes:

- How to recognize the method in data (column names, patterns)
- Interpretation guidance for the deep research prompt
- Reliability assessment
- Caveats

**The library is extensible.** When a new annotation method is encountered, add
it to the reference file after confirming the details with the user.

**Format varies by project.** Even for the same method (e.g., eggNOG), the actual
column layout may differ between projects. The library provides recognition
hints and default descriptions, but the skill must always ask the user to confirm
the specific format in their data.

---

## Parsing Reports (Downstream)

When the user has completed deep research reports and wants to compile them, the YAML front matter can be extracted from each report file. The YAML block is delimited by `---` at the start of the file. Key fields for compilation:

- `annotation.proposed_name` — cell type name
- `annotation.one_line` — one-sentence description
- `annotation.summary` — 2-3 sentence summary for supplementary tables
- `annotation.confidence` — high/medium/low
- `annotation.best_matches` — list of comparable cell types with shared TFs and genes
- `annotation.cell_type_family` — broad family classification
- `markers.top_diagnostic` — top 5-10 marker genes
- `markers.transcription_factors` — TF list

To compile across reports:
1. Glob all `*_report.md` or `*_deep_research.md` files
2. Parse YAML front matter from each
3. Build a summary table with one row per module/cluster

---

## Notes

- The template is organism-agnostic. All organism-specific content comes from the user inputs.
- Gene list format is flexible — the user describes their columns and that description is inserted verbatim into the prompt.
- The prompt asks the deep research tool to produce the YAML header as part of its output. The header schema is defined in the template.
- Reports prioritize accuracy: references must be verifiable, DOI links only when certain, hallucinated citations explicitly flagged.
