# Tool Resource Profiles

SLURM resource recommendations only. Tool-specific skills handle how to invoke each
tool, generate batch scripts, and interpret output. This table just covers how much to
request from SLURM. **Always check `jobstats` after initial runs and adjust.**

**Tools with dedicated skills:** `eggnog-mapper` (eggNOG-mapper), `prost-annotation`
(PROST), `protein-phylogeny` (IQ-TREE, MAFFT), `expression-report` (scanpy/matplotlib).
Use those skills for batch script generation — this table is a quick resource reference.

| Tool | CPUs | Memory | Time | Partition | GPU | Notes |
|------|------|--------|------|-----------|-----|-------|
| **IQ-TREE — ModelFinder** | 8 | 4G/cpu | 2h | day | — | Quick model selection |
| **IQ-TREE — fast model** | 8 | 4G/cpu | 4h | day | — | Gene tree screening |
| **IQ-TREE — PMSF/C60** | 8 | 8G/cpu | 1 day | day/week | — | Use fixed `-T 8` not AUTO |
| **MAFFT — auto** | 4 | 4G/cpu | 1h | day | — | |
| **MAFFT — linsi** | 4 | 8G/cpu | 8h | day | — | >500 sequences |
| **Cell Ranger** | 16 | 64G total | 12h | day | — | Use `--mem=64G` |
| **STARsolo** | 16 | 64G total | 8h | day | — | Use `--mem=64G` |
| **DIAMOND** | 16 | 4G/cpu | 4h | day | — | Scales well with threads |
| **PROST** | 4 | 32G total | 4h | gpu | 1 | 22 min for 25K proteins (RTX 5000 Ada). Actual RAM ~6.5G. |
| **TransDecoder** | 4 | 4G/cpu | 2h | day | — | |
| **BUSCO** | 8 | 4G/cpu | 4h | day | — | Varies with lineage DB |
| **EggNOG-mapper** | 8 | 4G/cpu | 4h | day | — | |
| **Genome assembly** | 32 | 200G total | 2 days | week/bigmem | — | Highly variable; scale from jobstats |
