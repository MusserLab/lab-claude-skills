# Choosing an eligible GPU partition

Compare queues only after establishing which partitions can run the actual workload.
See [§4 GPU jobs](../SKILL.md#gpu-jobs) for host RAM versus per-device VRAM, supported
multi-GPU execution and software compatibility. Hardware tables are references, not live access
checks; use the actual cluster's scheduler and policy. The bundled [partition profile](partitions.md)
retains dated YCRC facts and verification commands; no new scheduler query ran for this package.

## Discover and check candidates

Discover current partition names, state, limits and advertised GPU resources:

```bash
sinfo --format="%P %a %l %D %G"
scontrol show partition "$PARTITION"
```

Set `PARTITION` to a discovered candidate before inspecting it. Check account/association
and QoS access, permitted workload (including development-only restrictions), time/resource
and aggregate limits, host RAM, per-device VRAM, device/software compatibility and billing.
Use a private/priority partition only with the required authorization.

For preemptible candidates, establish safe restart/resumption and
protect partial/retained outputs first; Slurm requeue is **not application checkpointing**.
`--requeue` reruns the original submission script; that workflow must resume safely. Use
`sacct -j "$JOB_ID" --duplicates` to inspect requeue history.
No partition is a universal escape hatch, and a successful listing does not prove eligibility.

## Compare eligible queues

The partition names below are illustrative; replace them with verified eligible candidates.

```bash
PARTITIONS="gpu,gpu_h200"
if ! squeue --partition="$PARTITIONS" --states=PENDING,RUNNING \
    --format="%.18i %.20P %.10T %.8C %.12b %.30R"; then
  printf '%s\n' 'Queue query failed; availability is unknown.' >&2
  exit 1
fi
```

Keep command errors visible. Do not pipe a failed query through `wc` and report zero jobs.
A successful empty view means no visible jobs in those states, not that devices are idle or
the request can start immediately. Queue counts do not account for job size, constraints,
reservations, fair share or backfill and are not a guaranteed start-time ranking.

After submitting, inspect the actual job and its estimated start:

```bash
sprio -j "$JOB_ID"
squeue -j "$JOB_ID" --start
scontrol show job "$JOB_ID"
```

Treat estimated starts as uncertain; they can move or be unavailable. A pending message such
as "DOWN, DRAINED or reserved for jobs in higher priority partitions" lists possible causes,
not proof of a particular reservation or partition overlap. Check the job, relevant node/
partition state and available reservation information; unresolved causes remain unknown.

## Moving a pending job

When the site's policy permits it, an eligible partition change can retain the pending job's
ID and therefore preserve downstream `afterok:JOBID` dependencies:

```bash
scontrol update JobId="$JOB_ID" Partition="$NEW_PARTITION"
scontrol show job "$JOB_ID"
```

Before updating, verify that the job is still pending and that **the entire request** is valid
on the destination: account/QoS, workload, limits, CPU/RAM, GPU count/type/constraints,
software, billing and preemption/restart safety. A matching GPU GRES alone is insufficient.
Read back the updated partition, state and reason; a rejected update is not a move, and a
successful update does not guarantee an earlier start or unchanged priority calculation.

Prefer retaining the job ID when a suitable move is allowed and dependents already exist.
Cancel/resubmit creates a new ID; existing dependencies still refer to the old job and may
become `DependencyNeverSatisfied`. If resubmission is necessary, explicitly repair the
affected dependency chain rather than assuming it follows the new job.
