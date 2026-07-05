---
name: plugin-feedback
description: File a suggestion, bug report, or new-skill idea about the lab-claude-skills plugin as a GitHub issue on MusserLab/lab-claude-skills. Use when the user hits a limitation in a lab skill, says a skill did something wrong or didn't activate, wants to suggest a skill improvement or a new skill, or says "file a plugin issue", "report this skill", "suggest a skill", or invokes /plugin-feedback. Also invoked when Claude offers to capture skill friction per the general-reminders standing instruction. Do NOT load for the student-feedback / feedback-walkthrough advisor-feedback workflow, or for filing issues on a user's own project repo (use gh directly for those).
user-invocable: true
---

# Plugin Feedback

Capture an idea, rough edge, or bug about a lab skill and file it as a GitHub issue on
[`MusserLab/lab-claude-skills`](https://github.com/MusserLab/lab-claude-skills/issues), so skill
improvements reach the whole lab. Works whether or not the user has the `gh` CLI authenticated.

## When this runs

- The user typed `/plugin-feedback`, or asked to report / suggest something about a skill or the plugin.
- Claude offered to capture skill friction (per the general-reminders standing instruction) and the user accepted.

You usually already have the context from the conversation — draft the report **from it** rather than interrogating the user.

## Step 1 — Draft the report (don't interrogate)

Pull together, mostly from the conversation you already have:

- **Which skill** was involved (or "new skill idea" / "general" if none).
- **Type**: wrong behavior · missing case · activation problem · new-skill idea.
- **What happened** — the concrete rough edge, in one or two sentences.
- **What was expected** instead.
- **Context** (optional) — the relevant snippet of the conversation.

Keep it short and specific. Ask the user only for what you genuinely can't infer.

## Step 2 — Confirm before filing (always)

Show the drafted title + body and ask the user to confirm or edit. **Never file without asking.**

Title format:

```
[skill-feedback] <skill-name>: <one-line summary>
```

Body template:

```markdown
**Skill:** <name, or "new skill idea" / "general">
**Type:** wrong behavior | missing case | activation problem | new-skill idea

**What happened:**
<one or two sentences>

**What I expected:**
<one or two sentences>

**Context (optional):**
<relevant conversation snippet>

_Filed via the `plugin-feedback` skill._
```

## Step 3 — File it

Write the confirmed body to a temporary file first (your scratchpad dir if you have one, else
`mktemp`). Call its path `BODY_FILE` below.

**Check for gh first:**

```bash
gh auth status
```

**If gh is authenticated** — create the issue:

```bash
gh issue create \
  --repo MusserLab/lab-claude-skills \
  --title "[skill-feedback] <skill>: <summary>" \
  --body-file BODY_FILE \
  --label skill-feedback
```

If the command errors because the `skill-feedback` label doesn't exist in the repo, retry the
**same command without `--label skill-feedback`**. Report the issue URL that `gh` prints back to the user.

**If gh is missing or not authenticated** — build a pre-filled "new issue" URL and give it to the
user to click (no auth needed). URL-encode the title and body:

```bash
python3 - "$BODY_FILE" <<'PY'
import sys, urllib.parse
title = "[skill-feedback] <skill>: <summary>"
body  = open(sys.argv[1]).read()
base  = "https://github.com/MusserLab/lab-claude-skills/issues/new"
q = urllib.parse.urlencode({"title": title, "body": body, "labels": "skill-feedback"})
print(f"{base}?{q}")
PY
```

Give the user the resulting link: *"Open this to file the issue (pre-filled): &lt;URL&gt;"*. If the
body is very long (URL over ~7000 chars), trim the context snippet — GitHub rejects over-long URLs.

## Common mistakes

- **Auto-filing.** Always confirm the drafted issue with the user first.
- **Interrogating.** You already have the conversation — draft from it; ask only for gaps.
- **Assuming gh works.** Check `gh auth status`; fall back to the pre-filled URL for users without gh.
- **Over-filing.** One issue per distinct idea. If the user raises several, ask which to file (or file separate issues).
- **Wrong repo.** Always `MusserLab/lab-claude-skills`, never the user's own project repo.