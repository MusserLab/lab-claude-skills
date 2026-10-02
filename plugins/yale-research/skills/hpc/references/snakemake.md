# Batch Processing with Snakemake

## When to use Snakemake vs simple scripts

| Workflow pattern | Tool |
|-----------------|------|
| **Fan-out/fan-in** (many samples through same steps) | Snakemake |
| **Complex dependency graph** (multiple tools, conditional steps) | Snakemake |
| **Linear pipeline** (A → B → C, single sample) | Bash script or standalone Python |
| **Interactive/exploratory analysis** | `.qmd` script (local or cluster) |

Don't introduce Snakemake if it adds more complexity than it removes. A simple bash
script with checkpointing is fine for linear workflows.

## Resumption principle

Reuse a stage only when its expected outputs are complete for the intended inputs, producing
source and configuration. File existence alone is insufficient. Use the workflow's existing
metadata and completion evidence; do not add a cache or sentinel framework without a concrete need.

- In Snakemake, declare the actual inputs, outputs and relevant configuration, retain its metadata,
  and inspect a dry run. Output tracking alone does not validate scientific completeness or input
  identity. Check the workflow's expected outputs and successful completion evidence before reuse.
- In bash/Python, use the project's existing completion record and expected output checks together
  with producing source/input/configuration identity; a bare `test -f` or `Path.exists()` is insufficient.
- Before rerunning, preserve any retained, reviewed, shared or downstream-used outputs in an agreed
  alternate destination, or configure a fresh producer-owned output directory. Inspect
  `snakemake -n --forcerun <rule>` (or the selected target) before an authorized rerun; `--rerun-incomplete`
  handles incomplete jobs after their outputs are reviewed. Never delete retained outputs merely to
  make the workflow run. See the [official CLI](https://snakemake.readthedocs.io/en/stable/executing/cli.html).

## Setup

```bash
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
conda create -n snakemake -c conda-forge -c bioconda \
    snakemake snakemake-executor-plugin-slurm
conda activate snakemake
```

## Running

```bash
# Always dry-run first
snakemake -n --executor slurm

# Execute — Snakemake runs on the login node, each rule becomes a SLURM job
snakemake --executor slurm --jobs 50
```

## Per-rule resources in Snakefile

```python
rule align:
    input: "data/raw/{sample}.fasta"
    output: "results/alignments/{sample}.aln"
    log: "logs/align/{sample}.log"
    conda: "envs/phylo.yml"
    resources:
        slurm_partition="day",
        runtime=240,          # minutes
        mem_mb=20000,
        cpus_per_task=4,
        slurm_extra="'--mail-type=FAIL'"
    shell:
        "mafft --auto --thread {resources.cpus_per_task} {input} > {output} 2> {log}"
```

For GPU rules, add: `slurm_partition="gpu", slurm_extra="'--gpus=1'"`

## Snakemake profile (recommended)

Create `~/.config/snakemake/slurm/config.yaml` to set defaults:

```yaml
executor: slurm
jobs: 50
default-resources:
  slurm_partition: day
  runtime: 60
  mem_mb: 5000
  cpus_per_task: 1
latency-wait: 120
```

Then run: `snakemake --profile slurm`

## Use tmux for long-running orchestration

```bash
tmux new -s pipeline
module load miniconda
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate snakemake
snakemake --executor slurm --jobs 50
# Ctrl-b d to detach; tmux attach -t pipeline to reconnect
```

## Logging

Use Snakemake's `log:` directive to capture tool stdout/stderr. Follow the convention
`logs/{rule}/{sample}.log`. Retain useful logs according to project custody; Git tracking is project-specific.
