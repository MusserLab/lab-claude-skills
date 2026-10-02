# Building custom HMMs

When Pfam doesn't have an HMM for the family you care about — or its HMM is
too broad/narrow for your purpose — build a custom one from a curated MSA.

## When you need a custom HMM

- The family has no Pfam entry (rare for well-known families, common for
  novel/lineage-specific genes — e.g., a sponge-specific symbiosis gene set).
- Pfam's HMM is too broad (e.g., generic "EGF") and you want to discriminate a
  subfamily (e.g., laminin EGF specifically).
- You have a curated set of confirmed family members that's tighter than what
  Pfam captured.
- You want to enforce a specific seed alignment that reflects your scientific
  question.

## Pipeline

The `templates/build_custom_hmm.sh` script automates these steps. Manually:

### 1. Curate reference sequences

This is the part that **isn't templatable** — it's family-specific science.
Guidelines:

- **Coverage**: include reasonably diverse representatives of the family. For
  a metazoan-wide family, sample across phyla (sponge + cnidarian + protostome
  + deuterostome). For a lineage-specific family, sample across the lineage's
  internal diversity.
- **Quality**: only include sequences with experimental or strong
  computational evidence of family membership. Don't include "potential
  homologs from BLAST" unless you've sanity-checked them.
- **Length**: trim to the conserved domain region if possible. Full-length
  proteins with extensive non-conserved tails make for a noisier profile.
- **Paralog hygiene**: don't mix paralogs that have diverged biologically.
  Build one HMM per paralog if the question demands it.
- **Outgroup contamination**: a single sequence misclassified into the
  reference set can pull the profile away from the family. Inspect the MSA.

### 2. Align (MAFFT)

```bash
mafft --auto --thread -1 reference.fasta > reference.aln
```

`--auto` picks reasonable strategy by size; for 50–500 sequences this typically
chooses L-INS-i. For thousands, it falls back to FFT-NS-2 which is faster but
less accurate.

For deeply divergent families (sponge + protostome + deuterostome distances),
prefer L-INS-i explicitly:

```bash
mafft --localpair --maxiterate 1000 --thread -1 reference.fasta > reference.aln
```

This overlaps with the `protein-phylogeny` skill — same alignment step.

### 3. Trim (trimAl, optional)

```bash
trimal -in reference.aln -out reference.trim.aln -gappyout
```

`-gappyout` is automatic and conservative. Removes columns dominated by gaps.
Other options:
- `-strict` — slightly more aggressive
- `-automated1` — picks heuristically based on alignment characteristics
- `-nogaps` — keeps only gap-free columns (often over-trims)

**Sanity check**: if trimming leaves <50 columns, you've over-trimmed (or your
alignment is too gappy). Skip trimming or use `-nogaps` only on the
already-conserved domain region.

### 4. `hmmbuild`

```bash
hmmbuild reference.hmm reference.trim.aln
```

Produces a profile HMM. Defaults are usually fine. Useful flags:
- `--amino` — force amino-acid alphabet (default usually correct).
- `-n my_family` — set the model name (otherwise inherited from the alignment file).
- `--symfrac 0.5` — column inclusion threshold (default 0.5 of non-gap residues required).

### 5. Calibrate threshold against a control

This is the part most people skip. Do it.

```bash
hmmsearch --cpu 4 --tblout control.tbl reference.hmm control_proteome.fasta > control.log
```

The control proteome should be one where you know the **expected number** of
true hits (e.g., a model species' proteome with annotated family members).

Inspect the score distribution:

```bash
awk '!/^#/ && NF{print $5}' control.tbl | sort -g
```

You'll typically see a bimodal distribution: real family members at low
E-values (high scores), then a long tail of poor hits. Pick the cutoff at the
gap. Typical thresholds:
- `-E 1e-5` to `-E 1e-10` for full-sequence
- `--domE 1e-3` for per-domain

### 6. (Optional) Bake the threshold into the HMM

If you'll reuse the HMM, you can edit the HMM file to add `GA`, `TC`, `NC`
lines manually:

```
GA    25.0 25.0;
TC    30.0 30.0;
NC    20.0 20.0;
```

Then `--cut_ga` against your custom HMM works the same as for Pfam HMMs. This
avoids forgetting to pass `-E` every time.

## hmmsearch vs hmmscan for custom HMMs

For a single custom HMM searching a target proteome, **`hmmsearch` is correct
and faster** than `hmmscan`. Don't bother `hmmpress`-ing a single-HMM file
unless you'll combine it with others into a multi-HMM database.

## Worked example: cnidarian symbiosis genes in Spongilla

Hypothetical workflow if you want to find Spongilla homologs of a curated
cnidarian gene set:

1. Curate ~30 confirmed cnidarian family-X sequences from UniProt + lab data.
2. `mafft --localpair` → `trimal -gappyout` → `hmmbuild family_X.hmm`.
3. `hmmsearch -E 1e-5 family_X.hmm spongilla_proteome.fasta` → tblout.
4. Take the top N hits, BLAST back against the cnidarian set (reciprocal best
   hit) to confirm.
5. Build a tree (`protein-phylogeny` skill) including cnidarian references +
   Spongilla candidates to confirm the orthology relationship.

## Where this lives in the lab pipeline

- Custom HMM building is **upstream** of the lab's `annotation-pipeline`. Once
  built, custom HMMs can become a fifth evidence tier in `tf-list-generation`
  alongside eggNOG GO, PROST GO, curated lists, and name patterns.
- For phylogenomic gene-family extraction, custom HMMs feed into the
  `protein-phylogeny` skill's alignment step (which uses the same MAFFT
  call described here).