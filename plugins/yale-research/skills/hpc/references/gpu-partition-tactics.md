# Choosing a GPU partition

Choose eligible hardware and VRAM first, then compare current queue conditions. See the dated
[partition profile](partitions.md) and the main skill's explicit GPU requests. Queue length alone
cannot predict start time: requested GPU type/count, CPU/RAM, reservations, priority and job duration
matter. No partition is a reliable production-job escape hatch.

Official [Bouchet hardware](https://docs.ycrc.yale.edu/clusters/bouchet/) and
[scavenge guidance](https://docs.ycrc.yale.edu/clusters-at-yale/job-scheduling/scavenge/) checked
2026-10-01; no live queue query was performed. Bouchet documents `gpu`, `gpu_rtx6000`, `gpu_h100`,
`gpu_h200`, `gpu_b200` and `gpu_devel`; `scavenge_gpu` is documented in scavenge guidance.
Confirm current names and eligibility in an authorized session before using them.

```bash
# Cluster-side, read-only. Do not suppress an invalid-partition/query failure as zero queue depth.
sinfo -o '%P %G'
for partition in gpu gpu_h100 gpu_h200 gpu_rtx6000 gpu_b200 scavenge_gpu; do
  echo "$partition"
  squeue -p "$partition" -t PENDING,RUNNING -o '%.18i %.10T %.12P %.12b %.10M %R' || break
done
sprio -j <jobid>
squeue -j <jobid> --start
```

Treat the ETA as an estimate. `gpu_devel` is for GPU development/debugging within its current caps,
not general production jobs. Use a private/priority partition only with the required authorization.

## Changing a pending job's partition

Inspect the pending job and new partition's hardware, typed GPU request, walltime and other limits.
If the change remains inside the approved workload/resources, a pending job may be updated:

```bash
scontrol show job <jobid>
scontrol update JobId=<jobid> Partition=<new-partition>
scontrol show job <jobid>
```

This preserves the job ID, which matters when dependent jobs reference `afterok:<jobid>`.
Recheck the updated request and dependencies; do not assume eligibility, priority age or immediate
start is guaranteed. If updating is refused, investigate rather than cancelling a dependency chain
blindly. A running job needs a different plan; this is a pending-job procedure.

## Reservations and scavenge

A pending reservation/priority reason can concern overlapping nodes or several other scheduler
states. Inspect the actual reason and current node/partition configuration; do not infer a universal
reservation bypass. Scavenge uses idle resources but can be preempted without warning. Select it
only when restarting is acceptable and preserve completion/source/input identities plus retained
outputs. `--requeue` reruns the original submission script; the workflow itself must resume safely.
Use `sacct -j <jobid> --duplicates` to inspect requeue history.
