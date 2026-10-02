#!/bin/bash
# Resource sizing: 4 CPUs, 8G RAM and 2.5h are unvalidated starting examples
# for a small HMM database. Choose the site's partition and benchmark the actual
# profiles/input with jobstats before scaling out or increasing cores.
# Larger profile databases or inputs may need different resources.
# See references/gotchas.md "CPU allocation" for tuning guidance.
#SBATCH --job-name=hmmer
#SBATCH --partition=YOUR_PARTITION  # EDIT for the execution site
#SBATCH --time=2:30:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --array=1-N                           # EDIT: match number of rows in samples.tsv
#SBATCH --output=logs/slurm-hmmer-%A_%a.out
#SBATCH --mail-type=BEGIN,END,FAIL,ARRAY_TASKS
#SBATCH --mail-user=YOUR_EMAIL       # EDIT
#
# Generic HMMER scan template. Per task (one per input):
#   1. (Optional) transeq -frame 6 with chosen genetic code if input is nucleotide
#   2. hmmscan against a pressed HMM database with chosen threshold
#   3. Parsed TSV at the end (sample, marker, transcript_id, frame, evalue, score)
#
# Probe-first workflow: submit `--array=1` first, verify clean output, then submit `--array=2-N`.

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# EDIT: project-specific settings
# ─────────────────────────────────────────────────────────────
# Choose these for the current project before running; no biological defaults.
HMM_DB="${HMM_DB:?ERROR: set HMM_DB to the chosen pressed HMM database}"
INPUT_TYPE="${INPUT_TYPE:?ERROR: set INPUT_TYPE to nucl or prot}"
THRESHOLD_FLAGS="${THRESHOLD_FLAGS:?ERROR: set THRESHOLD_FLAGS for the chosen profiles}"
case "$INPUT_TYPE" in
  nucl) TRANSL_TABLE="${TRANSL_TABLE:?ERROR: set TRANSL_TABLE for the nucleotide source}" ;;
  prot) TRANSL_TABLE="${TRANSL_TABLE:-}" ;;
  *) echo "ERROR: INPUT_TYPE must be 'nucl' or 'prot' (got '$INPUT_TYPE')" >&2; exit 1 ;;
esac
read -r -a THRESHOLD_ARGS <<< "$THRESHOLD_FLAGS"
SAMPLES="batch/<area>/hmmer_samples.tsv"  # EDIT
OUT_BASE="outs/<area>/<XX_hmmer>"       # EDIT — per-sample subdirs created below
# ─────────────────────────────────────────────────────────────

# Provenance
BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"
echo "=== PROVENANCE ==="
echo "Job ID:      $SLURM_JOB_ID"
echo "Array task:  $SLURM_ARRAY_TASK_ID"
echo "Script:      $0"
echo "Git hash:    $(git rev-parse HEAD)"
echo "Git dirty:   $(git status --porcelain | head -5)"
echo "Date:        $(date -Iseconds)"
echo "Node:        $(hostname)"

# Read this task's row
LINE=$((SLURM_ARRAY_TASK_ID + 1))
read -r TASK_ID SAMPLE_ID INPUT_FASTA < <(sed -n "${LINE}p" "$SAMPLES")
if [[ -z "${SAMPLE_ID:-}" || -z "${INPUT_FASTA:-}" ]]; then
  echo "ERROR: could not parse line $LINE of $SAMPLES" >&2
  exit 1
fi
echo ""
echo "Task:        $TASK_ID"
echo "Sample:      $SAMPLE_ID"
echo "Input:       $INPUT_FASTA"

# Sanity checks
[[ -f "$INPUT_FASTA" ]] || { echo "ERROR: $INPUT_FASTA not found" >&2; exit 1; }
[[ -f "${HMM_DB}.h3i" ]] || { echo "ERROR: $HMM_DB not pressed. Run hmmer_setup.sh." >&2; exit 1; }

OUT_DIR="$OUT_BASE/$SAMPLE_ID"
if [[ -e "$OUT_DIR" || -L "$OUT_DIR" ]]; then
  echo "ERROR: output exists: $OUT_DIR" >&2
  echo "Use a fresh directory or preserve/clear it only after confirming it is disposable." >&2
  exit 1
fi

module purge
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hmmer_env
echo "Conda env:   $CONDA_DEFAULT_ENV"
echo "hmmscan:     $(hmmscan -h | head -2 | tail -1)"
echo "transeq:     $(transeq -version 2>&1 | head -1)"
echo "Input type:  $INPUT_TYPE"
echo "Transl tbl:  $TRANSL_TABLE"
echo "Threshold:   $THRESHOLD_FLAGS"
echo "=== END PROVENANCE ==="
mkdir -p "$OUT_DIR"

# ── Translation (if nucleotide input) ────────────────────────
if [[ "$INPUT_TYPE" == "nucl" ]]; then
  PEP="$OUT_DIR/${SAMPLE_ID}_6frame_t${TRANSL_TABLE}.fasta"
  echo ""
  echo "=== transeq -frame 6 -table $TRANSL_TABLE ==="
  SECONDS=0
  transeq -sequence "$INPUT_FASTA" -outseq "$PEP" -frame 6 -table "$TRANSL_TABLE" -clean
  echo "Translated:  $(grep -c '^>' "$PEP") peptides → $PEP (${SECONDS}s)"
elif [[ "$INPUT_TYPE" == "prot" ]]; then
  PEP="$INPUT_FASTA"
  echo ""
  echo "Skipping translation (INPUT_TYPE=prot)"
else
  echo "ERROR: INPUT_TYPE must be 'nucl' or 'prot' (got '$INPUT_TYPE')" >&2
  exit 1
fi

# ── hmmscan ──────────────────────────────────────────────────
TBLOUT="$OUT_DIR/${SAMPLE_ID}.tblout"
DOMTBL="$OUT_DIR/${SAMPLE_ID}.domtblout"

# -o /dev/null — per-query alignment text is multi-GB on large peptide inputs
# and is rarely used; tblout + domtblout already carry everything for downstream
# analysis. Use -o "$OUT_DIR/${SAMPLE_ID}.hmmscan.log" only when you need to
# inspect alignments by hand.
echo ""
echo "=== hmmscan $THRESHOLD_FLAGS ==="
SECONDS=0
hmmscan \
  --cpu       "$SLURM_CPUS_PER_TASK" \
  "${THRESHOLD_ARGS[@]}" \
  --tblout    "$TBLOUT" \
  --domtblout "$DOMTBL" \
  -o          /dev/null \
  "$HMM_DB" "$PEP"
echo "hmmscan took ${SECONDS}s"

# ── Parse tblout into a tidy TSV ─────────────────────────────
# transeq emits headers like "<transcript_id>_<frame>" (frame 1..6).
# For prot input, the "_<frame>" suffix won't be present and the regex falls back.
#
# IMPORTANT — HMM target names: tblout target_name is the HMM file's internal
# NAME field, set by InterPro at download time, which is NOT always the same
# as Pfam's canonical family name on its website. Always run
# `grep '^NAME' <pfam>.hmm` after downloading and put the actual NAME in your
# rename map. Examples: PF00115→COX1, PF00116→COX2, PF00510→COX3,
# PF00033→Cytochrome_B (NOT Cytochrom_B_N), PF00069→Pkinase, PF07714→Pkinase_Tyr.
PARSED="$OUT_DIR/${SAMPLE_ID}.parsed.tsv"
echo ""
echo "=== Parsing $TBLOUT → $PARSED ==="
python - <<PYEOF
import re, sys
from pathlib import Path
from collections import Counter

tblout = Path("$TBLOUT")
out    = Path("$PARSED")
sample = "$SAMPLE_ID"
input_type = "$INPUT_TYPE"

rows = []
with tblout.open() as fh:
    for line in fh:
        if line.startswith("#") or not line.strip():
            continue
        parts = line.split(maxsplit=18)
        target, _, query, _, evalue, score, bias = parts[:7]
        if input_type == "nucl":
            m = re.match(r"^(.+)_([1-6])$", query)
            if m:
                seq_id, frame = m.group(1), int(m.group(2))
            else:
                print(f"WARN: cannot parse query '{query}'", file=sys.stderr)
                seq_id, frame = query, 0
        else:
            seq_id, frame = query, 0
        rows.append((sample, target, seq_id, frame, evalue, score, bias, query))

rows.sort(key=lambda r: (r[1], float(r[4])))
with out.open("w") as fh:
    fh.write("sample\tmarker\tseq_id\tframe\tevalue\tscore\tbias\torf_id\n")
    for r in rows:
        fh.write("\t".join(map(str, r)) + "\n")

print(f"Wrote {len(rows)} hits → {out}")
counts = Counter(r[1] for r in rows)
print("Per-marker hit counts:")
for m, n in sorted(counts.items()):
    print(f"  {m}: {n}")
PYEOF

echo ""
echo "=== Completed sample $SAMPLE_ID ==="
ls -lh "$OUT_DIR"