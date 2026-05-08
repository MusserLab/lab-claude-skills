# Working on HPC Compute Nodes with Claude Code

Two ways to use Claude Code on a Bouchet compute node:

1. **CLI over plain SSH** — SSH into the compute node and run `claude` in the terminal.
   No IDE setup required. Use the `bouchet-day` alias from Step 1 below, then `cd` to
   your project and run `claude`.
2. **Positron / VS Code Remote SSH** — full IDE with file browser, git integration, and
   Claude Code in the integrated terminal. Requires the SSH config in Step 2 below.

## Prerequisites

- SSH key-based access to Bouchet (see main skill, Section 1)
- Positron or VS Code with the **Remote - SSH** extension installed
- macOS (Linux users: same approach, adjust shell config paths)

---

## Step 1: Shell alias to allocate the interactive session

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
# Allocate an interactive compute node on Bouchet (day partition)
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron"'
```

The `--job-name=positron` is important — the SSH config below uses it to find the allocated
node. After adding, run `source ~/.zshrc` or open a new terminal.

**Usage:** Run `bouchet-day` in a terminal. When the allocation is granted, you'll see the
compute node hostname (e.g., `c14n04`). Leave this terminal open — closing it releases the
allocation.

## Step 2: SSH config entry for the compute node

Add to `~/.ssh/config`:

```
Host bouchet-day
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n positron -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

Replace `<netid>` with your Yale NetID (both occurrences).

**How it works:** When Positron connects to `bouchet-day`, SSH first connects to the
Bouchet login node, runs `squeue` to find which compute node has your `positron` job, then
tunnels through to that node via `nc` (netcat). `ForwardAgent` passes your SSH key so git
operations work on the compute node. The keepalive settings prevent the connection from
dropping during idle periods.

## Step 3: Connect from Positron

1. **Allocate first:** Run `bouchet-day` in a local terminal. Wait for the allocation.
2. **Open Remote Explorer** in Positron (left sidebar, monitor icon)
3. **Connect to `bouchet-day`** — it will appear in your SSH targets list
4. **Open a folder** — navigate to your project directory (e.g.,
   `/nfs/roberts/project/pi_jm284/<project>/`)

**Important:** Use **"Open Folder"** to open your project directory, not "New Window".
Opening a folder gives Positron the full project context (git, file tree, integrated
terminal at the right path). A new window drops you at `~/` with no context.

---

## Troubleshooting

### "Connection refused" or timeout
- Is the allocation still running? Check with `squeue --me` on the login node
- Did the allocation expire? Re-run `bouchet-day`
- Wrong netid in SSH config? Both `User` and the `squeue -u` must match

### "No matching host" in squeue
- The job may not have started yet (pending in queue). Wait for the allocation prompt
- The job name must be `positron` — check that your alias uses `--job-name=positron`

### Git operations fail on compute node
- Check that `ForwardAgent yes` is in the SSH config
- Run `ssh-add -l` on the compute node — your key should be listed
- If not, run `ssh-add` locally before connecting

### Extensions not installing on remote
- Positron/VS Code installs extensions on the remote host on first connect. This can be
  slow on NFS. Be patient on the first connection.

### Session disconnects after idle period
- The `ServerAliveInterval 60` should prevent this. If it still drops, check whether
  the SLURM allocation timed out (`squeue --me`)

---

## Running multiple sessions simultaneously

The ProxyCommand finds compute nodes by job name (`-n positron`). If you run two
allocations with the same job name, `head -1` always connects to the same one (typically
the oldest). To run multiple simultaneous sessions, give each a distinct job name and
SSH config entry.

**Aliases** (add to `~/.zshrc`):

```bash
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron"'
alias bouchet-day2='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron2"'
```

**SSH config** (add to `~/.ssh/config`):

```
Host bouchet-day2
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n positron2 -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

Connect to `bouchet-day` or `bouchet-day2` in Positron depending on which session you
want. Add more (`positron3`, etc.) as needed.

---

## Variant: devel partition (shorter queue, 6-hour max)

For quick sessions when `day` has a long queue:

```bash
alias bouchet-devel='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=devel --time=6:00:00 --job-name=positron"'
```

Uses the same SSH config as `bouchet-day` — both aliases use `--job-name=positron`, so the
ProxyCommand finds whichever one is running. If you need a devel session alongside a day
session, use a distinct job name (e.g., `--job-name=positron-devel` with a matching SSH
config entry).