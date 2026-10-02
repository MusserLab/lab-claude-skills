<!-- project-type: data-science -->
# {Project Name}

{Scientific purpose, intended use, and current boundary.}

{WORK_COORDINATION}

## Environment and execution

{Exact Python/R/tool environment actually selected, activation/restoration commands, and any
host-specific differences. Do not claim another host is reproduced until tested.}

## Input, output, and custody boundary

- `data/` contains external or registered inputs; producers do not write there.
- `outs/` contains producer outputs. Generated or Git-ignored does not mean disposable.
- Retained scientific use identifies a focused Git commit containing the relevant producer,
  wrapper, helpers, and configuration; source remains outside `outs/`.
- {Record project-specific large-data location, identity, transfer, preservation, and rerun rules.}

## Repository layout and active-file discovery

{Describe actual producers, helper locations, and outputs. Point to the registered active-file/data
authority rather than duplicating volatile inventories here.}

## Workflows

{How to execute the current analysis or pipeline, including environment activation, dependency order,
seeds, output destinations, and relevant resource/scheduler wrapper.}

## Scientific and project-specific boundaries

{Consequential method choices, warnings, accepted exceptions, review stops, and downstream limits
that a fresh agent must see.}

## Project Document Registry

### Planning Documents

| Document | Programme/scientific role |
|---|---|
| {Add a programme plan only when the declared model uses one and it exists.} | |

### Scientific, Data, and Reference Records

| Document | Role and authority |
|---|---|
| {Add the native project instruction file(s) in scope, such as `CLAUDE.md` and/or `AGENTS.md`.} | Project instructions and discovery index |

{Register scientific/data records, provenance/validation records, and architecture
documents by role. Do not copy task checklists, numerical results, or a static skill catalog here.}
