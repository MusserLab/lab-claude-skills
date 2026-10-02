#!/bin/bash
# Single-input HMMER fallback (no SLURM). Same logic as hmmer_array.sh, run
# directly on the current node. Use for local quick checks when you have one
# input and don't want to deal with the cluster.
#
# Usage:
#   bash hmmer_local.sh <input.fasta> <out_dir> [<sample_id>]

set -euo pipefail

INPUT_FASTA="${1:?usage: hmmer_local.sh <input.fasta> <out_dir> [sample_id]}"
OUT_DIR="${2:?usage: hmmer_local.sh <input.fasta> <out_dir> [sample_id]}"
SAMPLE_ID="${3:-$(basename "${INPUT_FASTA%.*}")}"

# ─────────────────────────────────────────────────────────────
# EDIT: project-specific settings (or pass via environment)
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
N_CPU="${N_CPU:-4}"
# ─────────────────────────────────────────────────────────────

[[ -f "$INPUT_FASTA" ]] || { echo "ERROR: $INPUT_FASTA not found" >&2; exit 1; }
[[ -f "${HMM_DB}.h3i" ]] || { echo "ERROR: $HMM_DB not pressed" >&2; exit 1; }

# Refuse occupied run output before environment activation or translation.
if [[ -e "$OUT_DIR" || -L "$OUT_DIR" ]]; then
  echo "ERROR: output exists: $OUT_DIR" >&2
  echo "Use a fresh directory or preserve/clear it only after confirming it is disposable." >&2
  exit 1
fi
mkdir -p "$OUT_DIR"

# Activate hmmer_env (cluster: module load; local: assume it's on PATH)
if command -v module >/dev/null 2>&1; then
  module load miniconda
fi
if command -v conda >/dev/null 2>&1; then
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate hmmer_env
fi

if [[ "$INPUT_TYPE" == "nucl" ]]; then
  PEP="$OUT_DIR/${SAMPLE_ID}_6frame_t${TRANSL_TABLE}.fasta"
  echo "transeq -frame 6 -table $TRANSL_TABLE → $PEP"
  transeq -sequence "$INPUT_FASTA" -outseq "$PEP" -frame 6 -table "$TRANSL_TABLE" -clean
  echo "Translated $(grep -c '^>' "$PEP") peptides"
else
  PEP="$INPUT_FASTA"
fi

TBLOUT="$OUT_DIR/${SAMPLE_ID}.tblout"
DOMTBL="$OUT_DIR/${SAMPLE_ID}.domtblout"
LOG="$OUT_DIR/${SAMPLE_ID}.hmmscan.log"

echo "hmmscan $THRESHOLD_FLAGS → $TBLOUT"
hmmscan \
  --cpu       "$N_CPU" \
  "${THRESHOLD_ARGS[@]}" \
  --tblout    "$TBLOUT" \
  --domtblout "$DOMTBL" \
  -o          "$LOG" \
  "$HMM_DB" "$PEP"

echo "Done. Hits per marker:"
awk '!/^#/ && NF{print $1}' "$TBLOUT" | sort | uniq -c