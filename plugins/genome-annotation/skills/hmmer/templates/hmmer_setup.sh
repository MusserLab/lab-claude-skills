#!/bin/bash
# One-time setup for HMMER scans on the cluster.
# Run on a login node (small downloads + conda env build, no heavy compute).
#
# Usage:
#   bash batch/<area>/hmmer_setup.sh
#
# What it does:
#   1. Create conda env `hmmer_env` from environment.yml (or skip if present).
#   2. Download requested Pfam HMMs from InterPro into the lab shared databases
#      location, concatenate into one HMM file, and `hmmpress` it.
#
# Customize the `MARKERS` array below for your project. Each entry maps a short
# symbol → Pfam accession. The commented four-profile mitochondrial example
# (CO1/COX2/COX3/cyt-b) requires confirmation for the current project.

set -euo pipefail

BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

# ── EDIT: project-specific HMM set ──────────────────────────
# Fill the symbol:Pfam pairs for this project. Indexed arrays work in macOS Bash 3.2.
MARKERS=()
# Labelled invertebrate mitochondrial example, only after confirming its fit:
# HMM_SET_NAME="pfam_mt_markers"
# DB_FILENAME="mt_markers.hmm"
# MARKERS=(co1:PF00115 co2:PF00116 co3:PF00510 cytb:PF00033)
HMM_SET_NAME="${HMM_SET_NAME:?ERROR: set HMM_SET_NAME for the chosen profiles}"
DB_FILENAME="${DB_FILENAME:?ERROR: set DB_FILENAME for the combined profiles}"
if [[ ${#MARKERS[@]} -eq 0 ]]; then
  echo "ERROR: fill MARKERS with the project's chosen symbol:Pfam pairs" >&2
  exit 1
fi
# ────────────────────────────────────────────────────────────

SHARED_DBS="${SHARED_DBS:?ERROR: set SHARED_DBS to the chosen database cache root}"
HMM_DIR="$SHARED_DBS/$HMM_SET_NAME"
DB="$HMM_DIR/$DB_FILENAME"
# Preserve an existing combined database/index; use it or choose a fresh destination.
for artifact in "$DB" "${DB}.h3f" "${DB}.h3i" "${DB}.h3m" "${DB}.h3p"; do
  if [[ -e "$artifact" || -L "$artifact" ]]; then
    echo "ERROR: output exists: $artifact" >&2
    echo "Use the installed database or choose a fresh HMM set/filename." >&2
    exit 1
  fi
done

# 1. Conda env
if command -v module >/dev/null 2>&1; then
  module load miniconda
fi
command -v conda >/dev/null 2>&1 || {
  echo "ERROR: initialize your existing Conda installation before setup" >&2
  exit 1
}
source "$(conda info --base)/etc/profile.d/conda.sh"

if conda env list | awk '{print $1}' | grep -qx "hmmer_env"; then
  echo "[setup] hmmer_env already exists — skipping create"
else
  echo "[setup] creating hmmer_env from environment.yml"
  conda env create -f "$(dirname "$0")/hmmer_environment.yml"
fi

conda activate hmmer_env
echo "[setup] hmmer:  $(hmmscan -h | head -2 | tail -1)"
echo "[setup] emboss: $(transeq -version 2>&1 | head -1)"

# 2. Download HMMs from InterPro
mkdir -p "$HMM_DIR"
cd "$HMM_DIR"

for marker in "${MARKERS[@]}"; do
  SYM=${marker%%:*}
  PF=${marker#*:}
  HMM_FILE="${PF}.hmm"
  if [[ -s "$HMM_FILE" ]]; then
    echo "[setup] $PF ($SYM) already present"
    continue
  fi
  URL="https://www.ebi.ac.uk/interpro/wwwapi/entry/pfam/${PF}/?annotation=hmm"
  echo "[setup] downloading $PF ($SYM) from InterPro"
  curl -fsSL "$URL" -o "${PF}.hmm.gz"
  gunzip -f "${PF}.hmm.gz"
  if ! head -1 "$HMM_FILE" | grep -q "^HMMER3"; then
    echo "[setup] ERROR: $HMM_FILE is not a valid HMMER3 file" >&2
    head -3 "$HMM_FILE" >&2
    exit 1
  fi
done

# 3. Combine + hmmpress
echo "[setup] concatenating HMMs → $DB"
: > "$DB"
for marker in "${MARKERS[@]}"; do
  PF=${marker#*:}
  cat "${PF}.hmm" >> "$DB"
done

echo "[setup] hmmpress $DB"
hmmpress "$DB"

echo "[setup] done."
ls -lh "$HMM_DIR"