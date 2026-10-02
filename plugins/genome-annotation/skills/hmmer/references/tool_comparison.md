# When to use HMMER vs BLAST vs PROST

Three sequence-similarity tools, three distinct best-cases. Picking the wrong
one wastes compute or produces misleading results.

## One-line decision rule

- **BLAST** = "find this **exact thing's** matches"
- **HMMER** = "find members of this **family**"
- **PROST** = "find structurally similar proteins, sequence be damned"

## Comparison table

| Dimension | BLAST | HMMER | PROST |
|-----------|-------|-------|-------|
| Query unit | Single sequence | Profile (HMM) over an MSA | Embedded protein |
| Sensitivity floor | ~30% identity | ~20% identity (with right profile) | ~10% identity, structurally similar |
| Threshold | E-value, must tune | Pfam GA cutoff (curated) or E-value for custom | Embedding distance |
| Output | Pairwise alignment | Family/domain hit + coords | Distance ranking |
| Speed | Fastest | Medium | Slowest (GPU embed) |
| What it captures | Sequence similarity | Position-specific conservation | Structural geometry |

## Worked examples

### "Is this protein a kinase?"
- BLAST: top hit might be a real kinase, but score depends on which kinase happens to be in the database. Threshold is arbitrary.
- **HMMER (`hmmscan` against Pfam)**: hits Pkinase (PF00069) or Pkinase_Tyr (PF07714) — definitive family-level answer with curated GA cutoff. Also reports the kinase domain coordinates, separate from any other domains in the protein.
- PROST: would also work but is overkill — kinases are well-characterized, sequence retains enough signal.

### "Find all CO1 sequences in several sponge transcriptomes"
- BLAST: top-hit will say "Halichondria CO1" for everything because Halichondria has the most sponge mt sequences in NCBI nt — *misleading*.
- **HMMER (`hmmscan` against PF00115 with `--cut_ga`)**: identifies CO1 family members per pool with calibrated thresholds. Doesn't make species claims — just "passes the CO1 family filter".
- PROST: works, but overkill for a well-conserved family with curated Pfam profile.

### "Are there ancient proteins in the sponge proteome that match metazoan-conserved domains?"
- BLAST: misses (sequence too divergent).
- HMMER: catches some if the family has a Pfam HMM and the conservation pattern is captured.
- **PROST**: best — structural embeddings catch homologs invisible to sequence-level methods.

### "I have a curated set of 50 cnidarian gene-X sequences. Find homologs in Spongilla."
- BLAST: works for the closer ones; misses the distant ones.
- **HMMER with custom HMM** (`mafft` → `trimal` → `hmmbuild` → `hmmsearch`): leverages position-specific conservation across all 50 references; finds more distant Spongilla homologs than BLAST does.
- PROST: works if structures predicted; complementary, not a replacement.

### "Annotate the domain architecture of this 1500-aa protein"
- BLAST: tells you which proteins it's similar to, not which domains it contains.
- **HMMER (`hmmscan` against Pfam-A)**: lists every Pfam domain at specific residue ranges (kinase 50–340, SH2 360–450, etc.). Standard tool for this.
- PROST: not designed for domain decomposition.

## When to combine tools

A common pattern in the lab's `annotation-pipeline` is **HMMER + PROST together**:

- HMMER (via eggNOG-mapper) handles well-characterized families with high confidence.
- PROST catches twilight-zone homologs that HMMER missed.
- Reciprocal BLAST validates the closest hits where sequence is enough.

Each tool covers a different sensitivity zone. The combination is more sensitive than any one tool alone.

## When NOT to use HMMER

- **One specific protein, you just want to know "what is this"** → BLAST is faster and gives you direct hit context.
- **Whole-proteome functional annotation** → use eggNOG-mapper (which wraps HMMER + diamond + ortholog assignment).
- **Twilight-zone (<20% id), sequence has diverged below profile sensitivity** → PROST.
- **You have only one reference sequence and no time to build a profile** → BLAST or `phmmer` (HMMER's BLAST-equivalent).