#!/bin/bash
# =============================================================================
# protect-sensitive-bash.sh — PreToolUse hook for Bash tool
#
# Blocks Claude Code from running bash commands that reference sensitive
# paths or use dangerous patterns (credential extraction, pipe-to-execute).
#
# Edit the arrays below to customize. Changes take effect immediately.
# To manage this file interactively, run: /security-setup
# =============================================================================

# ---- CONFIGURATION (edit these) ---------------------------------------------

# BLOCKED PATH KEYWORDS: If a command contains any of these strings, block it.
BLOCKED_PATH_KEYWORDS=(
  # Credential stores
  ".ssh/"
  ".ssh "
  ".aws/"
  ".aws "
  ".gnupg/"
  ".gnupg "
  ".config/gh/"
  ".config/gcloud/"
  ".config/op/"
  ".git-credentials"
  ".netrc"
  ".npmrc"
  ".pypirc"
  # macOS Keychain
  "Library/Keychains"
  "keychain-db"
  # Password managers
  "1password"
  "1Password"
  "Bitwarden"
  "KeePass"
  "LastPass"
  # Browsers
  "Application Support/Google/Chrome"
  "Library/Safari"
  "Application Support/Firefox"
  "Application Support/Microsoft Edge"
  # Communication
  "Library/Mail"
  "Library/Messages"
  "Application Support/Microsoft/Teams"
  "Application Support/Slack"
  "Application Support/zoom.us"
  # IDE token storage
  "Application Support/Code/User"
  # Cloud storage (broad blocks)
  "OneDrive"
  "Google Drive"
  "CloudStorage"
  "Mobile Documents"
  # >>> SECURITY-SETUP will add any personal dir keywords here <<<
)

# BLOCKED COMMAND PATTERNS: Dangerous command patterns to block.
BLOCKED_COMMAND_PATTERNS=(
  # macOS credential access
  "security find-generic-password"
  "security find-internet-password"
  "security dump-keychain"
  "security export"
  # macOS preferences (can expose app tokens)
  "defaults read"
  # Pipe-to-execute patterns (download and run)
  "curl|bash"
  "curl|sh"
  "curl | bash"
  "curl | sh"
  "wget|bash"
  "wget|sh"
  "wget | bash"
  "wget | sh"
  "curl|python"
  "curl | python"
  "wget|python"
  "wget | python"
)

# BLOCKED STANDALONE COMMANDS: Block these when used alone (they dump secrets).
BLOCKED_STANDALONE=(
  "^env$"
  "^printenv$"
  "^printenv "
  "^set$"
)

# ALLOWED PATH EXCEPTIONS: If a command references a path under one of these
# directories, the BLOCKED_PATH_KEYWORDS check is bypassed for that keyword.
ALLOWED_PATH_EXCEPTIONS=(
  # >>> SECURITY-SETUP will populate these based on your choices <<<
  # "$HOME/Library/CloudStorage/GoogleDrive-user@univ.edu/My Drive/Research/ProjectX"
)

# ---- END CONFIGURATION ------------------------------------------------------

# Parse input
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# If we can't parse the command, allow (don't break Claude Code)
if [ -z "$COMMAND" ]; then
  exit 0
fi

# --- Check BLOCKED_STANDALONE commands ---
TRIMMED=$(echo "$COMMAND" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
for pattern in "${BLOCKED_STANDALONE[@]}"; do
  if echo "$TRIMMED" | grep -qE "$pattern"; then
    echo "BLOCKED: Command '$TRIMMED' can expose environment secrets. Use specific variable access instead." >&2
    exit 2
  fi
done

# --- Check BLOCKED_COMMAND_PATTERNS ---
for pattern in "${BLOCKED_COMMAND_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern" 2>/dev/null; then
    echo "BLOCKED: Dangerous command pattern detected: $pattern" >&2
    exit 2
  fi
done

# --- Check BLOCKED_PATH_KEYWORDS (with exception handling) ---
for keyword in "${BLOCKED_PATH_KEYWORDS[@]}"; do
  if echo "$COMMAND" | grep -qi "$keyword" 2>/dev/null; then
    # Check if the command references an allowed exception path
    EXCEPTION_MATCHED=false
    for exception in "${ALLOWED_PATH_EXCEPTIONS[@]}"; do
      expanded="${exception/#\~/$HOME}"
      if echo "$COMMAND" | grep -q "$expanded" 2>/dev/null; then
        EXCEPTION_MATCHED=true
        break
      fi
    done
    if [ "$EXCEPTION_MATCHED" = false ]; then
      echo "BLOCKED: Command references sensitive path keyword: $keyword" >&2
      exit 2
    fi
  fi
done

# All checks passed
exit 0
