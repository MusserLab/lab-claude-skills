#!/usr/bin/env bash
# hold-node.sh JOBNAME [salloc options...]
#
# Holds a persistent interactive allocation, meant to be run INSIDE a tmux session
# on a login node (see references/positron-ssh-setup.md, Tier 2).
#
# Idempotent: if a job named JOBNAME is already RUNNING, it opens a shell instead of
# queuing a duplicate (the squeue check is cluster-wide, so this holds even if you
# reconnect on the other login node). Otherwise it requests one with the salloc
# options you pass through.
#
# Uses `exec salloc` so salloc becomes the tmux window's root process: a disconnect
# leaves it alive (reattach -> no re-queue); a real end (walltime / exit / scancel)
# closes the window so re-running the alias cleanly re-allocates.
#
# Example:
#   hold-node.sh positron --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=12:00:00
set -u
job="${1:?usage: hold-node.sh JOBNAME [salloc options...]}"; shift
node=$(squeue -u "$USER" -n "$job" -t RUNNING -h -o %N | head -1)
if [ -n "$node" ]; then
  echo "[$job] already RUNNING on $node — opening a shell (node stays held)."
  exec bash
else
  echo "[$job] no running allocation — requesting one now..."
  exec salloc --job-name="$job" "$@"
fi