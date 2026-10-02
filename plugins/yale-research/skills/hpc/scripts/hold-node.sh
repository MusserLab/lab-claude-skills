#!/usr/bin/env bash
# hold-node.sh JOBNAME [salloc options...]
#
# Holds a persistent interactive allocation, meant to be run INSIDE a tmux session
# on a login node (see references/positron-ssh-setup.md, Tier 2).
#
# What it does, in order:
#   1. Rejects a caller-supplied job name. The positional JOBNAME is the ONLY source
#      of the submitted --job-name, so the name looked up and the name submitted
#      cannot drift.
#   2. Does ONE cluster-wide squeue lookup for your jobs with that exact name,
#      filtered to PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING. The filter is
#      written out on purpose: Slurm's no-state default covers PENDING, RUNNING and
#      COMPLETING but NOT the SUSPENDED base state.
#   3. Lookup FAILED           -> refuse, exit nonzero, allocate nothing. The
#                                 allocation state is unknown; do not guess.
#      One or more jobs FOUND  -> print each (id, state, node-or-reason), submit
#                                 nothing, exit 0. No shell is started.
#      Nothing found           -> exec salloc for a genuinely new allocation.
#
# It deliberately does NOT open a shell when it finds an existing job. On the other
# login node that shell would become the root of a fresh tmux session and could
# outlive the allocation, so a later alias run would reattach a stale shell and never
# re-run this script. Exiting lets that temporary tmux session end. Tier 2's
# `ControlPersist 30m` keeps the authenticated SSH master alive regardless.
#
# SCOPE OF THE GUARANTEE -- read this before relying on it:
#   It prevents an EXTRA SUBMISSION ON A NORMAL RECONNECT, where an earlier job is
#   already visible to squeue. It is NOT an atomic cross-login lock: two first
#   invocations racing each other can both see an empty queue and both allocate.
#   Do not start the alias twice at the same moment.
#
# Example (the supported form -- devel, within the aggregate per-user caps):
#   hold-node.sh positron-devel --nodes=1 --cpus-per-task=4 --mem=32G --partition=devel --time=06:00:00
set -u
job="${1:?usage: hold-node.sh JOBNAME [salloc options...]}"; shift

# Reject any caller-supplied job name BEFORE the lookup or the submission, in every
# spelling salloc accepts: -J NAME, -JNAME, --job-name NAME, --job-name=NAME.
for arg in "$@"; do
  case "$arg" in
    -J*|--job-name|--job-name=*)
      echo "[$job] REFUSING: set the job name only as the first argument; found '$arg'." >&2
      exit 2 ;;
  esac
done

# One lookup, captured whole. Deliberately NOT piped into `head`: a pipeline discards
# squeue's exit status, which would make a lookup FAILURE indistinguishable from
# "no job" and let this script allocate a duplicate.
states=PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING
if ! active=$(squeue -u "$USER" -n "$job" -t "$states" -h -o '%i %T %R'); then
  echo "[$job] REFUSING: squeue lookup failed -- not requesting an allocation." >&2
  echo "[$job] The allocation state is UNKNOWN. Investigate before re-running." >&2
  exit 1
fi

count=$(printf '%s\n' "$active" | grep -c '[^[:space:]]') || true
if [ "$count" -gt 0 ]; then
  if [ "$count" -gt 1 ]; then
    echo "[$job] WARNING: $count active jobs already share this name:"
  else
    echo "[$job] an allocation already exists:"
  fi
  printf '%s\n' "$active" | grep '[^[:space:]]' | while read -r id state where; do
    echo "    job $id  state=$state  node/reason=$where"
  done
  echo "[$job] NOT submitting another job; the allocation is untouched."
  echo "[$job] If it is PENDING, wait for it to reach RUNNING before connecting."
  exit 0
fi

# Only this branch starts salloc. `exec` makes salloc the tmux window's root process,
# so a disconnect leaves it alive (reattach -> no re-queue) while a real end (walltime
# / exit / scancel) closes the window and a later alias run cleanly re-allocates.
echo "[$job] no active allocation -- requesting one now..."
exec salloc --job-name="$job" "$@"
