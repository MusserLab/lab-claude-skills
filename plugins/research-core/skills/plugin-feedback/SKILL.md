---
name: plugin-feedback
description: Draft and, after review, submit research-plugin bugs, compatibility reports or improvements. Use when the user asks to report a plugin problem, or offer a draft when a reproducible plugin failure blocks work. Do not use for advisor feedback authoring or feedback-walkthrough.
---

# Report a research-plugin problem

Use the existing conversation to draft a small useful report. One distinct failure or suggestion
per report. Preserve any already selected destination; do not redirect an existing private report.

1. Identify the affected package and version, client/version, interface, operating system,
   execution host and installation scope. Record the concrete action, observed result, expected
   result and a minimal reproduction. Unknown fields remain unknown; ask only for essential gaps.
2. Choose visibility before drafting. Public package defects with a fully shareable reproduction
   go to https://github.com/MusserLab/lab-claude-skills/issues. Private package content, unpublished
   science, private identities, lab-only paths or uncertain eligibility stay private. Use the
   private distribution's documented issue tracker only when it exists and access is verified.
   If that destination is unavailable, keep a local draft and ask the maintainer for the route;
   never fall back to public submission. Do not invent a private repository URL.
3. Sanitize public reports: use synthetic identifiers and minimal excerpts, remove credentials,
   personal/home paths, private repository names, unpublished results and unrelated conversation.
   If removing private context makes the report misleading or unusable, retain a private draft.
   Never attach whole logs, source files or screenshots without inspecting their complete contents.
4. Show the exact destination, title and full body. Explain any remaining uncertainty. Obtain the
   user's approval of this concrete report before submitting; a general report request does not
   approve unreviewed private content. Changes to destination or contents need renewed review.
5. Submit with an available authorized connector, or write the approved body to a temporary file
   and use `gh issue create --repo OWNER/REPO --title TITLE --body-file BODY_FILE`.
   Do not assume authentication or create repositories/labels to make submission work. Report the
   actual returned URL and verify the issue. A failed command is not a submitted report.

Without a submission tool, provide the reviewed title/body and the repository's new-issue page
for manual copy/paste. Avoid putting private report bodies in URL query strings. A missing
private tracker holds only submission, not safe local diagnosis.

Suggested body:

```markdown
Package/version:
Client/version and interface:
OS / execution host / installation scope:
Action and minimal reproduction:
Observed:
Expected:
Checks already tried:
```

Use ordinary language and concrete evidence. Installation, fixture checks and real research use
are different observations; do not infer scientific validity from a passing package test.
