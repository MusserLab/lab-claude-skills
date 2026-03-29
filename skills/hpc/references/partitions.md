# Partition Quick-Reference

## McCleary partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 256 CPUs, 3 TiB | — | Default. 26× (64 CPU, 983 GiB) + 5× (36 CPU, 180 GiB) |
| **devel** | 6 hours | 4 CPUs, 32 GiB | — | Max 1 job/user |
| **week** | 7 days | 192 CPUs | — | Extended runtime |
| **long** | 28 days | 36 CPUs | — | 3× (36 CPU, 180 GiB) |
| **gpu** | 2 days | 12 GPUs | A5000 (24 GB), A100 (80 GB), RTX 3090 (24 GB) | |
| **gpu_devel** | 6 hours | 2 GPUs | Mixed | Max 2 jobs/user |
| **bigmem** | 1 day | 32 CPUs | — | Up to 3,960 GiB/node |
| **scavenge** | 1 day | 1,000 CPUs | All idle GPUs | Preemptable |
| **ycga** | — | — | — | **YCGA data — exempt from compute charges** |

## Bouchet partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 1,200 CPUs, 18 TiB | — | 84 nodes (64 CPU, 990 GiB each) |
| **day_AMD** | 1 day | 1,200 CPUs, 18 TiB | — | 26 Turin nodes (128 CPU, 2,251 GiB each) |
| **devel** | 6 hours | 8 CPUs, 120 GiB | — | Max 2 jobs/user |
| **week** | 7 days | 64 CPUs, 1 TiB | — | 6 nodes |
| **gpu** | 2 days | 6 GPUs | RTX 5000 Ada (32 GB) | 9 nodes, 4 GPUs/node |
| **gpu_rtx6000** | 2 days | 6 GPUs | RTX Pro 6000 Blackwell (96 GB) | 8 Turin nodes, 8 GPUs/node |
| **gpu_h200** | 2 days | 16 GPUs | H200 (141 GB) | 9 nodes, 8 GPUs/node |
| **gpu_devel** | 6 hours | 2 GPUs | RTX 5000 Ada + H200 | Max 1 job/user |
| **bigmem** | 1 day | 128 CPUs, 8 TiB | — | 4 nodes (64 CPU, 4,014 GiB each) |
| **mpi** | 2 days | 32 nodes | — | 60 nodes, tightly-coupled parallel |
| **scavenge** | 1 day | — | L40S, RTX 5000 Ada, H200 | Preemptable idle nodes |

## Misha partitions

| Partition | Max time | Per-user limits | GPUs | Notes |
|-----------|----------|----------------|------|-------|
| **day** | 1 day | 512 CPUs, 20 TiB | — | 18× Intel 6458 (64 CPU, 479 GiB) |
| **devel** | 6 hours | — | — | 2 nodes, interactive |
| **week** | 7 days | 128 CPUs, 1,280 GiB | — | 6 nodes |
| **gpu** | 2 days | 192 CPUs, 18 GPUs | H100 (80 GB), H200 (141 GB), A100 (80 GB), A40 (48 GB), L40S (48 GB) | 32 nodes |
| **gpu_devel** | 6 hours | 2 GPUs | Mixed | 2 nodes |
| **bigmem** | 1 day | 64 CPUs, 2 TiB | — | 2× (64 CPU, 1,991 GiB) |
