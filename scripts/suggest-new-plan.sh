#!/bin/bash
# PreToolUse hook for EnterPlanMode
# Suggests using /new-plan skill instead of built-in plan mode

cat << 'EOF'
{"decision": "allow", "reason": "STOP. You MUST ask the user before proceeding: 'Would you like me to use /new-plan to create a tracked planning document, or use built-in plan mode?' Do NOT enter plan mode without asking. The /new-plan skill creates a properly formatted planning document registered in the project CLAUDE.md. Only skip this if the user has already explicitly chosen built-in plan mode in this conversation."}
EOF
