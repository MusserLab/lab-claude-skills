#!/bin/bash
# =============================================================================
# protect-sensitive-reads.sh — PreToolUse hook for Read tool
#
# Blocks Claude Code from reading sensitive files on your machine.
# Supports two modes:
#   MODE="allowlist" — block everything except ALLOWED_DIRS (most secure)
#   MODE="blocklist" — block only BLOCKED_DIRS, allow everything else
#
# Cross-platform: macOS, Linux, and WSL. OS is detected automatically.
#
# Edit the arrays below to customize. Changes take effect immediately.
# To manage this file interactively, run: /security-setup
# =============================================================================

# ---- CONFIGURATION (edit these) ---------------------------------------------

# >>> SECURITY-SETUP will set this based on your choice <<<
MODE="blocklist"

# ALLOWLIST MODE: Only these directories (and their subdirectories) are readable.
# Your current project directory is always allowed automatically.
ALLOWED_DIRS=(
  # >>> SECURITY-SETUP will populate these <<<
  # "$HOME/path/to/your/research"
  # "$HOME/path/to/another/project"
)

# Detect platform for default paths
OS=$(uname -s)

# BLOCKLIST MODE: These directories are blocked; everything else is allowed.
# (Only used when MODE="blocklist")
#
# Universal paths (all platforms):
BLOCKED_DIRS=(
  # >>> SECURITY-SETUP will populate these based on scan results <<<
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

# Platform-specific defaults for BLOCKED_DIRS:
case "$OS" in
  Darwin)
    BLOCKED_DIRS+=(
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
      "$HOME/Library/Application Support/Microsoft/Teams"
      "$HOME/Library/Application Support/Slack"
      "$HOME/Library/Application Support/zoom.us"
      "$HOME/Library/Application Support/Code/User"
      "$HOME/Library/Mobile Documents"
      # >>> SECURITY-SETUP will add cloud storage paths found on your machine <<<
      # >>> SECURITY-SETUP will add any additional sensitive dirs you specify <<<
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
      # Keyring / wallet
      "$HOME/.local/share/keyrings"
      "$HOME/.local/share/kwalletd"
      # IDE configs
      "$HOME/.config/Code/User"
      "$HOME/.config/Positron"
      # >>> SECURITY-SETUP will add cloud storage paths found on your machine <<<
      # >>> SECURITY-SETUP will add any additional sensitive dirs you specify <<<
    )
    # WSL: also block Windows-side sensitive locations
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
          # >>> SECURITY-SETUP will add Windows-side paths found <<<
        )
      done
    fi
    ;;
esac

# ALWAYS BLOCKED: These are blocked in BOTH modes, even if under an allowed dir.
ALWAYS_BLOCK_DIRS=(
  "$HOME/.ssh"
  "$HOME/.aws"
  "$HOME/.gnupg"
)
case "$OS" in
  Darwin)
    ALWAYS_BLOCK_DIRS+=(
      "$HOME/Library/Keychains"
      "$HOME/Library/Mail"
      "$HOME/Library/Messages"
      "$HOME/Library/Safari"
      "$HOME/Library/Application Support/Google/Chrome"
      "$HOME/Library/Application Support/1Password"
      "$HOME/Library/Application Support/Code/User"
    )
    ;;
  Linux)
    ALWAYS_BLOCK_DIRS+=(
      "$HOME/.config/google-chrome"
      "$HOME/.mozilla/firefox"
      "$HOME/.local/share/keyrings"
      "$HOME/.local/share/kwalletd"
      "$HOME/.config/Code/User"
      "$HOME/.config/1Password"
    )
    ;;
esac

# ALWAYS BLOCKED: Sensitive filename patterns (matched anywhere in path).
ALWAYS_BLOCK_FILENAMES=(
  ".env"
  ".env."
  ".keychain-db"
  "credentials.json"
  "service-account"
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
  "id_dsa"
  ".pem"
  ".git-credentials"
  ".netrc"
  ".npmrc"
  ".pypirc"
)

# SYSTEM PATHS: Always allowed (needed for development tooling).
SYSTEM_DIRS=(
  "$HOME/miniconda3"
  "$HOME/.claude"
  "/tmp"
)
case "$OS" in
  Darwin)
    SYSTEM_DIRS+=(
      "/usr/local"
      "/opt/homebrew"
      "/Library/Frameworks"
      "$HOME/Library/Caches/R/renv"
      "/var/folders"
      "/private/tmp"
      "/private/var/folders"
    )
    ;;
  Linux)
    SYSTEM_DIRS+=(
      "/usr/local"
      "/usr/lib"
      "/opt"
      "$HOME/.local/lib"
      "$HOME/.cache/R/renv"
    )
    ;;
esac

# ---- END CONFIGURATION ------------------------------------------------------

# Parse input
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# If we can't parse the path, allow (don't break Claude Code)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Expand ~ in FILE_PATH if present
FILE_PATH="${FILE_PATH/#\~/$HOME}"

# --- Check ALWAYS_BLOCK_DIRS (both modes) ---
for dir in "${ALWAYS_BLOCK_DIRS[@]}"; do
  expanded="${dir/#\~/$HOME}"
  if [[ "$FILE_PATH" == "$expanded"* ]]; then
    echo "BLOCKED: Reading from protected directory: $expanded" >&2
    exit 2
  fi
done

# --- Check ALWAYS_BLOCK_FILENAMES (both modes) ---
BASENAME=$(basename "$FILE_PATH")
for pattern in "${ALWAYS_BLOCK_FILENAMES[@]}"; do
  if [[ "$BASENAME" == *"$pattern"* ]]; then
    echo "BLOCKED: Reading sensitive file matching pattern: $pattern" >&2
    exit 2
  fi
done

# --- Check SYSTEM_DIRS (always allowed in both modes) ---
for dir in "${SYSTEM_DIRS[@]}"; do
  expanded="${dir/#\~/$HOME}"
  if [[ "$FILE_PATH" == "$expanded"* ]]; then
    exit 0
  fi
done

# --- Mode-specific logic ---

if [ "$MODE" = "allowlist" ]; then
  # Allowlist mode: block everything not in ALLOWED_DIRS
  for dir in "${ALLOWED_DIRS[@]}"; do
    expanded="${dir/#\~/$HOME}"
    if [[ "$FILE_PATH" == "$expanded"* ]]; then
      exit 0
    fi
  done
  # Not in any allowed dir — block
  echo "BLOCKED: Path is outside allowed directories. Add it to ALLOWED_DIRS in ~/.claude/hooks/protect-sensitive-reads.sh or run /security-setup" >&2
  exit 2

elif [ "$MODE" = "blocklist" ]; then
  # Blocklist mode: block only BLOCKED_DIRS
  for dir in "${BLOCKED_DIRS[@]}"; do
    expanded="${dir/#\~/$HOME}"
    if [[ "$FILE_PATH" == "$expanded"* ]]; then
      echo "BLOCKED: Reading from protected directory: $expanded" >&2
      exit 2
    fi
  done
  # Not in any blocked dir — allow
  exit 0
fi

# Fallback: allow
exit 0
