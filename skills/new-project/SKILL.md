---
name: new-project
description: >
  Use when creating a new project, setting up a project from scratch, or when the user
  invokes /new-project. Scaffolds directory structure, environments, git, and Claude Code
  configuration. Supports data science, documentation, and general project types.
user-invocable: true
---

# Create a New Project

When the user invokes `/new-project`, scaffold a complete project with version control and Claude Code configuration. The project type determines which conventions, directories, and environments to set up.

Run this skill from **inside the target project directory** (which may be empty or newly created).

---

## 1. Gather Project Information

Use AskUserQuestion to collect:

### Question 1: Project type
- **Data science** (Recommended) — Analysis project with numbered scripts, data/outs/ directories, renv/conda, Quarto analysis documents
- **Documentation** — Quarto book or website (teaching material, lab manual, reference docs)
- **General** — Any other project (infrastructure, tools, packages, scripts without data science conventions)

### Question 2: Project basics (all types)
- **Project name**: Default to current directory name
- **Brief description**: 1-2 sentences for CLAUDE.md and README

### For Data Science projects, also ask:

#### Question 3: Languages
- R only
- Python only
- Both R and Python (Recommended)

#### Question 4: Layout
- **Flat**: Single `scripts/` directory — for small projects with <10 scripts on one topic
- **Sectioned**: Subdirectories under `scripts/`, `data/`, `outs/` — for larger projects with multiple analytical threads

If sectioned, ask for section names (e.g., `phosphoproteomics`, `transcriptomics`).

#### Question 5: Cluster
- **Yes** — This project will also live on the YCRC HPC cluster (dual-environment)
- **No** (Default) — Local analysis only

If yes:
- Adds `batch/` directory (tracked in git — SLURM batch scripts)
- Adds `logs/` directory (tracked in git — SLURM output for review in both environments)
- Adds a "Dual Environment: Local + Cluster" section to CLAUDE.md (see template below)
- Asks for the **cluster path** (default: `/nfs/roberts/project/<pi_netid>/<project_name>/`)
- Notes in CLAUDE.md which directories are cluster-only (gitignored)
- Batch scripts use `BASEDIR=$(git rev-parse --show-toplevel)` — no hardcoded paths
- See `hpc` skill for full dual-environment conventions

### For General projects, also ask:

#### Question 3: Languages
- R only
- Python only
- Both R and Python
- None / other (Markdown, Bash, etc.)

### For all types:

#### Question: GitHub
- **Lab organization** (recommended for research projects) or **personal account**?
- **Private** (recommended) or **public**?

#### Question: Changelog
- **Yes** (recommended) — create a `CHANGELOG.md` to track changes over time. The `/done` skill will propose entries automatically.
- **No** — skip. You can always add one later.

---

## 2. Create Directory Structure

### Data Science layout

#### Flat

```bash
mkdir -p R python scripts/exploratory data outs/exploratory .claude
```

(Omit `R/` if Python-only, omit `python/` if R-only.)

#### Sectioned

For each section (e.g., `phosphoproteomics`, `transcriptomics`):

```bash
mkdir -p R python scripts/exploratory data outs/exploratory .claude
# Per section:
mkdir -p scripts/{section} data/{section} outs/{section}
```

#### Cluster directories (if cluster = yes)

```bash
mkdir -p batch logs
```

These are gitignored (see `.gitignore` section below) — they hold ephemeral SLURM scripts and log output.

#### Create placeholder files

Add `.gitkeep` files to empty directories so git tracks them:

```bash
touch R/.gitkeep python/.gitkeep scripts/exploratory/.gitkeep outs/.gitkeep data/.gitkeep
```

### Documentation layout

Hand off to the `/quarto-book-setup` skill:

> "This is a documentation project — I'll use `/quarto-book-setup` to scaffold the Quarto book. Would you like to proceed?"

After `/quarto-book-setup` completes, return here to add `project-type: general` to the generated CLAUDE.md (documentation projects use the general type since they don't follow data science conventions).

### General layout

```bash
mkdir -p .claude
```

Create only the `.claude/` directory. Do NOT create `data/`, `outs/`, `scripts/`, `R/`, or `python/` directories — let the user organize as appropriate for their project.

---

## 3. Python Environment (if using Python)

### One-time conda configuration (check first)

```bash
conda config --show channel_priority
```

If not already `strict`:

```bash
conda config --set channel_priority strict
conda config --set solver libmamba
conda config --add channels conda-forge
```

### For Data Science projects: create project-specific environment

```bash
source ~/miniconda3/etc/profile.d/conda.sh
conda create -n {project_name} python=3.11 numpy pandas matplotlib ipykernel -y
conda activate {project_name}
```

> **Customize**: Replace `~/miniconda3` with your actual conda installation path (see `conda-env` skill).

`ipykernel` is required for Quarto to execute Python chunks.

### For General projects: default to `lab-general`

General projects always get the shared `lab-general` environment by default. This is included in the CLAUDE.md regardless of whether the project currently uses Python — it ensures Claude knows which env to activate if Python is needed later.

1. Check if the `lab-general` environment already exists:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh && conda env list | grep lab-general
   ```

   > **Customize**: Replace `~/miniconda3` with your actual conda installation path (see `conda-env` skill).

2. If it does NOT exist, create it:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh
   conda create -n lab-general python=3.11 ipykernel pyyaml requests pandas -y
   ```

3. Do NOT export an `environment.yml` into the project — `lab-general` is managed independently, not per-project.

**Opt-out: project-specific environment.** If the user specifically says they need specialized Python dependencies, create a project-specific env instead:

1. Ask the user which packages to install.

2. Create the environment:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh
   conda create -n {project_name} python=3.11 ipykernel {user_packages} -y
   conda activate {project_name}
   ```

3. Export environment:
   ```bash
   conda env export --from-history > environment.yml
   ```

### Export environment (Data Science and project-specific General only)

Always use `--from-history` for portable environment files:

```bash
conda env export --from-history > environment.yml
```

Do NOT create an `environment.yml` for projects using the shared `lab-general` environment.

### Lab policy

- Never install into the `base` environment
- **Data science projects**: one environment per project, named to match the project
- **General projects**: use `lab-general` shared environment by default; create project-specific only when specialized dependencies are needed
- Prefer `conda install` over `pip install`
- Always include `ipykernel` for Quarto compatibility

---

## 4. R + renv (Data Science only — if using R)

### Check available R versions

```bash
rig list
```

Ask the user which version to use (default: latest installed).

### Pin R version in Positron

Ask: "Do you use Positron as your IDE?"

If yes, create `.positron/settings.json`:

```json
{
  "r.rpath.mac": "/Library/Frameworks/R.framework/Versions/{VERSION}-arm64/Resources/bin/R"
}
```

Replace `{VERSION}` with the chosen version (e.g., `4.4`). For Intel Macs, use `{VERSION}-x86_64`.

Add `.positron/` to `.gitignore` (already in the template).

### Initialize renv

```r
renv::init()
install.packages(c("tidyverse", "here"))
renv::snapshot()
```

### Lab policy

- Every R data science project uses renv
- Snapshot after every package install
- Commit `renv.lock`, `renv/activate.R`, `.Rprofile` to git
- Do NOT commit `renv/library/` or `renv/staging/`

---

## 5. Write .gitignore

### Data Science .gitignore

```
# Generated outputs (reproducible from code)
outs/

# R artifacts
.Rhistory
.RData
.Rproj.user/
renv/library/
renv/staging/
renv/local/
*_cache/

# Python artifacts
__pycache__/
*.py[cod]
*.egg-info/
.eggs/
*.egg
.venv/
venv/

# Quarto rendering
*_files/
.quarto/
*.html

# Claude Code
.claude/worktrees/

# OS files
.DS_Store
Thumbs.db

# IDE settings
.vscode/
.positron/
*.Rproj

# Secrets
.env
*.pem
credentials.json
```

If cluster project, also add:

```
# HPC cluster — batch scripts and SLURM logs
batch/
logs/
```

**Note on `data/`**: Whether to gitignore `data/` depends on file sizes. Small data files (< a few MB) can be committed. Large files should be gitignored with a `data/README.md` documenting sources. Ask the user.

### General .gitignore

```
# Python artifacts
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/

# R artifacts
.Rhistory
.RData
.Rproj.user/

# Quarto rendering
*_files/
.quarto/

# Claude Code
.claude/worktrees/

# OS files
.DS_Store
Thumbs.db

# IDE settings
.vscode/
.positron/

# Secrets
.env
*.pem
credentials.json
```

Omit language-specific sections if that language isn't used.

---

## 6. Generate .claude/CLAUDE.md

### Data Science template

Read `templates/claude_md_data_science.md` and fill in project-specific details:
- Replace all `{placeholders}` with actual values from the discussion
- Include only language sections relevant to the chosen languages
- Include the "Dual Environment" section only if cluster = Yes
- Remove `<!-- IF CLUSTER -->` comment markers after deciding

If `~/lib/R/` or `~/lib/python/` exist, add to the Conventions section:

```markdown
### Cross-Project Helpers

Shared helper functions are available at:
- `~/lib/R/` — source with `source("~/lib/R/helpers.R")`
- `~/lib/python/` — import with `sys.path.insert(0, os.path.expanduser("~/lib/python"))`
```

### General project template

Read `templates/claude_md_general.md` and fill in project-specific details.
Same placeholder and cluster section rules as the data science template.

### Project reminders file

Create `.claude/project-reminders.txt` — this is read by the `project-reminders` hook to inject critical project-specific rules at every session start.

#### Data Science projects

```
CRITICAL REMINDERS (re-injected after compaction):
1. (Add project-specific rules here as the project develops)
2. Check planning documents before modifying scripts
3. Never silently default unmatched data classifications
```

#### General projects

```
REMINDERS (re-injected after compaction):
1. (Add project-specific rules here as the project develops)
```

Tell the user: *"I created `.claude/project-reminders.txt` — edit this as you discover critical rules that Claude keeps forgetting after long sessions."*

---

## 7. Generate README.md

### Data Science README

````markdown
# {Project Name}

{Brief description}

## Setup

### Prerequisites
- [Positron](https://positron.posit.co/) (recommended IDE)
- [rig](https://github.com/r-lib/rig) (R version manager)
- [Conda](https://docs.conda.io/) (Python environment manager)
- [Quarto](https://quarto.org/) (literate programming)

### Python
```bash
conda env create -f environment.yml
conda activate {project_name}
```

### R
```r
# renv auto-activates via .Rprofile
renv::restore()
```

## Data

(Document data sources and how to obtain them)

## Running the Analysis

(Document how to run scripts in order)
````

Omit Python or R sections if not using that language.

### General README

````markdown
# {Project Name}

{Brief description}

## Setup

{Document prerequisites and setup steps as the project develops}

## Usage

{Document how to use the project}
````

---

## 7b. Create CHANGELOG.md (if requested)

If the user opted for a changelog in Step 1, create `CHANGELOG.md`:

````markdown
# Changelog

## {today's date}

### Added
- Initial project setup
````

The `/done` skill auto-detects this file and proposes entries at each session wrap-up. No CLAUDE.md entry needed.

---

## 8. Git + GitHub

```bash
git init
git add .
git commit -m "Initial project setup"
```

Then create the remote:

```bash
# Lab org, private (default)
gh repo create LAB_ORG/{project_name} --private --source=. --push

# Personal, private
gh repo create {project_name} --private --source=. --push

# Personal, public
gh repo create {project_name} --public --source=. --push
```

> **Customize**: Replace `LAB_ORG` with your lab's GitHub organization name.

---

## 9. Summary

After completing all steps, print a type-appropriate summary:

### Data Science summary

```
Project "{project_name}" created successfully!

  Project type: Data science
  Directory structure: {flat/sectioned}
  Languages: {R/Python/both}
  Conda env: {project_name}
  R version: {version} (renv initialized)
  Git remote: {github_url}

Next steps:
  1. Add data files to data/
  2. Create your first script: scripts/01_import.qmd
  3. See the quarto-docs skill for QMD templates
```

### General summary

```
Project "{project_name}" created successfully!

  Project type: General
  Languages: {languages}
  Conda env: {lab-general (shared) / project_name (project-specific)}
  Git remote: {github_url}

Next steps:
  1. Start adding code and documentation
  2. Update .claude/CLAUDE.md as the project develops
```
