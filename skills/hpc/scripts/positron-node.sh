#!/usr/bin/env bash
# positron-node.sh [JOBNAME]   (legacy default JOBNAME: positron)
#
# The runtime default stays `positron` for backward compatibility: an unknown number of
# already-copied ~/.ssh/config ProxyCommands call this with no argument, and changing the
# default would silently break them. It is a LEGACY default only — current supported
# configurations pass the job name explicitly, and that name is `positron-devel`.
#
# Resolves the compute node holding the RUNNING job named JOBNAME and pipes stdio to
# its sshd on port 22. Used by the ProxyCommand in ~/.ssh/config so Positron / VS Code
# Remote-SSH can tunnel into the node (see references/positron-ssh-setup.md, Tier 2).
#
# Filters to -t RUNNING and fails loudly on an empty result, so a pending/stale job
# never sends Positron to the wrong (or no) node.
#
# ProxyCommand usage in ~/.ssh/config:
#   ProxyCommand ssh <cluster>.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron-devel'"
job="${1:-positron}"   # legacy default; supported configs pass positron-devel explicitly
n=$(squeue -u "$USER" -n "$job" -t RUNNING -h -o %N | head -1)
[ -z "$n" ] && { echo "no RUNNING job named '$job'" >&2; exit 1; }
exec nc "$n" 22