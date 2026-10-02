---
name: hmmer
description: Run HMMER profile-HMM searches (hmmscan / hmmsearch / phmmer / hmmbuild / jackhmmer) for protein-family detection, marker-gene extraction from assemblies, and custom HMM profiles. Generates conda env setup, Pfam-HMM download + hmmpress, SLURM array scripts with sample-sheet fan-out, a local single-input fallback, and a tblout aggregator. Covers nucleotide inputs (6-frame translation with the right genetic code) and protein inputs. Use when the user mentions "HMMER", "hmmscan", "hmmsearch", "phmmer", "Pfam", "profile HMM", "custom HMM", "domain detection", "marker-gene extraction", "CO1 / COX2 / COX3 / cyt-b", or asks to find members of a protein family in a non-model proteome/transcriptome. Do NOT load for whole-proteome functional annotation (use eggnog-mapper, which wraps HMMER), structural homology of distant relatives (use prost-annotation), or BLAST-style top-hit searches without HMMER's profile statistics (use BLAST directly).
---

# HMMER profile-HMM searches

Run HMMER 3 to detect members of a protein family in a proteome or
transcriptome via profile HMMs (Pfam or custom). HMMER outperforms BLAST for
distant homologs (~20–40% identity) because the profile encodes
position-specific conservation, and Pfam GA cutoffs give curated thresholds
that need no tuning.

This skill covers cluster (SLURM array, default for non-trivial inputs) and
local (single-input fallback). Templates live in `templates/`; reference
material (gotchas, common Pfam IDs, tool comparison) in `references/`.

---

## When to use HMMER vs BLAST vs PROST

| Tool | Best for | Sensitivity | Output |
|------|----------|-------------|--------|
| **BLAST** | Closely related sequences (>30% id), one-off lookups, "what is this" | Low for distant homologs | Pairwise hits |
| **HMMER** | Members of a **family** (Pfam-defined or custom), domain architecture, marker-gene extraction | Medium-high (~20–40% id with right profile) | Family/domain hits with curated GA cutoffs |
| **PROST** | Twilight-zone (<20% id), structural homology beyond sequence | Highest | Structural distance |

**Decision rule**: BLAST = "find this exact thing's matches". HMMER = "find members of this family". PROST = "find structurally similar proteins, sequence be damned".

See `references/tool_comparison.md` for the long-form discussion and worked examples.

---

## Quick Reference

| Component | Value |
|-----------|-------|
| CLI tools | `hmmscan`, `hmmsearch`, `hmmbuild`, `hmmpress`, `jackhmmer`, `phmmer` |
| Conda env | `hmmer_env` (HMMER 3.4+ and EMBOSS 6.6 for `transeq`) |
| Min version | HMMER 3.3+ |
| HMM cache | `${SHARED_DBS}/<hmm_set>/`; set the cache root explicitly |
| Activation | Initialize the existing Conda installation; load its site module only on clusters that require it, then activate `hmmer_env` |
| Output root | `outs/<area>/<XX_hmmer>/<input>/` |

---

## Tool selection: hmmscan vs hmmsearch vs others

| Command | Direction | Use when |
|---------|-----------|----------|
| `hmmscan` | queries (proteins) vs HMM database | You have **few queries**, **many HMMs** (e.g., one proteome × all of Pfam). Always pair with `hmmpress` on the HMM db. |
| `hmmsearch` | one HMM (or a few) vs sequence database | You have **few HMMs**, **many sequences** (e.g., extract one Pfam from many proteomes). Faster than hmmscan for this direction. |
| `phmmer` | single sequence vs sequence database | Like BLAST but profile-aware. Builds a profile from the query on the fly. Useful for one-off similarity searches with HMMER's statistics. |
| `jackhmmer` | iterative profile search | Build a profile by iterating phmmer + hmmbuild. Use when you have a single seed sequence and want to find distant homologs. |
| `hmmbuild` | MSA → profile HMM | Build a custom HMM from an aligned reference set. |
| `hmmpress` | binary-index a multi-HMM file | Required before `hmmscan`; once per HMM database. |

**Common mistake**: using `hmmscan` when `hmmsearch` is correct. If you have 4 HMMs and a 5M-peptide database, `hmmsearch` is much faster — the HMMs become the inner loop and the sequence DB streams once. `hmmscan` reverses it (database streams once, but per query you scan all 4 HMMs).

---

## Genetic-code & translation choices for nucleotide inputs

When searching a transcriptome / genome / IsoSeq dataset, you must translate to protein first. **Genetic code matters**:

| Source | Translation table | Why |
|--------|-------------------|-----|
| Cytoplasmic proteins (most cases) | **1** (standard) | Default for nuclear-encoded proteins. |
| Invertebrate mitochondrial (CO1/COX2/COX3/cyt-b in animals) | **5** | TGA codes for **Trp** in invertebrate mt, not stop. Using table 1 splits CO1 ORFs at every internal Trp → weakened HMM hits. |
| Vertebrate mitochondrial | **2** | Different deviations from standard. |
| Coelenterate mt (cnidarians, ctenophores; some demosponge lineages contested) | **4** | Mold/Protozoan/Coelenterate mt code. Like table 5 in that TGA = Trp, but differs at AGA/AGG (Arg, not Ser) and a few starts. Default for cnidarian mt; for non-demosponge sponge mt-genomes, check the literature. |
| Bacterial / archaeal | **11** | Alternative starts. |

**Translation strategy**:
- **6-frame raw** (`transeq -frame 6`): catches partial / fragmented ORFs from imperfect transcripts. HMMER 3 handles `*` (stop) and `X` (with `-clean`) characters natively. Best for IsoSeq / Trinity assemblies where ORF boundaries are uncertain.
- **ORF-bounded** (`getorf -find <N>`): cleaner peptides, but misses fragments. Best for polished proteomes.

For IsoSeq mt-marker extraction (the canonical use case for this skill), use `transeq -frame 6 -table <N> -clean`.

---

## Threshold strategy: GA cutoffs vs E-value

| Strategy | Flag | When to use |
|----------|------|-------------|
| **Pfam GA (gathering)** | `--cut_ga` | **Default for Pfam HMMs**. Curated per-family thresholds calibrated to capture real family members without false positives. No tuning needed. |
| Pfam TC (trusted) | `--cut_tc` | Stricter than GA; lowest-scoring true-positive hit. |
| Pfam NC (noise) | `--cut_nc` | More permissive than GA; highest-scoring known false-positive. |
| Manual E-value | `-E 1e-5` | Custom HMMs (no GA cutoff exists), or when GA is producing zero hits for a marker that should be present. |
| Per-domain | `--domE 1e-5` | Domain-level hits, complements `-E` (full-sequence). |

**Custom HMMs do not have GA cutoffs.** Use `-E` with a sensible threshold (`1e-5` to `1e-10` is typical) and inspect the score distribution.

---

## Workflow

Requires Research Core. Resolve bundled resources relative to this skill directory.
Set `SHARED_DBS` to the confirmed cache root in the project environment or source an
optional site profile that exports it before setup. Set `HMM_DB` to the chosen pressed
database before running; no personal path is assumed. Initialize the local Conda
installation before running setup on a laptop.

Before copying batch wrappers, adapt module and environment lines for the execution site.
`jobstats` is a scheduler-accounting example where available; use the site's equivalent otherwise.

A HMMER project has three phases — **setup**, **run**, **aggregate**.

Before copying or generating scripts, establish or reuse the project's chosen tool,
profiles/database, input type, threshold and (for nucleotide input) translation code.
The bundled run wrappers implement **hmmscan** and six-frame translation only. Use them
only when that recipe matches the agreed method; `hmmsearch`, `phmmer` and other routes
need their corresponding commands, not a renamed wrapper. Unresolved biological choices
return to the researcher before generation.

The wrappers require explicit `HMM_DB`, `INPUT_TYPE` and `THRESHOLD_FLAGS`; nucleotide
inputs also require `TRANSL_TABLE`. The setup's four mitochondrial profiles and the sponge
resource measurements are labelled examples, not defaults for arbitrary input.

### Phase 1 — Setup (one-time per cluster)

Creates the `hmmer_env` conda environment and downloads requested HMMs into the chosen cache:

```bash
bash batch/<area>/hmmer_setup.sh
```

The setup script (`templates/hmmer_setup.sh`):
- Creates `hmmer_env` from `templates/hmmer_environment.yml` if not present.
- Requires the chosen `HMM_SET_NAME` and `DB_FILENAME`; fill `MARKERS` with the current
  project's symbol:Pfam pairs before setup. The commented four-profile mt recipe is an example.
- Downloads HMMs from InterPro (`https://www.ebi.ac.uk/interpro/wwwapi/entry/pfam/<PFid>/?annotation=hmm`) into `${SHARED_DBS}/<hmm_set>/`.
- Concatenates them into one HMM database and runs `hmmpress`.

**Custom HMMs**: skip the InterPro download step and `hmmbuild` from your aligned MSA(s) instead. See `references/custom_hmms.md`.

### Phase 2 — Run

**Cluster (SLURM array, one task per input)**:

```bash
sbatch batch/<area>/hmmer_array.sh
```

The array script (`templates/hmmer_array.sh`):
- Reads `templates/hmmer_samples.tsv` (one row per input).
- Per task: optional `transeq` translation → `hmmscan` with the chosen threshold → tblout/domtblout.
- Writes parsed TSV at the end (transcript ID, frame, marker, E-value, score) for downstream aggregation.

Starting resources in the template: **4 CPUs, 8 GB RAM, 2.5 hr walltime** for a small profile database. These are unvalidated starting examples; choose the site's partition and check `jobstats <jobid>` on the first project run before scaling out.

**Tune CPU allocation for the chosen HMM database.** Parallelism can be limited with few HMMs; benchmark the actual profiles and input before increasing cores.

**Suppress alignment-text output.** Per-query alignment details can create large files. The template uses `-o /dev/null` because tblout + domtblout contain the fields used downstream. Switch to a real path when hand-inspecting alignments.

**Local (single input, no SLURM)**:

```bash
bash batch/<area>/hmmer_local.sh <input.fasta> <output_dir>
```

Same hmmscan recipe as the array, no scheduler. Set the chosen settings first, for example:

```bash
# Labelled invertebrate mitochondrial example: confirm profiles and code for this organism.
export HMM_DB="/chosen/cache/pfam_mt_markers/mt_markers.hmm"
export INPUT_TYPE=nucl TRANSL_TABLE=5 THRESHOLD_FLAGS="--cut_ga"
bash batch/<area>/hmmer_local.sh transcripts.fasta outs/<area>/fresh_mt_scan
```

Both run wrappers refuse an existing output directory before activating tools or translating.
Translated peptides stay inside that fresh directory, so separate runs cannot share a temporary filename.
Use a fresh directory, or preserve/clear the old one only after confirming it is disposable.
Custom HMM builds likewise refuse existing artifacts for the requested prefix. Setup preserves
an existing combined HMM database/index; reuse it or select a fresh set/filename.

### Phase 3 — Aggregate (local Quarto)

Each cluster task writes a parsed TSV (`<sample>.parsed.tsv`) — schema: `sample, marker, seq_id, frame, evalue, score, bias, orf_id`. The aggregator script lives **project-side**, not in the skill, because the join logic (sample metadata, FL counts, species labels, expression) is project-specific.

Typical structure:
- Read all `<sample>.parsed.tsv` into one long DataFrame.
- Join per-sample metadata.
- Optionally join external counts (e.g., FL counts at the transcript level).
- Output: per-marker hit counts wide table, top-N candidates per marker per sample, summary figure.

---

## Probe-first submission pattern

For any non-trivial array job, submit **one task first** and verify it completes cleanly before launching the rest:

```bash
sbatch --array=1 batch/<area>/hmmer_array.sh         # probe
# inspect outputs, then:
sbatch --array=2-N batch/<area>/hmmer_array.sh       # the rest
```

This catches fast-fail issues (translation crashing on weird headers, conda env misconfig, sample-sheet parse error) before they happen N times.

---

## Common gotchas

See `references/gotchas.md` for the full list. The big ones:

1. **HMM internal `NAME` ≠ Pfam family name on the website**: e.g., PF00033 ships with `NAME Cytochrome_B`, not `Cytochrom_B_N`. Hard-coded rename maps that key off the website name silently drop every hit. Always `grep '^NAME' <pfam>.hmm` after downloading. See `references/gotchas.md` for the full PF→NAME table and the symptom-first diagnostic recipe.
2. **`/` in IsoSeq3 headers**: HMMER + EMBOSS handle them fine (unlike BUSCO 6.x). No sanitization needed.
3. **Wrong genetic code**: see translation-table table above. Inverts ≠ verts ≠ standard.
4. **`hmmscan` vs `hmmsearch` direction**: pick whichever has the bigger thing as the streamed DB.
5. **`hmmpress` not run**: `hmmscan` errors out with `hmm_index_t: file not found`. Re-run setup.
6. **`--cut_ga` on a custom HMM**: silently zero hits. Custom HMMs have no GA cutoff; use `-E`.
7. **Profile vs full-sequence E-value**: `-E` filters at full-sequence; `--domE` at per-domain. For multi-domain proteins, the latter matters.

---

## Common Pfam IDs

Quick lookup for typical use cases. See `references/pfam_markers.md` for the
expanded list with notes on coverage and known caveats.

| Family | Pfam | Notes |
|--------|------|-------|
| CO1 | PF00115 | Cytochrome c oxidase subunit I (mt) |
| COX2 | PF00116 | Subunit II (mt) |
| COX3 | PF00510 | Subunit III (mt) |
| cyt-b | PF00033 | Cytochrome b N-terminal (mt) |
| Pkinase | PF00069 | Protein kinase domain (catalytic) |
| Pkinase_Tyr | PF07714 | Tyrosine kinase domain |
| 7tm_1 | PF00001 | Rhodopsin-family GPCR |
| HLH | PF00010 | bHLH transcription factor DBD |
| Homeobox | PF00046 | Homeodomain |
| zf-C2H2 | PF00096 | Classical zinc finger |
| Laminin_N | PF00055 | Laminin LN domain |
| Laminin_EGF | PF00053 | Laminin EGF-like repeat |
| EGF | PF00008 | EGF-like domain |
| Ig | PF00047 | Immunoglobulin V-set |
| NACHT | PF05729 | NACHT NTPase (NLR) |

---

## Templates

| File | Purpose |
|------|---------|
| `templates/hmmer_environment.yml` | Conda env: HMMER 3.4 + EMBOSS (transeq) |
| `templates/hmmer_setup.sh` | One-time: build conda env, download Pfam HMMs from InterPro, `hmmpress` |
| `templates/hmmer_samples.tsv` | Sample sheet (one row per input) |
| `templates/hmmer_array.sh` | SLURM array job — translation + hmmscan + parse tblout |
| `templates/hmmer_local.sh` | Single-input local fallback (no SLURM) |
| `templates/build_custom_hmm.sh` | Custom HMM build: MAFFT → trimAl → hmmbuild → optional control scan |

**Deferred**: a generic `hmmer_aggregate.qmd` template. Project-side aggregators have so much input-specific joining (FL counts, sample metadata, species labels) that we'll wait for the first project version to exist and decide whether to abstract it.

When using this skill, copy the templates into the project's `batch/<area>/`
and `scripts/<area>/`, fill in the project-specific bits (sample sheet, HMM
list, output paths), and submit after the method and settings are settled. Later runs
reuse the same environment and chosen HMM cache with a fresh output destination.

---

## References

| File | Topic |
|------|-------|
| `references/tool_comparison.md` | HMMER vs BLAST vs PROST — long-form, with worked examples |
| `references/gotchas.md` | Translation tables, threshold pitfalls, hmmscan/hmmsearch direction, custom HMM caveats |
| `references/pfam_markers.md` | Common Pfam IDs by use case (mt markers, kinases, TFs, GPCRs, ECM domains, NLRs) |
| `references/custom_hmms.md` | Building custom HMMs with `hmmbuild` from a curated MSA: when, how, threshold strategy |