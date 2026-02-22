#!/bin/bash
# =============================================================================
# protect-sensitive-reads.sh — Plugin baseline: block reads to sensitive dirs
#
# This is the generic plugin hook that ships with lab-claude-skills.
# It blocks reads to macOS-standard sensitive locations (credentials,
# password managers, browsers, email, etc.).
#
# For personalized protections (cloud storage exceptions, allowlist mode),
# run /security-setup to generate customized hooks at ~/.claude/hooks/.
# =============================================================================

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

FILE_PATH="${FILE_PATH/#\~/$HOME}"

# --- Always-blocked directories ---
BLOCKED_DIRS=(
  "$HOME/.ssh"
  "$HOME/.aws"
  "$HOME/.gnupg"
  "$HOME/Library/Keychains"
  "$HOME/Library/Mail"
  "$HOME/Library/Messages"
  "$HOME/Library/Safari"
  "$HOME/Library/Application Support/Google/Chrome"
  "$HOME/Library/Application Support/1Password"
  "$HOME/Library/Application Support/Bitwarden"
  "$HOME/Library/Application Support/KeePassXC"
  "$HOME/Library/Application Support/LastPass"
  "$HOME/Library/Application Support/Firefox"
  "$HOME/Library/Application Support/Microsoft Edge"
  "$HOME/Library/Application Support/Code/User"
)

for dir in "${BLOCKED_DIRS[@]}"; do
  if [[ "$FILE_PATH" == "$dir"* ]]; then
    echo "BLOCKED: Reading from protected directory: $dir" >&2
    echo "  For personalized protections, run /security-setup" >&2
    exit 2
  fi
done

# Also block 1Password containers (path varies by install)
if [[ "$FILE_PATH" == *"/Containers/com.1password"* ]]; then
  echo "BLOCKED: Reading from 1Password container" >&2
  exit 2
fi

# --- Always-blocked filename patterns ---
BASENAME=$(basename "$FILE_PATH")
BLOCKED_FILENAMES=(".env" ".env." ".keychain-db" "credentials.json" "service-account" "id_rsa" "id_ed25519" "id_ecdsa" "id_dsa" ".git-credentials" ".netrc" ".npmrc" ".pypirc")

for pattern in "${BLOCKED_FILENAMES[@]}"; do
  if [[ "$BASENAME" == *"$pattern"* ]]; then
    echo "BLOCKED: Reading sensitive file matching pattern: $pattern" >&2
    exit 2
  fi
done

exit 0
