#!/bin/bash
# Block bare pip install without conda activation.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))")

if echo "$COMMAND" | grep -qE '^\s*(pip|pip3) install'; then
  echo "BLOCKED: Never use bare pip install. Activate the project conda env first (source ~/miniconda3/etc/profile.d/conda.sh && conda activate ENV_NAME)." >&2
  exit 2
fi
exit 0
