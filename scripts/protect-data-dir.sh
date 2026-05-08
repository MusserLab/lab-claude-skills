#!/bin/bash
# Enforce data/ as read-only in data-science projects.
# Convention: data/raw/ holds immutable external inputs; data/processed/ holds
# derived analytical stores written by canonical preprocessing scripts; outs/
# holds per-script reports/figures.
#
# This hook blocks writes anywhere under data/ EXCEPT:
#  - Provenance files (CITATION, PROVENANCE, README, MANIFEST, CHANGELOG,
#    LICENSE, rights.txt) — they belong with the data they describe.
#  - Anything under data/processed/ — sanctioned target for derived stores.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")

# Only act on writes inside a data/ directory.
if [[ "$FILE_PATH" != */data/* ]]; then
  exit 0
fi

# Allowlist: derived analytical stores under data/processed/.
if [[ "$FILE_PATH" == */data/processed/* ]]; then
  exit 0
fi

# Allowlist: provenance / metadata files that belong with the data.
BASENAME="${FILE_PATH##*/}"
case "$BASENAME" in
  CITATION|CITATION.txt|CITATION.md| \
  PROVENANCE|PROVENANCE.txt|PROVENANCE.md| \
  README|README.md|README.txt| \
  MANIFEST|MANIFEST.txt|MANIFEST.md| \
  CHANGELOG.md|CHANGES.md| \
  LICENSE|LICENSE.txt|LICENSE.md| \
  rights.txt)
    exit 0
    ;;
esac

echo "BLOCKED: data/ is read-only by convention. Outputs should go to outs/, derived stores to data/processed/. If you truly need to update another data file, ask the user first. (Exempt names: CITATION/PROVENANCE/README/MANIFEST/CHANGELOG/LICENSE.)" >&2
exit 2
