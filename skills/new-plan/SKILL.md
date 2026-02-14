---
name: new-plan
description: Create a new planning document and register it in the project CLAUDE.md
user-invocable: true
---

# Create a New Planning Document

When the user invokes `/new-plan`, create a structured planning document and register it in the project's document registry.

## 1. Gather Information

Ask the user:
- **Topic**: What is this plan for? (e.g., "transcriptomics volcano plots", "structural analysis")
- **Category**: Planning doc (tracks status of ongoing work) or Data doc (describes datasets/file formats)?

If the user provides the topic directly as an argument (e.g., `/new-plan thermal proteome profiling`), use that and default to "Planning" category.

## 2. Create the Document

Create a new `.md` file in the project's `.claude/` directory.

### Naming convention
- Use `SCREAMING_SNAKE_CASE` matching existing docs
- Planning docs: `{TOPIC}_PLAN.md` (e.g., `THERMAL_PROTEOME_PLAN.md`)
- Data docs: `{TOPIC}_DATA.md` (e.g., `SECRETOMICS_DATA.md`)

### Planning document template

```markdown
# {Topic} Plan

## Overview

{Brief description of what this plan covers}

## Goals

- [ ] Goal 1
- [ ] Goal 2

## Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | {First phase} | Not started |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| {today} | Created planning document | {reason} |

## Key Files

### Inputs
- (list input files as they become relevant)

### Outputs
- (list output files as they are created)

### Scripts

Track all scripts here. When a script is superseded, move it to the Legacy section.

#### Active
| Script | Purpose | Status |
|--------|---------|--------|
| (add scripts as they are created) | | |

#### Legacy / Inactive
| Script | Replaced by | Notes |
|--------|-------------|-------|
| (move superseded scripts here) | | |
```

### Data document template

```markdown
# {Topic} Data

## Overview

{Brief description of the dataset}

## Experimental Design

{Describe the experiment that generated this data}

## Key Files

| File | Description |
|------|-------------|
| | |

## Column Descriptions

{For key files, describe important columns}

## Processing Notes

{Any important notes about how data was processed or should be used}
```

## 3. Register in Project CLAUDE.md

After creating the document, add it to the **Project Document Registry** in the project's `.claude/CLAUDE.md`:

1. Read `.claude/CLAUDE.md` and find the "Project Document Registry" section
2. Add a new row to the appropriate table (Planning Documents or Data Documents)
3. Include the document name, topic, and whether it has a status table

If no registry exists, create the registry section first (following the format in the `/done` skill documentation).

## 4. Confirm

Tell the user:
- What file was created and where
- That it was registered in the project CLAUDE.md
- Suggest they start filling in the details or that you can help plan the work