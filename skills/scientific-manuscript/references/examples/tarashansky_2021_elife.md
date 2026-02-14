# Tarashansky et al., 2021, eLife — Annotated Examples

**Paper**: Mapping single-cell atlases throughout Metazoa unravels cell type evolution
**DOI**: 10.7554/eLife.66747
**Key topic**: SAMap algorithm for cross-species single-cell comparison; ancient cell type families

---

## Abstract: Problem-Solution Structure

**Excerpt**:
> Comparing single-cell transcriptomic atlases from diverse organisms can elucidate the origins of cellular diversity and assist the annotation of new cell atlases. Yet, comparison between distant relatives is hindered by complex gene histories and diversifications in expression programs.

**Why this works**:
- Opens with the promise/opportunity
- Immediately states the obstacle ("Yet...")
- Specific about the challenges (gene histories, expression divergence)
- Sets up the need for a solution

**Principle**: When presenting a method, first establish why existing approaches are insufficient.

---

## Abstract: Method + Validation

**Excerpt**:
> Here, we build on SAM to map cell atlas manifolds across species. This new method, SAMap, identifies homologous cell types with shared expression programs across distant species within phyla, even in complex examples where homologous tissues emerge from distinct germ layers.

**Why this works**:
- Names the method clearly (SAMap)
- States what it does concisely
- Includes a concrete validation ("even in complex examples")
- Shows the scope (across phyla)

**Principle**: When introducing a method, immediately demonstrate that it works on hard cases.

---

## Introduction: Building the Problem

**Excerpt**:
> However, recent comparative single-cell analyses are mostly limited to species within the same phylum. Comparisons across longer evolutionary distances and across phyla are challenging for two major reasons. First, gene regulatory programs diversify during evolution, diminishing the similarities in cell-type-specific gene expression patterns. Second, complex gene evolutionary history causes distantly related organisms to share few one-to-one gene orthologs, which are often relied upon for comparative studies.

**Why this works**:
- States the limitation of prior work clearly
- Numbers the challenges (First... Second...)
- Explains WHY each challenge matters
- Specific technical detail (one-to-one orthologs)

**Rhetorical moves**:
1. Acknowledge what exists
2. State its limitations
3. Enumerate specific challenges
4. Explain why each is problematic

**Principle**: When building a case for your approach, be specific about what existing methods cannot do and why.

---

## Results: Method Description as Narrative

**Excerpt**:
> SAMap iterates between two modules. The first module constructs a gene-gene bipartite graph with cross-species edges connecting homologous gene pairs, initially weighted by protein sequence similarity. In the second module, SAMap uses the gene-gene graph to project the two single-cell transcriptomic datasets into a joint, lower-dimensional manifold representation, from which each cell's mutual cross-species neighbors are linked to stitch the cell atlases together.

**Why this works**:
- Clear structure (two modules)
- Explains each step functionally
- Uses accessible language alongside technical terms
- Flow matches the algorithm's logic

**Principle**: When describing a method, organize by functional steps, not implementation details.

---

## Results: Validation Through Expected Results

**Excerpt**:
> SAMap revealed broad agreement between transcriptomic similarity and developmental ontogeny, linking 26 out of 27 expected pairs based on previous annotations. The only exception is the embryonic kidney (pronephric duct/mesenchyme), potentially indicating that their gene expression programs have significantly diverged.

**Why this works**:
- Quantifies agreement (26/27)
- References external validation (previous annotations)
- Addresses the exception honestly
- Provides biological interpretation of the exception

**Principle**: Validate methods by showing they recover known biology, and explain exceptions.

---

## Results: Surprising Findings

**Excerpt**:
> SAMap also linked a group of secretory cell types that differ in their developmental origin, some even arising from different germ layers. Within ectoderm, frog cement gland cells map to zebrafish muc5ac+ secretory epidermal cells, and frog small secretory cells (SSCs) map to zebrafish pvalb8+ mucous cells. Across germ layers, SSCs also map weakly to zebrafish endodermal cells, and frog ectodermal hatching gland maps to zebrafish mesodermal hatching gland.

**Why this works**:
- Flags the surprising result ("differ in developmental origin")
- Provides specific examples
- Quantifies relationship strength ("map weakly")
- Organizes by biological category (within ectoderm, across germ layers)

**Principle**: When reporting surprising findings, be specific and organize them clearly for the reader.

---

## Results: Section Heading (Question-Driven)

**Excerpt**:
> "Homologous cell types emerging from distinct germ layers in frog and zebrafish"

**Why this works**:
- States the finding, not the method
- Captures the biological surprise
- Makes reader want to understand how this is possible
- Specific to the species compared

**Principle**: Section headings should intrigue the reader and state the biological finding.

---

## Discussion: Conceptual Framework

**Excerpt**:
> Together, the conserved cell type specification programs between developmentally distinct secretory cells support the notion that they may be transcriptionally and evolutionarily related despite having different developmental origins.

**Why this works**:
- Synthesizes findings into a concept
- Addresses a major evolutionary question (cell type homology)
- Appropriately hedged ("support the notion")
- Clear take-home message

**Principle**: Discussion should synthesize findings into conceptual frameworks, not just summarize results.

---

## Algorithm Description: Addressing Challenges Systematically

**Excerpt**:
> This algorithm overcomes several challenges inherent to mapping single-cell transcriptomes between distantly related species. First, complex gene evolutionary history often results in many-to-many homologies with convoluted functional relationships. SAMap accounts for this by using the full homology graph... Second, frequent gene losses and the acquisitions of new genes result in many cell type gene expression signatures being species-specific... SAMap solves this problem by constructing the joint space through the concatenation of within- and cross-species projections...

**Why this works**:
- Numbers the challenges (First... Second...)
- States each challenge clearly
- Immediately follows with the solution
- Specific about how the solution works

**Principle**: When presenting a method, explicitly link each design choice to the problem it solves.

---

## Benchmarking: Fair Comparison

**Excerpt**:
> To benchmark the performance of SAMap, we used eggNOG to define one-to-one vertebrate orthologs between zebrafish and frog and fed these gene pairs as input to several broadly used single-cell data integration methods, Seurat, LIGER, Harmony, Scanorama, and BBKNN. We found that they failed to map the two atlases, yielding minimal alignment between them.

**Why this works**:
- Names the benchmark (eggNOG orthologs)
- Lists comparison methods explicitly
- States result clearly ("failed to map")
- Fair comparison (same input data)

**Principle**: Benchmark against established methods using the same inputs, and report results honestly.

---

## Evolutionary Implications

**Excerpt**:
> Comparing all seven species from sponge to mouse, we identified densely interconnected cell type families broadly shared across animals, including contractile and stem cells, along with their respective gene expression programs.

**Why this works**:
- States the scope (sponge to mouse = all animals)
- Names the findings (cell type families)
- Includes both cell types AND their programs
- Broad evolutionary implication

**Principle**: End papers with the broadest supportable evolutionary or mechanistic implication.
