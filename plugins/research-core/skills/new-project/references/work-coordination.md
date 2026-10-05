# Project work coordination

This reference defines the explicit declaration consumed by setup, planning, closeout, and audit.
Project type and coordination model are independent. A declaration routes authority; it grants no
write permission by itself.

## Read the declaration

Resolve `<new-project-skill-dir>` from the installed `new-project/SKILL.md` location, then run
`python3 <new-project-skill-dir>/scripts/coordination.py --cwd <actual-project-directory>`
with an available compatible Python interpreter. The path is inside the skill, not the project.
This reader and reference also support planning, closeout and project audit.
For setup before Git initialization, use `--root <exact-target-root>`. The reader is read-only and
returns `model`, resolved `root`, declaration `sources`, and a diagnostic `reason`; invalid input
exits 2.

- The declaration is exactly one standalone `<!-- coordination-model: plan -->`, `github`, or
  `hybrid` in each native project instruction surface in scope: one Claude instruction file
  (`.claude/CLAUDE.md` or root `CLAUDE.md`) and/or root `AGENTS.md`, outside examples.
- When both Claude and Codex instructions exist, each may contain the declaration once and both must
  name the same model. A disagreeing, duplicate, malformed, local/override-only, or unreadable
  declaration is invalid until explicitly reconciled.
- No marker means **undeclared**: preserve established behavior without inferring adoption.
- Invalid/conflicting declarations enable no model-dependent GitHub mutation. Explain the conflict
  and continue valid independent work.

The human-readable section must agree with the marker and identify the actual authority links. The
reader does not establish adoption history, current access, source freshness, approval, or semantic
truth; the agent checks those. Do not infer a model from repository contents, Issues, plans, or logs.

## Setup fragments

### Plan

```markdown
<!-- coordination-model: plan -->
## Work Coordination

Registered Markdown plans own programme intent, consequential decisions, phase boundaries,
acceptance, and current work. Use the Project Document Registry to find the relevant plan. The
callable `/planning` workflow creates or improves one when substantial work genuinely needs it.
GitHub may store code without becoming a second task authority.
```

### GitHub

```markdown
<!-- coordination-model: github -->
## Work Coordination

[GitHub Issues]({GITHUB_REPOSITORY_URL}/issues) own executable scope, dependencies, current state,
and task completion. Meaningful comments hold task evidence, decisions, limitations, and acceptance.
Do not create Markdown task plans merely because work spans sessions. Architecture, scientific/data
authority, provenance, validation, and human acceptance retain their own registered records.
Chronological logs, when used, preserve history and dated resumption cues rather than a backlog.
```

### Hybrid

```markdown
<!-- coordination-model: hybrid -->
## Work Coordination

Registered Markdown plans own programme intent, consequential decisions, phase boundaries,
cross-phase relationships, and programme acceptance. [GitHub Issues]({GITHUB_REPOSITORY_URL}/issues)
own granular executable work and its current state. Read the relevant plan and linked Issues;
cross-link them without copying Issue checklists, assignees, labels, state, or counts into plans.
Task closure never accepts a dataset/programme phase or authorizes downstream work.
Chronological logs, when used, preserve history and dated resumption cues rather than a backlog.
```

## Adoption and compatibility

For an existing project, show the declaration, authority links, affected instruction projections,
record transition, and rollback before explicit adoption. Preserve old plans/logs as history and
evidence. Reversing the declaration is also a project-level decision.

Keep existing plan formats usable; do not require schema migration or reopen settled scientific
choices. Preserve collaborator privacy, validators, provenance, ratification, acceptance, host
differences, and configuration protection. A project-specific summary consumer may remain, but no
coordination model requires universal `STATUS_SUMMARY` regeneration.

Each client's native instruction discovery and live registration are separate concerns. Do not copy
skill wrappers, change machine-local client state, or assume Claude/Codex or workstation/cluster
behavior is identical merely because the declarations parse.
