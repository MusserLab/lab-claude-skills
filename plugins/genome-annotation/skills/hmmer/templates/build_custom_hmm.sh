#!/bin/bash
# Build a custom HMM from a curated reference FASTA.
#
# Pipeline:
#   1. MAFFT alignment        (--auto picks reasonable strategy by size)
#   2. trimAl trimming        (-gappyout removes gappy/poorly-conserved cols)
#   3. hmmbuild                (writes the profile HMM)
#   4. (optional) hmmpress     (only needed if you'll use it with hmmscan)
#   5. (optional) sanity scan  (run hmmsearch against a control proteome)
#
# Custom HMMs do NOT have Pfam GA cutoffs — use `-E` thresholds with hmmsearch
# and inspect the score distribution to pick a sensible cutoff.
#
# Prereq conda env: `hmmer_env` (built by hmmer_setup.sh) — already includes
# HMMER, EMBOSS, MAFFT, and trimAl. No extra installs needed.
#
# Usage:
#   bash build_custom_hmm.sh <reference.fasta> <output_prefix> [<control_proteome.fasta>]
#
# Outputs:
#   <prefix>.aln           MAFFT alignment
#   <prefix>.trim.aln      trimAl-trimmed alignment
#   <prefix>.hmm           the profile HMM
#   <prefix>.scan.tblout   (if control proteome given) hits in the control

set -euo pipefail

REF_FASTA="${1:?usage: build_custom_hmm.sh <reference.fasta> <out_prefix> [control.fasta]}"
PREFIX="${2:?usage: build_custom_hmm.sh <reference.fasta> <out_prefix> [control.fasta]}"
CONTROL="${3:-}"

[[ -f "$REF_FASTA" ]] || { echo "ERROR: $REF_FASTA not found" >&2; exit 1; }

# Every artifact belongs to this prefix; a rerun needs a fresh prefix.
for suffix in aln trim.aln hmm hmm.h3f hmm.h3i hmm.h3m hmm.h3p scan.tblout scan.log; do
  if [[ -e "${PREFIX}.${suffix}" || -L "${PREFIX}.${suffix}" ]]; then
    echo "ERROR: output exists: ${PREFIX}.${suffix}" >&2
    echo "Use a fresh prefix or preserve/clear it only after confirming it is disposable." >&2
    exit 1
  fi
done

if command -v conda >/dev/null 2>&1; then
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate hmmer_env
fi

ALN="${PREFIX}.aln"
TRIM="${PREFIX}.trim.aln"
HMM="${PREFIX}.hmm"

echo "[1/4] mafft --auto $REF_FASTA → $ALN"
mafft --auto --thread -1 "$REF_FASTA" > "$ALN"

echo "[2/4] trimal -gappyout $ALN → $TRIM"
trimal -in "$ALN" -out "$TRIM" -gappyout

# Sanity: trimAl can over-trim small alignments. If <50 columns remain, warn.
N_COL=$(awk '/^>/{next} {print length($0); exit}' "$TRIM")
echo "       Trimmed alignment: $N_COL columns"
if [[ "$N_COL" -lt 50 ]]; then
  echo "       WARN: <50 columns after trimming. Consider -nogaps or skipping trim." >&2
fi

echo "[3/4] hmmbuild $HMM $TRIM"
hmmbuild "$HMM" "$TRIM"

if [[ -n "$CONTROL" && -f "$CONTROL" ]]; then
  echo "[4/4] hmmsearch -E 1e-5 $HMM $CONTROL → ${PREFIX}.scan.tblout"
  hmmsearch \
    --cpu 4 \
    -E 1e-5 \
    --tblout "${PREFIX}.scan.tblout" \
    "$HMM" "$CONTROL" > "${PREFIX}.scan.log"
  N_HITS=$(awk '!/^#/ && NF' "${PREFIX}.scan.tblout" | wc -l)
  echo "       Found $N_HITS hits in control proteome (E < 1e-5)"
  echo "       Inspect score distribution:"
  awk '!/^#/ && NF{print $5}' "${PREFIX}.scan.tblout" | sort -g | head -5
  echo "       (top 5 E-values; calibrate threshold from full distribution)"
else
  echo "[4/4] No control proteome provided; skipping sanity scan."
fi

echo ""
echo "Done. Custom HMM at $HMM"
echo "To use with hmmsearch (recommended for one-HMM searches):"
echo "  hmmsearch -E 1e-5 --tblout out.tbl $HMM <target_proteome.fasta>"
echo "To use with hmmscan (slow for one HMM; better when scanning many):"
echo "  hmmpress $HMM"
echo "  hmmscan -E 1e-5 --tblout out.tbl $HMM <queries.fasta>"