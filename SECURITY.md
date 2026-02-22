# Security Guide

Claude Code is an AI coding assistant that works by reading your files and running shell commands on your behalf. This is what makes it powerful — but it also means Claude has access to everything on your machine: saved passwords, API keys, email, browser data, cloud storage, and sensitive research data.

This isn't a hypothetical risk. An AI agent that can read arbitrary files and run bash commands can, in principle:

- Read your SSH keys, AWS credentials, or API tokens
- Access saved passwords in your browser or password manager's local storage
- Read email and messages stored on disk
- Browse files in cloud storage (Dropbox, OneDrive, Google Drive)
- Run commands that extract credentials from the macOS Keychain
- Pipe downloaded scripts directly to your shell

Claude won't do any of these things intentionally — but mistakes happen, prompt injections exist, and defense-in-depth is good practice. The lab plugin sets up protections so these scenarios are blocked automatically.

## How protection works

The lab plugin uses three layers of defense. Each layer catches what the others might miss.

### Layer 1: Hooks (automatic interception)

Hooks are shell scripts that run *before* Claude executes certain operations. They inspect what Claude is about to do and block it if it touches something sensitive.

The plugin installs two security hooks:

**`protect-sensitive-reads.sh`** — intercepts every file read and blocks access to:
- Credential stores: `~/.ssh/`, `~/.aws/`, `~/.gnupg/`
- Password managers: 1Password, Bitwarden, KeePassXC, LastPass local storage
- Browsers: Chrome, Safari, Firefox, Edge (saved passwords, cookies, sessions)
- Communication apps: Apple Mail, iMessage
- IDE configs: VS Code settings (may contain tokens)
- Sensitive filenames: `.env`, `credentials.json`, SSH keys, `.git-credentials`, `.netrc`

**`protect-sensitive-bash.sh`** — intercepts every bash command and blocks:
- Commands that reference sensitive paths (anything in the lists above)
- macOS credential extraction (`security find-generic-password`, `security dump-keychain`, etc.)
- Environment variable dumping (`env`, `printenv`, `set` — these can leak API keys)
- Pipe-to-execute patterns (`curl | bash`, `wget | sh`, etc.)

These hooks activate automatically when the plugin is installed. You don't need to configure anything.

### Layer 2: Deny rules (defense-in-depth)

Deny rules in your `settings.json` provide a second line of defense. Even if a hook has a bug, deny rules block access at the settings level:

```json
"deny": [
  "Bash(sudo *)",
  "Bash(git push --force *)",
  "Bash(git reset --hard *)",
  "Read($HOME/.ssh/*)",
  "Read($HOME/.aws/*)",
  "Read($HOME/Library/Keychains/*)",
  "Read($HOME/Library/Application Support/1Password/*)",
  "Read($HOME/Library/Application Support/Google/Chrome/*)"
]
```

The `settings-example.json` template includes these. If you haven't copied it yet, see the [Starter configuration](#starter-configuration) section of the README.

### Layer 3: Bash scoping (least privilege)

Instead of granting Claude blanket permission to run any command (`Bash(*)`), the settings template pre-approves only specific tools:

```
Bash(git *), Bash(conda *), Bash(python *), Bash(Rscript *), Bash(quarto *), ...
```

If Claude tries to run a command that isn't on the list, it asks you first. This means unexpected commands (like `curl` piping to `bash`) require your explicit approval.

## What you should do

### 1. Install the plugin

This gives you Layer 1 (hooks) automatically:

```
/plugin marketplace add MusserLab/lab-claude-skills
/plugin install lab-skills
```

### 2. Copy the settings template

This gives you Layer 2 (deny rules) and Layer 3 (bash scoping):

```bash
cp templates/settings-example.json ~/.claude/settings.json
```

If you already have a `settings.json`, merge in the `deny` array manually. See the README for details.

### 3. Run `/security-setup` for personalized protections (recommended)

The plugin hooks provide a good baseline, but they don't know about your specific machine. The `/security-setup` skill:

1. **Scans your machine** for sensitive locations (cloud storage mounts, installed password managers, scattered `.env` files, etc.)
2. **Presents what it found** in a categorized table
3. **Lets you choose a protection mode:**
   - **Allowlist** (most secure): block everything except directories you explicitly permit
   - **Blocklist** (more permissive): block only the sensitive locations, allow everything else
4. **Generates personalized hooks** at `~/.claude/hooks/` tailored to your machine
5. **Updates your `settings.json`** with deny rules for paths that actually exist on your system

You can re-run `/security-setup` at any time to adjust your protections (add directories, change modes, re-scan after installing new software).

### Allowlist vs. blocklist mode

**Allowlist mode** is the more secure option. Claude can only read files in directories you've explicitly allowed (plus system directories like `/usr/local` and `~/miniconda3`). If you start a project in a new directory, you'll need to add it. This is good for people who work in a small number of known project directories.

**Blocklist mode** is more permissive. Claude can read anything *except* the sensitive locations identified in the scan. This is good for people who work across many directories and don't want to maintain an allowlist. The tradeoff is that anything not in the blocklist is accessible.

Both modes always block critical locations (`.ssh`, `.aws`, `.gnupg`, Keychains, etc.) regardless of your choice.

## What's protected and what's not

### Always protected (both modes, all layers)

| Category | Examples |
|----------|----------|
| SSH/cloud credentials | `~/.ssh/`, `~/.aws/`, `~/.gnupg/` |
| Password managers | 1Password, Bitwarden, KeePassXC, LastPass |
| Browsers | Chrome, Safari, Firefox, Edge |
| Communication | Apple Mail, iMessage |
| macOS Keychain | `~/Library/Keychains/` |
| Sensitive files | `.env`, `credentials.json`, SSH keys, `.git-credentials` |

### Protected with `/security-setup` (personalized)

| Category | Examples |
|----------|----------|
| Cloud storage | OneDrive, Google Drive, Dropbox, iCloud, Box |
| Chat apps | Teams, Slack, Zoom |
| IDE configs | VS Code, Positron, Jupyter settings |
| Dev credentials | `.npmrc`, `.pypirc`, `.Renviron`, Docker/Kubernetes configs |
| Custom directories | Student records, patient data, personal documents |

### Not protected by hooks

| Category | Notes |
|----------|-------|
| Network access | Claude can fetch URLs; use WebFetch domain allowlists in settings |
| Current project files | Your project directory is intentionally accessible — that's where you work |
| Bash output | A command's output isn't filtered; be thoughtful about what you ask Claude to run |

## If something gets blocked

When a hook blocks an operation, you'll see a message like:

```
BLOCKED: Reading from protected directory: /Users/you/.ssh
```

This means the protection is working as intended. If you need to access something that's being blocked (e.g., a project folder inside cloud storage), run `/security-setup` to add an exception rather than disabling the hook.

## Updating protections

- **New software installed** (password manager, browser, cloud storage): re-run `/security-setup` and choose "re-scan"
- **New project directory**: run `/security-setup` to add it to your allowlist
- **Cloud storage project folder**: run `/security-setup` to add a path exception
- **Plugin update**: pull the latest plugin version; hook updates apply automatically
