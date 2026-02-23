#!/bin/bash
# =============================================================================
# protect-sensitive-bash.sh — Plugin baseline: block dangerous bash commands
#
# This is the generic plugin hook that ships with lab-claude-skills.
# It blocks bash commands that reference sensitive paths or use dangerous
# patterns (credential extraction, pipe-to-execute). Cross-platform:
# macOS, Linux, and WSL.
#
# For personalized protections (cloud storage exceptions, custom keywords),
# run /security-setup to generate customized hooks at ~/.claude/hooks/.
# =============================================================================

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# --- Detect platform ---
OS=$(uname -s)

# --- Block standalone commands that dump secrets ---
TRIMMED=$(echo "$COMMAND" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if echo "$TRIMMED" | grep -qE "^env$|^printenv$|^printenv |^set$"; then
  echo "BLOCKED: Command can expose environment secrets. Use specific variable access instead." >&2
  exit 2
fi

# --- Block dangerous command patterns ---
DANGEROUS_PATTERNS=(
  "curl|bash" "curl|sh" "curl | bash" "curl | sh"
  "wget|bash" "wget|sh" "wget | bash" "wget | sh"
  "curl|python" "curl | python" "wget|python" "wget | python"
)

# Platform-specific dangerous commands
case "$OS" in
  Darwin)
    DANGEROUS_PATTERNS+=(
      "security find-generic-password"
      "security find-internet-password"
      "security dump-keychain"
      "security export"
      "defaults read"
    )
    ;;
  Linux)
    DANGEROUS_PATTERNS+=(
      "secret-tool lookup"
      "secret-tool search"
      "kwallet-query"
    )
    ;;
esac

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qFi "$pattern" 2>/dev/null; then
    echo "BLOCKED: Dangerous command pattern: $pattern" >&2
    exit 2
  fi
done

# --- Block commands referencing sensitive paths ---
SENSITIVE_KEYWORDS=(
  # Credential stores (all platforms)
  ".ssh/" ".ssh " ".aws/" ".aws " ".gnupg/" ".gnupg "
  ".config/gh/" ".config/gcloud/" ".config/op/"
  ".git-credentials" ".netrc" ".npmrc" ".pypirc"
  # Password managers (cross-platform keywords)
  "1password" "1Password" "Bitwarden" "KeePass" "LastPass"
)

# Platform-specific sensitive keywords
case "$OS" in
  Darwin)
    SENSITIVE_KEYWORDS+=(
      "Library/Keychains" "keychain-db"
      "Application Support/Google/Chrome" "Library/Safari"
      "Application Support/Firefox" "Application Support/Microsoft Edge"
      "Library/Mail" "Library/Messages"
      "Application Support/Microsoft/Teams"
      "Application Support/Slack" "Application Support/zoom.us"
      "Application Support/Code/User"
    )
    ;;
  Linux)
    SENSITIVE_KEYWORDS+=(
      ".config/google-chrome" ".config/chromium"
      ".mozilla/firefox" ".config/microsoft-edge"
      ".thunderbird" ".local/share/evolution"
      ".local/share/keyrings" ".local/share/kwalletd"
      ".config/Slack" ".config/teams-for-linux"
      ".config/Code/User" ".config/Positron"
    )
    # WSL: also block Windows-side sensitive keywords
    if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
      SENSITIVE_KEYWORDS+=(
        "AppData/Local/Google/Chrome"
        "AppData/Local/Microsoft/Edge"
        "AppData/Roaming/Mozilla/Firefox"
        "AppData/Local/1Password"
        "AppData/Roaming/keepassxc"
      )
    fi
    ;;
esac

for keyword in "${SENSITIVE_KEYWORDS[@]}"; do
  if echo "$COMMAND" | grep -qi "$keyword" 2>/dev/null; then
    echo "BLOCKED: Command references sensitive path: $keyword" >&2
    echo "  For personalized protections, run /security-setup" >&2
    exit 2
  fi
done

exit 0
