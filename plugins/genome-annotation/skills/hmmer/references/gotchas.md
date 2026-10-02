# HMMER gotchas

Common issues and diagnostic lessons for HMMER pipelines.

## Translation table mismatches

Wrong genetic code → silently weakened HMM hits. The classic mistake is using
default table 1 (standard) for invertebrate mitochondrial markers.

| Source | Table | Symptom of using wrong table |
|--------|-------|------------------------------|
| Cytoplasmic proteins | 1 | None — this is the default |
| Invertebrate mt (animals incl. sponges) | **5** | TGA = Trp in inverts, but Stop in standard. Table 1 splits CO1/COX2/COX3/cyt-b ORFs at every internal Trp → fragmented peptides → weakened hmmscan scores. |
| Vertebrate mt | 2 | Different deviations from standard |
| Coelenterate mt (cnidarians, ctenophores; some demosponge lineages contested) | 4 | Like table 5 (TGA = Trp), but AGA/AGG = Arg (not Ser). Default for cnidarian mt-genomes. Check the literature for non-demosponge sponge mt. |
| Bacterial / archaeal | 11 | Alternative starts |

For IsoSeq mt-marker extraction, select the translation code for the organism and sequence source,
then use `transeq -frame 6 -table <chosen_code>`. Table 5 is a labelled invertebrate
mitochondrial example only when that code applies; it is not universal across animals.

## hmmscan vs hmmsearch direction

`hmmscan` scans **queries against an HMM database**. `hmmsearch` scans **HMMs
against a sequence database**. Same math, different inner loop:

- **`hmmscan`**: outer loop is queries, inner loop is HMMs. Best when **few queries, many HMMs** (annotating a single proteome with all of Pfam-A).
- **`hmmsearch`**: outer loop is HMMs, inner loop is sequences. Best when **few HMMs, many sequences** (extract one Pfam family from many proteomes).

With few HMMs and many sequences, consider the `hmmsearch` route and its
HMM-query output structure. With `hmmscan`, queries are sequences and targets
are HMM profiles. Choose the direction and parser together for the project;
benchmark the chosen recipe on its actual input.

Either way: pre-`hmmpress` the HMM database — both commands need the binary
indices.

## `--cut_ga` on a custom HMM = silent zero hits

Pfam HMMs carry GA / TC / NC cutoff lines in their headers. Custom HMMs built
with `hmmbuild` have **no GA cutoff** by default. Using `--cut_ga` against a
custom HMM passes silently and returns zero hits.

Fix: use `-E 1e-5` (full-sequence E-value) or `--domE 1e-5` (per-domain) for
custom HMMs. Inspect score distributions to pick a sensible cutoff, then
optionally edit the HMM file's `GA` / `TC` / `NC` lines if you want to bake the
threshold in.

## `transeq -clean` semantics

EMBOSS `-clean` replaces stop codons (`*`) with `X`, not "removes them". HMMER 3
handles both fine. The misleading note in some scripts ("stops emitted as `*`")
is stale documentation; if you use `-clean`, expect `X`.

## Profile vs full-sequence E-value (`-E` vs `--domE`)

`-E` filters at the **full sequence level** (best score over the whole
protein). `--domE` filters at the **per-domain level**. For multi-domain
proteins where one domain is well-conserved and the rest are noise, `-E` may
miss real hits that `--domE` catches.

Defaults:
- `-E 10` (very permissive — keeps anything with score above noise)
- `--domE 10` (same)
- `--cut_ga` overrides both with the curated Pfam cutoff.

For one-off searches, `-E 1e-5` (sequence) and `--domE 1e-3` (domain) are
sensible starting points.

## `hmmpress` not run

`hmmscan` errors out with `hmm_index_t: file not found` if the HMM database
hasn't been pressed. `hmmpress` produces 4 binary index files (`.h3m`, `.h3i`,
`.h3f`, `.h3p`); all must be present. If you regenerate the combined HMM file,
delete the old indices first.

## IsoSeq3 `/` characters in headers

Unlike BUSCO 6.x, **HMMER and EMBOSS handle `/` in FASTA headers fine**. No
sanitization needed. If you sanitized for BUSCO, you can use the same FASTA
for HMMER too — just keep in mind that downstream parsers may need to know
whether headers were rewritten.

## `transeq` silent on protein input

If you accidentally pass a protein FASTA to `transeq -frame 6`, it produces
no output and exits silently. Always check that `INPUT_TYPE=nucl` matches the
actual file. The local template guards against this by checking
`grep -c '^>' "$PEP"` is non-zero.

## Combined-HMM ordering matters for tblout

`hmmscan` reports hits in the order they appear in the HMM database file. If
you `cat A.hmm B.hmm > combined.hmm`, the tblout for a query that hits both
will list A's hit first. This shouldn't affect downstream processing if you
join by target name, but is worth knowing if you're eyeballing the raw output.

## Inflated E-values for huge sequence databases

E-value scales with database size. Searching a 6-frame translation of a
million-transcript IsoSeq dataset (~6M peptides) gives much larger E-values
for a real hit than searching SwissProt (~500K). Use `--cut_ga` (Pfam-curated,
size-independent) when possible. With manual `-E`, scale with database size or
use score cutoffs instead.

## Memory for hmmsearch on large databases

`hmmsearch` with a multi-HMM file and a large sequence database can use
several GB of RAM. Treat 8 GB as an unvalidated starting example and check
project jobstats before extending the run set.

## `-o <log>` writes multi-GB alignment text on large inputs

`hmmscan` and `hmmsearch` write alignment details to the path passed via
`-o`; large translated inputs can produce large files. The `tblout` and
`domtblout` contain the fields used downstream (target, query, E-value,
score, bias and domain coordinates).

Use `-o /dev/null` unless you specifically plan to inspect alignments by hand.
Switch to `--noali` if you want a small human-readable summary without the
per-residue alignment text.

## CPU allocation for small HMM databases

Parallelism can be limited with few HMMs. Four cores is an unvalidated starting
example; check project jobstats and benchmark the actual HMM database before
increasing cores. Input size alone does not establish useful CPU allocation.

## HMM internal NAME ≠ Pfam family name on the website

The `target_name` column in `hmmscan` tblout (or `query_name` in `hmmsearch`
tblout) is the **HMM file's internal `NAME` field**, set by InterPro when
the HMM was prepared. It is NOT always identical to Pfam's canonical family
name as listed on its website. The most painful example:

- Pfam website lists **PF00033** as `Cytochrom_B_N`.
- The HMM downloaded from `interpro/wwwapi/entry/pfam/PF00033/?annotation=hmm`
  has `NAME  Cytochrome_B`.

If your downstream parser maps `target_name` → short symbol with a hard-coded
table (e.g. `{"Cytochrom_B_N": "cytb"}`), the real hits fall through and look
like zero. For example, `Cytochrome_B` hits remain unmapped when the parser
expects only the website's `Cytochrom_B_N` name. Check actual NAME values
before treating a missing parsed marker as biological absence.

**Always run** `grep '^NAME' <pfam>.hmm` after downloading and put the
**actual NAME** (not the website family name) in your rename map. Confirmed
NAME fields for common mt markers from InterPro:

| Pfam | Pfam website name | Actual HMM NAME |
|------|-------------------|-----------------|
| PF00115 | Cytochrome_C_Oxidase | `COX1` |
| PF00116 | COX2 | `COX2` |
| PF00510 | COX3 | `COX3` |
| PF00033 | Cytochrom_B_N | **`Cytochrome_B`** |
| PF00032 | Cytochrom_B_C | `Cytochrom_B_C` |
| PF00069 | Pkinase | `Pkinase` |
| PF07714 | PK_Tyr_Ser-Thr | `Pkinase_Tyr` |

Defensive parsing: if you see `UNMAPPED:` or unexpectedly missing markers in
your per-marker counts, dump the unique `target_name` values from the tblout
(`awk '!/^#/{print $1}' tblout | sort -u`) and update the map.

**Diagnostic recipe — symptom-first.** If your parser reports zero hits for a
marker that should be present, *don't* re-run hmmscan. Instead, submit a small
`hmmsearch -E 10` probe job (very permissive threshold) directly against the
existing pressed HMM database and dump unique target/query name values:

```
hmmsearch -E 10 --tblout probe.tblout pfam_db.hmm <peptides.fasta>
# hmmsearch tblout: query_name is column 3
awk '!/^#/{print $3}' probe.tblout | sort -u
# hmmscan  tblout: target_name is column 1
awk '!/^#/{print $1}' tblout | sort -u
```

If the probe shows hits with NAME values your parser doesn't map (e.g.,
`Cytochrome_B` vs your hard-coded `Cytochrom_B_N`), the original tblout
already contains those hits — just re-parse with the corrected NAME map.
**No hmmscan re-run needed.**

Use a small representative probe and size its resources for the current input.
Compare its NAME values with the original tblout and parser map; preserve
unmapped hits explicitly rather than silently dropping them.