---
name: new-project
description: >
  Create a new project or scaffold an empty project directory with the smallest useful structure,
  instructions, environment specification, Git boundary, and declared work coordination. Use when
  the user asks to start or set up a project. Do not use to migrate an existing project's authority
  or impose data-science layout on a general project.
---

# Create a Project Around Its Actual Work

Agree the purpose and operating boundary before creating files. A project scaffold should make the
first real task easier; it should not predict every future directory, dependency, or governance need.

Run from the exact target directory. Verify host, physical path, parent repositories, existing
files, permissions, and unrelated work before writing.

## Settle the project boundary

Infer what is already clear and ask only for consequential missing choices:

- project purpose, intended users, and first real outcome;
- **data-science** or **general** project type (documentation/software remain general unless they
  actually use the scientific analysis conventions);
- Plan, GitHub, or Hybrid work coordination and its real authority links;
- languages/tools and whether a project-specific environment is needed;
- input/data custody, retained outputs, privacy, and external/shared storage;
- local-only versus cluster/dual-host use and the actual host-specific paths;
- repository ownership, remote destination, private/public visibility, and deployment boundary;
- any collaborator-owned content or existing material that must remain untouched.

Recommend Plan when programme/scientific questions and human phase acceptance drive the work;
GitHub for Issue-sized engineering tasks; Hybrid only when programme reasoning and executable tasks
clearly live at different levels. The researcher chooses the model. Read
[Work coordination](references/work-coordination.md); setup is not permission to create Issues,
milestones, boards, or a first plan.

Do not ask a fixed questionnaire after the answer is available from the requested project or
existing evidence. Explain material alternatives and their consequences.

## Create only the useful structure

### Data-science baseline

Use the smallest subset needed now:

```text
CLAUDE.md and/or AGENTS.md  # native project entry points for the clients in scope
.claude/                    # optional shared project records referenced by those instructions
scripts/                    # retained producers/analysis workflows
data/                       # external or registered inputs; scripts do not write here
outs/                       # producer outputs; ignored/generated never means disposable
```

Add `R/` or `python/` only for meaningful shared helpers. Add subdirectories, `batch/`, scratch,
exploratory, publication, or section layouts only when the agreed work needs them. Do not force
numbered scripts, QMD, lifecycle headers, or a one-script/one-output-folder scheme at project
creation. The active-file/data authority can describe whatever structure the project actually uses.

### General baseline

Create the native root instruction file or files for the clients in scope, plus `.claude/` only when
the project needs shared records, and only the code/document/source directories required for the first outcome.
Do not create scientific `data/`, `outs/`, script numbering, renv, or analysis conventions for a
general project.

For documentation projects, use the relevant documentation/site setup procedure for its native
structure, then apply `project-type: general` and the coordination declaration here.

## Establish environments without global mutation

Use the project's declared environment tooling. Do not change global Conda channels/solver or
install a generic package bundle as a side effect of scaffolding.

For Python work, agree the interpreter version and initial direct dependencies. If a new project
environment is part of the requested setup, create it through the `conda-env` procedure and record
a portable direct-dependency specification such as `environment.yml --from-history`. A general
project can use an existing compatible shared environment; do not create or assume `lab-general`
unless it is actually selected.

For R data-science work, agree the R version and use `r-renv` when the project needs an isolated
library. Record the exact R path only as host-specific project guidance. Do not install/snapshot a
broad default package set before the project needs it.

Keep dependency specifications current when dependencies are actually added. Environment creation,
package installation, cross-host restoration, and successful execution are separate verified states.

## Define custody and ignore behavior

Write a concise `.gitignore` for actual generated/build/cache/secret files. Include language and IDE
patterns only when relevant. Decide data tracking from custody and size, not one arbitrary threshold;
large or external inputs need a registered source/identity and retrieval guidance.

Ignoring `outs/` may keep generated files out of Git, but it never makes retained/shared/manually
edited or downstream-consumed results disposable. Document the producer and preservation/rerun
boundary in the appropriate project record.

For retained scientific use, the relevant producer, wrapper, helpers and configuration must
match a focused Git commit. Keep that source in tracked source directories and keep generated
results in `outs/`; do not scaffold a generic code-copy bundle inside output directories. Existing
specialized custody records remain valid and should be registered rather than replaced.

Cluster batch scripts and portable launchers are normally tracked; scheduler logs and large scratch
products are normally ignored unless the project has a different reviewed use. Keep site-specific
setup in thin wrappers and scientific logic in recoverable scripts.

## Generate native project instructions

Use the appropriate shared-content template:

- [general project instructions](templates/claude_md_general.md)
- [data-science project instructions](templates/claude_md_data_science.md)

Create a root `CLAUDE.md` when Claude Code is in scope and a root `AGENTS.md` when Codex is in
scope; do not assume Codex discovers `.claude/CLAUDE.md`. When both clients are in scope, keep shared
project facts in one clear record and make both native files useful entry points with the same
coordination declaration, without maintaining two independent copies of the full procedure.

Fill every retained placeholder with verified project facts. Omit empty sections instead of leaving
promises. Native root instructions should provide or point directly to:

- project purpose and stable boundaries;
- actual environment/setup guidance;
- useful layout and run instructions;
- critical project-specific warnings/exceptions;
- the work-coordination declaration and authority links;
- a concise Project Document Registry pointing to scientific/data/architecture/reference records.

The registry is a discovery index, not a duplicate task tracker, script catalog, or result database.
Do not copy the live global skill catalog into project instructions. Keep client-native entry points
small and explicit; do not copy skill implementations or machine-local client configuration into the project.

Replace `{WORK_COORDINATION}` with the selected fragment from
[Work coordination](references/work-coordination.md). Then run the bundled reader before delivery:

```bash
python3 <new-project-skill-dir>/scripts/coordination.py --root <exact-project-root>
```

It must report exactly one valid model and the intended root. Check that the human-readable links
are real; the reader validates syntax, not adoption or access.

For GitHub coordination, remove the template's `### Planning Documents` subsection while retaining
scientific/data/architecture/reference entries. Plan and Hybrid retain it for programme records.
Do not leave an empty task-plan table in a GitHub project.

Create a README with purpose, setup, input/custody boundary, and the first runnable/useful workflow.
Create a changelog, session-log convention, project reminders, or a plan only when the user/project
actually wants that record. Do not scaffold global-maintenance consumers for `/done`.

## Initialize Git within the agreed boundary

Inspect the complete new file set before staging. Initialize Git, make one coherent setup commit,
and create or push the selected owned remote only when that destination and visibility were agreed as
part of project setup. Do not infer remote-write authority from this public skill.

Stop for public publication, an organization/collaborator destination not already authorized,
deployment, remote/authentication changes, inclusion of private/large data, or any conflict with an
enclosing repository. Show the concrete scope before that boundary. A commit or push is neither
scientific acceptance nor proof that the environment runs.

## Verify and hand back

Check:

- exact root, project type, coordination declaration, and authority links;
- no unresolved placeholders or broken local links;
- ignore rules against the intended tracked/untracked set;
- dependency specifications match packages actually introduced;
- README commands and environment paths are truthful;
- Git scope, remote visibility/destination, and pushed refs where applicable.

Report created files, environment and dependency state, Git/remote state, checks, held actions, and
the first substantive next step. Do not claim a natural `/done` pilot, cross-host reproduction,
scientific readiness, or deployment from scaffold checks.
