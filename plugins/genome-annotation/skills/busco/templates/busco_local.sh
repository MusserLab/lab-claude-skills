#!/bin/bash
# Local single-input BUSCO wrapper.
# Quick QC of one assembly/transcriptome/proteome without SLURM.
#
# Usage:
#   bash busco_local.sh <fasta> <lineage> <mode> [output_dir]
#
# Examples:
#   bash busco_local.sh assembly.fasta vertebrata_odb10 genome
#   bash busco_local.sh transcripts.fasta metazoa_odb10 transcriptome outs/qc
#   bash busco_local.sh proteins.faa eukaryota_odb10 proteins
#
# This script lives outside SLURM but uses the same FASTA-header sanitization
# as busco_array.sh so behavior matches.

set -euo pipefail

FASTA="${1:?ERROR: provide input FASTA as first argument}"
LINEAGE="${2:?ERROR: provide lineage as second argument (e.g. metazoa_odb10)}"
MODE="${3:?ERROR: provide mode as third argument (genome|transcriptome|proteins)}"
OUT_PARENT="${4:-outs/busco_local}"

case "$MODE" in
  genome|transcriptome|proteins) ;;
  *) echo "ERROR: invalid mode '$MODE'. Must be: genome, transcriptome, or proteins." >&2; exit 1 ;;
esac

# Activate env
if ! command -v busco >/dev/null 2>&1; then
  if command -v module >/dev/null 2>&1; then
    module load miniconda
  fi
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate busco_env
fi

# Lineage dir — shared cache (cluster) or project-local (laptop)
SHARED_DBS="${SHARED_DBS:?ERROR: set SHARED_DBS to the chosen database cache root}"
LINEAGE_DIR="$SHARED_DBS/busco_lineages/$LINEAGE"
if [[ ! -d "$LINEAGE_DIR" ]]; then
  # Fallback: try local project_busco_lineages/
  if [[ -d "busco_lineages/$LINEAGE" ]]; then
    LINEAGE_DIR="busco_lineages/$LINEAGE"
  else
    echo "ERROR: lineage $LINEAGE not found at $LINEAGE_DIR or busco_lineages/$LINEAGE" >&2
    echo "       Download it with: busco --download $LINEAGE --download_path busco_lineages" >&2
    exit 1
  fi
fi

INPUT_NAME=$(basename "$FASTA" | sed 's/\.[^.]*$//')
OUT_NAME="${INPUT_NAME}_${LINEAGE}"
if [[ -e "$OUT_PARENT/$OUT_NAME" ]]; then
  echo "ERROR: output exists: $OUT_PARENT/$OUT_NAME" >&2
  echo "Use a fresh name or preserve/clear it only after confirming it is disposable." >&2
  exit 1
fi
mkdir -p "$OUT_PARENT"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
SCRIPT_ABS="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"
BASEDIR=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)
case "$SCRIPT_ABS" in
  "$BASEDIR"/*) PROJECT_JOB=${SCRIPT_ABS#"$BASEDIR"/} ;;
  *) echo "ERROR: wrapper must be inside the project Git repository" >&2; exit 1 ;;
esac
# Add every project-local helper, small configuration and environment lock used by this run.
RELEVANT_PATHS=("$PROJECT_JOB")
ENV_LOCK="$(dirname "$PROJECT_JOB")/busco_environment.yml"
[[ -f "$BASEDIR/$ENV_LOCK" ]] && RELEVANT_PATHS+=("$ENV_LOCK")
GIT_COMMIT=$(git -C "$BASEDIR" rev-parse HEAD)
git -C "$BASEDIR" cat-file -e "${GIT_COMMIT}^{commit}"
for source_path in "${RELEVANT_PATHS[@]}"; do
  [[ -f "$BASEDIR/$source_path" ]] || { echo "ERROR: missing producing file: $source_path" >&2; exit 1; }
  committed_blob=$(git -C "$BASEDIR" rev-parse "${GIT_COMMIT}:${source_path}" 2>/dev/null) || {
    echo "ERROR: Relevant producing files do not match HEAD; make a focused commit before retained execution" >&2
    exit 1
  }
  working_blob=$(git -C "$BASEDIR" hash-object "$source_path")
  [[ "$committed_blob" == "$working_blob" ]] || {
    echo "ERROR: Relevant producing files do not match HEAD; make a focused commit before retained execution" >&2
    exit 1
  }
done
echo "Producing commit: $GIT_COMMIT"

# Sanitize headers
CLEAN_FASTA=$(mktemp "${TMPDIR:-/tmp}/${OUT_NAME}_clean.XXXXXX")
echo "[busco_local] sanitizing $FASTA -> $CLEAN_FASTA"
sed '/^>/ s|/|_|g' "$FASTA" > "$CLEAN_FASTA"
echo "[busco_local] $(grep -c '^>' "$CLEAN_FASTA") seqs"

CPU="${BUSCO_CPU:-4}"
echo "[busco_local] running BUSCO ($MODE, $LINEAGE, $CPU threads)"

busco \
  --in        "$CLEAN_FASTA" \
  --out       "$OUT_NAME" \
  --out_path  "$OUT_PARENT" \
  --mode      "$MODE" \
  --lineage_dataset "$LINEAGE_DIR" \
  --cpu       "$CPU" \
  --offline

# Show short summary
SHORT_SUMMARY=$(find "$OUT_PARENT/$OUT_NAME" -name "short_summary.specific.*.txt" 2>/dev/null | head -1)
if [[ -f "$SHORT_SUMMARY" ]]; then
  echo ""
  echo "=== BUSCO SHORT SUMMARY ==="
  cat "$SHORT_SUMMARY"
else
  echo "ERROR: BUSCO exited without its expected short summary" >&2
  exit 1
fi
SHORT_JSON=$(find "$OUT_PARENT/$OUT_NAME" -name "short_summary.specific.*.json" 2>/dev/null | head -1)
[[ -f "$SHORT_JSON" ]] || { echo "ERROR: BUSCO summary JSON is missing" >&2; exit 1; }

# Cleanup the task-local input before writing the completion record as the final action.
rm -f "$CLEAN_FASTA"
for source_path in "${RELEVANT_PATHS[@]}"; do
  [[ "$(git -C "$BASEDIR" hash-object "$source_path")" == \
      "$(git -C "$BASEDIR" rev-parse "${GIT_COMMIT}:${source_path}")" ]] || {
    echo "ERROR: Relevant producing files changed during execution" >&2
    exit 1
  }
done
{
  printf 'completion: complete\n'
  printf 'script: %s\n' "$PROJECT_JOB"
  printf 'date: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'commit: %s\n' "$GIT_COMMIT"
  printf 'invocation: busco --in <sanitized %s> --out %s --mode %s --lineage_dataset %s --cpu %s --offline\n' \
    "$FASTA" "$OUT_NAME" "$MODE" "$LINEAGE_DIR" "$CPU"
  printf 'input: %s | bytes=%s\n' "$FASTA" "$(wc -c <"$FASTA" | tr -d ' ')"
  printf 'environment: %s | busco=%s\n' "${CONDA_DEFAULT_ENV:-unknown}" "$(busco --version 2>&1 | head -1)"
  for source_path in "${RELEVANT_PATHS[@]}"; do
    printf 'source: %s | content verified against commit\n' "$source_path"
  done
  printf 'output: %s\n' "$OUT_PARENT/$OUT_NAME"
} >"$OUT_PARENT/$OUT_NAME/BUILD_INFO.txt"
