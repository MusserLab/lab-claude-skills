---
name: feedback-walkthrough
description: Walk a student through feedback their advisor left on their project — pedagogically, one item at a time, so the student understands and acts on it themselves. Use when a student wants to go through advisor/PI feedback, work through a feedback issue (a GitHub issue labelled `feedback`) or a feedback doc (docs/feedback/*.md), or says "walk me through the feedback", "go through Jacob's feedback", or "help me with my feedback". This is the student side; the advisor authors it with the student-feedback skill.
user-invocable: true
---

# Feedback Walkthrough (student side)

Help a student work through feedback their advisor (e.g. Jacob) left on their project. The goal
is for the student to **understand and act on the feedback themselves** — a reflective dialogue,
not a checklist you complete for them.

## Mindset

- The feedback exists to deepen the student's understanding of their **data**, their
  **analysis**, and the **biological reasoning** — and to build their judgment. Treat each item
  as a chance to think, not a defect to silently patch.
- **Coach, don't do it for them.** When an item calls for a change, help the student make it —
  explain the idea, let them attempt it, review what they wrote — rather than implementing it
  yourself. The learning is in the doing.
- **Feedback is two-way.** The advisor explicitly invites push-back and the student's own ideas.
  Encourage the student to question the suggestion, question the field's conventions, and
  propose alternatives — and capture that.
- Be encouraging and curious, never grading.

## Steps

### 1. Find the feedback
Feedback arrives as a **GitHub issue** (the default). List open feedback issues and read the one
to work through:
```bash
gh issue list --label feedback --state open      # find the round(s)
gh issue view <n> --comments                     # read the issue body + any prior discussion
```
If there are several, ask which to work through. Note each item's priority from the task-list
and item headings (`needs-attention` > `consider` > `optional`). If `gh` errors with an
auth/not-installed message, run `gh auth login` (or install `gh`), or use the fallback below.

**Fallback:** older or non-GitHub feedback may be a doc at `docs/feedback/*.md` — read that
instead.

### 2. Orient
Reflect back the structure: read out **what's working well first** (it matters), and how many
items there are by priority. Offer to go in priority order, and make clear there's no rush —
this is for thinking, not speed.

### 3. Walk through one item at a time
For each item, do NOT jump to the fix:
1. **Restate** what the advisor noticed (the observation).
2. **Ask the student first** — what do they think is going on, and why might the advisor have
   raised this? Draw out their understanding of the data / analysis / biology *before* revealing
   the advisor's reasoning.
3. **Then surface the advisor's "why"** and suggestion, and close any gap between the student's
   take and the advisor's.
4. **Invite a decision** — agree, adapt, or push back with their own approach. All are valid;
   the advisor asked for exactly this.
5. **If a change is warranted, coach the student to make it themselves** — explain, let them
   attempt, review. Implement it directly only if they ask *and* can articulate why it's right.
6. **Record their response as an issue comment** — `gh issue comment <n> --body "..."` — their
   reasoning, their decision, any change made, and anything they want to raise with the advisor.
   The comment is the record of record (and it's what notifies the advisor). If you have write
   access to the repo — you do on your own project — you can also **tick the item's task-list
   checkbox** in the issue body via the GitHub web UI so per-item progress shows; ticking edits
   the issue body, so if you can't edit it, the comment alone is enough. (Fallback doc: write the
   response in that item's `Student response:` field instead.)

Move at the student's pace; one or two items per sitting is fine.

### 4. Wrap up
Summarize what was worked through, what's left, and a short list of items the student wants to
**discuss with the advisor** (push-backs, open questions, uncertainties). Post that
discuss-with-advisor list as a final summary **comment** on the issue — the comment is what
notifies the advisor (ticking checkboxes does not). The filled-in comments (and any ticked
checkboxes) are the hand-back — the advisor sees them on the issue.
**Don't close the issue** — the advisor closes it once they've reviewed. (Fallback doc: leave the
`Student response:` fields filled in instead.)

## What this skill does NOT do
- Does not bulk-apply the feedback or silently implement fixes — the student does the work.
- Does not change the advisor's observations or reasoning — it only records the student's
  responses (as issue comments / ticked checkboxes; fallback: the doc's `Student response:` fields).
- Does not close the feedback issue (the advisor does) or commit/push to the shared repo without
  the student's say-so (their normal workflow).
