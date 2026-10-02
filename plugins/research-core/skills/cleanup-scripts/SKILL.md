---
name: cleanup-scripts
description: >
  Consolidate scratch or exploratory code from the current work when its retained role is known.
  Use when the user asks to clean up scripts, when session-owned scratch files need disposition,
  or when a changed workflow has unclear helper/output ownership. Do not use as a mandatory
  project-wide closeout scan or to enforce numbering, lifecycle labels, or one script format.
---

# Consolidate Session-Owned Scientific Code

Clean up only the files and workflows in the agreed scope. The goal is to leave retained work
discoverable and runnable without tidying away useful exploration, provenance, or outputs.

## Establish authority and ownership

Read the project instructions and registered active-file/scientific authority before moving or
deleting code. Identify the session-owned files, their purpose, current consumers, producing
outputs, and any related plan/Issue. Preserve unrelated dirty work.

Do not infer status from a path name. `scratch/` or `exploratory/` may contain disposable trials,
influential investigation, a retained terminal report, or code still cited by a document. For each
candidate, determine:

- what question it answered or test it performed;
- whether it influenced scope, method, interpretation, or a retained result;
- which code, document, output, or person still consumes it;
- what a move, merge, rename, or deletion would break;
- whether its exact producing state is preserved elsewhere.

## Choose the smallest disposition

Use the project's actual conventions; do not impose numbered scripts, QMD, lifecycle headers, or a
fixed `scripts/`/`outs/` correspondence on projects that do not use them.

- **Keep in place:** the name/location still communicates a useful role and has real consumers.
- **Integrate:** stable logic belongs in a retained producer or meaningful shared helper. Move only
  the part that reduces duplication or clarifies the workflow; keep consequential choices visible.
- **Preserve as evidence:** influential or cited exploration no longer executes routinely but must
  remain recoverable with its disposition and relevant output/evidence links.
- **Remove:** confirmed disposable, session-owned material with no retained consumer or evidence
  value. Verify recoverability or obtain the required file-safety approval before irreversible loss.
- **Leave unresolved:** authority, scientific meaning, ownership, or consumers remain ambiguous.
  Report the ambiguity rather than guessing.

Helpers should exist because they reduce a researcher's burden, not because every unnumbered file
must leave `scripts/`. Do not split sole-use logic when its calling workflow is clearer inline. Do
not renumber or rename working producers merely to regularize an inventory.

## Preserve outputs and producing state

Before consolidating code, trace its outputs and downstream uses. Generated, ignored, or orphaned
does not mean disposable. Moving or archiving a producer does not move, recreate, or invalidate its
outputs automatically.

For retained scientific use, verify that the relevant producer, launcher, helpers and configuration
match a focused commit, and record that identity with the inputs, command, seed and environment in
the project's established provenance record. Reuse an existing commit when the source is unchanged;
unrelated dirty work does not block the scoped source. Keep scripts and outputs separate rather than
copying a generic source bundle into `outs/`, and preserve any specialized custody record the project
already requires. Cleanup does not automatically commit scientific source merely because files were
inspected or moved. The lead or assigned worker handles a needed scoped commit or push only when
the task and user or project instructions authorize it; the analytical script must never stage, commit or push.
Owned draft or experimental code may be committed before scientific acceptance. A retained
scientific run still requires a settled approach and source that matches the recorded commit.

If a later run is needed, use a fresh destination unless the existing destination is confirmed
producer-owned and disposable. Cleanup itself does not authorize a scientific rerun.

## Apply and check

Show the concrete stay/integrate/preserve/remove mapping when a destructive or consequential move
needs a decision. Within already authorized, reversible session work, apply routine consolidation
without reopening settled implementation choices.

After editing:

- read the retained workflow in data-flow order;
- check changed imports, links, launcher paths, and output references;
- confirm unique rationale and influential exploration remain discoverable;
- inspect the exact diff and preserved/removed paths;
- update only the affected active-file or decision record when its role changed.

Report the files consolidated, retained, removed, or left unresolved; affected consumers; checks;
and limits. Do not create a project-wide audit report, rebuild summaries, or scan unrelated scripts
as a cleanup side effect.
