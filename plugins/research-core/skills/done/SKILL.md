---
name: done
description: >
  Close a session or explicitly scoped worker task when that is the whole message's intent.
  Quoted wrap-up language, a finished subtask, and commit-then-continue do not trigger closeout.
  Complete accompanying requested work first, reconcile only affected records and
  dependency specifications, verify owned changes, perform only authorized Git work, and report
  the actual outcome. For a cross-machine transition, follow the project's departure and
  arrival procedure; close out this session when requested.
---

# Finish the Work and Leave a Truthful Handoff

`done` is a final reconciliation, not a project-wide maintenance event. Finish the intended work,
preserve scientific meaning and unrelated state, then account for what actually happened.

## 1. Interpret the whole message

An actual request to close the session triggers this skill even when it also requests a final edit,
record, check or deliverable. Quoted discussion, a finished subtask, or “commit then continue” does
not trigger it. Complete requested work before closeout unless it crosses an unresolved
scientific, destructive, external, deployment, or publication boundary. Do not reduce “update the
plan and wrap up” to a summary of work that has not been done.

Use the conversation and current state to identify:

- the objective and paths owned by this session;
- remaining authorized work needed to make it reviewable;
- decisions/evidence that changed the current authority;
- explicit holds, pending scientific discussion, or separate deployment/external actions.

## 2. Establish role, checkout, and authority

Verify the physical project root, host, branch, remote, dirty/staged state, and unrelated changes.
Read project instructions, applicable overrides/extensions, and the coordination declaration with
[the read-only reader](../new-project/references/work-coordination.md). Project type does not select
task authority.

- **Plan/undeclared:** registered plans retain their established roles. Missing declarations do not
  authorize adoption.
- **GitHub:** Issues own executable task state. Load [GitHub closeout](references/github-closeout.md)
  if this session has a material, already identified Issue event.
- **Hybrid:** programme plans own intent, consequential decisions, phase boundaries, and human
  acceptance; Issues own executable tasks. Update each only for its own subject.
- **Invalid/conflicting:** surface the problem and hold model-dependent writes; continue valid
  independent closeout.

Read any project-specific closeout extension named by the native project instructions, including
`.claude/done_extensions.md` where that convention is established. Apply authorized additions at the
specified points without letting them erase core truthfulness, ownership, or safety boundaries.
Match older numbered extension steps to their named operation, not this version's new step number;
surface an ambiguous extension before doing its dependent action.

In a collaborator/third-party repository, keep personal overlays, private review notes, and local
session artifacts in their established private locations and out of the owner's commit. Recommend
the exact shared change set, but do not push, open a PR, or publish feedback without the applicable
collaborator authorization. Preserve owner conventions instead of installing the user's own project
records or cleanup rules.

### Worker closeout

If this task is a bounded worker/subagent assignment, complete the assigned actions and always end
with a scoped handback. Preserve only assigned deliverables and relevant evidence; report changed
files, checks, limitations, host/checkout, and unresolved seams. Do not rewrite shared project
plans/logs/registries, commit/push, integrate branches, retire worktrees, or perform external actions
unless the brief expressly assigns that action. Assignment of a checkpoint or push does not assign
integration or a broader closeout. Use only worker and task controls the current client actually
provides; do not invent retirement or messaging actions. The lead handles every unassigned closeout
action and reconciles canonical records and Git once.

## 3. Reconcile affected meaning and history

Summarize what changed, why, what evidence supports it, and what remains unresolved. Update only
records whose current meaning changed during this session.

### Current authority

- In Plan work, update the affected phase/decision record with actual work, evidence, review state,
  scientific decisions, limitations, and next substantive question. Do not restructure the plan at
  closeout or infer acceptance.
- In GitHub work, preserve task evidence in a meaningful Issue comment/body change only when there
  is a material event and that external write is already authorized or separately approved.
- In Hybrid work, keep executable state in the Issue and programme meaning/acceptance in the plan;
  cross-link without mirroring checklists, labels, state, or counts.
- Keep scientific/data, active-file, architecture, provenance, validation, and human acceptance in
  their field-specific records. A commit or closed Issue does not replace them.

When a substantial phase reached an audit/review point, integrate relevant worker notes into one
durable record with scope, consequential findings/dispositions, evidence, and limits. Do not save a
per-script or per-worker report merely because one participated.

### Chronological record and registry

If the project already uses session logs or another chronological record, add one concise entry for
this session in its established location and format. Record work, authority links, consequential
decisions, checks, limitations, and a dated resumption cue. GitHub/Hybrid logs remain history, not a
parallel backlog. Do not migrate log formats, trim history, manufacture a new log system, or scan all
old entries during closeout.

Update the root Project Document Registry only for a document created, removed, renamed, or whose
declared role changed in this session. Keep the entry descriptive and link the actual authority.
Do not rebuild a catalog of scripts, datasets, skills, numerical results, or task status.

Do not regenerate `STATUS_SUMMARY.md` by default. A project-specific instruction or real consumer
may require it; then treat that as an explicit local closeout step without making it a universal
rule. Do not perform broad project audits, global memory/skill maintenance, system-incident redesign,
or unrelated documentation cleanup at wrap-up.

### Relevant shared-system evidence

If this work exposes a reusable defect in shared tooling, use the project's or distribution's
established support route when that write is already in scope. Otherwise include the occurrence,
consequence, checks, and actual deployment state in the handoff. Keep project science in its project,
and do not create an incident for every observation or ask each worker to perform global maintenance.
A public closeout has no dependency on a personal delegation guide, outcome ledger, or maintainer script.

### Completed HPC job observations

If this session handled HPC jobs and the installed Yale/HPC package is available, follow its
`hpc/references/resource-learning.md` procedure for completed jobs not yet captured. Use existing
job/run evidence and the user's configured private profile; do not scan unrelated jobs, wait for
pending jobs, or edit installed skills. Pending jobs keep their normal project resumption cue.
Without that optional package or authorized host access, preserve relevant IDs/evidence in the
project and report what remains unchecked. Ordinary non-HPC closeout skips this step.

### Scientific acceptance

Preserve the distinction between prepared, technically checked, review-ready, scientifically
accepted, published, and closed. If the agreed stop is scientific review, orient the user to the
question, inputs, transformations, actual figures/tables, principal findings, anomalies, and limits.
Invite their interpretation before recording acceptance. Do not accept on their behalf.

### Retained scientific source

Before reporting a scientific run as retained, downstream-ready, or shareable, verify that its
relevant producer, wrapper, helpers and configuration match a focused commit. Reuse an existing
commit when those source bytes are unchanged; unrelated dirty work does not block the scoped
provenance. Keep source in tracked source locations and outputs in their owned destinations rather
than creating a generic code-copy bundle in `outs/`. Preserve any specialized custody record the
project already requires.

The lead, or a worker expressly assigned the scoped checkpoint or working-branch push, handles that
Git action only when the task and user or project instructions authorize it; this skill grants no
additional Git permission. A worker's assigned Git action does not assign integration, shared records, or
other closeout work. Do not place `git add`, `git commit`, or `git push` inside an analytical script.
Owned draft or experimental code may be committed before scientific acceptance; the commit does not
accept the method or result. If the approach is still unsettled, hold retained scientific use rather
than inventing acceptance from Git.

## 4. Reconcile dependencies for every project type

Before the final commit, inspect session-owned code/config changes for new, removed, or changed
runtime dependencies. This applies to general, documentation, and data-science projects alike.

- Update the project's existing dependency specification and lock/snapshot using its declared
  environment/tooling when the code change requires it.
- Keep host-specific runtime details in the appropriate project record and preserve deliberate
  local/cluster differences.
- Do not create an environment, install packages, or rewrite a lockfile merely because `done` ran.
- Do not claim the dependency state is current from a hand-edited lockfile or an unrun tool.

If required dependency metadata cannot be updated or verified, remove the unsupported dependency or
hold the final commit and report the exact blocker. A project with no dependency change needs no
environment scan.

## 5. Verify the owned result proportionally

Read the main changed workflow in execution/data-flow order and challenge whether each added layer
is needed and understandable. Run the smallest checks that can catch plausible failures introduced
by the actual diff. Reuse current relevant passing evidence; do not rerun science or unrelated suites
for a wording or bounded change.

Check as applicable:

- syntax/parse/frontmatter and changed local links;
- focused normal and important failure paths for behavioral changes;
- exact input/output and producing-state evidence for retained scientific work;
- preservation of retained/shared/manual/downstream-consumed outputs;
- phase-final figure-producing run outputs in PNG, PDF, and SVG;
- changed dependency specifications and environment identity;
- source versus installed/runtime state when deployment is part of the authorized work.

Distinguish static review, executed checks, installed readback, natural use, scientific acceptance,
and publication. Stop when further checks repeat the same evidence rather than change confidence.

## 6. Complete authorized Git work

Inspect the full session-owned diff, staged state, and outgoing ancestry. Stage only owned files or
hunks. Preserve unrelated dirty/staged work and shared history.

For repositories the user owns, follow the current task and native user or project instructions for
commit, push, and integration authority. Make ordinary coherent Git changes without repeating a
permission question when that authority is already established. When accepted work is authorized
for integration, follow the repository's normal workflow, including a PR where used: review its
exact head and full diff, confirm the target and permissions, resolve routine mechanical conflicts,
check required checks, integrate, and verify the default branch. Follow the repository's reviewer
and exception policy; this public skill grants no auto-push policy or owner/admin exception. Never
alter branch protection to make a merge possible. Preserve producing commits cited by retained
scientific provenance and follow the project's Git conventions.

Failed checks or a changed reviewed head pause integration for investigation, scoped repair,
renewed review and affected checks. Confirm a changed target remains authorized. Ask the user about
substantive boundaries: public publication, deployment/live installation, collaborator or
third-party repository writes, remote/authentication changes, shared-history rewriting, semantic
conflicts, changes to others' work, or an explicit substantive hold. Git integration is not
scientific acceptance. A wrap-up request does not authorize an external message, Issue mutation,
deployment or public release that was not already in scope.

Before each mutation, recheck the relevant baseline. After commit/push/integration, read back refs
and report exact hashes/destinations. No owned changes is a valid result; do not invent a commit.
If an action fails or is held, keep dependent publication/closure claims pending and report the
actual disposition.

## 7. Apply separately authorized Issue or external actions

For valid GitHub/Hybrid work with a material authorized Issue action, follow
[GitHub closeout](references/github-closeout.md) after required local checks/Git prerequisites.
Apply accepted closure last and read back actual state.

Do not post Slack/email or another external update as a standard wrap-up step. If the user already
requested one, use the relevant skill/connector and its explicit destination/content boundary.
Otherwise leave a ready draft in chat only when it materially helps; do not add an approval ritual
for routine closeout.

## 8. Reassess worktree and branch ownership

The lead assesses only worktrees/branches owned by completed implementation work. Confirm that
changes are recoverable from recorded refs, preserve useful untracked/ignored evidence, and verify
no task, process, job, or installed consumer still depends on the checkout.

Follow project-specific retirement policy and use the supported Git/app mechanism. Unfinished work
or a concrete dependency justifies retention. Delayed pilot/acceptance alone need not retain a
worktree once version, deployment, recovery, evidence, and pending acceptance are recorded. Branch
deletion is separate. Keep conversation history visible; never archive or delete a task/chat unless
the user explicitly asks.

If the calling task cannot move itself or retirement is not authorized, name the exact pending
action rather than declaring cleanup complete.

## 9. Report the actual outcome

Give a concise factual handback:

- work and decisions completed;
- records and registry entries changed;
- checks run and their limits;
- dependency specification/environment disposition;
- commits, pushes, integrations, Issue actions, and readbacks;
- held, failed, pending, or unverified actions;
- next substantive question or resumption cue.

Do not say the wrap-up is complete while a required action or approval remains unresolved. An
explicit hold is a truthful disposition, not a successful action. Preserve unrelated work and name
the exact remaining owner/boundary.
