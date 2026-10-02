# BUSCO Gotchas

Known issues and mitigations. The array template handles most of these
automatically; this file documents the reasoning so a future user knows
why each guard exists.

## FASTA header issues

### `/` in headers (BUSCO 6.x crashes)

**Error:** `ERROR: The character "/" is present in the fasta header
>transcript/N, which will crash Reader.`

**Cause:** BUSCO 6.x hard-rejects `/` in headers. Common sources:
- IsoSeq3 cluster IDs: `>transcript/7001`
- Some assemblers' contig naming
- Pipeline outputs that put coordinate ranges in headers

**Fix:** The array script sanitizes headers before BUSCO sees them:

```bash
sed '/^>/ s|/|_|g' input.fasta > $TMPDIR/clean.fasta
```

The substitution is bounded to header lines only (`/^>/`), so sequence
lines are untouched. Output goes to `$TMPDIR` (task-local, auto-cleaned).

### Other forbidden characters

Reports of similar crashes on `|`, `:`, and whitespace in headers across
BUSCO versions. The same sed approach generalizes — extend the substitution
if you see a different forbidden character.

### Long headers

BUSCO truncates long headers in `full_table.tsv`. If you need the full
original ID for downstream analysis, save a mapping (`grep '^>' input.fasta`)
before BUSCO runs.

### Trailing `*` (stop codon) on BRAKER `.aa` proteomes

BRAKER's `augustus.hints.aa` files include trailing `*` on many sequences
(the stop codon, encoded as a literal `*` in the protein sequence). BUSCO's
`proteins` mode uses HMMER directly and tolerates `*`, but stripping keeps
length statistics clean and matches the convention used by `eggnog-mapper`
and `prost-annotation`. Strip during representative-proteome extraction:

```python
seq = seq.rstrip("*")
```

This is upstream of BUSCO; do it once when generating the representative
proteome, not per-tool.

## Lineage path issues

### `--download` puts lineage in wrong path

**Behavior:** `busco --download metazoa_odb10 --download_path /shared/db`
creates `/shared/db/lineages/metazoa_odb10/`, not `/shared/db/metazoa_odb10/`.

**Mitigation:** The setup script flattens with `mv` after download:

```bash
mv "$LINEAGE_ROOT/lineages/$L" "$LINEAGE_ROOT/$L"
rmdir "$LINEAGE_ROOT/lineages" 2>/dev/null || true
```

This matches what the array script expects via `--lineage_dataset`.

### `--offline` requires explicit path

Passing just the lineage name (`--lineage_dataset metazoa_odb10`) without
`--offline` makes BUSCO look online and fail on compute nodes (no internet).
Always pair `--offline` with an absolute or relative path to the lineage
directory.

## Output overwrite

### "Refuses to overwrite existing run"

**Behavior:** BUSCO refuses to start if `out_path/out_name/` exists.

**Mitigation:** The templates refuse an existing `$OUT_PARENT/$OUT_NAME`. Use a fresh
name, or preserve/clear that exact producer-owned directory only after confirming its
contents are disposable. A cancelled run is not automatically disposable.

## Resource gotchas

### CPU saturation drops near end of metaeuk

**Behavior:** `--cpu 16` is saturated during the search step, but the final
HMMER+postprocessing phase is largely single-threaded. Don't be alarmed if
`jobstats` shows lower utilization at the end — that's the tail of metaeuk
finishing per-ortholog work.

### Memory for large genomes

Genome-mode BUSCO on >2 Gb genomes (mammals, plants) can need 64–128 GB.
Default 32 GB is enough for transcriptome and small-genome work but will
OOM on large genomes — bump `--mem` and consider the `week` partition.

## Score interpretation

### Inflated duplication on transcriptomes

IsoSeq, Trinity, and similar de novo transcriptome assemblers emit many
isoforms per gene. BUSCO counts every match, so `D:` (Duplicated) is
inflated relative to a genome's `D:`. Focus on `C:` (Complete = S+D) for
transcriptome QC.

To get a meaningful S/D split on transcriptomes, collapse with CD-HIT
(99% or 95% identity) before BUSCO. The skill does not do this by default
— it's an opt-in upstream step.

### Different lineages give different scores

Different lineage datasets test different marker sets and denominators. A score difference
alone does not diagnose assembly quality, biological loss or lineage mismatch, and does not
justify preferring the broader score automatically. Keep the appropriate primary assessment
separate from an agreed sensitivity or out-of-clade exploration; inspect input/mode, logs and
marker-level results before interpretation. See `lineage_table.md` "Interpreting optional lineage
comparisons."

## Conda environment

### `busco_env` solver hangs on bioconda

If the env solve takes >5 minutes, try:

```bash
conda env create -f busco_environment.yml --solver libmamba
```

The bioconda channel has many packages and the classical solver can be
slow on a fresh activation.
