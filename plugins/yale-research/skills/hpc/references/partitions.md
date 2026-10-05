# Partition Quick-Reference

Dated Yale profile: official documentation checked 2026-10-01. The `agent` entry separately
retains the source's 2026-09-30 scheduler/QoS evidence; no new scheduler query ran for this package.
Sources: [Bouchet](https://docs.ycrc.yale.edu/clusters/bouchet/),
[McCleary](https://docs.ycrc.yale.edu/clusters/mccleary/),
[Misha](https://docs.ycrc.yale.edu/clusters/misha/) and
[scavenge](https://docs.ycrc.yale.edu/clusters-at-yale/job-scheduling/scavenge/).

Per-user limits are aggregate across jobs in that partition. Submitted/running-job caps are
additional limits; account/QoS/group limits can constrain a request further. A single-node request
also cannot exceed that node's CPUs, RAM or GPUs. Use the current cluster page and scheduler
configuration for detailed hardware counts; node counts are not capacity guarantees.

## Bouchet

| Partition | Max time | Aggregate user limit / important cap | GPU / purpose |
|---|---|---|---|
| `day` | 1 day | 1500 CPUs, 20000G | General batch |
| `devel` | 6 h | 4 CPUs, 60G; 2 submitted jobs | Interactive |
| `agent` | 7 days; default 1 h | Per job: 1 CPU, 8G; 2 running jobs/user | Small longer-lived coding-agent allocations; check workload/account eligibility |
| `week` | 7 days | 96 CPUs, 1.50T | Extended batch |
| `gpu` | 2 days | 32 GPUs; 12 running jobs | RTX 5000 Ada 32 GB, L40S/A40 48 GB, A5000 24 GB |
| `gpu_rtx6000` | 2 days | 16 GPUs; 16 running jobs | RTX Pro 6000 Blackwell 96 GB |
| `gpu_h100` | 2 days | 32 GPUs; 12 running jobs | H100 80 GB |
| `gpu_h200` | 2 days | 16 GPUs; 6 running jobs | H200 141 GB |
| `gpu_b200` | 2 days | 16 GPUs; 6 running jobs | B200 193 GB |
| `gpu_devel` | 6 h | Check current CPU/memory/GPU and submitted-job caps | GPU development/debugging |
| `bigmem` | 1 day | 128 CPUs, 8000G | Up to 4014 GiB/node |
| `mpi` | 2 days | 48 nodes; 10 running jobs | Tightly coupled multi-node |
| `scavenge` / `scavenge_gpu` | 1 day | Check selected partition/QoS | Preemptable idle resources |

The older separate `day_AMD` entry is not asserted here: the current public `day` table includes
Turin and Intel hardware. Absence from the web table does not establish absence from live Slurm.

The source's read-only Bouchet check on 2026-09-30 reported `agent` as `State=UP`,
`MaxTime=7-00:00:00`, `DefaultTime=01:00:00` and partition QoS `part_agent`.
`MaxTRESPJ=cpu=1,mem=8G` is a **per-job** cap; `MaxJobsPU=2` limits **running**, not submitted,
jobs per user. `part_agent` had `DenyOnLimit`; allowed job QoS lacked `OverPartQOS`, so
[Slurm's partition QoS rules](https://slurm.schedmd.com/qos.html#partition-qos) apply the partition
limits first. Account/access restrictions can further constrain a request. Recheck before use:

```bash
scontrol show partition agent
sacctmgr -P show qos where Name=part_agent,normal,nothrottle,interactive format=Name,Flags,MaxTRESPJ,MaxTRESPU,MaxJobsPU,MaxSubmitJobsPU
```

No over-limit submission was made to test enforcement; a successful smaller request alone would
not establish these limits. This partition is not an exception to the documented IDE policy.

## McCleary

| Partition | Max time | Aggregate user limit / important cap | GPU / purpose |
|---|---|---|---|
| `day` | 1 day | 256 CPUs, 3000G | General batch |
| `devel` | 6 h | 4 CPUs, 32G; 1 submitted job | Interactive |
| `week` | 7 days | 192 CPUs, 2949G | Extended batch |
| `long` | 28 days | 36 CPUs | Extended batch |
| `gpu` | 2 days | 12 GPUs | A5000/A100/RTX 3090/RTX 5000; 16–80 GB |
| `gpu_devel` | 6 h | Check current caps | GPU development/debugging |
| `bigmem` | 1 day | Check current caps | Large-memory batch |
| `scavenge` / `scavenge_gpu` | 1 day | Check selected partition/QoS | Preemptable |
| `ycga` | Check current partition | Eligibility and current limits required | YCGA-related compute-charge exemption |

Check the [decommission notice](https://docs.ycrc.yale.edu/clusters/grace-mccleary-decommission/) before new setup.

## Misha

| Partition | Max time | Aggregate user limit | GPU / purpose |
|---|---|---|---|
| `day` | 1 day | 512 CPUs, 20T | General batch |
| `devel` | 6 h | 10 CPUs, 70G | Interactive; connection route untested here |
| `week` | 7 days | 128 CPUs, 1280G | Extended batch |
| `gpu` | 2 days | 192 CPUs, 18 GPUs | H100/H200/A100/A40/L40S; 48–141 GB |
| `gpu_devel` | 6 h | 4 CPUs, 32G, 1 GPU | A40 48 GB |
| `bigmem` | 1 day | Check current caps | Large-memory batch |

## Verify before submission

Run these read-only queries in an already authorized cluster session, not on the laptop:

```bash
sinfo -o '%P %l %c %m %G'
scontrol show partition <selected-partition>
```

Inspect current account/QoS/group limits when a request is blocked; do not bypass them. Request
GPUs explicitly and select a required type on mixed-hardware partitions. IDE sessions use devel
partitions under [YCRC's VS Code guidance](https://docs.ycrc.yale.edu/clusters-at-yale/access/ood-vscode/);
treating Positron Remote-SSH similarly is an explicit inference. `gpu_devel` serves development,
not a production escape hatch. Scavenge jobs can be killed without advance notice; restart safely
from the workflow's completion/source/input evidence while preserving retained outputs.
