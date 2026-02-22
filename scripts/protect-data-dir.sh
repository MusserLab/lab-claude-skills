#!/bin/bash
# Enforce data/ as read-only in data-science projects.
# Blocks writes to data/ directories (convention: outputs go to outs/).
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")

# Check if writing to a data/ directory
if [[ "$FILE_PATH" == */data/* ]]; then
  echo "BLOCKED: data/ is read-only by convention. Outputs should go to outs/. If you truly need to update a data file, ask the user first." >&2
  exit 2
fi
exit 0
