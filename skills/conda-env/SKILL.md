---
name: conda-env
description: Conda environment activation for Python commands. Use when running Python scripts, pip, or conda-dependent tools.
user-invocable: false
---

# Conda Environment Management

Claude Code runs in a non-interactive shell where conda isn't automatically initialized. Always source the conda setup script before activating environments.

## Activation Pattern

```bash
source ~/miniconda3/etc/profile.d/conda.sh && conda activate ENV_NAME && YOUR_COMMAND
```

Or for miniforge3:
```bash
source ~/miniforge3/etc/profile.d/conda.sh && conda activate ENV_NAME && YOUR_COMMAND
```

> **Customize**: Replace `~/miniconda3` or `~/miniforge3` with your actual conda installation path. Find it with `conda info --base`.

## Before Running Commands

1. **Check if the project has a conda environment:**
   - Look for `environment.yml`, `environment.yaml`, or conda env name in project's `.claude/CLAUDE.md`
   - Check for an env name matching the project directory name

2. **List available environments:**
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh && conda env list
   ```

3. **If the project specifies a conda environment**, always activate it before running:
   - Python scripts
   - Shell commands that depend on conda packages
   - Tools like quarto (in some setups)

## Package Installation

**Always install packages into the project's conda environment, never into the system Python or base env.**

1. **Prefer `conda install`** — it resolves dependencies against the full environment:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh && conda activate ENV_NAME && conda install PACKAGE
   ```

2. **Fall back to `pip` only within the active conda env** — if a package isn't available via conda/conda-forge:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh && conda activate ENV_NAME && pip install PACKAGE
   ```

3. **Never run bare `pip install`** without first activating the project's conda environment. This would install into the wrong Python and cause confusion.

4. When suggesting install commands to users (e.g., for students or collaborators), always include the conda activation step.

## One-Time Configuration

Run once on a new machine to ensure consistent package resolution:

```bash
conda config --set channel_priority strict
conda config --set solver libmamba
conda config --add channels conda-forge
```

- **strict channel priority**: When a package exists in multiple channels, conda uses only the highest-priority channel. Prevents mixing incompatible builds.
- **libmamba solver**: Dramatically speeds up environment creation and package installation. The default solver can be very slow with complex dependencies.
- **conda-forge channel**: Community-maintained packages, often more up-to-date than `defaults`.

## Environment Export

Always use `--from-history` for portable environment files:

```bash
conda env export --from-history > environment.yml
```

This records only explicitly installed packages (not platform-specific transitive dependencies), making the file portable across OS and architectures.

## Lab Policy

1. **Never install into the `base` environment** — always create project-specific environments
2. **One environment per project** — named to match the project directory
3. **Always include `ipykernel`** — required for Quarto to execute Python chunks
4. **Prefer `conda install`** over `pip install` — conda resolves dependencies holistically. Use pip only as a fallback for packages not available via conda/conda-forge
5. **Install conda packages before pip packages** — if mixing both, conda packages first to avoid conflicts

## Shell Environment

- **Shell**: zsh (macOS default)
- **Conda base**: Typically `~/miniconda3` or `~/miniforge3` — customize to match your installation