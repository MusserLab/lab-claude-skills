---
name: git-conventions
description: Git commit practices and conventions. Use when committing changes, writing commit messages, creating branches, or making PRs.
user-invocable: false
---

# Git Practices

## Before Starting Work

```bash
# Check current branch and status
git status
git branch

# Pull latest changes if on a shared branch
git pull
```

## Committing Changes

1. **Commit frequently** — after completing each logical unit of work
2. **Write descriptive commit messages** — explain the "what" and "why"
3. **Include the co-author line** at the end of commit messages:
   ```
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

4. **Check what will be committed** before committing:
   ```bash
   git status
   git diff --staged
   ```

## Commit Message Format

**IMPORTANT: Use multiple `-m` flags for commit messages — do NOT use heredocs (`<<'EOF'`).**

Heredocs create multi-line Bash commands that don't match permission allowlist glob patterns (the `*` wildcard doesn't match newlines). Multiple `-m` flags keep the command on a single line.

Single-line message:
```bash
git commit -m "Title line here" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
```

Multi-line message (title + body + co-author):
```bash
git commit -m "Title line here" -m "Body paragraph explaining the why." -m "Co-Authored-By: Claude <noreply@anthropic.com>"
```

Each `-m` flag adds a separate paragraph to the commit message (separated by a blank line in the git log).

## Don't Commit

- Large output files (check `.gitignore`)
- Credentials or secrets (`.env`, `credentials.json`, etc.)
- IDE-specific files unless project convention says otherwise
- Claude Code worktrees (`.claude/worktrees/`)
- Rendered HTML from Quarto/Rmarkdown scripts — these are large, regenerable artifacts

## When to Prompt User About Commits

- After completing a significant task
- Before switching to a different area of the codebase
- At the end of a working session (use `/done` skill)
- After updating documentation

## Troubleshooting

**"Command not found" for git tools**
→ Git should be available system-wide; check PATH if issues arise

**Merge conflicts**
→ Alert the user and explain the conflict before attempting resolution

**Git push fails with SSH permission denied**
→ SSH keys aren't available in Claude Code's terminal environment
→ Switch remote to HTTPS: `git remote set-url origin https://github.com/OWNER/REPO.git`
→ The gh CLI provides HTTPS authentication automatically