---
name: feedback-walkthrough
description: Walk a student through feedback their advisor left on their project — pedagogically, one item at a time, so the student understands and acts on it themselves. Use when a student wants to go through advisor/PI feedback, work through a feedback doc (e.g. docs/feedback/*.md), or says "walk me through the feedback", "go through Jacob's feedback", or "help me with my feedback". This is the student side; the advisor authors the doc with the student-feedback skill.
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
Locate the feedback doc(s) — usually `docs/feedback/*.md`. If there are several, ask which to
work through. Read it and note each item's priority (`needs attention` > `consider` > `optional`).

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
6. **Record their response** in that item's `Student response:` field — their reasoning, their
   decision, any change made, and anything they want to raise with the advisor.

Move at the student's pace; one or two items per sitting is fine.

### 4. Wrap up
Summarize what was worked through, what's left, and a short list of items the student wants to
**discuss with the advisor** (push-backs, open questions, uncertainties). Leave the doc with the
`Student response:` fields filled in — that's the hand-back to the advisor.

## What this skill does NOT do
- Does not bulk-apply the feedback or silently implement fixes — the student does the work.
- Does not change the advisor's observations or reasoning — it only records the student's
  responses (and may mark an item as addressed).
- Does not commit/push to the shared repo without the student's say-so (their normal workflow).
