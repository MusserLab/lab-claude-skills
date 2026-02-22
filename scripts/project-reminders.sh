#!/bin/bash
# Inject critical project-specific rules at every session start.
# Reads from .claude/project-reminders.txt in the project root if it exists.
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))")

REMINDERS_FILE="$CWD/.claude/project-reminders.txt"

if [[ ! -f "$REMINDERS_FILE" ]]; then
  exit 0
fi

CONTENT=$(cat "$REMINDERS_FILE")
# Escape for JSON: backslashes, quotes, newlines
ESCAPED=$(echo "$CONTENT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ESCAPED
  }
}
EOF
