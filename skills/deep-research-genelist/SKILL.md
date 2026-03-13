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

Generates a customized deep research prompt from a scRNAseq marker gene list. The prompt is designed to be pasted into a deep research tool (e.g., Claude, ChatGPT) to produce a research-level cell type annotation report.

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
| `CLADE_PLURAL` | Plural form for comparative text (auto-derive if obvious) | molluscs |
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

**Required for family_aware mode only:**

| Input | Description | Example |
|-------|-------------|---------|
| `CLADE_FAMILY` | (per-cluster, from clade lookup) | neurons, epithelial, mesoderm |
| `FAMILY_MARKERS_DIR` | Path to per-family filtered marker TSVs | `outs/13_.../family_markers_filtered/` |
| `CLADE_LOOKUP_PATH` | Path to clade lookup TSV | `outs/13_.../clade_lookup.tsv` |
| `MEMBER_CLUSTERS` | (per-family report) List of fine clusters in this family | `["VNC-ChAT+", "VNC-interneuron-ChAT", ...]` |

**Optional (ask if not provided):**

| Input | Description | Default |
|-------|-------------|---------|
| `SOURCE_OBJECT` | Path to source .rds/.h5ad file | *(empty)* |
| `CLUSTERING_COLUMN` | Metadata column used for clustering | *(empty)* |
| `ORGANISM_SPECIFIC_CONTEXT` | Specific biological questions to address | *(empty — section G will use generic guidance)* |
| `COMPARATIVE_ORGANISMS` | Organisms to prioritize for comparison | *(model organisms + closest well-studied relatives)* |
| Output path | Where to save the prompt | `outs/deep_research/{MODULE_ID}/{MODULE_ID}_prompt.md` |

### Step 2: Detect Input Type and Read Gene List

Determine whether the input is a **marker table** (with statistics) or a **plain gene list** (names only).

1. Read the first 10–20 lines of the gene list file.
2. Check for statistical columns (`p_val`, `p_val_adj`, `avg_log2FC`, `pct.1`, `pct.2`).

**If marker table:**
- Filter genes to `p_val_adj < 0.05` AND `pct.1 > 0.10`
- Report filtering: "Starting with N markers, filtered to M after p_val_adj < 0.05 and pct.1 > 10%."
- Extract the slim gene list: `display_name`, `pct.1`, and `comparison_type` if present
- Set `FILTERING_DESCRIPTION` to: "Genes were pre-filtered to adjusted p-value < 0.05 and expression in at least 10% of cluster cells."

**If plain gene list:**
- Take all genes as-is
- Set `FILTERING_DESCRIPTION` to: "All genes in the provided list are included."

3. Count total genes.

### Step 2b: Determine Marker Comparison Type

Check whether the gene list has a `comparison_type` column:

| Type | Description |
|------|-------------|
| `single` | One gene list without comparison_type (e.g., vs all cells only, or a plain gene list) |
| `merged` | One list with `comparison_type` column (vs_all / within_clade / both) |
| `family_aware` | Merged list + family marker data available (see detection below) |

**Decision tree:**

```
Has comparison_type column?
├─ NO → single mode (unchanged)
└─ YES → Has family marker data available?
    ├─ NO → merged mode (unchanged)
    └─ YES → family_aware mode
         ├─ Generate family reports (one per family, using family template)
         └─ Generate cluster reports (family markers removed, cross-reference added)
```

**Detecting family marker data:** Family-aware mode is available when the marker directory contains:
- `family_markers_filtered/` directory with per-family marker TSVs
- `family_marker_genes.tsv` (gene IDs per family for exclusion reference)
- `clade_lookup.tsv` with `cluster_name` and `family` columns

If these files are present, offer family-aware mode to the user. If not present but the user has family/clade groupings, suggest computing family markers first.

For `merged` mode:
- Ask which **cell type clade/family** is used for the within-clade comparison (e.g., "shell clade", "neuron clade"). These are groups of related cell types on the cell type tree.
- The merged list should have a `comparison_type` column with values:
  - `both` — gene is a marker in BOTH vs-all and within-clade comparisons (most diagnostic)
  - `vs_all` — gene is distinctive globally but shared within the clade (reflects clade-level identity)
  - `within_clade` — gene distinguishes this cluster from its closest relatives but is not globally distinctive

For `family_aware` mode:
- All `merged` mode inputs apply (comparison_type semantics are the same)
- Additionally require:
  - `FAMILY_MARKERS_DIR` — path to per-family filtered marker TSVs (e.g., `family_markers_filtered/`)
  - `CLADE_LOOKUP_PATH` — path to clade lookup TSV (`cluster_name`, `family` columns)
- Per-cluster merged files should already have family markers removed (the marker computation script handles this)
- **Two report types are generated:**
  1. **Family reports** — one per family, using the family report template (`templates/family-report-template.md`). Gene list is the broadly expressed family markers.
  2. **Cluster reports** — one per cluster, using the cluster template with family cross-reference conditionals. Gene list is the per-cluster merged markers (family markers already removed).

### Step 3: Build Annotation Source Guide

This is the key section that tells the deep research tool how to interpret gene names. The approach depends on whether an annotation profile already exists for this dataset.

#### 3a. Check for existing annotation profile

Look for `annotation_profile.yaml` in the dataset's output directory (e.g., `outs/deep_research/annotation_profile.yaml`).

**If profile exists:** Read it, briefly confirm with user ("Using annotation profile: orthology via custom phylome + PROST homology. Correct?"), and proceed to Step 3c.

**If no profile:** Proceed to Step 3b (interactive discovery).

#### 3b. Interactive annotation source discovery

**This step is critical for new species/datasets.** The annotation profile determines
how the deep research tool interprets every gene in the list. Invest significant time
here to get it right — errors propagate to all prompts generated from this profile.

1. **Sample gene names** from the gene list. Categorize by pattern:
   - Clean gene symbols (e.g., `Msx2`, `Rnf5`)
   - Symbols with `*` suffix (e.g., `Hes1*`, `Ngf/Ntf3*`)
   - Slash-separated names without `*` (e.g., `Nab1/2`, `Cpne5/8/9`)
   - Species-prefixed names (e.g., `hs-NGF`, `Dm-GYC`)
   - Names with orthology ratio (e.g., `1-to-4 Ralgds,Rgl1,Rgl2`)
   - Multi-word functional descriptions (e.g., `GTPase activity`, `metalloendopeptidase activity`)
   - Bare gene IDs (e.g., `comp12345_c0`, `XLOC_012345`)
   - Other patterns

2. **Present detected categories** with counts and examples to the user.

3. **Ask which annotation sources were used.** Use `AskUserQuestion` with multi-select:
   - eggNOG-mapper (orthology)
   - OrthoFinder (orthology)
   - Custom phylome pipeline (orthology)
   - PROST structural homology
   - BLASTp sequence similarity
   - Manual curation
   - Other (describe)

4. **For each selected source**, ask the user to provide:
   - **Concrete examples** of gene names from that source (at least 2-3 per source).
     Show detected patterns and ask the user to confirm or correct: "I see names like
     `Cpne5/8/9` and `Dm-cg1672/Spla2` — are these from the custom phylome?"
   - **How to distinguish** names from this source vs. other sources in the display_name
     column. Some sources may be indistinguishable by format alone (e.g., eggNOG single
     symbols look identical to phylome single symbols) — document this explicitly.
   - **Any special formatting conventions** — e.g., condensed names (`Cpne5/8/9` = Cpne5,
     Cpne8, Cpne9), overflow notation (`(+N)`), species prefixes (`Dm-`), truncation
     markers (`...`), description-only entries without gene symbols.
   - If the source is not in the annotation methods library, ask for a description of
     what it does and what confidence level to assign.

5. **Validate understanding** before saving. Present back a summary:
   > "Here's my understanding of the annotation sources in this dataset:
   > - **Orthology** (Tier 1): [methods] — [format description and examples]
   > - **Homology** (Tier 2): [methods] — [format description and examples]
   > - **Unannotated**: [pattern and examples]
   >
   > Is this correct? Any sources or formats I'm missing?"

   The user should explicitly confirm before saving. This is especially important for
   cases where multiple Tier 1 methods produce overlapping formats (e.g., eggNOG and
   phylome both produce single gene symbols).

6. **Save the annotation profile** as `annotation_profile.yaml` (see schema in Step 3d).

#### 3c. Assemble the Annotation Source Guide

Using the confirmed methods (from profile or interactive discovery), build the
`ANNOTATION_SOURCE_GUIDE` text block for the prompt. Consult
`~/.claude/skills/deep-research-genelist/references/annotation_methods.md`
for the interpretation guidance text for each method.

Structure the guide by tier:

```
**How to interpret gene names in this list:**

The gene names come from the following annotation sources, listed from highest to
lowest confidence:

1. **[Tier 4 — Manual curation]** (if present)
   [formatting description] → [interpretation guidance from reference]

2. **[Tier 1 — Orthology]** via [specific method(s)]
   [formatting description] → [interpretation guidance from reference]

3. **[Tier 2 — Homology]** via [specific method(s)]
   [formatting description] → [interpretation guidance from reference]

4. **[Tier 3 — Sequence similarity]** via [specific method(s)] (if present)
   [formatting description] → [interpretation guidance from reference]

Genes with bare gene IDs (e.g., comp12345_c0) have no identified homolog —
these are uncharacterized.
```

Only include tiers that are actually present in this dataset's annotation sources.

#### 3d. Annotation profile YAML schema

Save to `outs/deep_research/annotation_profile.yaml` (or dataset-specific location).
See `~/.claude/skills/deep-research-genelist/templates/annotation_profile_example.yaml`
for a complete example (Acanthochitona crinata chiton dataset).

```yaml
# Annotation profile for [dataset description]
# Generated: YYYY-MM-DD
# Confirmed by user: yes

dataset: "<dataset description>"
organism: "<organism>"
common_name: "<common name>"
date_created: "YYYY-MM-DD"
confirmed_by_user: true

sources:
  - method: "custom_phylome"       # key from annotation_methods.md
    tier: "orthology"              # orthology | homology | sequence_similarity | manual
    name_format: "clean gene symbol, sometimes with slash-separated co-orthologs"
    distinguishing_feature: "slash-separated names without * suffix; Dm- prefix; ... truncation"
    examples: ["Msx2", "Cpne5/8/9", "Dm-cg1672/Spla2", "Bdnf/Ngf/Ntf3..."]
    notes: "Custom phylome built for this species"

  - method: "prost"
    tier: "homology"
    name_format: "gene symbols with * suffix, max 4 genes with (+N) overflow"
    distinguishing_feature: "* suffix on display_name"
    examples: ["Hes1*", "Ngf/Ntf3/Bdnf/Ntf4 (+18)*"]
    notes: "Ordered best-to-worst; weight earlier hits more"

  - method: "manual"
    tier: "manual"
    name_format: "same as orthology names but for specific well-known genes"
    distinguishing_feature: "cannot be distinguished from orthology names by format alone"
    examples: []
    notes: "Small number of hand-verified names"

  # Add more sources as needed

unannotated:
  format: "bare gene ID"
  examples: ["comp101768_c0"]
  pattern: "comp\\d+-c\\d+"   # regex for detection (optional)
```

### Step 4: Fill Template

1. Read the template at `~/.claude/skills/deep-research-genelist/templates/report-prompt-template.md`.
2. Replace all `{{PLACEHOLDER}}` tokens with the gathered and generated inputs.

**Conditional placeholders by mode:**

The template has placeholders that differ between single and merged mode. Fill them
as follows:

**`{{COMPARISON_TYPE_COLUMN_DESCRIPTION}}`:**
- Single mode: *(remove — no comparison_type column)*
- Merged mode:
  > - `comparison_type`: how this gene was identified as a marker:
  >   - `both` — distinctive both globally AND within the cell type clade (most diagnostic)
  >   - `vs_all` — distinctive globally but shared within the clade (reflects clade-level identity)
  >   - `within_clade` — distinctive within the clade but not globally (subtype specialization)

**`{{MERGED_MODE_INPUT_GUIDANCE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > **The `comparison_type` column is central to your analysis.** It determines which
  > genes define the shared clade identity vs. the unique subtype specialization.
  > You must track and report which comparison_type each gene comes from throughout
  > all sections of the report. Genes marked `both` are the most diagnostic — they
  > define this cell type at both the global and local level. Genes marked `vs_all`
  > reflect the broader {{CLADE_FAMILY}} identity. Genes marked `within_clade` reveal
  > what specifically distinguishes this cluster from its closest relatives.
  >
  > **Important context for subclusters:** The clusters in this dataset are often
  > subclusters within a larger cell type clade. Subclusters within the same clade
  > may be very similar cell types or even cell states — the `vs_all` markers will
  > be largely overlapping across subclusters of the same clade because they reflect
  > the shared clade identity. The `within_clade` markers are where the meaningful
  > biological differences between subclusters lie. Do not over-interpret small
  > differences in vs_all markers between subclusters of the same clade — focus on
  > the within_clade markers to understand what makes this specific subcluster unique.

**`{{COMPARISON_TYPE_OR_RANK}}`:**
- Single mode: `rank in the gene list`
- Merged mode: `comparison_type category`

**`{{SECTION_A_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > **Organize modules by comparison_type:**
  >
  > 1. **Core identity modules** — modules composed primarily of `both` genes. These define this cell type at both the global and local level.
  > 2. **Shared clade modules** — modules composed primarily of `vs_all`-only genes. These reflect the broader program shared with other {{CLADE_FAMILY}} cell types.
  > 3. **Subtype specialization modules** — modules composed primarily of `within_clade`-only genes. These reveal what makes this specific cell type unique within its clade.
  >
  > Modules may span comparison types — note when this happens, as it suggests a program that is partly shared and partly specialized.

**`{{SECTION_A_TABLE_COLUMNS}}`:**
- Single mode: *(empty)*
- Merged mode: `(2) comparison_type,`

**`{{SECTION_BCD_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > For each gene, note its `comparison_type`. Identify which receptors/ligands/markers are part of the **shared clade program** (`vs_all`) vs. **subtype-specific** (`within_clade`) vs. **core identity** (`both`). This distinction reveals which aspects of the cell's surface, secretory, or metabolic profile are shared with relatives vs. unique to this cell type.

**`{{SECTION_E_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > For each TF, note its comparison_type:
  > - `vs_all` TFs are likely **clade-level regulators** (e.g., TFs that define all neurons, or all shell cells)
  > - `within_clade` TFs are likely **subtype-specific regulators** (e.g., TFs that distinguish this particular neuron subtype)
  > - `both` TFs define this specific cell type at all levels — these are the strongest candidates for master regulators of this cell identity
  >
  > Discuss how clade-level and subtype-specific TFs may interact to produce this cell's unique expression program.

**`{{SECTION_F_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > Address three questions explicitly:
  > 1. **What programs does this cell share with other {{CLADE_FAMILY}} cells?** (Reflected in `vs_all`-only markers and their associated TFs.)
  > 2. **What makes this cell distinctive within the {{CLADE_FAMILY}} clade?** (Reflected in `within_clade` and `both` markers and their associated TFs.)
  > 3. **How do shared and unique programs interact?** The interplay between clade-level and subtype-specific programs often reveals how a cell type diversified from its relatives.

**`{{SECTION_H_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > 6. When presenting candidate cell type matches, note whether the shared genes are `both`, `vs_all`, or `within_clade` markers. A match based primarily on `vs_all` genes suggests homology at the clade/family level. A match based on `within_clade` genes suggests convergent subtype specialization or a more specific homology. Matches based on `both` genes provide the strongest evidence because they define this cell type at both the global and local level.

**`{{SECTION_I_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > The `vs_all` markers may point to the conserved or clade-level identity (the family this cell belongs to), while `within_clade` markers may reveal the lineage-specific diversification within that family. Discuss how the comparison_type patterns inform which level of conservation this cell type represents.

**`{{SECTION_J_COMPARISON_TYPE}}`:**
- Single mode: *(empty)*
- Merged mode:
  > 4. **Comparison type patterns:** Note any genes that are strong `within_clade` markers but absent from the `vs_all` list. These may represent genes that are broadly expressed across the dataset but specifically enriched in this subtype relative to its clade — potentially the most interesting candidates for understanding subtype identity and diversification.

**`{{SECTION_K}}`:**
- Single mode:
  > Provide a concise summary of the key findings:
  > 1. **Proposed cell type identity** and confidence level
  > 2. **Top 5 most diagnostic genes** and their functions
  > 3. **Key TF regulators** and any known regulatory circuits
  > 4. **Best cross-species match(es)** with shared evidence
  > 5. **Most notable unknowns** — uncharacterized genes or surprising absences worth investigating
- Merged mode:
  > Provide a concise summary organized by comparison_type:
  >
  > 1. **Shared clade program** (`vs_all` genes): What functional modules, TFs, and effectors define the broader {{CLADE_FAMILY}} identity? What does this cell share with its relatives? List the top 3-5 genes and the key functional theme.
  > 2. **Subtype specialization** (`within_clade` genes): What modules, TFs, and effectors distinguish this specific cluster from other {{CLADE_FAMILY}} cells? What is unique about this cell? List the top 3-5 genes and the key functional theme.
  > 3. **Core identity** (`both` genes): What defines this cell at all levels? These are the strongest diagnostic markers. List the top 3-5 genes and the key functional theme.
  >
  > For each category, provide 1-2 sentences summarizing the functional theme and the most important genes.

**Family-aware mode additional placeholders (cluster template only):**

These resolve to empty for single and merged modes. In family_aware mode, they add family cross-reference context to cluster reports.

**`{{FAMILY_CROSS_REFERENCE}}`:**
- Single/merged mode: *(empty)*
- Family_aware mode:
  > **Family context:** This cluster belongs to the **{{CLADE_FAMILY}}** cell type family
  > ({{N_FAMILY_MEMBERS}} clusters: {{FAMILY_MEMBER_LIST}}). A separate family-level report
  > characterizes the shared {{CLADE_FAMILY}} program.
  >
  > **Important:** The gene list below has had broadly expressed family markers removed —
  > genes that define the shared {{CLADE_FAMILY}} identity are analyzed in the family report,
  > not here. The top family markers include: {{TOP_FAMILY_MARKERS}}.
  >
  > Your analysis should focus on what makes this specific cluster **unique within** the
  > {{CLADE_FAMILY}} family, not on features shared across all {{CLADE_FAMILY}} cells.

**`{{FAMILY_AWARE_SYNTHESIS_NOTE}}`:**
- Single/merged mode: *(empty)*
- Family_aware mode (added to Section F):
  > **Family context:** Since family-level markers have been removed from this gene list,
  > the genes here represent this cluster's **specialization within** the {{CLADE_FAMILY}}
  > family. Focus your synthesis on what distinguishes this cluster from other
  > {{CLADE_FAMILY}} cells. Refer to the separate {{CLADE_FAMILY}} family report for the
  > shared program.

**`{{SECTION_K_FAMILY_AWARE}}`:**
- Single/merged mode: *(empty)*
- Family_aware mode (appended to Section K):
  > 6. **Relationship to family program:** Briefly note how this cluster's unique features
  >    relate to the shared {{CLADE_FAMILY}} program (described in the family report).
  >    Is this a specialized subtype, a developmental stage, or a functionally distinct
  >    member of the family?

**`{{ORGANISM_SPECIFIC_CONTEXT}}`:**
- If provided, insert as a paragraph at the end of Section G:
  > *Additional context:* [user-provided text]
- If not provided, insert:
  > Consider the known biology of {{COMMON_NAME}} cell types and how the inferred functions relate to the organism's life history and ecology.

### Step 4b: Fill Family Template (family_aware mode only)

For family reports, use the family template at `~/.claude/skills/deep-research-genelist/templates/family-report-template.md`.

1. Read the family template.
2. Replace all `{{PLACEHOLDER}}` tokens. The family template uses the same organism/dataset placeholders as the cluster template, plus family-specific ones:
   - `{{FAMILY_NAME}}` — the coarse family name (e.g., "neurons", "epithelial")
   - `{{MEMBER_CLUSTERS}}` — comma-separated list of fine cluster names in this family
   - `{{N_MEMBER_CLUSTERS}}` — count of member clusters
   - `{{FAMILY_MARKERS_DESCRIPTION}}` — how family markers were computed (broadly expressed across ≥80% of member clusters)
3. The gene list for family reports is the filtered family markers from `family_markers_filtered/{family}_markers.tsv`.

### Step 5: Build Slim Gene List and Embed

Build the gene list for Section 6 of the prompt.

**Columns to include:**
- `display_name` — always
- `comparison_type` — only if merged mode
- `pct.1` — only if available (marker table input)

**Format as a simple text table** (tab-separated or pipe-separated).

**Embed as Section 6** at the end of the prompt:

```markdown
## 6. Gene List

The following gene list contains N genes for {{MODULE_TYPE_DESCRIPTION}}.
[If merged mode:] The `comparison_type` column indicates how each gene was
identified (both / vs_all / within_clade).

```
[gene list here]
```
```

### Step 6: Save Prompt

1. Create the output directory if needed (e.g., `outs/deep_research/{MODULE_ID}/`).
2. Write the completed prompt to the output path.
3. Report the file path to the user.

### Step 7: Instruct User

Tell the user:

> **Prompt saved to `{output_path}`.**
>
> To use it:
> 1. Open your deep research tool (e.g., Claude deep research, ChatGPT deep research).
> 2. Paste the contents of the prompt file. The gene list is already embedded in Section 6 — no attachment needed.
> 3. Run the query.
>
> The report will include a YAML header block at the top that can be parsed
> programmatically for compilation across clusters.

---

## Batch Mode

When generating prompts for multiple clusters from the same dataset, most inputs
are shared. The skill should:

1. Gather shared inputs once (organism, clade, dataset description, etc.)
2. Build or load the annotation profile once for the whole batch.
3. Determine mode (single vs merged vs family_aware) once for the whole batch.
4. Apply marker filtering once (p_val_adj < 0.05, pct.1 > 0.10) if input is a marker table.
5. For each cluster:
   - Set `MODULE_ID`, `MODULE_TYPE_DESCRIPTION`, `BIOLOGICAL_CONTEXT`, and `CLADE_FAMILY`
   - Extract the cluster's genes from the marker table(s)
   - Build the slim gene list (display_name, comparison_type, pct.1)
   - Fill template and save
6. Report all saved file paths at the end.

For batch mode, the `BIOLOGICAL_CONTEXT` can use a default based on the cluster
name (e.g., "Markers of cluster 'shell_14_1' in the shell cell type clade")
unless the user provides specific context for individual clusters.

The `CLADE_FAMILY` is set per-cluster from the clade lookup table.

The annotation profile (`annotation_profile.yaml`) is read once and applied to
all clusters — no need to re-ask annotation source questions per cluster.

### Family-aware batch mode

In `family_aware` mode, batch generation produces **two passes**:

**Pass 1 — Family reports** (one per family):
- Use the family report template (`templates/family-report-template.md`)
- Gene list: filtered family markers from `family_markers_filtered/{family}_markers.tsv`
- `MODULE_ID`: `family_{family_name}` (e.g., `family_neurons`, `family_epithelial`)
- `MODULE_TYPE`: `"family markers"`
- `MODULE_TYPE_DESCRIPTION`: `"broadly expressed markers defining the {family} cell type family"`
- `BIOLOGICAL_CONTEXT`: `"Markers shared across {N} clusters in the {family} family: {member_list}"`
- Apply same marker filtering (p_val_adj < 0.05, pct > 0.10) to family marker files

**Pass 2 — Cluster reports** (one per cluster):
- Use the cluster template with family cross-reference placeholders filled
- Gene list: per-cluster merged markers from `per_cluster_merged/{cluster}.tsv` (family markers already removed)
- Fill `{{FAMILY_CROSS_REFERENCE}}`, `{{FAMILY_AWARE_SYNTHESIS_NOTE}}`, `{{SECTION_K_FAMILY_AWARE}}` with family context
- `{{TOP_FAMILY_MARKERS}}`: top 10 family markers by score from the family filtered file

**Single-member families** (e.g., glia with 1 cluster): Skip the family report. Generate the cluster report in merged mode (not family_aware mode) since there's no meaningful family vs. cluster distinction.

Report all saved file paths at the end, grouped by family reports and cluster reports.

---

## Annotation Method Library

The file `~/.claude/skills/deep-research-genelist/references/annotation_methods.md`
contains descriptions of known gene annotation methods organized by confidence tier.
Each entry includes:

- Tier assignment (orthology / homology / sequence_similarity / manual)
- How to recognize the method in data (column names, patterns)
- Interpretation guidance for the deep research prompt
- Caveats

**The library is extensible.** When a new annotation method is encountered, add
it to the reference file after confirming the details with the user.

**Format varies by project.** Even for the same method (e.g., eggNOG), the actual
column layout and name formatting may differ between projects. The library provides
recognition hints and default descriptions, but the skill must always ask the user
to confirm the specific format in their data.

---

## Annotation Profile

The annotation profile (`annotation_profile.yaml`) stores the confirmed annotation
sources and their formatting for a specific dataset. This avoids re-asking the user
for every prompt in a batch.

- **Location:** Saved alongside the prompts, typically `outs/deep_research/annotation_profile.yaml`
- **Created:** Interactively during Step 3b on first use
- **Reused:** Automatically loaded in batch mode and subsequent single prompts
- **Schema:** See Step 3d in the workflow above

---

## Notes

- The template is organism-agnostic. All organism-specific content comes from the user inputs.
- Gene list format is flexible — the annotation profile describes how to interpret names for each dataset.
- The prompt asks the deep research tool to produce the YAML header as part of its output. The header schema is defined in the template.
- Reports prioritize accuracy: references must be verifiable, DOI links only when certain, hallucinated citations explicitly flagged.
- **Marker table filtering:** When the input has statistical columns, genes are filtered to p_val_adj < 0.05 and pct.1 > 0.10 before inclusion. Plain gene lists (no statistics) are included as-is.
