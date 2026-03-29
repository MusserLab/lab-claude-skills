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

## Checkpointing principle

All orchestrators (Snakemake, bash, Python) must implement checkpointing: **do not re-run
a stage if its output already exists.** The presence of the output file itself is the
checkpoint — never use sentinel files or hidden state.

- Snakemake gets this for free via output file tracking
- In bash: check with `[ -f output.fasta ] && echo "Skipping..." && exit 0`
- In Python: check with `if Path("output.fasta").exists(): ...`
- To re-run a specific stage: delete its output and re-launch

## Setup

```bash
module load miniconda
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
conda activate snakemake
snakemake --executor slurm --jobs 50
# Ctrl-b d to detach; tmux attach -t pipeline to reconnect
```

## Logging

Use Snakemake's `log:` directive to capture tool stdout/stderr. Follow the convention
`logs/{rule}/{sample}.log`. Exclude `logs/` from version control.
