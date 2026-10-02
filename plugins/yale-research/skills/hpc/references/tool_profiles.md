# Tool Resource Profiles

SLURM resource recommendations only. Tool-specific skills handle how to invoke each
tool, generate batch scripts, and interpret output. This table just covers how much to
request from SLURM. These are initial estimates, not benchmarks or guarantees. Resolve the
actual tool/version, input scale, hardware and project environment. Follow
[resource learning](resource-learning.md) to record private observations and adjust comparable
future requests; do not edit installed package files with private job evidence.

**Tools with dedicated skills:** `eggnog-mapper` (eggNOG-mapper), `prost-annotation`
(PROST), `protein-phylogeny` (IQ-TREE, MAFFT), `busco` (BUSCO), `hmmer`
(hmmscan/hmmsearch), `transdecoder` (TransDecoder), `expression-report`
(scanpy/matplotlib). Use those skills when they are actually installed; optional domain skills are not dependencies
bundled in this Yale package. Otherwise use the tool's primary documentation and project workflow.
This table is a quick resource reference.

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
| **PROST** | 4 | 32G total | 4h | gpu | 1 | Initial GPU estimate; select compatible hardware and confirm actual RAM/runtime. |
| **TransDecoder** | 4 | 4G/cpu | 2h | day | — | |
| **BUSCO** | 8 | 4G/cpu | 4h | day | — | Varies with lineage DB |
| **IsoSeq refine + cluster2** | refine 8 / cluster2 16–32 | refine 40G / cluster2 **64–96G** total | 6h / day | day | — | cluster2 memory depends on transcript diversity and algorithm settings as well as FLNC count. Measure the actual workload; do not scale from read count alone. Consult `isoseq-pipeline` when installed. |
| **HMMER hmmscan (6-frame)** | 4 | 8G total | 2.5h | day | -- | Few profiles can limit thread scaling. Account for the six-frame peptide expansion and potentially large alignment text; verify behavior with the project's workload. |
| **barrnap (rRNA scan)** | 4 | 8G total | 30m | day | — | Resolve the declared environment and verify installed version, supported `--kingdom` values, required nuclear/mitochondrial coverage and invocation from `barrnap --help`/primary documentation. Environment names or a newer version do not establish compatible kingdom support. |
| **eggNOG-mapper** | 8 | 4G/cpu | 4h | day | — | |
| **Genome assembly** | 32 | 200G total | 2 days | week/bigmem | — | Highly variable; scale from jobstats |