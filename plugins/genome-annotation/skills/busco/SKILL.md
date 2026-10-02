---
name: busco
description: Run BUSCO completeness assessment on genomes, transcriptomes, or predicted proteomes. Generates conda env setup, shared-lineage download, SLURM array scripts with sample-sheet-driven (input × lineage) fan-out, a local single-input fallback, and an aggregator. Use when running BUSCO, assessing genome/transcriptome/proteome completeness, scoring against an odb10 lineage, or when the user mentions "BUSCO", "BUSCO score", "completeness", "C/S/D/F/M", "ortholog completeness", "genome/transcriptome/assembly QC", or asks whether an assembly is complete. Sanitizes FASTA headers automatically — BUSCO 6.x rejects "/" in headers, which trips up IsoSeq3 transcripts. Do NOT load for FCS-GX foreign-sequence screening (use fcs-gx), eggNOG-mapper functional annotation (use eggnog-mapper), or PROST structural homology (use prost-annotation).
---

# BUSCO Completeness Assessment

Run BUSCO on a genome assembly, transcriptome, or predicted proteome to score
against a lineage's single-copy ortholog set (`*_odb10`). Reports the standard
five-letter summary: **C** (Complete), **S** (Single-copy), **D** (Duplicated),
**F** (Fragmented), **M** (Missing) — out of **n** total orthologs in the
lineage.

This skill covers cluster (SLURM array, the default for any non-trivial input)
and local (single-input fallback for quick checks). Templates live in
`templates/`.

---

## Quick Reference

| Component | Value |
|-----------|-------|
| CLI | `busco` |
| Conda env | `busco_env` |
| Min version | BUSCO 5.7+ (this skill assumes 6.x output structure) |
| Lineage cache | `${SHARED_DBS}/busco_lineages/`; set the cache root explicitly |
| Activation | Initialize the existing Conda installation; load its site module only on clusters that require it, then activate `busco_env` |
| Modes | `genome`, `transcriptome`, `proteins` |
| Input formats | nucleotide FASTA (genome/transcriptome) or amino-acid FASTA (proteins) |
| Output root | `outs/<area>/<XX_busco>/<input>_<lineage>/` |

---

## When to use which BUSCO mode

| Mode | Typical input | What it measures | Speed |
|------|--------------|------------------|-------|
| `genome` | Genome assembly FASTA (contigs, scaffolds, or chromosomes) | Completeness of the assembly itself — uses metaeuk/Augustus to find orthologs in the genome | Slow (hours) |
| `transcriptome` | de novo / IsoSeq / Trinity / HiFi-RNA transcript FASTA | Completeness of the transcriptome — uses miniprot to find orthologs in transcript-space | Medium (input-dependent; see starting resource estimates) |
| `proteins` | Predicted proteome (after gene prediction) | Completeness of the annotated proteome — uses HMMER directly. Sanity-check that gene prediction recovered conserved orthologs | Fast (~30 min for 20K proteins) |

Choose the mode for the input and question. Genome, predicted-proteome and transcriptome
assessments examine different inputs; transcript coverage also depends on sampled expression.
Do not expect equal scores by default. A lower proteome score can motivate investigation of gene
prediction, but is not a diagnosis by itself. Report each input, mode and lineage separately.

---

## Lineage Selection

Use the most specific available lineage that confidently contains the organism for the
primary completeness assessment. Reuse the project's agreed lineage and dataset version when
applicable; otherwise discuss the choice before setup. Confirm availability with
`busco --list-datasets` and record the exact lineage release, input, mode and BUSCO version.
The existing templates use explicit odb10 examples; this correction does not upgrade datasets
or tools. A different dataset release needs its own compatibility and comparison review.

| Example lineage | Taxonomic scope to check against the actual organism |
|-----------------|----------------------------------------------------|
| `eukaryota_odb10` | Broad eukaryotic set; lower resolution than an appropriate specific lineage |
| `metazoa_odb10` | Animals, including sponges, ctenophores, cnidarians and placozoans |
| `vertebrata_odb10` | Vertebrates |
| `mammalia_odb10` | Mammals |
| `bacteria_odb10` | Bacteria; consider a more specific available bacterial lineage |
| `fungi_odb10` | Fungi |
| `viridiplantae_odb10` | Green plants |
| `arthropoda_odb10` | Arthropods |
| `nematoda_odb10` | Nematodes |

Choanoflagellates are not animals: do not use a metazoan set as their default completeness
reference. Choose an available lineage containing the organism (for example, a broad eukaryotic
set when no suitable narrower set is available). Placozoans are animals and belong with the
animal examples. Keep any deliberately out-of-clade comparison separate from completeness QC.

An additional broader lineage can address an agreed sensitivity question, but it is not a
mandatory second run or an automatic substitute for the primary score. Different lineage sets
have different markers and denominators; their percentages are not a bound or a strictness scale.
Agreement does not prove overall completeness, and disagreement does not by itself show which
score to trust. Investigate lineage fit, input/mode, search or gene-prediction limitations and the
actual missing/fragmented markers before interpreting a low score.

For dataset examples and interpretation see `references/lineage_table.md` and the
[BUSCO user guide](https://busco.ezlab.org/busco_userguide#tips-for-running-busco).

---

## Workflow

Requires Research Core. Resolve bundled resources relative to this skill directory.
Set `SHARED_DBS` to the confirmed cache root in the project environment or source an
optional site profile that exports it before setup/submission; no personal path is assumed.
Initialize the local Conda installation before running setup on a laptop.

Before copying batch wrappers, adapt module and environment lines for the execution site.
`jobstats` is a scheduler-accounting example where available; use the site's equivalent otherwise.

A BUSCO project has three phases — **setup**, **run**, **aggregate**. Each
maps to one or more files copied from `templates/` into the project's
`batch/<area>/` and `scripts/<area>/` directories.

### Phase 1 — Setup (one-time per cluster)

Creates the `busco_env` conda environment and downloads requested lineages
into the chosen cache so they're reusable across projects where access permits.

```bash
bash batch/<area>/busco_setup.sh
```

The setup script (`templates/busco_setup.sh`):
- Creates `busco_env` from `templates/busco_environment.yml` if not already present
- Downloads each requested lineage into `${SHARED_DBS}/busco_lineages/<lineage>/` if not already there
- Idempotent — safe to re-run

The lineage list inside the setup script must be edited to include the
lineages you want.

### Phase 2 — Run (SLURM array, the default)

The array job reads a sample sheet (`batch/<area>/busco_samples.tsv`) and
fans out one task per `(input × lineage)` combination.

```bash
EXPECTED_COMMIT=$(git rev-parse HEAD)
sbatch --export=ALL,EXPECTED_COMMIT="$EXPECTED_COMMIT" batch/<area>/busco_array.sh
```

Submit from the project root after the array wrapper, sample sheet, and any
project-local environment lock match that commit. The queued task verifies those
producing files against `EXPECTED_COMMIT`; unrelated working-tree changes do not
block the run.

The array script (`templates/busco_array.sh`):
- Reads its task row from the sample sheet by `$SLURM_ARRAY_TASK_ID`
- **Sanitizes FASTA headers** — substitutes `/` → `_` on header lines into a
  uniquely named `$TMPDIR` copy, so concurrent runs cannot share a temporary file. This is required because BUSCO
  6.x crashes on `/` in headers, which is common in IsoSeq3 (`>transcript/N`)
  and some assembler outputs. Sequence lines are untouched.
- Runs BUSCO in `--offline` mode against the shared lineage cache
- Writes outputs to `outs/<area>/<XX_busco>/<input>_<lineage>/`

The sample sheet has columns: `task_id`, `input`, `species` (free-text label),
`lineage`, `mode`, `fasta_path`. Edit `--array=1-N` in the SBATCH header to
match the number of data rows.

#### Local single-input fallback

For ad-hoc completeness checks (a single small assembly or proteome you want
to look at on a laptop or during interactive cluster sessions), use
`templates/busco_local.sh` instead. Same sanitization, same output structure,
but no SLURM and no sample sheet — takes input/lineage/mode as positional args.

### Phase 3 — Aggregate (after the array completes)

Parse the `short_summary.specific.<lineage>.<input>_<lineage>.json` files
into a tidy table and a comparison plot; retain the matching text summaries for sharing.

Render with Quarto and the project's existing declared Python kernel containing pandas,
matplotlib and ipykernel. Confirm that kernel before rendering; do not silently switch it.
The `busco_env` template is the compute environment and does not supply all render dependencies.

Aggregate one BUSCO mode at a time from its corresponding output root. A new genome
project may have three separate run/aggregation sets; compare their tables deliberately later.

The aggregator template (`templates/busco_aggregate.qmd`) uses a numbered
script convention (`XX_busco_aggregate.qmd`), reads from the array's output
directory, and produces:

- A long-format TSV with one row per (input, lineage, metric)
- A wide-format comparison TSV with one row per input
- A bar/dot plot of completeness by input, faceted by lineage
- A copy of every `short_summary.txt` consolidated under `outs/.../summaries/`

---

## SLURM Resources

> These resource values are unvalidated starting examples. Check your site's limits and
> use `jobstats <jobid>` on the first run for the actual project input; tune subsequent runs.

| Mode | CPUs | Memory | Time | Notes |
|------|------|--------|------|-------|
| `transcriptome` | 8 | 16 GB | 4h | Starting example; adjust for the actual input and measured jobstats. |
| `genome` (small, <500 Mb) | 16 | 32 GB | 12h | Augustus/metaeuk dominate runtime |
| `genome` (medium, 0.5–2 Gb) | 16 | 64 GB | 24h | Increase RAM for repeat-rich plant/animal genomes |
| `genome` (large, >2 Gb) | 32 | 128 GB | 48h | May need a long-job partition |
| `proteins` | 8 | 16 GB | 2h | HMMER is fast; mostly I/O-bound |

Always check `jobstats <jobid>` after the first run and tune for subsequent
runs. BUSCO's CPU saturation drops near the end of metaeuk; `--cpu 16` is
usually saturated only in the search step.

For the SLURM partition table see the `hpc` skill.

---

## Output Structure

Each run directory `outs/<area>/<XX_busco>/<input>_<lineage>/` contains:

| File | Contents |
|------|----------|
| `short_summary.specific.<lineage>.<input>_<lineage>.txt` | Headline scores (C/S/D/F/M/n). The aggregator parses this. |
| `short_summary.specific.<lineage>.<input>_<lineage>.json` | Same scores in JSON. Easier to parse programmatically. |
| `run_<lineage>/full_table.tsv` | Per-ortholog status, hit transcript/contig ID, length |
| `run_<lineage>/missing_busco_list.tsv` | Orthologs not found |
| `run_<lineage>/busco_sequences/` | FASTA of recovered ortholog sequences (often useful) |
| `logs/` | Per-tool logs (miniprot/metaeuk/HMMER) |

When `--tar` is set (recommended), `run_<lineage>/` is tarred and removed
after completion to save inodes; `short_summary*` remains uncompressed.

Synthetic score-format illustration only (these numbers do not report a real run):

```
C:80.0%[S:70.0%,D:10.0%],F:5.0%,M:15.0%,n:100
```

---

## Sample Sheet Format

`batch/<area>/busco_samples.tsv` (tab-separated):

```
task_id	input	species	lineage	mode	fasta_path
1	pool_A	Sycon_ciliatum	metazoa_odb10	transcriptome	data/<area>/pool_A.fasta
2	pool_B	Halichondria_panicea	metazoa_odb10	transcriptome	data/<area>/pool_B.fasta
3	pool_A	Sycon_ciliatum	eukaryota_odb10	transcriptome	data/<area>/pool_A.fasta
4	pool_B	Halichondria_panicea	eukaryota_odb10	transcriptome	data/<area>/pool_B.fasta
```

The bundled sample sheet is a transcriptome-only example and matches the aggregator's
single-mode scope. Its broader-lineage rows illustrate an optional, separately justified sensitivity
comparison; remove those rows when only the primary assessment is intended. For genome or proteins,
make a separate sample sheet, array wrapper,
BUSCO output root and aggregation destination for each mode; adjust resources accordingly.
The array can switch `--mode` per row, but the aggregator deliberately refuses a mixed-mode
run directory. Keep modes separate rather than weakening that scientific guard.

---

## Common Gotchas

See `references/gotchas.md` for the full list. The headline ones:

- **`/` in FASTA headers** — BUSCO 6.x rejects this with `"crash Reader"`.
  IsoSeq3 (`>transcript/N`) and some assemblers produce these. The array script
  sanitizes automatically (`sed '/^>/ s|/|_|g'`); record this in any custom
  workflows.
- **Lineage path errors** — `busco --download` places lineages under
  `<download_path>/lineages/<lineage>/`. The setup script flattens to
  `<download_path>/<lineage>/` because that's what the array script expects.
- **`--offline` requires the lineage exactly at `--lineage_dataset` path** —
  passing just the lineage name without an explicit path falls back to network
  lookup and fails on compute nodes.
- **Refuses to overwrite existing runs** — the array and local templates stop when the per-task
  output already exists. Use a fresh name or preserve/clear that specific producer-owned output
  only after confirming it is disposable.
- **Duplication score on transcriptomes** — IsoSeq and Trinity produce many
  isoforms per gene, which inflates the `D:` (Duplicated) score. Focus on
  `C:` (Complete = S+D) rather than the S/D split for transcriptome QC.

---

## Setup Detail: Conda Environment

```yaml
# templates/busco_environment.yml
name: busco_env
channels:
  - conda-forge
  - bioconda
dependencies:
  - python=3.11
  - busco>=5.7
  - pandas
```

Bioconda's `busco` package (currently 6.0.0) bundles the dependencies BUSCO
needs (metaeuk, miniprot, HMMER, sepp, etc.). Do not install these separately.

---

## Setup Detail: Shared Lineage Cache

Lineages download once into `${SHARED_DBS}/busco_lineages/` after you choose the cache root.
Layout after setup:

```
busco_lineages/
├── eukaryota_odb10/
│   ├── lengths_cutoff
│   ├── score_cutoffs
│   ├── hmms/
│   ├── refseq_db.faa.gz
│   └── ...
├── metazoa_odb10/
└── ...
```

The array script checks `${SHARED_DBS}/busco_lineages/<lineage>/lengths_cutoff`
exists before invoking BUSCO. If you need a different shared root, set
`SHARED_DBS` in the environment before submitting.

---

## When this skill should NOT generate scripts

- **Genome assembly QC where you also want contamination screening** — pair
  with the `fcs-gx` skill (NCBI foreign-contamination screen) for a more
  complete picture. BUSCO measures completeness; FCS-GX measures contamination.
- **Functional annotation** — use `eggnog-mapper` or `prost-annotation`. BUSCO
  only scores ortholog presence; it does not assign GO/KO/Pfam.
- **Single-cell or expression QC** — wrong tool entirely.
