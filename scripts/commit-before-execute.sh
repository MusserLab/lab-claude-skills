#!/bin/bash
# Hook: Remind to commit before sbatch or quarto render
# Fires on Bash tool calls. Checks if the command is sbatch or quarto render,
# and if so, checks for uncommitted changes in the git tree.

set -euo pipefail

# Parse the tool input from stdin (JSON with "command" field)
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null || echo "")

# Only check for sbatch and quarto render commands
case "$COMMAND" in
    sbatch*|*quarto\ render*|*quarto\ preview*)
        ;;
    *)
        exit 0
        ;;
esac

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

# Check for uncommitted changes (staged + unstaged + untracked in scripts/batch/)
DIRTY=$(git status --porcelain -- scripts/ batch/ R/ python/ 2>/dev/null || true)

if [ -n "$DIRTY" ]; then
    echo "SUGGESTION: You have uncommitted changes in scripts or code files:"
    echo "$DIRTY" | head -10
    NCHANGES=$(echo "$DIRTY" | wc -l)
    if [ "$NCHANGES" -gt 10 ]; then
        echo "  ... and $((NCHANGES - 10)) more"
    fi
    echo ""
    echo "Consider committing before executing so the git hash in BUILD_INFO.txt"
    echo "accurately reflects the code that produced the outputs."
    echo ""
    echo "This is a suggestion, not a block — the command will still run."
fi

exit 0