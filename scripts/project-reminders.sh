#!/bin/bash
# Inject critical project-specific rules at every session start.
# Also checks if personal security hooks are outdated vs the plugin version.
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))")

CONTENT=""

# --- General reminders (all sessions) ---
GENERAL_REMINDERS="$HOME/.claude/hooks/general-reminders.txt"
if [[ -f "$GENERAL_REMINDERS" ]]; then
  CONTENT=$(cat "$GENERAL_REMINDERS")
fi

# --- Project reminders ---
REMINDERS_FILE="$CWD/.claude/project-reminders.txt"
if [[ -f "$REMINDERS_FILE" ]]; then
  if [[ -n "$CONTENT" ]]; then
    CONTENT="$CONTENT"$'\n\n'"$(cat "$REMINDERS_FILE")"
  else
    CONTENT=$(cat "$REMINDERS_FILE")
  fi
fi

# --- Security version check ---
# Determine plugin root (from env or relative to this script)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PLUGIN_VER_FILE="$PLUGIN_ROOT/scripts/SECURITY_VERSION"
PERSONAL_VER_FILE="$HOME/.claude/hooks/SECURITY_VERSION"
PERSONAL_HOOK="$HOME/.claude/hooks/protect-sensitive-reads.sh"

if [[ -f "$PLUGIN_VER_FILE" && -f "$PERSONAL_HOOK" ]]; then
  PLUGIN_VER=$(cat "$PLUGIN_VER_FILE" | tr -d '[:space:]')
  if [[ -f "$PERSONAL_VER_FILE" ]]; then
    PERSONAL_VER=$(cat "$PERSONAL_VER_FILE" | tr -d '[:space:]')
  else
    PERSONAL_VER=0
  fi
  if [[ "$PERSONAL_VER" -lt "$PLUGIN_VER" ]] 2>/dev/null; then
    NUDGE="Security hooks updated (v${PERSONAL_VER} -> v${PLUGIN_VER}). Run /security-setup to update your protections."
    if [[ -n "$CONTENT" ]]; then
      CONTENT="$CONTENT"$'\n\n'"$NUDGE"
    else
      CONTENT="$NUDGE"
    fi
  fi
fi

# --- Emit output ---
if [[ -z "$CONTENT" ]]; then
  exit 0
fi

ESCAPED=$(echo "$CONTENT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ESCAPED
  }
}
EOF
