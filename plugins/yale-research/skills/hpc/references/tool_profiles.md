# Tool Resource Profiles

Slurm sizing guidance only; dedicated skills own invocation, templates and interpretation.
Prefer comparable successful project runs, then applicable version-specific tool guidance,
then an estimate. **Table requests are inherited estimates, not calibrated defaults.**
Review the applicability limits below before reusing them. Memory entries describe a single-node
request (`--mem` is per node, `G/cpu` is per allocated CPU). Partitions require live eligibility
checks. Review available accounting after initial runs before adjusting.

Use dedicated skills when separately installed: `eggnog-mapper`, `prost-annotation`,
`protein-phylogeny`, `busco`, `hmmer`, `transdecoder`, `isoseq-pipeline` and `expression-report`.
They are not bundled dependencies of Yale Research. Otherwise use the tool's versioned primary
documentation and the project workflow. A version/database/input mismatch requires a new
applicability judgment, not copying a number from either source. Follow
[resource learning](resource-learning.md) to keep useful observations in the existing private
project record; do not edit installed package files with job evidence.

| Tool | CPUs | Memory | Time | Partition | GPU | Notes |
|------|------|--------|------|-----------|-----|-------|
| **IQ-TREE — ModelFinder** | 8 | 4G/cpu | 2h | day | — | Quick model selection |
| **IQ-TREE — fast model** | 8 | 4G/cpu | 4h | day | — | Gene tree screening |
| **IQ-TREE — PMSF/C60** | 8 | 8G/cpu | 1 day | day/week | — | Use fixed `-T 8` not AUTO |
| **MAFFT — auto** | 4 | 4G/cpu | 1h | day | — | |
| **MAFFT — linsi** | 4 | 8G/cpu | 8h | day | — | >500 sequences |
| **Cell Ranger** | 16 | 64G total | 12h | day | — | Use `--mem=64G` |
| **STARsolo** | 16 | 64G total | 8h | day | — | Use `--mem=64G` |
| **DIAMOND** | 16 | 4G/cpu | 4h | day | — | Check scaling for the selected database and search parameters |
| **PROST** | 4 | 32G | 4h | gpu | 1 | Initial embedding estimate; search stages can have different requirements. Verify hardware, RAM and runtime. |
| **TransDecoder** | 4 | 4G/cpu | 2h | day | — | |
| **BUSCO** | 8 | 4G/cpu | 4h | day | — | Varies with lineage DB |
| **IsoSeq refine + cluster2** | Consult tool guidance | — | — | — | — | Transcript diversity and parameters affect RAM; read count alone does not bound deeper runs. Use versioned templates when available. |
| **HMMER hmmscan (6-frame)** | 4 | 8G | 2.5h | day | — | Small-profile-set estimate; account for six-frame peptide expansion and poor thread scaling. |
| **barrnap (rRNA scan)** | 4 | 8G | 30m | day | — | Verify installed version, supported kingdoms and invocation; environment names or a newer version do not establish compatibility. |
| **eggNOG-mapper** | Consult tool guidance | — | — | — | — | Budget by mapper version, database, input and parameters, including Pfam mode; use the versioned workflow when available. |
| **Genome assembly** | 32 | 200G | 2 days | week/bigmem | — | Rough estimate only; assembler, genome and coverage dominate |

## Applicability and observation limits

The inherited estimates do not preserve complete measurement dates or tool/database/parameter
metadata. Missing context stays unknown; a documentation review date is not a measurement date.
Use comparable completed project evidence to resolve the actual request.

Different observations can disagree when their exact run correspondence is unresolved. Do not
combine them into a new benchmark or extrapolate a tiny profile database to full-Pfam searches.
Suppress HMMER alignment text with `-o /dev/null` when it is not needed. For Iso-Seq, retain
headroom for transcript diversity and deeper runs rather than deriving a universal RAM-per-read
formula. For barrnap, verify required nuclear/mitochondrial coverage and supported `--kingdom`
values with `barrnap --help` and primary documentation.

Use [resource learning](resource-learning.md) to inspect comparable completed work and update the
specific next request with its reason in the existing project record. Preserve approved tool
versions and scientific parameters; resource guidance does not authorize changing them.
