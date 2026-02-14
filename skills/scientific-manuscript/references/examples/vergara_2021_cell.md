# Vergara et al., 2021, Cell — Annotated Examples

**Paper**: Whole-body integration of gene expression and single-cell morphology
**DOI**: 10.1016/j.cell.2021.07.017
**Key topic**: Integrated atlas of gene expression and ultrastructure for Platynereis; multimodal cell type analysis

---

## Abstract: Framing the Challenge

**Excerpt**:
> Animal bodies are composed of cell types with unique expression programs that implement their distinct locations, shapes, structures, and functions. Based on these properties, cell types assemble into specific tissues and organs. To systematically explore the link between cell-type-specific gene expression and morphology, we registered an expression atlas to a whole-body electron microscopy volume of the nereid Platynereis dumerilii.

**Why this works**:
- Opens with universal principle (expression → phenotype)
- Builds logically (cell types → tissues → organs)
- States the goal clearly ("systematically explore the link")
- Introduces the approach concisely

**Principle**: Open abstracts with the biological question, then introduce your approach.

---

## Abstract: Technical Innovation + Biological Discovery

**Excerpt**:
> Automated segmentation of cells and nuclei identifies major cell classes and establishes a link between gene activation, chromatin topography, and nuclear size. Clustering of segmented cells according to gene expression reveals spatially coherent tissues.

**Why this works**:
- States what was achieved technically (segmentation)
- Immediately provides biological insight (chromatin-gene-size link)
- Shows application (tissue clustering)
- Each sentence delivers a finding

**Principle**: For Resource papers, balance technical achievements with biological insights.

---

## Abstract: Specific Discovery

**Excerpt**:
> Besides interneurons, we uncover sensory-neurosecretory cells in the nereid mushroom bodies, which thus qualify as sensory organs. They furthermore resemble the vertebrate telencephalon by molecular anatomy.

**Why this works**:
- States a specific discovery (sensory-neurosecretory cells)
- Draws a clear conclusion (mushroom bodies = sensory organs)
- Makes a comparative claim (resembles telencephalon)
- Punchy, confident language

**Principle**: Abstracts should include at least one specific, memorable discovery.

---

## Introduction: The Vision

**Excerpt**:
> Cells are the basic units of life. In multicellular organisms, distinct genes are expressed in different cells, producing individual traits that define cell types. Deciphering how genotype is decoded into cellular phenotype is thus critical to understand the structure and function of an entire body. To this end, we need to establish the link between expression profiles and cellular morphologies.

**Why this works**:
- Opens with fundamental principle
- Builds the logic step by step
- States the goal clearly ("establish the link")
- Frames the entire paper's purpose

**Rhetorical moves**:
1. Universal truth (cells = basic units)
2. Core mechanism (genes → traits)
3. Central question (genotype → phenotype)
4. What's needed (link expression to morphology)

**Principle**: Introduction should build from first principles to your specific contribution.

---

## Introduction: Justifying the System

**Excerpt**:
> At this stage, Platynereis already exhibits a rich and differentiated set of cell types, which is comparable to that of many bilaterians, including vertebrates. However, because each cell type comprises a few cells only, the overall number of cells remains small. This goes in concert with a considerable stereotypy of Platynereis development and differentiation: the developmental lineage is invariant, and differentiated larvae and young worms resemble each other down to the cellular detail.

**Why this works**:
- Justifies the system choice with specific reasons
- Addresses potential skepticism (small animal = limited?)
- Turns limitation into advantage (few cells = tractable)
- Mentions stereotypy (enables atlas approach)

**Principle**: Explicitly justify your system choice by explaining what makes it uniquely suited to address the question.

---

## Results: Resource Description

**Excerpt**:
> An EM image stack of a complete 6-dpf young Platynereis worm was collected by SBEM at a pixel size (x/y) of 10 nm and 25 nm section thickness (z), resulting in 11,416 planar images made of >200,000 tiles for a total size of 2.5 TB. This dataset enabled detailed analyses of overall anatomy and ultrastructural detail throughout the body.

**Why this works**:
- Specific technical parameters (10 nm, 25 nm, 2.5 TB)
- Quantifies the achievement (11,416 images, 200,000+ tiles)
- States what it enables (detailed analyses)
- Impressive but not boastful

**Principle**: For Resource papers, quantify the resource's scope and resolution precisely.

---

## Results: Validation

**Excerpt**:
> Segmentations were validated against 8 manually annotated slices (4 transversal and 4 horizontal) distributed throughout the dataset. Here, we found a 99.0% agreement with the automatic nuclear segmentation and a 90.3% agreement with the cellular segmentation.

**Why this works**:
- States validation approach clearly
- Quantifies agreement precisely (99.0%, 90.3%)
- Includes both metrics (nuclear and cellular)
- Sampling strategy explained (distributed slices)

**Principle**: Validate computational methods with ground truth and report agreement quantitatively.

---

## Results: Biological Insight from Technical Data

**Excerpt**:
> These relationships also apply to all nuclei. The larger heterochromatin surface should reflect an increased exposure (i.e., unpacking) of the DNA, which we speculated might be indicative of a higher number of activated genes. Supporting this, active gene bodies are found on the heterochromatin surface in Platynereis nuclei. This indicates that, in the 6-dpf young worm, nucleus size is a proxy for the extent of gene activation in a cell type.

**Why this works**:
- Moves from observation to interpretation
- Provides mechanistic explanation (unpacking = more active genes)
- Cites supporting evidence
- States a useful principle (nucleus size = gene activation proxy)

**Principle**: Extract generalizable biological principles from your specific observations.

---

## Results: Integration as Validation

**Excerpt**:
> The mapping of tissue markers confirmed the registration accuracy. For example, muscle markers label myocytes, with myosin heavy chain (mhc) in longitudinal and other muscles and the paraxis and twist transcription factors in oblique muscles and stomodaeal muscles, respectively.

**Why this works**:
- Uses biology to validate technical achievement
- Specific examples (mhc, paraxis, twist)
- Shows expected patterns are recovered
- Multiple examples strengthen the validation

**Principle**: Validate technical achievements by showing they recover known biology.

---

## Resource Paper: Browser as Deliverable

**Excerpt**:
> We provide an integrated browser as a Fiji plugin for remote exploration of all available multimodal datasets.

**Why this works**:
- States the resource clearly
- Specifies the platform (Fiji)
- Emphasizes accessibility ("remote exploration")
- Highlights scope ("all available multimodal datasets")

**Principle**: For Resource papers, clearly state what you're providing and how others can access it.

---

## Figure Legend: Complete Technical Detail

**Excerpt (reconstructed from text)**:
> (A) Horizontal and transverse sections with 3D renderings of cells (left) and nuclei (right). (B) Intertwined epithelial cells shown as EM-overlaid colored segments and 3D renderings. Scale bar: 50 μm (A), 2 μm (B-D).

**Why this works**:
- States what each panel shows
- Includes rendering details
- Scale bars specified per panel
- Complete but concise

**Principle**: Figure legends should enable interpretation without reading the main text.

---

## Structural Pattern: Resource Paper Architecture

This Cell paper follows a clear Resource structure:
1. **Technical achievement** (EM volume, segmentation)
2. **Validation** (ground truth comparison)
3. **Biological application** (cell type classification)
4. **Discovery** (mushroom body findings)
5. **Resource availability** (browser, data access)

**Principle**: Resource papers should balance technical description with biological discovery and emphasize accessibility.

---

## Writing for Interdisciplinary Audiences

**Excerpt**:
> This required techniques that permit the integration of genetic and phenotypic information for all cells of the body. On one hand, volume electron microscopy (EM) produces 3D ultrastructural data for cells and tissues with unprecedented coherency and detail. On the other, spatial single-cell omics techniques have revolutionized expression profiling.

**Why this works**:
- Explains two different fields briefly
- Assumes neither audience knows the other field
- Uses accessible language ("unprecedented," "revolutionized")
- Sets up the integration

**Principle**: For interdisciplinary work, briefly introduce each field to the other's audience.
