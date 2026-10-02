---
name: git-conventions
description: Git commit practices and conventions. Use when committing changes, writing commit messages, creating branches, or making PRs.
---

# Git Practices

## Before Starting Work

```bash
# Check current branch and status
git status
git branch

# Pull only after checking that the branch, upstream, worktree and incoming history are compatible
git fetch
git status
git log --oneline --decorate --left-right HEAD...@{upstream}
```

## Committing Changes

1. **Commit frequently** — after completing each logical unit of work
2. **Write descriptive commit messages** — explain the "what" and "why"
3. **Follow the repository's attribution policy.** Add a co-author trailer only when the user or
   project requests one, using the identity they specify; do not invent a client identity.
4. **Check what will be committed** before committing:
   ```bash
   git status
   git diff --staged
   ```

## Commit Message Format

Prefer multiple `-m` flags for short, reviewable commit messages. If a longer body needs a file, use
a literal body file or another non-interpolating method supported by the current client and project.
Do not assume one client's shell-approval rules apply everywhere.

Single-line message:
```bash
git commit -m "Title line here"
```

Multi-paragraph message:
```bash
git commit -m "Title line here" -m "Body paragraph explaining the why."
```

Each `-m` flag adds a separate paragraph to the commit message. Add any requested attribution
trailer as another paragraph.

## Don't Commit

- Large output files (check `.gitignore`)
- Credentials or secrets (`.env`, `credentials.json`, etc.)
- IDE-specific files unless project convention says otherwise
- Client-managed worktrees, caches, or session state inside the client's configuration directories
- Rendered HTML from Quarto/Rmarkdown scripts — these are large, regenerable artifacts

## Commit authority and boundaries

When the current task and native user or project instructions authorize Git writes, make coherent
task-owned commits and working-branch pushes without asking again merely because a logical unit is
ready. This public skill grants no Git write authority by itself. Inspect status and the complete staged diff,
stage only owned paths, preserve unrelated dirty or staged work, and report what was committed and
pushed.

When the user or project authorizes integration of accepted work, complete it without another
permission question. Use the repository's normal route, preparing or updating a PR where used;
review the exact head and full diff, confirm the target and permissions, resolve routine mechanical
conflicts, check every required check, integrate, and verify the default-branch ref. Follow the
repository's reviewer and exception policy; this skill grants no owner/admin exception. Never
edit branch protection to make a merge possible.

A changed reviewed head or failed check pauses integration. Investigate and repair within agreed
scope, then review the updated diff and rerun affected checks before proceeding. A changed target
requires confirmation that it is still the authorized destination. Bring substantive holds,
semantic conflicts, changes to others' work, public/deployment boundaries and history rewriting
to the user. Do not squash, rebase away, or otherwise orphan a producing commit whose hash is recorded
in retained scientific provenance.

Before retained scientific execution, make or reuse a commit containing the producer, wrapper,
relevant local helpers and configuration, then verify those files match it. Record that full hash
with the run; unrelated dirty files do not prevent a focused checkpoint. Commit and push are agent
workflow actions, not operations embedded in scientific scripts. No new commit is needed when the
relevant source is unchanged. Report local checkpoint and verified remote push separately;
diagnose and report a failed push without claiming a remote backup. Git history is not scientific
acceptance and does not itself preserve external inputs or recreate the software environment.

Bring the user a concrete conflict at the boundaries above. End-of-session work still uses the
`done` skill.

## Troubleshooting

**"Command not found" for git tools**
→ Git should be available system-wide; check PATH if issues arise

**Merge conflicts**
→ Resolve routine task-owned conflicts when the intended result is clear; bring consequential or
  ambiguous semantic conflicts to the user with the affected paths and evidence

**Git push fails with SSH permission denied**
→ Inspect the current remote, intended destination and available authentication route; do not
  assume keys are unavailable or rewrite the remote automatically. Preserve the configured
  destination and obtain separate scope before making a real authentication or remote change.
