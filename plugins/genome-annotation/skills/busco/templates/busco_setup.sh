#!/bin/bash
# One-time setup for BUSCO runs on the cluster.
# Run on a login node (no heavy compute — only conda env creation and lineage
# downloads from busco-data.ezlab.org).
#
# Usage:
#   bash batch/<area>/busco_setup.sh
#
# Edit LINEAGES below for your project's species. Lineages download once
# into the lab's shared cache so they're reusable across projects.

set -euo pipefail

# ── EDIT THIS LIST ───────────────────────────────────────────
# Choose the project's primary lineage; add a broader set only for an agreed comparison.
# Example for an appropriate animal assessment: LINEAGES=(metazoa_odb10)
# See SKILL.md "Lineage Selection"; dataset/tool versions are project choices.
LINEAGES=()
if [[ ${#LINEAGES[@]} -eq 0 ]]; then
  echo "ERROR: choose the project's lineage in LINEAGES before setup" >&2
  exit 1
fi
# ─────────────────────────────────────────────────────────────

BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

# Shared lab databases location (override-able via env var if needed)
SHARED_DBS="${SHARED_DBS:?ERROR: set SHARED_DBS to the chosen database cache root}"
LINEAGE_ROOT="$SHARED_DBS/busco_lineages"

# ---------------------------------------------------------------------------
# 1. Conda env
# ---------------------------------------------------------------------------
if command -v module >/dev/null 2>&1; then
  module load miniconda
fi
command -v conda >/dev/null 2>&1 || {
  echo "ERROR: initialize your existing Conda installation before setup" >&2
  exit 1
}
source "$(conda info --base)/etc/profile.d/conda.sh"

# Find this script's directory (where the environment.yml lives next to it)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/busco_environment.yml"

if conda env list | awk '{print $1}' | grep -qx "busco_env"; then
  echo "[setup] busco_env already exists — skipping create"
else
  echo "[setup] creating busco_env from $ENV_FILE"
  conda env create -f "$ENV_FILE"
fi

conda activate busco_env
echo "[setup] busco: $(busco --version)"

# ---------------------------------------------------------------------------
# 2. Lineage datasets — shared across lab projects
# ---------------------------------------------------------------------------
mkdir -p "$LINEAGE_ROOT"
cd "$LINEAGE_ROOT"

for L in "${LINEAGES[@]}"; do
  if [[ -d "$L" && -f "$L/lengths_cutoff" ]]; then
    echo "[setup] $L already present at $LINEAGE_ROOT/$L — skipping download"
    continue
  fi
  echo "[setup] downloading $L → $LINEAGE_ROOT"
  busco --download "$L" --download_path "$LINEAGE_ROOT"
  # busco places downloads in $LINEAGE_ROOT/lineages/$L — flatten:
  if [[ -d "$LINEAGE_ROOT/lineages/$L" ]]; then
    mv "$LINEAGE_ROOT/lineages/$L" "$LINEAGE_ROOT/$L"
    rmdir "$LINEAGE_ROOT/lineages" 2>/dev/null || true
  fi
done

echo "[setup] done. Lineages in: $LINEAGE_ROOT"
ls -lh "$LINEAGE_ROOT"