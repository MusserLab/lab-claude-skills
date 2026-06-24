# Picking the fastest GPU partition

Tactics for choosing the least-congested GPU partition before submitting, and for
switching a pending GPU job to a faster partition. See §4 "GPU jobs" in `SKILL.md` for
the basic `--gpus` request and the partition/VRAM table.

> **Verify partition names before relying on this.** The partition list in the queue-depth
> loop below (`gpu_b200`, `scavenge_gpu`) and the "all four GPU types" note may lag the live
> cluster — `SKILL.md`'s §4 GPU table and `partitions.md` document three Bouchet GPU
> partitions (`gpu`, `gpu_rtx6000`, `gpu_h200`) plus `scavenge`. Confirm with `sinfo -o "%P"`
> on Bouchet and reconcile the names across all three locations if they disagree.

**Always check queue depth across GPU partitions before submitting** — they swing
wildly day-to-day, and "the obvious choice" is often the slowest. Before any non-
trivial GPU job:

```bash
# 1. Queue depth across all GPU partitions
for p in gpu gpu_h200 gpu_rtx6000 gpu_b200 scavenge_gpu gpu_devel; do
  pd=$(squeue -p $p -h -t PD 2>/dev/null | wc -l)
  rn=$(squeue -p $p -h -t R 2>/dev/null | wc -l)
  echo "$p: $rn running, $pd pending"
done
```

Wide swings are normal. Recent example (2026-05-24): `gpu` had 233 pending, `gpu_h200`
92, `gpu_rtx6000` 17, `gpu_devel` 0. Past experience said `gpu_h200` was fastest;
on that day it had a 15-hour ETA.

**After submitting, check your priority position and ETA:**

```bash
sprio -j <jobid>                                    # your priority breakdown
squeue -p <part> -t PD -O JobID,Priority -S -p \    # your rank in pending queue
  | head -10
squeue -j <jobid> --start                           # estimated start time
                                                    # (conservative — actual often sooner)
```

If estimated start is too far out, switch partitions on the pending job:

```bash
scontrol update job=<jobid> Partition=<new_part>
```

This works on PD jobs only; no resubmit needed. The job keeps its priority age.
Session-7 trick — used it to escape a 5-day `gpu` ETA into a fast `gpu_h200` slot.

**Gotcha — "reserved for jobs in higher priority partitions":**
If a pending job shows reason `(Nodes required for job are DOWN, DRAINED or reserved
for jobs in higher priority partitions)` even when you have top priority *within*
your partition, the `priority_gpu` partition has reserved nodes that overlap your
target partition's nodes. Check overlap with `sinfo -p priority_gpu --Format=Gres`.
Switching to another general GPU partition may help (different node overlap) or may
not (`priority_gpu` reserves nodes across all four GPU types on Bouchet). If the
job is OK with preemption, `scavenge_gpu` bypasses this reservation system entirely
— but a higher-priority job arriving mid-run will kill yours, so only worth it for
work that's safe to restart (good per-stage checkpointing or fingerprint-based
resumption).