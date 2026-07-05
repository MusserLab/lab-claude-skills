#!/usr/bin/env bash
# positron-node.sh [JOBNAME]   (default JOBNAME: positron)
#
# Resolves the compute node holding the RUNNING job named JOBNAME and pipes stdio to
# its sshd on port 22. Used by the ProxyCommand in ~/.ssh/config so Positron / VS Code
# Remote-SSH can tunnel into the node (see references/positron-ssh-setup.md, Tier 2).
#
# Filters to -t RUNNING and fails loudly on an empty result, so a pending/stale job
# never sends Positron to the wrong (or no) node.
#
# ProxyCommand usage in ~/.ssh/config:
#   ProxyCommand ssh <cluster>.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron'"
job="${1:-positron}"
n=$(squeue -u "$USER" -n "$job" -t RUNNING -h -o %N | head -1)
[ -z "$n" ] && { echo "no RUNNING job named '$job'" >&2; exit 1; }
exec nc "$n" 22