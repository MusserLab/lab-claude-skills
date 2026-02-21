---
name: tree-formatting
description: >
  Phylogenetic tree visualization and formatting with ETE4. Use when rendering a phylogenetic
  tree as a figure, choosing tree layout, coloring branches or labels by taxonomy, collapsing
  clades, displaying support values, or adding alignment/domain overlays to a tree.
  Do NOT load for tree inference (use protein-phylogeny skill) or domain annotation
  (future separate skill).
user-invocable: false
---

# Tree Formatting & Visualization

Conventions for rendering phylogenetic trees as publication-quality PDF figures using ETE4.
Covers layout choice, taxonomic coloring, clade collapsing, support value display, and
optional alignment/domain overlays.

---

## Layout Decision Tree

Choose layout based on the number of tips in the tree. **If > 250 tips, ask the user.**

| Tips | Layout | Details |
|------|--------|---------|
| **<= 250** | Rectangular phylogram | All tips shown, branch + label colored by taxonomy |
| **> 250** | **Ask user:** | Option A: Unrooted radial, branch colors only, no labels |
| | | Option B: Rectangular with collapsed clades (triangles) |
| | | Option C: Both |

- **Rectangular:** Default for most trees. Supports alignment display alongside tips.
- **Unrooted radial:** For large overview trees (500+ tips). Shows overall family structure without committing to a root. Branch colors only, no tip labels (they'd be unreadable).

---

## Tip Labels

### Format

```
G. species GeneSymbol
```

Examples:
- `H. sapiens WNT7A`
- `S. lacustris LAMC1`
- `N. vectensis NvNetrin`
- `L. gigantea V4AN98` (non-model: use accession)

### Rules

- One-letter genus + full species name in italics
- **Model organisms** (human, mouse, fly, worm, etc.): use official gene symbols
- **Non-model organisms:** use protein accession or ID
- Space-separated, no pipes
- Both label text and branch colored by taxonomy (see color scheme below)

---

## Taxonomic Color Scheme (Branch + Label Coloring)

Used when displaying individual tips. Both branch segments and tip label text are colored.

| Taxonomic Group | Color | Hex (suggested) |
|-----------------|-------|-----------------|
| Demosponges + Hexactinellida | Green | `#2ca02c` |
| Calcarea + Homoscleromorpha | Light green | `#98df8a` |
| Ctenophora | Purple | `#9467bd` |
| Cnidaria + Placozoa | Orange | `#ff7f0e` |
| Deuterostomia (Chordata + Ambulacraria) | Red | `#d62728` |
| Protostomia | Blue | `#1f77b4` |
| Non-metazoan eukaryotes | Black | `#000000` |

### Requirements

This coloring requires a **taxonomy mapping table**: a file mapping each sequence ID to its
species and major taxonomic group. The skill should ask for this if not provided.

Format (TSV):
```
seq_id	species	group
Q3UNG0	Mus musculus	Deuterostomia
V4AN98	Lottia gigantea	Protostomia
Q18823	Caenorhabditis elegans	Protostomia
```

---

## Collapsed Clade Coloring (OG Breadth)

Used when collapsing monophyletic clades in large trees. Triangle color indicates the
taxonomic breadth of the orthology group.

| OG Breadth | Color | Hex (suggested) |
|------------|-------|-----------------|
| Bilaterian OG | Red | `#d62728` |
| Cnidaria/Placozoa + Bilateria (no sponges/ctenophores) | Orange | `#ff7f0e` |
| Animal OG (includes sponges and/or ctenophores) | Green | `#2ca02c` |
| Opisthokont OG | Blue | `#1f77b4` |
| Broader eukaryote OG | Purple | `#9467bd` |

### Determining OG breadth

Assess which major groups are represented in the clade:
- Contains sponges/ctenophores + bilaterians → **Animal OG** (even if cnidarians are missing — infer loss)
- Contains cnidarians/placozoans + bilaterians but no sponges/ctenophores → **Cnidaria/Placozoa + Bilateria**
- Bilaterians only → **Bilaterian OG**
- Includes choanoflagellates or fungi → **Opisthokont OG**
- Includes plants, amoebae, or other non-opisthokonts → **Broader eukaryote OG**

---

## Clade Collapsing

### When to collapse

Collapse clades in trees with **> 250 tips** when the user chooses the rectangular collapsed
layout. Reasonable units to collapse:

- Bilaterian OGs (all bilaterian members of one orthology group)
- Cnidarian + bilaterian OGs
- Animal OGs
- Opisthokont OGs
- Eukaryote OGs

### How to collapse: soft monophyly with user approval

**Do not require strict monophyly.** Use a soft threshold:

1. Identify candidate monophyletic (or near-monophyletic) clades for a given taxonomic scope
2. Allow collapsing if >= 90% of the clade belongs to the target taxonomic group
3. **Flag outliers:** If a clade is 90-99% target group, report the outlier sequences with their support values
4. **Ask the user before collapsing:** "Found a bilaterian clade (42 sequences) but S. lacustris XP_123456 nests inside it with UFBoot 34. Likely misplacement. Collapse as bilaterian OG anyway?"
5. The user decides for each flagged case

### Display of collapsed clades

- **Triangle** shape representing the collapsed subtree
- **Colored** by OG breadth (see table above)
- **Label** with: OG name (if known) + list of model species gene names in the clade
- Example: `"LAMC1 — H. sapiens LAMC1, M. musculus Lamc1, D. melanogaster LanB1"`

---

## Branch Support Display

Show UFBoot2 and SH-aLRT values together at internal nodes.

### Format

```
UFBoot/SH-aLRT
```

Example: `97/85`

### Display threshold

Show values at a node if **UFBoot >= 70 OR SH-aLRT >= 50.** Omit values at nodes where
both are below these thresholds.

### Reference for interpreting support

| | UFBoot2 | SH-aLRT | Traditional bootstrap |
|---|---|---|---|
| Strong | >= 95 | >= 80 | >= 70 |
| Moderate | 70-94 | 50-79 | 50-69 |
| Weak | < 70 | < 50 | < 50 |

Note: UFBoot values are inflated relative to traditional bootstrap. UFBoot >= 95 roughly
corresponds to traditional bootstrap >= 70.

---

## Scale Bar

Always show a scale bar on the tree. Use branch lengths (substitutions per site).

---

## Rooting

- **Default: midpoint rooting**
- If the user specifies an outgroup, root on that instead

---

## Optional Overlays

### Alignment display (for trees with <= ~200 tips)

- Use ETE4's `link_to_alignment()` to display the multiple sequence alignment alongside
  the tree tips
- Only practical for smaller trees where individual columns are visible

### Pfam domain annotation

- Requires domain annotations from a **separate domain annotation skill** (not yet built)
- Input: a table of sequence ID, domain name, start position, end position
- Display using ETE4's SeqMotifFace or TreeProfiler
- Domain boxes overlaid on sequences next to the tree

---

## ETE4 Rendering

### Output format

- **PDF** (vector graphics, scalable) as the primary output
- SVG as secondary option

### Basic rendering pattern

```python
from ete4 import Tree

t = Tree(open("tree.treefile").read())
# ... apply styles, layouts, collapsing ...
t.render("tree.pdf", w=800)
```

### Key ETE4 components

- `TreeStyle`: overall tree appearance (layout mode, scale bar, etc.)
- `NodeStyle`: per-node styling (branch color, size, etc.)
- Layout functions: Python functions that dynamically apply styles to nodes
- `SeqMotifFace`: domain architecture display (ETE3 API, migration to ETE4 in progress;
  TreeProfiler may be needed)

---

## Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| ETE4 | Tree rendering | `pip install ete4` |
| TreeProfiler | Domain/annotation display (optional) | `pip install treeprofiler` |

---

## Related Skills

- **protein-phylogeny:** Inference pipeline that produces the tree
- **Pfam domain annotation (future):** Generates domain annotations for overlay
- **Sequence retrieval / naming (future):** Maps accessions to proper gene symbols
