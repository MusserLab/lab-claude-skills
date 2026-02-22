#!/bin/bash
# =============================================================================
# protect-sensitive-writes.sh — Plugin baseline: block writes to sensitive dirs
#
# This is the generic plugin hook that ships with lab-claude-skills.
# It blocks writes to common sensitive locations on macOS, Linux, and WSL.
#
# For personalized protections (allowlist mode, cloud storage exceptions),
# run /security-setup to generate customized hooks at ~/.claude/hooks/.
# =============================================================================

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

FILE_PATH="${FILE_PATH/#\~/$HOME}"

# --- Detect platform ---
OS=$(uname -s)

# --- Always-blocked directories (all platforms) ---
BLOCKED_DIRS=(
  "$HOME/.ssh"
  "$HOME/.aws"
  "$HOME/.gnupg"
  "$HOME/.config/gh"
  "$HOME/.config/gcloud"
  "$HOME/.docker"
  "$HOME/.kube"
  "$HOME/.azure"
  "$HOME/.config/op"
)

# --- Platform-specific blocked directories ---
case "$OS" in
  Darwin)
    BLOCKED_DIRS+=(
      "$HOME/Library/Keychains"
      "$HOME/Library/Mail"
      "$HOME/Library/Messages"
      "$HOME/Library/Safari"
      "$HOME/Library/LaunchAgents"
      "$HOME/Library/Application Support/Google/Chrome"
      "$HOME/Library/Application Support/1Password"
      "$HOME/Library/Application Support/Bitwarden"
      "$HOME/Library/Application Support/KeePassXC"
      "$HOME/Library/Application Support/LastPass"
      "$HOME/Library/Application Support/Firefox"
      "$HOME/Library/Application Support/Microsoft Edge"
      "$HOME/Library/Application Support/Code/User"
    )
    ;;
  Linux)
    BLOCKED_DIRS+=(
      # Browsers
      "$HOME/.config/google-chrome"
      "$HOME/.config/chromium"
      "$HOME/.mozilla/firefox"
      "$HOME/.config/microsoft-edge"
      # Password managers
      "$HOME/.config/1Password"
      "$HOME/.config/Bitwarden"
      "$HOME/.config/keepassxc"
      "$HOME/.local/share/keepassxc"
      # Communication
      "$HOME/.thunderbird"
      "$HOME/.local/share/evolution"
      "$HOME/.config/Slack"
      "$HOME/.config/teams-for-linux"
      # Keyring
      "$HOME/.local/share/keyrings"
      "$HOME/.local/share/kwalletd"
      # IDE configs
      "$HOME/.config/Code/User"
      "$HOME/.config/Positron"
      # Shell configs
      "$HOME/.bashrc"
      "$HOME/.bash_profile"
      "$HOME/.profile"
    )
    # WSL: also block Windows-side sensitive paths
    if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
      for win_user_dir in /mnt/c/Users/*/; do
        [ -d "$win_user_dir" ] || continue
        [[ "$(basename "$win_user_dir")" == "Public" ]] && continue
        [[ "$(basename "$win_user_dir")" == "Default" ]] && continue
        BLOCKED_DIRS+=(
          "${win_user_dir}.ssh"
          "${win_user_dir}.aws"
          "${win_user_dir}AppData/Local/Google/Chrome"
          "${win_user_dir}AppData/Local/Microsoft/Edge"
          "${win_user_dir}AppData/Roaming/Mozilla/Firefox"
          "${win_user_dir}AppData/Local/1Password"
          "${win_user_dir}AppData/Roaming/keepassxc"
        )
      done
    fi
    ;;
esac

for dir in "${BLOCKED_DIRS[@]}"; do
  if [[ "$FILE_PATH" == "$dir"* ]]; then
    echo "BLOCKED: Writing to protected directory: $dir" >&2
    echo "  For personalized protections, run /security-setup" >&2
    exit 2
  fi
done

# Also block 1Password containers (macOS path varies by install)
if [[ "$FILE_PATH" == *"/Containers/com.1password"* ]]; then
  echo "BLOCKED: Writing to 1Password container" >&2
  exit 2
fi

# --- Always-blocked filename patterns ---
BASENAME=$(basename "$FILE_PATH")
BLOCKED_FILENAMES=(".env" ".env." ".keychain-db" "credentials.json" "service-account" "id_rsa" "id_ed25519" "id_ecdsa" "id_dsa" ".pem" ".git-credentials" ".netrc" ".npmrc" ".pypirc")

for pattern in "${BLOCKED_FILENAMES[@]}"; do
  if [[ "$BASENAME" == *"$pattern"* ]]; then
    echo "BLOCKED: Writing sensitive file matching pattern: $pattern" >&2
    exit 2
  fi
done

exit 0
