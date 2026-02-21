---
name: protein-phylogeny
description: >
  Protein (gene) phylogeny inference pipeline: alignment, trimming, tree building.
  Use when building phylogenetic trees from protein sequences, aligning protein families,
  running IQ-TREE or MAFFT for phylogenetics, or when the user says "gene tree" or
  "protein tree." Covers single domains, whole proteins, and multi-domain proteins
  across deep evolutionary distances (sponges, animals, eukaryotes).
  Do NOT load for nucleotide-only phylogenies, species trees from concatenated matrices,
  or tree visualization (use tree-formatting skill for that).
user-invocable: false
---

# Protein Phylogeny Inference

Pipeline for building protein phylogenies across deep evolutionary distances. Designed for
single domains, whole single-domain proteins, and multi-domain proteins, from ~10 to
several thousand sequences, spanning sponges to all eukaryotes.

**If the user says "gene tree" they may mean protein sequences.** Confirm if ambiguous,
or inspect the input sequences (amino acid alphabet vs nucleotide).

---

## Step 1: Input & Curation

### Accept and validate input

- Input: protein FASTA file
- If sequences look like nucleotides (only A/T/G/C/N), confirm with user: "These look like nucleotide sequences. Did you mean to use protein sequences?"
- Report basic stats: number of sequences, median length, min/max length

### Minimum length cutoff

- Calculate median sequence length
- Flag sequences shorter than 50% of median: "You have N sequences shorter than 50% of the median length (X aa). Short fragments can degrade alignment quality. Want to remove them, use a different cutoff, or keep all?"
- Let the user decide the threshold

### Optional: CD-HIT redundancy reduction

- **Off by default**
- If requested: CD-HIT at 99% sequence identity (`cd-hit -i input.fasta -o output.fasta -c 0.99`)
- Report how many sequences were removed

### No automated outlier removal

- The user inspects the tree after inference and decides if anything looks wrong
- Do not use TreeShrink or similar tools automatically

---

## Step 2: Alignment

### Tool: MAFFT (only)

Choose the algorithm based on data characteristics. **Ask the user to confirm** after making a recommendation.

| Condition | Algorithm | MAFFT flags |
|-----------|-----------|-------------|
| Single domain or whole protein, <= 2000 seq | **L-INS-i** (default) | `--localpair --maxiterate 1000 --reorder` |
| Multi-domain protein with variable linkers | **E-INS-i** | `--genafpair --maxiterate 1000 --reorder` |
| > 2000 sequences | **auto** (MAFFT decides) | `--auto --reorder` |

### Recommendation logic

- "You have N sequences, median length X aa. This looks like a [single-domain / multi-domain / whole-protein] dataset. I'd recommend MAFFT [L-INS-i / E-INS-i / auto]. Does that sound right?"
- For > 2000 sequences with L-INS-i requested: warn about memory/time scaling (O(n^2))

### After alignment

- Report alignment dimensions (sequences x columns)
- Suggest visual inspection: "I'd recommend checking the alignment in Jalview or AliView before proceeding."

### Future options (not yet implemented)

- Structure-guided alignment (e.g., MAFFT --merge with AlphaFold structures)
- Protein language model-based alignment

---

## Step 3: Trimming

### Default: no trimming

Do not trim unless the user requests it. Rationale: for deep divergences, aggressive trimming
can remove phylogenetically informative sites. Good models (site-heterogeneous) can handle
noisy columns.

### Optional trimming tools

Offer these if the user asks, or suggest if the alignment looks very gappy:

| Tool | Mode | Command | Best for |
|------|------|---------|----------|
| **ClipKIT** | `kpic-gappy` | `clipkit input.aln -m kpic-gappy` | General purpose; preserves informative + constant sites |
| **BMGE** | BLOSUM30 | `bmge -i input.aln -t AA -m BLOSUM30` | Very deep divergences with compositional heterogeneity |

### Recommendation logic

- If user asks for trimming on a very deep dataset (cross-animal, cross-eukaryote): recommend BMGE
- Otherwise: recommend ClipKIT
- **Warn if trimming removes > 50% of alignment columns:** "Trimming removed X% of columns. This is aggressive and may be removing real signal. Want to proceed, try a less aggressive option, or skip trimming?"

### Not offered by default

- trimAl: user can request it, but it's not a primary option
- Gblocks: outdated, not recommended

---

## Step 4: Tree Inference

### Tool: IQ-TREE 3

Use a tiered approach. **Ask the user which tier** or recommend based on dataset size and scope.

### Tier 1: Quick baseline

For initial exploration or when speed matters.

```bash
iqtree3 -s alignment.fasta -m MFP -B 1000 -alrt 1000 -nstop 50 -T AUTO
```

- ModelFinder (`-m MFP`) selects the best site-homogeneous model automatically
- UFBoot2 + SH-aLRT for branch support

### Tier 2: Standard (default for deep eukaryotic protein phylogenies)

Two-pass PMSF workflow with ELM exchangeability matrix.

**Pass 1 — guide tree:**
```bash
iqtree3 -s alignment.fasta -m ELM+C60+G -nstop 50 -T 8 -pre guide
```

**Pass 2 — PMSF tree with full search:**
```bash
iqtree3 -s alignment.fasta -m ELM+C60+G -ft guide.treefile -B 1000 -alrt 1000 -nstop 50 -T 8
```

> **Bug workaround (IQ-TREE 3.0.1):** `-T AUTO` crashes with an assertion error
> during PMSF site frequency computation (`computePartialParsimonyFast`). Use a
> fixed thread count (e.g., `-T 8`) instead. Re-test with future IQ-TREE releases.

- **ELM** (Eukaryotic Linked Mixture): exchangeability matrix estimated under C60 from eukaryotic data. Better than LG when paired with profile mixture models (Banos et al. 2024, MBE).
- C60: 60-class amino acid profile mixture capturing site heterogeneity
- PMSF: posterior mean site frequency profiles — ML approximation of Bayesian CAT model

### Tier 2 alternative: LG-based

If the dataset is not primarily eukaryotic, or for comparison:

```bash
# Pass 1
iqtree3 -s alignment.fasta -m LG+C60+F+R -nstop 50 -T 8 -pre guide
# Pass 2
iqtree3 -s alignment.fasta -m LG+C60+F+R -ft guide.treefile -B 1000 -alrt 1000 -nstop 50 -T 8
```

### Tier 3: PhyloBayes (optional, not default)

For small datasets (< ~200 sequences) when maximum rigor is needed, e.g., resolving
controversial deep nodes. Offer but do not default to this.

```bash
# Run two independent chains
pb_mpi -d alignment.phy -cat -gtr -x 1 10000 chain1
pb_mpi -d alignment.phy -cat -gtr -x 1 10000 chain2

# Check convergence
bpcomp -x 2500 chain1 chain2    # maxdiff < 0.3, ideally < 0.1
tracecomp -x 2500 chain1 chain2  # effective sizes > 100
```

- CAT+GTR: infinite mixture model, gold standard for deep phylogenetics
- Very slow; not practical for > ~200 sequences
- Requires PhyloBayes-MPI

### Branch support

- **Default:** UFBoot2 (1000 replicates) + SH-aLRT (1000 replicates), run simultaneously with `-B 1000 -alrt 1000`
- **Optional:** Non-parametric bootstrap for publication-quality final trees (`-b 1000` instead of `-B`)
- Note: UFBoot values are inflated vs traditional bootstrap. UFBoot >= 95 ~ traditional bootstrap >= 70.

### Optional sensitivity analyses

Offer these but do not run automatically:

- **Dayhoff6 recoding:** Reduces 20 amino acids to 6 physicochemical groups. Tests whether topology is driven by compositional convergence. Run with `-m GTR+R` on the recoded alignment.
- **AU topology test:** If competing hypotheses exist for specific nodes. Run with `-zb 10000 -au` in IQ-TREE.

---

## Step 5: Output

### Rooting

- **Default: midpoint rooting**
- If user specifies an outgroup, use that instead

### Summary report

After tree inference, report:
- Number of sequences in final alignment
- Alignment length (columns), and if trimmed, before/after
- Model selected (with tier noted)
- Support value summary: how many nodes have UFBoot >= 95, >= 70; how many have SH-aLRT >= 80, >= 50
- Output file locations (.treefile, .iqtree log, .sitefreq if PMSF)

### Next steps

- "Tree is ready. Want to visualize it? The tree-formatting skill handles layout, coloring, and clade collapsing."
- "Want to re-run with trimming / different model / PhyloBayes?"

---

## Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| MAFFT | Alignment | `conda install -c bioconda mafft` |
| IQ-TREE 3 | Tree inference | `conda install -c bioconda iqtree` (ensure v3+) |
| CD-HIT | Redundancy reduction (optional) | `conda install -c bioconda cd-hit` |
| ClipKIT | Trimming (optional) | `pip install clipkit` |
| BMGE | Trimming (optional) | `conda install -c bioconda bmge` |
| PhyloBayes-MPI | Bayesian inference (optional) | `conda install -c bioconda phylobayes-mpi` |

---

## Key References

- Katoh & Standley (2013) MAFFT v7. Mol Biol Evol 30:772-780.
- Banos et al. (2024) GTRpmix: A linked GTR model for profile mixture models. Mol Biol Evol 41:msae174.
- Steenwyk et al. (2020) ClipKIT: a multiple sequence alignment trimming software. PLoS Biol 18:e3001007.
- Criscuolo & Gribaldo (2010) BMGE. BMC Evol Biol 10:210.
- Wang et al. (2017) PMSF model. Syst Biol 67:216-235.
- Lartillot et al. (2013) PhyloBayes-MPI. Syst Biol 62:611-615.
