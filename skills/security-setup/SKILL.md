---
name: security-setup
description: Configure and manage Claude Code security protections for sensitive files, credentials, and data. Use when the user invokes /security-setup to set up or modify protections against unauthorized file access, credential exposure, or sensitive data leaks.
user-invocable: true
---

# Security Setup & Management

When the user invokes `/security-setup`, configure or update Claude Code security protections. This skill is **re-runnable** — it detects whether protections are already configured and adjusts its workflow accordingly.

---

## Detect Mode

Check if `~/.claude/hooks/protect-sensitive-reads.sh` exists:
- **Not found** → First-time setup (Section 1)
- **Found** → Returning user (Section 2)

---

## Section 1: First-Time Setup

### Step 1: Explain the Threat Model

Tell the user:

> Claude Code can read any file on your machine and run any shell command — including accessing saved passwords, API keys, email, cloud storage, and sensitive research data. This skill sets up layered protections:
>
> 1. **Hooks** — scripts that intercept Read and Bash operations, blocking access to sensitive locations
> 2. **Deny rules** — settings.json rules that block access even if a hook has a bug
> 3. **Bash scoping** — replacing the blanket `Bash(*)` permission with specific allowed commands
>
> The plugin already provides baseline protection. This setup adds **personal protections** tailored to your machine.

### Step 2: Comprehensive Scan

Run discovery commands to check which sensitive locations exist on the user's machine. Use `ls -d` with `2>/dev/null` for each path. Organize results by category:

**Credential stores & password managers:**
- `~/.ssh/`, `~/.aws/`, `~/.gnupg/`
- `~/.config/gh/`, `~/.config/gcloud/`, `~/.docker/`, `~/.kube/`, `~/.azure/`
- `~/.config/op/` (1Password CLI)
- `~/.netrc`, `~/.npmrc`, `~/.pypirc`, `~/.git-credentials`
- `~/.Renviron` (R environment variables, may contain API keys)
- macOS Keychain: `~/Library/Keychains/`
- 1Password: `~/Library/Application Support/1Password/`, `~/Library/Containers/com.1password.*`
- Bitwarden: `~/Library/Application Support/Bitwarden/`
- KeePassXC: `~/Library/Application Support/KeePassXC/`
- LastPass: `~/Library/Application Support/LastPass/`

**Browser profiles (saved passwords, cookies, sessions):**
- Chrome: `~/Library/Application Support/Google/Chrome/`
- Safari: `~/Library/Safari/`
- Firefox: `~/Library/Application Support/Firefox/`
- Edge: `~/Library/Application Support/Microsoft Edge/`

**Communication apps (email, messages, chat logs):**
- Apple Mail: `~/Library/Mail/`
- iMessage: `~/Library/Messages/`
- Teams: `~/Library/Application Support/Microsoft/Teams/`
- Slack: `~/Library/Application Support/Slack/`
- Zoom: `~/Library/Application Support/zoom.us/`

**Cloud storage mounts:**
- OneDrive: `~/Library/CloudStorage/OneDrive-*/`
- Google Drive: `~/Library/CloudStorage/GoogleDrive-*/`, `~/*Google Drive*`
- Dropbox: `~/Dropbox/`
- iCloud: `~/Library/Mobile Documents/`
- Box: `~/Library/CloudStorage/Box-*/`, `~/Box/`

**IDE configs (may contain tokens):**
- VS Code: `~/Library/Application Support/Code/User/`
- Positron: `~/.positron/`
- Jupyter: `~/.jupyter/`
- IPython: `~/.ipython/`

**Scattered credential files:**
- `.env` files: `find ~ -maxdepth 3 -name ".env" -o -name ".env.*" 2>/dev/null`
- GCP service accounts: `find ~ -maxdepth 3 -name "credentials.json" -o -name "service-account*.json" 2>/dev/null`

### Step 3: Present Findings

Show a categorized summary table with "Found" / "Not found" for each item. Group by risk level (Critical / High / Medium).

### Step 4: Choose Protection Mode

Use AskUserQuestion:

- **Allowlist mode (most secure)**: Block everything except directories you explicitly allow. You add project directories as needed. Best if you want maximum protection.
- **Blocklist mode (more permissive)**: Block only the sensitive directories found in the scan. Everything else is accessible. Best if you work across many directories and want less friction.

### Step 5: Configure Paths

Depending on mode choice:

**Allowlist mode:**
Ask: "Which directories should Claude be allowed to read? Your current project directory is always allowed automatically."

Suggest common patterns:
- Research/work directories
- Specific cloud storage project folders
- Shared data directories

**Blocklist mode:**
All scanned sensitive dirs are blocked by default. Ask two questions:
1. "Are there additional directories with sensitive data (student records, patient data, HR files, personal documents) that Claude should never access?"
2. "Are there specific project folders within cloud storage that Claude SHOULD be allowed to access?"

### Step 6: Generate Personal Hooks

Read the template files from the skill's `templates/` directory:
- `templates/protect-sensitive-reads.sh`
- `templates/protect-sensitive-bash.sh`

Customize the templates:
1. Set `MODE=` to the user's choice
2. Populate `ALLOWED_DIRS` or `BLOCKED_DIRS` with the user's paths
3. Add discovered cloud storage mount points to `BLOCKED_DIRS` (blocklist mode) or leave them out of `ALLOWED_DIRS` (allowlist mode)
4. Add any 1Password container paths found (e.g., `com.1password.1password-launcher`) to `ALWAYS_BLOCK_DIRS`
5. Populate `ALLOWED_PATH_EXCEPTIONS` in the bash hook with the same cloud storage project exceptions

Write the customized hooks to `~/.claude/hooks/`:
- `~/.claude/hooks/protect-sensitive-reads.sh`
- `~/.claude/hooks/protect-sensitive-bash.sh`

Make them executable with `chmod +x`.

### Step 7: Update settings.json

Read `~/.claude/settings.json`. Make these changes:

**Add deny rules** (defense-in-depth) for critical paths found in the scan. Only add deny rules for paths that actually exist. Use the user's actual home directory path (not `$HOME`):
```json
"Read(/Users/username/.ssh/*)",
"Read(/Users/username/.aws/*)",
"Read(/Users/username/Library/Keychains/*)",
"Read(/Users/username/Library/Mail/*)",
"Read(/Users/username/Library/Messages/*)",
"Read(/Users/username/Library/Safari/*)",
"Read(/Users/username/Library/Application Support/1Password/*)",
"Read(/Users/username/Library/Application Support/Google/Chrome/*)"
```

**Register hooks** in the PreToolUse section (if not already registered):
```json
{ "matcher": "Read", "hooks": [{ "type": "command", "command": "~/.claude/hooks/protect-sensitive-reads.sh" }] }
```
Add the bash hook to the existing Bash matcher's hooks array.

**Ask about Bash scoping**: "The current setting allows all bash commands (`Bash(*)`). Would you like to replace this with a specific allowlist of commands (more secure but you'll be prompted for unlisted commands)?"

If yes, replace `Bash(*)` with scoped commands. Collect what tools they commonly use and suggest a starting list:
```
git, conda, pip, python, Rscript, R, quarto, ls, mkdir, cp, mv, rm, chmod,
wc, diff, head, tail, sort, cut, uniq, which, type, gh, npm
```
Plus any domain-specific tools (mafft, iqtree, samtools, etc.).

### Step 8: Verify

Test that protections work:
1. Attempt to read `~/.ssh/` — should be blocked
2. Attempt to run `cat ~/.aws/credentials` — should be blocked
3. Read a file in the current project directory — should work
4. Run `git status` — should work

Report results to the user.

---

## Section 2: Returning User (Manage Existing Protections)

### Step 1: Read Current Config

Parse `~/.claude/hooks/protect-sensitive-reads.sh` to extract:
- Current `MODE` (allowlist or blocklist)
- `ALLOWED_DIRS` array contents
- `BLOCKED_DIRS` array contents
- `ALWAYS_BLOCK_DIRS` array contents

Parse `~/.claude/hooks/protect-sensitive-bash.sh` to extract:
- `BLOCKED_PATH_KEYWORDS` array contents
- `ALLOWED_PATH_EXCEPTIONS` array contents

Parse `~/.claude/settings.json` to extract:
- Deny rules
- Bash permission rules (scoped or `Bash(*)`)

### Step 2: Present Current Protections

Show a summary organized by:
- **Protection mode**: allowlist or blocklist
- **Allowed directories** (allowlist mode) or **Blocked directories** (blocklist mode)
- **Always-blocked directories** (both modes)
- **Cloud storage exceptions** (paths where access is allowed within otherwise-blocked cloud storage)
- **Deny rules** in settings.json
- **Bash permissions**: scoped commands or `Bash(*)`

### Step 3: Ask What to Change

Use AskUserQuestion with mode-appropriate options:

**Allowlist mode options:**
- Add allowed directories
- Remove allowed directories
- Switch to blocklist mode

**Blocklist mode options:**
- Add directories to block
- Remove directories from block list
- Add cloud storage exceptions (grant access to project folders)
- Remove cloud storage exceptions
- Switch to allowlist mode

**Both modes:**
- Add Bash commands to allowlist
- Remove Bash commands from allowlist
- Re-scan for new sensitive locations (if new software was installed)

### Step 4: Apply Changes

Modify the relevant hook script(s) and/or settings.json. When editing hook scripts:
- Read the current file
- Use the Edit tool to modify the specific array
- Preserve all other configuration

Show the user what changed (before/after for the modified arrays).

### Step 5: Verify

Run the same verification tests as first-time setup to confirm changes work.
