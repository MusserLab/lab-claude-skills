# Tool Resource Profiles

SLURM resource recommendations only. Tool-specific skills handle how to invoke each
tool, generate batch scripts, and interpret output. This table just covers how much to
request from SLURM. **Always check `jobstats` after initial runs and adjust.**

**Tools with dedicated skills:** `eggnog-mapper` (eggNOG-mapper), `prost-annotation`
(PROST), `protein-phylogeny` (IQ-TREE, MAFFT), `busco` (BUSCO), `hmmer`
(hmmscan/hmmsearch), `transdecoder` (TransDecoder), `expression-report`
(scanpy/matplotlib). Use those skills for batch script generation — this table is a
quick resource reference.

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
| **IsoSeq refine + cluster2** | refine 8 / cluster2 16–32 | refine 40G / cluster2 **64–96G** total | 6h / day | day | — | cluster2 is the bottleneck, and **its mem depends on transcript diversity, not just FLNC**: sponge-2024 data ~8G@8M→18G@18M FLNC, but **JM_pool5 (Oscarella/Leuco) 29G@8M→67G@18M (~3.7G/M FLNC)**. refine ≤36G / 7–16 min @8c (40G barely enough); cluster2 9–29 min @32c. Size cluster2 ≥4–8G/M FLNC + check jobstats. See `isoseq-pipeline` skill. |
| **HMMER hmmscan (6-frame)** | 4 | 8G total | 2.5h | day | -- | Few HMMs -> parallelism falls off >4 cores. ~6G peak / 40-65 min on a 0.3-0.9M-transcript IsoSeq transcriptome (transeq -frame 6 -> ~5M peptides) vs a 4-HMM db. Use `-o /dev/null` (alignment text is huge). |
| **barrnap (rRNA scan)** | 4 | 8G total | 30m | day | — | **Two envs, pick by KINGDOM — not interchangeable:** `barrnap09` (v0.9, bioconda) does `--kingdom euk` (nuclear 18S/28S/5.8S/5S) + `mito` (mt 12S/16S); `barrnap` (v1.10.6) does ONLY `bac arc fun` — the newer line dropped euk/mito. Invoke: `barrnap --kingdom euk --threads N --outseq hits.fa in.fa >out.gff`. ~4.5 min / 94% CPU eff / 2.6G peak on a 1.2G (857K-seq) IsoSeq transcriptome (job 15601417). No dedicated skill. |
| **eggNOG-mapper** | 8 | 4G/cpu | 4h | day | — | |
| **Genome assembly** | 32 | 200G total | 2 days | week/bigmem | — | Highly variable; scale from jobstats |