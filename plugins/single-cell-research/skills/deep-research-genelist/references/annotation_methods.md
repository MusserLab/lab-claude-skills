# Annotation Method Library

Reference descriptions for gene annotation methods used in scRNAseq gene lists.
The deep-research-genelist skill consults this file when generating the Annotation
Source Guide for deep research prompts.

**Usage:** The skill detects which methods are present in the data (from column
names, data patterns, suffixes, or the annotation profile), then ALWAYS asks the
user to confirm before using any of these descriptions. Never silently assume.

---

## Confidence Tiers

Legacy tier labels organize method descriptions; they are not interchangeable confidence scores.
Use the actual relationship evidence, tool/database version, output fields and project curation.
Separate confidence in a broad gene family, a particular ortholog and a conserved function.
Name syntax and the fact that a tool was used do not establish those claims.

### Tier 1: Orthology (high confidence for gene identity)

Use this category when the retained source supports an inferred orthologous relationship.
Preserve one-to-one, one-to-many or many-to-many scope from that source, including unresolved
cases. A representative symbol or shared group alone does not supply this evidence. The
relationship can guide functional interpretation but does not prove identical function.

**Methods in this tier:**

#### eggnog

**Full name:** eggNOG-mapper annotation and orthology inference
**How to recognize:** Source columns may mention eggnog, emapper or an OG; display names may
be symbols or functional descriptions. These are discovery hints. Read the generating code,
output fields and dataset annotation profile to determine what was actually retained.

**How it works:** eggNOG-mapper uses precomputed orthologous-group phylogenies to refine
assignments and transfer annotations. It can also produce pairwise orthology reports. An OG
identifier, a transferred preferred name and a pairwise relationship are different evidence.
Counting query/reference genes in a shared OG or choosing one representative symbol does not,
by itself, establish a one-to-one ortholog or orthology to every named member.

**Interpretation guidance for deep research:**
> If the dataset retains inferred pairwise relationships, describe their actual one-to-one,
> one-to-many or many-to-many scope and uncertainty. If it retains only group-derived names or
> annotations, use them as evidence for the reported family/function and leave specific ortholog
> identity unresolved. A single symbol can be a representative label; a comma-separated list can
> summarize group members. Do not infer relationship type from either display format. A functional
> description supplies that annotation, not proof of a uniquely identified gene. Functional
> conservation remains an inference even when orthology is supported.

Preserve the tool/database version and source output in the dataset profile. Do not reinterpret
older exports using a newer release's fields. The version-2 method distinguishes annotation and
pairwise reports: [Cantalapiedra et al. 2021](https://doi.org/10.1093/molbev/msab293).
Consult the version-matched [official usage](https://github.com/eggnogdb/eggnog-mapper/blob/main/USAGE.md)
when resolving a particular export.

---

#### orthofinder

**Full name:** OrthoFinder orthology inference
**How to recognize:** TBD — format varies by project. Ask the user.

**How it works:** Infers phylogenetic gene trees and reconciles them against a
species tree to identify orthologs and paralogs. Distinguishes orthologs from
paralogs more rigorously than sequence similarity methods alone.

**Interpretation guidance for deep research:**
> Gene names derived from OrthoFinder are based on phylogenetic gene tree
> inference and species tree reconciliation when the actual orthology outputs are used.
> Report those inferred relationships and their resolution. An orthogroup-membership table alone
> is not a pairwise orthology table; preserve unresolved paralogy and distinguish inferred function
> from experimentally established function.

---

#### custom_phylome

**Full name:** Custom phylogenomic pipeline
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

### Tier 4: Manual curation

Expert-reviewed annotations with their recorded supporting evidence and scope.

#### manual

**Full name:** Manual expert curation
**How to recognize:** No systematic marker — may be indicated by `name_type`
column value like `manual` or `existing`, or by absence of method-specific
markers on well-known gene symbols.

**Interpretation guidance for deep research:**
> Manually curated gene names assigned by domain experts based on published
> literature, experimental evidence, or phylogenetic analysis. Describe which evidence supports
> the assignment; “manual” alone does not establish certainty or demonstrated functional identity.

---

### Other / User-defined

For annotation methods not in this library. When the skill encounters unrecognized
annotation patterns, it asks the user to describe:
1. What the method is and how it works
2. What evidence supports gene identity/family/function and what remains unresolved
3. How names from this method are formatted (how to distinguish them)

Record the user's description with its evidence and unresolved limits in the Annotation Source Guide.

---

## How the Skill Should Use This File

### With an annotation profile (batch mode / repeat use)

If a `annotation_profile.yaml` exists for this dataset, read the confirmed
methods and formatting from there. Skip detection — go directly to assembling
the Annotation Source Guide from the profile.

### Without a profile (first use / interactive)

1. **Detect:** Read the gene list header and sample rows. Look for column names
   and data patterns matching each method's "How to recognize" field.

2. **Present to user:** Show unverified name-pattern categories as discovery hints:
   > "I detect the following annotation sources in this gene list:
   > - Clean gene symbols like `Msx2`, `Rnf5` — 156 genes; source/evidence not yet established
   > - Names with `*` suffix like `Hes1*`, `Ngf/Ntf3*` — 87 genes; confirm the project convention
   > - **Unannotated**: bare IDs like `comp101768_c0` — 42 genes
   >
   > Which methods and actual outputs generated these categories? Include group-derived or unresolved assignments."

3. **For each confirmed method**, ask how names are formatted in this dataset
   (the formatting varies between projects even for the same method).

4. **Save profile** as `annotation_profile.yaml` in the dataset's output directory
   for batch reuse.

5. **Assemble the Annotation Source Guide** — combine the tier-appropriate
   interpretation guidance for each confirmed method into a concise section
   that goes into the deep research prompt (Section 2).
