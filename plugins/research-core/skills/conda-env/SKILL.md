---
name: conda-env
description: Conda environment activation for Python commands. Use when running Python scripts, pip, or conda-dependent tools.
---

# Conda Environment Management

Use the project's existing compatible declared runtime. Apply this skill's Conda commands when
the project selects Conda or the chosen tool requires it; preserve an established alternative
runtime rather than replacing it because a task uses Python.

Initialize and activate Conda in the same shell invocation as the command that needs it. Activation
does not persist between tool calls; source the host's setup script before activating.

## Activation Pattern

Read the project environment declaration and any optional site execution profile. Do not infer
the Conda setup from the operating system or from the presence of an environment-modules command.

When `conda` is already discoverable, a portable invocation is:

```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate ENV_NAME && YOUR_COMMAND
```

If `conda` is not discoverable, run the setup command documented by the project or selected site
profile first. An HPC profile may load an environment module, but the profile must name the module;
do not invent a scheduler, module, installation path, or environment name.

## Before Running Commands

1. **Read the project's declared runtime and environment:**
   - Check its instructions and dependency specification; reuse the existing compatible setup.
   - For Conda, look for `environment.yml`, `environment.yaml`, or an environment name in the
     project's native instructions.
   - A name matching the project directory is a discovery hint, not a requirement to create or
     rename an environment.

2. **List available environments after the declared setup:**
   ```bash
   source "$(conda info --base)/etc/profile.d/conda.sh" && conda env list
   ```

3. **When the selected runtime is Conda**, activate that environment in the same invocation before running:
   - Python scripts
   - Shell commands that depend on conda packages
   - Tools like quarto (in some setups)

## Package Installation

**For Conda work, install packages into the selected project environment, never into the system Python or base env.**

1. **Prefer `conda install`** — it resolves dependencies against the full environment:
   ```bash
   source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate ENV_NAME && conda install PACKAGE
   ```

2. **Fall back to `pip` only within the active Conda environment** when the package is unavailable
   through the project's declared channels:
   ```bash
   source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate ENV_NAME && python -m pip install PACKAGE
   ```

3. **Never run bare `pip install`** without first activating the project's conda environment. This would install into the wrong Python and cause confusion.

4. When suggesting install commands to users (e.g., for students or collaborators), always include the conda activation step.

5. **Record pip installs in `environment.yml`.** When you fall back to pip, add the package under a `pip:` subsection (and ensure `pip` is listed as a conda dependency). `conda env export --from-history` does **not** capture pip-installed packages, so they are otherwise silently lost:
   ```yaml
   dependencies:
     - python=3.11
     - pip                 # required for the pip: section below
     - numpy
     - pip:
         - some-pip-only-package==1.2.3
   ```
   Detect what was pip-installed (channel shows as `pypi`):
   ```bash
   source "$(conda info --base)/etc/profile.d/conda.sh" && conda list -n ENV_NAME | awk 'NR>3 && $NF=="pypi" {print $1"=="$2}'
   ```

## Separately Requested Global Configuration

Global Conda settings affect other projects. Change them only as a separately requested machine
setup operation, after inspecting the current settings. Do not run this configuration as a side
effect of activation, package installation or project scaffolding. Example settings for that setup:

```bash
conda config --set channel_priority strict
conda config --set solver libmamba
conda config --add channels conda-forge
```

- **strict channel priority**: When a package exists in multiple channels, conda uses only the highest-priority channel. Prevents mixing incompatible builds.
- **libmamba solver**: Dramatically speeds up environment creation and package installation. The default solver can be very slow with complex dependencies.
- **conda-forge channel**: Community-maintained packages, often more up-to-date than `defaults`.

## Environment Export

`environment.yml` is hand-curated and portable. Use `--from-history` for the conda
packages — it records only explicitly installed packages, not platform-specific transitive
deps:

```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda env export -n ENV_NAME --from-history
```

**`--from-history` silently omits pip-installed packages.** Capture those separately and
record them under a `pip:` subsection (with `pip` listed as a conda dependency):

```bash
source "$(conda info --base)/etc/profile.d/conda.sh" && conda list -n ENV_NAME | awk 'NR>3 && $NF=="pypi" {print $1"=="$2}'
```

Prefer **reconciling** the existing hand-curated `environment.yml` (add new conda packages
to `dependencies:`, new pip packages to the `pip:` subsection) over overwriting it — a full
`conda env export` produces pinned, platform-specific build strings that aren't portable.

**Hygiene** — keep out of `environment.yml`:
- **`prefix:` line** — machine-specific absolute path, not portable
- Preserve the project's declared channels and order; do not impose a universal channel set.
- For a project using Bioconda, follow its documented compatible channel order and strict-priority
  guidance. Apply that policy only to the relevant environment, with authority for any change.

## Shared and Project Environments

Use a shared environment only when the project or an optional site profile explicitly declares
one. Otherwise use the named environment in the project's environment specification. A reusable
public procedure must not assume a lab-wide environment name or package set.

## General Policy

1. **Do not install into `base`** — use the project's named environment.
2. **Keep analysis environments project-specific** when versions or reproducibility matter.
3. **Include `ipykernel`** when the project executes Python through Jupyter or Quarto.
4. **Prefer the declared Conda channels and packages**; use pip only as a recorded fallback.
5. **Install Conda packages before pip packages** when both are required.
6. **Follow the selected site profile for shell and module setup**; the operating system alone does
   not determine how Conda is installed.