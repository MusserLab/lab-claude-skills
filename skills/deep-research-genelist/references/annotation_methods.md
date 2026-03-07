# Annotation Method Library

Reference descriptions for gene annotation methods used in scRNAseq gene lists.
The deep-research-genelist skill consults this file when generating the Annotation
Source Guide for deep research prompts.

**Usage:** The skill detects which methods are present in the data (from column
names, data patterns, suffixes, or the annotation profile), then ALWAYS asks the
user to confirm before using any of these descriptions. Never silently assume.

---

## Confidence Tiers

Methods are grouped into tiers that determine how the deep research tool should
interpret gene names. All methods within the same tier get equivalent treatment.

### Tier 1: Orthology (high confidence for gene identity)

These methods infer true orthologous relationships. When the relationship is 1:1,
the gene name represents a specific ortholog — treat with high confidence. When
the relationship is 1:many (e.g., `Nab1/2` or `1-to-4 Ralgds,Rgl1,Rgl2,Rgl3`),
the gene belongs to this family but the specific member is unresolved — consider
all listed orthologs as potential functional matches.

**Methods in this tier:**

#### eggnog

**Full name:** eggNOG-mapper orthology
**Projects using it:** Most projects (sponges, Platynereis, Acropora, chitons, etc.)
**How to recognize:** Column names containing `eggnog`, `emapper`, `OG`, or
`orthology_group`; n-to-n notation; human gene symbols listed as comma-separated
groups. In display_name, may appear as single gene symbols (indistinguishable
from other orthology methods) or as multi-word functional descriptions when no
gene symbol was available.

**How it works:** Finds the closest orthology group (OG) shared between the
species and human (often at the metazoan level), then summarizes the relationship
by counting genes from each species in the same OG. The OG levels are predefined
(not computed per species pair), so for deeply divergent taxa (e.g., cnidarians)
the appropriate ancestral level may not be exact — but in practice, the orthology
calls are reliable and comparable to phylogenetic methods.

**IMPORTANT:** The actual column format varies substantially between projects.
Always ask the user to describe their specific eggNOG-derived columns.

**Common display_name formats:**

1. **Single gene symbol** — when the OG has a representative gene symbol.
   Examples: `Cebpb`, `Gbp1`, `Spdef`. Note: in older conventions, eggNOG
   may assign a single representative name rather than listing all co-orthologs.
   This is still a true ortholog but represents only one member of the OG, not
   the full orthology relationship.

2. **Functional description only** — when the OG lacks a gene symbol.
   Examples: `GTPase activity`, `neurotransmitter:sodium symporter activity`,
   `AAC-rich mRNA clone AAC4 protein-like`. These are multi-word descriptions
   that indicate the protein family but not a specific gene. Treat as Tier 1
   for family membership but lower confidence for specific gene identity.

**Interpretation guidance for deep research:**
> Gene names assigned via eggNOG-mapper represent true orthologs based on
> orthology group membership. When a single gene symbol is shown, it is the
> representative ortholog from that OG — treat with the same confidence as
> other orthology methods. When a functional description appears instead of
> a gene symbol (e.g., "GTPase activity"), this indicates the protein belongs
> to a known family but no specific gene symbol was assigned — interpret at the
> family level. When multiple human genes are listed, it indicates n-to-n
> orthology — the gene is orthologous to all listed human genes, but the
> specific closest functional match is unresolved. Consider all listed orthologs
> when discussing potential function.

---

#### orthofinder

**Full name:** OrthoFinder orthology inference
**Projects using it:** Various (format not yet standardized across projects)
**How to recognize:** TBD — format varies by project. Ask the user.

**How it works:** Infers phylogenetic gene trees and reconciles them against a
species tree to identify orthologs and paralogs. Distinguishes orthologs from
paralogs more rigorously than sequence similarity methods alone.

**Interpretation guidance for deep research:**
> Gene names derived from OrthoFinder are based on phylogenetic gene tree
> inference and species tree reconciliation. These are true orthologs with
> well-resolved orthology/paralogy relationships. Treat with high confidence
> for functional inference.

---

#### custom_phylome

**Full name:** Custom phylogenomic pipeline
**Projects using it:** chitons (Acanthochitona), Spongilla
**How to recognize:** Column names containing `phylome`; gene names with
`1-to-N` orthology count notation; Pfam family references in source columns.

**How it works:** A custom phylogenomic pipeline that reconstructs gene family
trees across a curated set of species. Similar to OrthoFinder but built with
curated species sampling specific to the project. Not the same as the public
PhylomeDB database.

**Interpretation guidance for deep research:**
> Gene names derived from a custom phylogenomic pipeline are based on
> phylogenetic tree reconstruction across curated species sets. These are
> sequence-based orthologs. When a 1:1 ortholog is identified, the gene name
> represents a likely functional equivalent. When 1:many orthologs are listed
> (e.g., "1-to-7 Ca1, Ca13, Ca2..."), all listed genes are co-orthologs and
> should be considered as potential functional matches. The notation "1-to-N"
> indicates N co-orthologs in the target species.

---

### Tier 2: Homology (moderate confidence — gene family, not specific gene)

These methods identify membership in a gene family or protein superfamily
without resolving specific orthology. The gene likely belongs to the named
family but may not be the specific functional equivalent of any one listed gene.

#### prost

**Full name:** PROST structural homology (protein language model)
**Projects using it:** chitons, Platynereis, potentially others
**How to recognize:** `*` suffix on gene names (display_name); columns like
`prost_top1`, `prost_human`, `prost_fly`; `name_type` column.

**How it works:** Uses protein language model embeddings (ESM-2) to find
proteins with similar predicted 3D structure across species. All reported hits
are within the threshold of structural homology. Hits are ordered from best
(most similar) to worst, typically cut after 4-5 genes for display purposes.

**Interpretation guidance for deep research:**
> Names marked with `*` (asterisk suffix) are derived from PROST structural
> homology. PROST identifies proteins with similar predicted 3D structure,
> indicating membership in the same protein superfamily. This is NOT sequence
> orthology — a PROST hit means the protein belongs to the same gene family,
> but may not be the specific functional equivalent of any one listed gene.
> When multiple hits are listed (e.g., `Ngf/Ntf3/Bdnf*`), they are ordered
> from most to least structurally similar. **Weight earlier names more heavily
> than later ones** — the first hit is the closest structural match.

---

### Tier 3: Sequence similarity (lower confidence — gap-filler)

Simple sequence similarity searches without phylogenetic context. Confidence
varies with alignment quality and evolutionary distance between species.

#### blastp

**Full name:** BLASTp sequence similarity search (typically against human)
**Projects using it:** Spongilla (gap-filler for genes without phylome/eggNOG hits)
**How to recognize:** Column names containing `blast`, `evalue`, `identity`,
`bitscore`; typically applied to a subset of genes.

**How it works:** Standard protein BLAST against a reference proteome (usually
human). Best hit by e-value is reported. For divergent organisms, BLAST may
miss distant homologs or return misleading best hits.

**Interpretation guidance for deep research:**
> Gene names assigned by BLASTp represent the best sequence similarity match in
> the reference proteome (typically human). Interpret cautiously — for divergent
> organisms, the best BLAST hit may not be the true ortholog. These names are
> used as gap-fillers for genes that were not annotated by orthology-based
> methods. Consider the gene family rather than the specific gene name.

---

### Tier 4: Manual curation (highest confidence)

Expert-reviewed annotations that override all automated methods.

#### manual

**Full name:** Manual expert curation
**Projects using it:** All projects (selective, for well-known or important genes)
**How to recognize:** No systematic marker — may be indicated by `name_type`
column value like `manual` or `existing`, or by absence of method-specific
markers on well-known gene symbols.

**Interpretation guidance for deep research:**
> Manually curated gene names assigned by domain experts based on published
> literature, experimental evidence, or phylogenetic analysis. These are the
> most reliable annotations. Treat with full confidence for functional inference.

---

### Other / User-defined

For annotation methods not in this library. When the skill encounters unrecognized
annotation patterns, it asks the user to describe:
1. What the method is and how it works
2. What confidence level to assign (which tier it belongs to)
3. How names from this method are formatted (how to distinguish them)

The user's description is incorporated into the Annotation Source Guide verbatim.

---

## How the Skill Should Use This File

### With an annotation profile (batch mode / repeat use)

If a `annotation_profile.yaml` exists for this dataset, read the confirmed
methods and formatting from there. Skip detection — go directly to assembling
the Annotation Source Guide from the profile.

### Without a profile (first use / interactive)

1. **Detect:** Read the gene list header and sample rows. Look for column names
   and data patterns matching each method's "How to recognize" field.

2. **Present to user:** Show detected annotation tiers with examples:
   > "I detect the following annotation sources in this gene list:
   > - **Orthology** (Tier 1): clean gene symbols like `Msx2`, `Rnf5` — 156 genes
   > - **Homology** (Tier 2): names with `*` suffix like `Hes1*`, `Ngf/Ntf3*` — 87 genes
   > - **Unannotated**: bare IDs like `comp101768_c0` — 42 genes
   >
   > Which methods were used? [multi-select from known methods + Other]"

3. **For each confirmed method**, ask how names are formatted in this dataset
   (the formatting varies between projects even for the same method).

4. **Save profile** as `annotation_profile.yaml` in the dataset's output directory
   for batch reuse.

5. **Assemble the Annotation Source Guide** — combine the tier-appropriate
   interpretation guidance for each confirmed method into a concise section
   that goes into the deep research prompt (Section 2).
