#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=YOUR_PARTITION  # EDIT for the execution site
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --array=1-N            # ← EDIT to match number of data rows in busco_samples.tsv
#SBATCH --output=logs/slurm-busco-%A_%a.out
#SBATCH --mail-type=BEGIN,END,FAIL,ARRAY_TASKS
#SBATCH --mail-user=YOUR_EMAIL
#
# ── PER-MODE TUNING ───────────────────────────────────────────
# These SBATCH defaults are unvalidated starting examples for TRANSCRIPTOME mode; check project jobstats.
# Use a separate sample sheet and output root per mode for aggregation.
# For a genome or proteins sheet, update these SBATCH headers to match.
# BUSCO still reads the per-task `mode` column; the aggregator rejects mixed modes.
#
# Genome (small <500 Mb):    --time=12:00:00 --cpus-per-task=16 --mem=32G
# Genome (medium 0.5–2 Gb):  --time=24:00:00 --cpus-per-task=16 --mem=64G
# Genome (large >2 Gb):      --time=48:00:00 --cpus-per-task=32 --mem=128G  (use a suitable long-job partition)
# Proteins:                  --time=2:00:00  --cpus-per-task=8  --mem=16G
# ──────────────────────────────────────────────────────────────
#
# BUSCO array job. One task per (input × lineage) combination.
# Sample sheet: batch/<area>/busco_samples.tsv (task_id, input, species,
#   lineage, mode, fasta_path)
#
# Pre-requisites:
#   - Run batch/<area>/busco_setup.sh first (creates conda env + lineages)
#   - Update --array=1-N to match data row count
#   - Update --mail-user
#
# Submit:
#   cd <project_root>
#   mkdir -p logs
#   EXPECTED_COMMIT=$(git rev-parse HEAD)
#   sbatch --export=ALL,EXPECTED_COMMIT="$EXPECTED_COMMIT" batch/<area>/busco_array.sh

set -euo pipefail

# ── Provenance ───────────────────────────────────────────────
BASEDIR=$(git rev-parse --show-toplevel)
cd "$BASEDIR"

echo "=== PROVENANCE ==="
echo "Job ID:      $SLURM_JOB_ID"
echo "Array task:  $SLURM_ARRAY_TASK_ID"
echo "Script:      $0"
echo "Date:        $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Node:        $(hostname)"

module purge
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate busco_env
echo "Conda env:   $CONDA_DEFAULT_ENV"
echo "busco:       $(busco --version)"
echo "=== END PROVENANCE ==="

# ── Read this task's row from the sample sheet ───────────────
# EDIT this path to point at your project's sample sheet
SAMPLES="batch/<area>/busco_samples.tsv"

# Declare every project-local producer, wrapper, helper, small configuration and environment lock.
PROJECT_JOB="batch/<area>/busco_array.sh"
ENV_LOCK="batch/<area>/busco_environment.yml"
RELEVANT_PATHS=("$PROJECT_JOB" "$SAMPLES" "$ENV_LOCK")
for source_path in "${RELEVANT_PATHS[@]}"; do
  [[ -f "$BASEDIR/$source_path" ]] || { echo "ERROR: missing producing file: $source_path" >&2; exit 1; }
done

# Header is line 1 → data line for task N is line N+1
LINE=$((SLURM_ARRAY_TASK_ID + 1))
read -r TASK_ID INPUT SPECIES LINEAGE MODE FASTA < <(sed -n "${LINE}p" "$SAMPLES")

if [[ -z "${INPUT:-}" || -z "${LINEAGE:-}" || -z "${MODE:-}" || -z "${FASTA:-}" ]]; then
  echo "ERROR: could not parse line $LINE of $SAMPLES" >&2
  echo "Expected 6 tab-separated fields: task_id, input, species, lineage, mode, fasta_path" >&2
  exit 1
fi

echo ""
echo "Task:        $TASK_ID"
echo "Input:       $INPUT ($SPECIES)"
echo "Lineage:     $LINEAGE"
echo "Mode:        $MODE"
echo "FASTA:       $FASTA"

# ── Sanity checks ────────────────────────────────────────────
if [[ ! -f "$FASTA" ]]; then
  echo "ERROR: $FASTA not found." >&2
  exit 1
fi

case "$MODE" in
  genome|transcriptome|proteins) ;;
  *) echo "ERROR: invalid mode '$MODE'. Must be: genome, transcriptome, or proteins." >&2; exit 1 ;;
esac

SHARED_DBS="${SHARED_DBS:?ERROR: set SHARED_DBS to the chosen database cache root}"
LINEAGE_DIR="$SHARED_DBS/busco_lineages/$LINEAGE"
if [[ ! -d "$LINEAGE_DIR" ]]; then
  echo "ERROR: lineage dataset $LINEAGE_DIR missing. Did you run busco_setup.sh?" >&2
  exit 1
fi

# Refuse occupied output before preprocessing or analysis, independent of Git state.
OUT_PARENT="outs/<area>/<XX_busco>"
OUT_NAME="${INPUT}_${LINEAGE}"
if [[ -e "$OUT_PARENT/$OUT_NAME" ]]; then
  echo "ERROR: output exists: $OUT_PARENT/$OUT_NAME" >&2
  echo "Use a fresh name or preserve/clear it only after confirming it is disposable." >&2
  exit 1
fi
mkdir -p "$OUT_PARENT"

GIT_COMMIT="${EXPECTED_COMMIT:?submit with EXPECTED_COMMIT set to the producing commit}"
git -C "$BASEDIR" cat-file -e "${GIT_COMMIT}^{commit}"
for source_path in "${RELEVANT_PATHS[@]}"; do
  committed_blob=$(git -C "$BASEDIR" rev-parse "${GIT_COMMIT}:${source_path}" 2>/dev/null) || {
    echo "ERROR: relevant producing file is absent from $GIT_COMMIT: $source_path" >&2
    exit 1
  }
  working_blob=$(git -C "$BASEDIR" hash-object "$source_path")
  [[ "$committed_blob" == "$working_blob" ]] || {
    echo "ERROR: relevant producing file does not match $GIT_COMMIT: $source_path" >&2
    exit 1
  }
done
submitted_wrapper_blob=$(git -C "$BASEDIR" hash-object "${BASH_SOURCE[0]}")
[[ "$submitted_wrapper_blob" == "$(git -C "$BASEDIR" rev-parse "${GIT_COMMIT}:${PROJECT_JOB}")" ]] || {
  echo "ERROR: queued wrapper does not match $GIT_COMMIT" >&2
  exit 1
}
echo "Producing commit: $GIT_COMMIT"

# ── Sanitize FASTA headers ───────────────────────────────────
# BUSCO 6.x rejects "/" in FASTA headers (Reader crash). IsoSeq3 cluster IDs
# look like ">transcript/N", and some assemblers also produce slash-containing
# headers. Substitute "/" -> "_" on header lines only and write the cleaned
# copy to $TMPDIR (task-local, auto-cleaned).
CLEAN_FASTA=$(mktemp "${TMPDIR:-/tmp}/${OUT_NAME}_clean.XXXXXX")
echo ""
echo "=== Cleaning FASTA headers ==="
echo "Source:      $FASTA"
echo "Destination: $CLEAN_FASTA"
sed '/^>/ s|/|_|g' "$FASTA" > "$CLEAN_FASTA"
N_CLEAN=$(grep -c '^>' "$CLEAN_FASTA")
echo "Cleaned seqs: $N_CLEAN"

# ── BUSCO ────────────────────────────────────────────────────
SECONDS=0
busco \
  --in        "$CLEAN_FASTA" \
  --out       "$OUT_NAME" \
  --out_path  "$OUT_PARENT" \
  --mode      "$MODE" \
  --lineage_dataset "$LINEAGE_DIR" \
  --cpu       "$SLURM_CPUS_PER_TASK" \
  --offline \
  --tar

echo ""
echo "=== Completed in ${SECONDS}s ($(date)) ==="

# Print headline summary
SHORT_SUMMARY=$(find "$OUT_PARENT/$OUT_NAME" -name "short_summary.specific.${LINEAGE}.${OUT_NAME}.txt" 2>/dev/null | head -1)
if [[ -f "$SHORT_SUMMARY" ]]; then
  echo ""
  echo "=== BUSCO SHORT SUMMARY ==="
  grep -E "^\s*(C:|Complete BUSCOs|Complete and single|Complete and dupl|Fragmented|Missing|Total)" "$SHORT_SUMMARY"
else
  echo "ERROR: BUSCO exited without its expected short summary" >&2
  exit 1
fi
SHORT_JSON=$(find "$OUT_PARENT/$OUT_NAME" -name "short_summary.specific.${LINEAGE}.${OUT_NAME}.json" 2>/dev/null | head -1)
[[ -f "$SHORT_JSON" ]] || { echo "ERROR: BUSCO summary JSON is missing" >&2; exit 1; }

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
  printf 'invocation: busco --in <sanitized %s> --out %s --mode %s --lineage_dataset %s --cpu %s --offline --tar\n' \
    "$FASTA" "$OUT_NAME" "$MODE" "$LINEAGE_DIR" "$SLURM_CPUS_PER_TASK"
  printf 'input: %s | bytes=%s\n' "$FASTA" "$(wc -c <"$FASTA" | tr -d ' ')"
  printf 'input: %s | task_id=%s\n' "$SAMPLES" "$TASK_ID"
  printf 'environment: %s | busco=%s\n' "$CONDA_DEFAULT_ENV" "$(busco --version 2>&1 | head -1)"
  printf 'slurm_job_id: %s\n' "$SLURM_JOB_ID"
  for source_path in "${RELEVANT_PATHS[@]}"; do
    printf 'source: %s | content verified against commit\n' "$source_path"
  done
  printf 'output: %s\n' "$OUT_PARENT/$OUT_NAME"
} >"$OUT_PARENT/$OUT_NAME/BUILD_INFO.txt"
