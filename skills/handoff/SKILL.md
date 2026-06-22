---
name: handoff
description: Coordinate handoff between local (macOS) and cluster (Bouchet) Claude Code sessions for the same project. Use when the user mentions switching machines ("continuing locally", "switching to cluster", "back on the laptop", "I'll work on the other one"), pastes a `git status` from the other side, or when Claude is about to give cross-machine instructions involving rsync, `git push`+`git pull`, `/sync-project`, or `/sync-cluster`. Enforces a strict departure → gate → arrival sequence with multi-chat awareness — pending work in the working tree or unpushed commits may belong to other parallel chats and must NOT be silently swept up. Always write an explicit "DO NOT start work on arrival side yet" gate before any arrival instructions. Do NOT load for single-machine work, regular `/done` wrap-ups within one machine, or git questions unrelated to cross-machine coordination.
user-invocable: true
---

# Handoff between local and cluster sessions

When the same project is worked on across local (macOS) and cluster (Bouchet) Claude Code sessions, the gap between `/done` (per-side wrap-up) and `/sync-project` (per-side arrival) is unmanaged. This skill fills the gap: it enforces a strict **departure → gate → arrival** sequence so the user never starts work on the arrival side before the departure side is at a clean pushed state.

---

## The core rule

> **Never write "do this on side B" instructions without first verifying side A is committed AND pushed AND working tree clean.**

Most concretely: before writing any instruction that involves `git pull`, `rsync`, `/sync-project`, or `/sync-cluster` on the arrival side, write the explicit gate:

> **DO NOT start work on \[arrival side\] yet.**

Hold that gate in the conversation until the user reports the arrival side is clean.

---

## When this skill triggers

- User says: "continuing locally" / "on the cluster", "I'll switch to ...", "back on the ...", "now I'm on ...", "moving to ..."
- User pastes a `git status` (or other git output) from a side that is not where Claude currently is
- About to issue cross-machine commands: `rsync`, `git push` immediately followed by `git pull` on the other side, `/sync-project`, `/sync-cluster`
- Mid-session, the user mentions starting work on the other side ("local Claude Code can do this part", "I'll do that on cluster")

---

## Workflow

### Step 1 — Departure-side audit

Before issuing ANY arrival instructions, run all three:

```bash
git status                          # working tree state
git log @{u}..HEAD --oneline        # local commits not on origin
git log --oneline -5                # recent history (sanity check)
```

For each piece of pending state, classify it before acting:

| State | Owner | Action |
|-------|-------|--------|
| Files modified in THIS session | This session | Commit per `/done` rules — specific files by name, never `git add -A` |
| Files modified by ANOTHER chat | Other chat | **Surface to user; do not commit** without explicit confirmation |
| Untracked files from THIS session | This session | Stage + commit |
| Untracked files from ANOTHER chat or unknown origin | Other chat / unknown | Surface to user; do not stage |
| Unpushed commits authored in THIS session | This session | Push after committing this session's work |
| Unpushed commits from ANOTHER chat | Other chat | **Surface to user; ask whether to push them** — the other chat may want to amend before pushing |

This is the **multi-chat-safe** discipline: this session only owns this session's changes. Anything else needs the user's explicit decision before being swept into a push.

### Step 2 — The gate (explicit message to user)

Once departure-side is clean and pushed, write the gate verbatim:

```
🛑 DO NOT start work on [arrival side] yet.

Departure ([cluster|local]) is now at commit <short-sha>, pushed to origin/main.
Working tree clean.
[If other chats had pending work: that work was left untouched; you may
need to coordinate with those chats before they push.]

Run the arrival steps below in order. Do not begin any new edits on
[arrival side] until step N below reports clean.
```

The gate is the most important sentence the skill produces. It is what was missing in the 2026-05-07 BUSCO Phase 2 case study — without it, the user reasonably assumes "I can start now while you finish wrap-up here."

### Step 3 — Arrival-side recipe

Write the arrival commands as a **checkpointed sequence**, not a "run all of these" block. Each step has a verification, and a STOP-and-report-back gate if the verification fails:

```bash
# On [arrival side]:

# === Step 3a — verify clean state ===
cd <project_root>
git status
# Expected: "On branch main" + "Your branch is up to date with 'origin/main'."
#           or "Your branch is behind 'origin/main' by N commits"
# If you see uncommitted changes: STOP and report back — they may be from
# another chat. Do not proceed.
```

```bash
# === Step 3b — pull ===
git pull --ff-only
# If --ff-only fails: STOP and report — there may be local commits to merge.
# Do not run plain `git pull` without --ff-only unless you know there are
# divergent local commits AND you want a merge.
```

```bash
# === Step 3c — env updates if needed ===
# Only if conda env or renv lock may have changed during the departure session:
# /sync-project
```

```bash
# === Step 3d — only after the above are clean, RESUME WORK ===
```

### Step 4 — When both sides are already divergent

If the departure-side audit reveals the working state has already drifted from origin AND the arrival side has uncommitted changes touching the same files — i.e., the gate was not held and parallel work has already happened — manual reconciliation is required.

The recovery recipe lives in [`references/divergence_recovery.md`](references/divergence_recovery.md). It captures the recipe used in the 2026-05-07 BUSCO Phase 2 case (commit-locally-first, then `git pull --no-rebase`, then resolve markers).

---

## Multi-chat scenarios

The same machine can run multiple Claude Code chats in parallel. Handle each:

### Scenario A: One chat per side, sequential

The clean case. Skill applies as written. Gate works.

### Scenario B: Multiple chats on the SAME side

Common for parallel workstreams (e.g., one chat doing analysis, another writing docs). Each chat's `/done` only commits files it modified. When ANY of those chats does a handoff:

- Do NOT commit other chats' uncommitted files
- Do NOT push other chats' unpushed commits unless the user explicitly confirms
- Surface the multi-chat state to the user so they can coordinate

### Scenario C: Active chats on BOTH sides simultaneously

The handoff model breaks down. Refuse to coordinate a handoff in this case:

> Both sides have active chats (parallel work in progress on local AND cluster). The handoff model assumes one side is fully wrapped before the other resumes. Pick one side to finish first; come back when only one side is active.

Don't try to handoff while both sides are actively producing commits.

### Scenario D: User wants to push another chat's commits

If the user says "yes, push that other commit too — that chat is done, just hadn't pushed," proceed but note in the handoff gate message that you pushed work that wasn't from this session. The other chat may still need to know its push happened.

---

## Anti-patterns

These are the failure modes this skill prevents. **Do not do any of these.**

| Anti-pattern | What it causes |
|--------------|----------------|
| Issuing arrival instructions before departure is committed+pushed | User starts working on stale state, both sides diverge |
| Telling the user "after you switch to local, do X, Y, Z" without first writing "DO NOT start work on local yet" | User starts work in parallel with the wrap-up; divergent commits |
| Running `git add -A` or `git add .` during /done or handoff | Picks up another chat's uncommitted work |
| Pushing commits another chat made without surfacing them to the user | Other chat loses ability to amend before push |
| Using `git pull` without `--ff-only` when the goal is a clean catch-up | Silently produces a merge commit when you intended a fast-forward |
| Treating uncommitted files in `git status` as "this session's mess to clean up" | Not all dirty files belong to this session |
| Telling the user to run `/sync-project` while they have uncommitted changes | `/sync-project` happy-paths assume a clean tree; surprises ahead |

---

## Case study: 2026-05-07 BUSCO Phase 2

Concrete example of how it goes wrong without this skill. Refer to it when the discipline feels overcautious — the cost of skipping the gate is not abstract.

**What happened:**
1. Cluster session was mid-`/done` with uncommitted `.claude/CLAUDE.md`, `.claude/MBL_SPONGE_ISOSEQ_PLAN.md`, `STATUS_SUMMARY.md`.
2. User said: *"I'm continuing the analysis of the IsoSeq data locally."*
3. Cluster Claude gave a sync recipe assuming serialized work, but stayed mid-/done. **Did not write a "DO NOT start work locally yet" gate.**
4. User started parallel local work: edited `.claude/CLAUDE.md`, `.claude/MBL_SPONGE_ISOSEQ_PLAN.md`, `batch/sponge_isoseq_qc/README.md`, added 03_mt_markers scaffolding + 17_spongilla_utr_candidates.qmd.
5. Reconciliation required a manual three-way merge with conflicts on the two `.claude/` files. Resolution took ~20 minutes of conversation.

**What the skill enforces to prevent this:**
- At step 2, recognize "continuing locally" as a handoff trigger.
- At step 3, refuse to give arrival instructions; instead complete cluster /done first (commit + push).
- At step 4, write the gate verbatim: *"DO NOT start local work yet. Cluster is at commit X, pushed."*
- At step 5, only THEN give the arrival recipe.

**Cost comparison:**
- Doing it right: one extra cluster commit + push (~30 seconds) before local work starts.
- Doing it wrong: ~20 minutes of merge resolution.

---

## Relationship to other skills

- `/done` — per-side wrap-up. Does not handle handoffs by itself. The handoff skill triggers ALONGSIDE /done when /done detects an imminent machine switch (or runs after /done if the switch is announced after wrap-up starts).
- `/sync-project` — per-side arrival (git pull + conda env + renv). The handoff skill calls `/sync-project` as part of arrival-step 3c, AFTER the gate has been held.
- `/sync-cluster` — separate workflow for `~/.claude/` skills + config (not project git). Handoff skill mentions it as a follow-up if the departure session touched `~/.claude/`.

---

## Quick reference card

For Claude's own use during a handoff. The full sequence in 6 steps:

1. Detect handoff trigger.
2. Run departure audit (`git status`, `git log @{u}..HEAD`).
3. Classify pending state by owner; commit + push only THIS session's work, surface other chats' work to user.
4. Confirm origin matches departure HEAD.
5. **Write the gate.** ("DO NOT start work on \[arrival\] yet.")
6. Write arrival recipe as checkpointed steps with STOP gates.
