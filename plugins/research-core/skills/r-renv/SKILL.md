---
name: r-renv
description: >
  R renv package management for data science projects. Use when working with renv (renv.lock,
  renv::restore, renv::snapshot) in R analysis projects. Do NOT load for projects that do not
  use R or renv.
---

# R Environment Management

## R Runtime

Use the R version declared by the project and recorded in its environment or producing-state
evidence. An optional site profile may describe how that runtime is made available. Do not infer a
host path, processor architecture, editor, module, or version-manager command.

Before restoring packages, confirm the selected executable:

```bash
Rscript --version
Rscript -e 'cat(R.version.string, "\n")'
```

When the project uses a version manager or editor-specific runtime setting, configure it through
that tool's documented project workflow and keep machine-local paths out of shared project files.

---

## renv: Package Management

Most R projects use **renv** for reproducible package management.

### Key Commands

```r
renv::status()        # Check sync status
renv::restore()       # Install packages from lockfile
renv::snapshot()      # Record current packages to lockfile
renv::install("pkg")  # Install a package
renv::update()        # Update all packages
```

### How renv Works

- **Activates automatically** via `.Rprofile` when R starts in the project directory
- **Warnings about "project out-of-sync"** are informational, not errors
- **When running R scripts via Bash**, renv still activates but may show warnings — these don't prevent execution

### Workflow

1. If you see "project out-of-sync" warning → run `renv::status()` to see details
2. To sync packages with lockfile → run `renv::restore()`
3. After installing new packages → run `renv::snapshot()` then commit `renv.lock` to git

### Git Tracking

**Commit**: `renv.lock`, `renv/activate.R`, `.Rprofile`
**Ignore**: `renv/library/`, `renv/staging/`, `renv/local/`

---

## Bioconductor

Bioconductor packages have coordinated releases tied to R versions.

### Installation

```r
install.packages("BiocManager")
BiocManager::install("DESeq2")
BiocManager::install(c("limma", "edgeR", "tximport"))
renv::snapshot()  # Always snapshot after installing
```

With renv, you can also use:

```r
renv::install("bioc::DESeq2")
```

### Version Synchronization

Bioconductor releases are tied to R versions and the mapping changes over time. Inspect the active
project instead of relying on a copied version table:

```r
R.version.string
BiocManager::version()
renv::status()
```

Resolve mismatches against the project's lockfile and the current Bioconductor release guidance
for that R version. Treat a release change as an environment change and review it before snapshotting.

---

## Troubleshooting

### "Project out-of-sync"
→ Run `renv::status()` to see details. Run `renv::restore()` to sync, or `renv::snapshot()` if you've installed new packages.

### Failed package installation
→ Try `renv::install("package", rebuild = TRUE)`

### Starting fresh
→ Reset only when explicitly requested after diagnosing the problem. Preserve `renv.lock`, the
project library and unrelated `.Rprofile` content before changing activation.
`renv::deactivate(clean = FALSE)` removes renv's autoloader while retaining the lockfile/library
([official documentation](https://pkgs.rstudio.com/renv/reference/activate.html)). Do not delete
`renv/` or the whole `.Rprofile` as routine troubleshooting; review reinitialization against the
existing lockfile before proceeding.