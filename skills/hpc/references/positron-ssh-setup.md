# Working on HPC Compute Nodes with Positron / Claude Code

Two ways to use Claude Code on a Bouchet **or** McCleary compute node:

1. **CLI over plain SSH** — SSH into the compute node and run `claude` in the terminal.
   No IDE setup required. Use one of the allocation aliases below, then `cd` to your
   project and run `claude`.
2. **Positron / VS Code Remote SSH** — full IDE with file browser, git integration, and
   Claude Code in the integrated terminal. Requires the SSH config below.

Examples below use **Bouchet** and **McCleary**; **Misha** works identically — clone any
`*.ycrc.yale.edu` block plus the alias and `Host` entries, swapping in `misha.ycrc.yale.edu`
and your job name.

There are **two reliability tiers** — pick one based on how much you'd mind losing the
allocation if your laptop drops:

| Tier | Setup effort | A laptop / VPN drop… | Use for |
|------|--------------|----------------------|---------|
| **Tier 1 — Basic** | ~5 min, laptop only | **kills your allocation** — you re-queue | quick `devel` tests; short sessions |
| **Tier 2 — Persistent** | ~10–15 min, +2 cluster-side scripts | **survives** — reconnect, no re-queue | long/big allocations; anything you'd hate to lose |

Both tiers share the Duo + ControlMaster mechanism below — read that first, then jump to
the tier you want. Tier 2 builds on Tier 1's concepts, so skim Tier 1 even if you go straight
to Tier 2.

---

## ⚠️ Read this first: YCRC requires Duo 2FA, so you MUST use SSH ControlMaster

YCRC login nodes (Bouchet, McCleary, Misha) require **two-factor authentication**: your SSH
key gets you *"partial success"*, then the server demands a Duo passcode
(`keyboard-interactive`). You can watch this happen with `ssh -v <cluster>.ycrc.yale.edu`:

```
Authenticated using "publickey" with partial success.
debug1: Authentications that can continue: keyboard-interactive
Passcode or option (1-3):
```

This breaks the Positron Remote-SSH ProxyCommand by default. Positron spawns the outer
`ssh <cluster>` **non-interactively** — it has nowhere to show the Duo prompt and nothing to
type into it — so the connection dies in ~5 seconds with `ERR_STREAM_PREMATURE_CLOSE` and
**no `Trying publickey authentication` line** in the Remote-SSH log.

**The fix is SSH connection multiplexing (`ControlMaster`).** You authenticate *once*,
interactively (passing Duo), keep that connection open, and every later ssh — including
Positron's ProxyCommand — **reuses** it instead of re-authenticating. In Tier 1 the
allocation alias itself doubles as that master connection; in Tier 2 a short `ControlPersist`
window keeps the master alive even after you close the terminal. (This is why a setup that
works in a terminal can still fail in Positron — the terminal has an authenticated/agent
connection the GUI spawn can't see.)

---

## Prerequisites

- **SSH key set up on the target cluster.** Keys are **per-cluster** — Bouchet and McCleary
  have separate home directories and separate `~/.ssh/authorized_keys`. A key authorized on
  Bouchet does **not** work on McCleary. Set up each with
  `ssh-copy-id -i ~/.ssh/id_ed25519.pub <netid>@<cluster>.ycrc.yale.edu` (see main skill,
  Section 1). Verify: `ssh <cluster>.ycrc.yale.edu` should accept your key and then prompt
  for a Duo passcode (not a password).
- Positron or VS Code with the **Remote - SSH** extension installed.
- **macOS, Linux, or Windows-via-WSL** — see Platform notes just below. The Windows caveat
  matters: the native Windows OpenSSH client *cannot* do the ControlMaster trick this setup
  depends on, so Windows users must use WSL.
- **Tier 2 only:** the two helper scripts must exist in `~/bin` **on each cluster you use**
  (separate home dirs — see Tier 2 §a).

---

## Platform notes (macOS / Linux / Windows)

The setup below is written for **macOS**. The Duo + ControlMaster mechanism is the
load-bearing part; here is how it ports.

### macOS
Use the recipe as written.

### Linux
The same `~/.ssh/config` works with three changes:
- **Keep `ControlMaster` / `ControlPath` / `ControlPersist`** — these are upstream OpenSSH
  (since 2004), not macOS-specific, so the Duo-once-then-reuse behavior carries over
  unchanged. Keep the `%r@%h:%p` tokens in `ControlPath` so each master socket is unique.
- **Remove `UseKeychain`** — it's an Apple-only option; stock OpenSSH aborts the *entire*
  connection with `Bad configuration option: usekeychain`. Delete the line, or to keep one
  cross-platform config, put `IgnoreUnknown UseKeychain` on the line **immediately before** it
  (order matters).
- **Shell rc:** put the aliases in `~/.bashrc` (bash) instead of `~/.zshrc`. If you run zsh
  on Linux, `~/.zshrc` is fine as-is.
- **Persist the key passphrase** (the Keychain equivalent): keep `AddKeysToAgent yes`, then
  either bound the agent cache with `ssh-add -t 8h`, or for persistence across logins use the
  [`keychain`](https://www.funtoo.org/Funtoo:Keychain) utility or GNOME Keyring / KWallet.
  (GNOME Keyring's SSH agent is **off by default since v46** — enable the
  [`gcr-ssh-agent.socket`](https://www.adamsdesk.com/posts/fix-gnome-keyring-ssh-auth-sock/)
  user unit.)

### Windows — use WSL
**Native Windows OpenSSH does not support `ControlMaster`** (`ControlMaster` / `ControlPath` /
`ControlPersist`). It's explicitly scoped out — the multiplexing relies on passing file
descriptors over a Unix-domain socket, which the Windows port doesn't implement — and has sat
unresolved since 2019 ([Win32-OpenSSH #1328](https://github.com/PowerShell/Win32-OpenSSH/issues/1328),
confirmed open through 2026). Setting the options yields an opaque
`muxclient socket(): Unknown error`. **So the Duo-once-then-reuse trick cannot work on the
native client** — every `ssh` invocation (and the IDE makes 2+ per window) opens a fresh
connection and re-fires Duo.

**Recommended: run the whole workflow from WSL**, whose Linux OpenSSH has working
multiplexing. Follow the **Linux** instructions above *inside* WSL, and make the IDE use WSL's
ssh — either launch the editor from within WSL, or set `remote.SSH.path` to the WSL `ssh`
binary. One gotcha: keep the `ControlPath` socket on the **Linux** filesystem (`~/.ssh` on
ext4), **not** under `/mnt/c`, or the multiplexed client can
[hang](https://github.com/microsoft/WSL/issues/3370). tmux (Tier 2) runs on the cluster, so
it is unaffected by the Windows client limitation.

> The per-connection-Duo fallback that **VS Code** users rely on —
> `"remote.SSH.showLoginTerminal": true`, then approve each Duo push in the surfaced terminal
> (also YCRC's documented [OOD-VS-Code](https://docs.ycrc.yale.edu/clusters-at-yale/access/ood-vscode/)
> approach) — **does not exist in Positron** (its open-remote-ssh extension doesn't expose that
> setting). So on native Windows + Positron there is no good substitute; WSL is the path.

---

# Tier 1 — Basic interactive session

Quickest to set up (laptop only, no cluster-side files). The single
`ssh -t "salloc …"` connection both holds the allocation and serves as the ControlMaster.
**Limitation:** that one connection holding the allocation means a laptop/VPN drop sends
`SIGHUP` to `salloc`, SLURM releases the node, and you have to re-queue. If that's a problem,
use Tier 2.

### 1. `~/.ssh/config` — ControlMaster + per-session compute-node entries

Replace **`<netid>`** with your Yale NetID (every occurrence):

```sshconfig
# --- Login nodes: authenticate Duo ONCE, reuse everywhere (ControlMaster) ---
Host *.ycrc.yale.edu
    User <netid>
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p

# --- Default key for all hosts ---
# Point IdentityFile at the key you actually generated (id_ed25519 or id_rsa).
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

# --- Interactive compute-node sessions (your Positron Remote-SSH targets) ---
Host bouchet-day
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n positron -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

Host bouchet-devel
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n positron-devel -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

Host mccleary-ycga
    User <netid>
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n ycga -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

Notes:
- **`%%N` is intentional** — in an SSH config file `%%` escapes to a literal `%`, so squeue
  receives `%N` (the node-list format). Do not "fix" it to a single `%`.
- The `ProxyCommand` connects to the login node, runs `squeue` to find which compute node
  holds your job (matched **by job name**, `-n`), then tunnels to it via `nc`.
- **Use the round-robin name** (`bouchet.ycrc.yale.edu`), NOT an individual login node like
  `login1.bouchet.ycrc.yale.edu` — the per-node names are generally **not reachable** from off
  the cluster and will time out.
- `ForwardAgent yes` passes your key to the compute node so git works there.
- The `-n <name>` in the ProxyCommand **must match `--job-name`** in the alias below.

### 2. `~/.zshrc` (or `~/.bashrc`) — allocation aliases

```bash
# Bouchet — day partition (general work)
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron"'

# Bouchet — devel partition (shorter queue, quick sessions)
alias bouchet-devel='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=devel --time=6:00:00 --job-name=positron-devel"'

# McCleary — ycga partition
alias mccleary-ycga='ssh mccleary.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=2 --mem=16G --partition=ycga --time=12:00:00 --job-name=ycga"'
```

Then `source ~/.zshrc` or open a new terminal. The `--job-name` in each alias must match the
`-n` in the corresponding SSH config entry.

### 3. Each work session — order of operations

1. **Run the alias** (e.g. `mccleary-ycga`). **Authenticate Duo once** when prompted. Wait for
   the allocation — you'll see the compute node. **Leave this terminal open.** This connection
   is your ControlMaster master *and* it holds the allocation; closing it releases both.
2. **Connect in Positron:** Remote Explorer → connect to the matching host (`mccleary-ycga` /
   `bouchet-day`). It reuses the master — **no second Duo prompt** — and installs the Positron
   server on the node.
3. **First connect installs the server** (~400 MB over NFS, a few minutes). If it fails with
   `Error server did not start successfully`, just **reconnect 1–3 times** (NFS race — see
   Troubleshooting).
4. **Use "Open Folder"**, not "New Window", and navigate to your project.

### Reconnecting after a drop (Tier 1) — you can't, really

If the laptop/VPN connection drops, the `ssh -t "salloc …"` connection dies, `salloc` receives
`SIGHUP`, and **SLURM releases the node**. There is nothing to reconnect to — re-run the alias,
which **queues a brand-new allocation** (a wait if you asked for a lot). This is the one
limitation Tier 2 removes.

---

# Tier 2 — Persistent session (survives disconnects)

> **Heads-up: this takes a bit longer to set up** — two small scripts on each cluster plus a
> few extra `~/.ssh/config` lines. The payoff: a VPN drop, laptop sleep, or closed lid no
> longer kills your allocation. Reconnect with one Duo and Positron picks the same node back
> up. Worth it for anything bigger than a quick devel shell.

### What it adds, and why

The Tier 1 fragility is that **one process** (the `ssh -t salloc`) both holds the allocation
and is the master. Tier 2 decouples them:

- **`salloc` runs inside a `tmux` session on the login node.** tmux's server is a daemon
  reparented to PID 1, so it is no longer in the SSH session's process group — a disconnect's
  `SIGHUP` never reaches `salloc`. The allocation lives on, bounded only by `--time`.
  (This is YCRC's own documented pattern: run tmux on the login node, `salloc` inside it.)
- **`ControlPersist`** keeps the Duo-authenticated master alive after the foreground ssh
  closes, so Positron's non-interactive ProxyCommand can still reuse it on reconnect.
- **`ServerAliveInterval`** makes a half-dead master *fail fast* instead of hanging after an
  ungraceful drop.
- **Helper scripts** add an idempotency guard (don't double-allocate) and a hardened node
  lookup (`-t RUNNING` + fail-on-empty).

Positron's ProxyCommand is unchanged in spirit — it finds the node by job name and tunnels in;
YCRC's `pam_slurm_adopt` admits the SSH because you own a running job there. That works whether
the job is held by `salloc`-in-tmux or a batch placeholder (see Variant B).

### One-time setup

#### a. Helper scripts in `~/bin` — **on each cluster** (separate home dirs)

The two helper scripts ship with this skill in `scripts/`. Because the skill is present on the
cluster too (your synced `~/.claude/skills/`, or the lab plugin), **copy** the bundled copies into
`~/bin/` rather than pasting them inline — run this **on a login node of each cluster you use**
(Bouchet, McCleary, …):

```bash
mkdir -p ~/bin
# Resolve this skill's scripts/ dir, whether it's a synced ~/.claude/skills copy or a lab-plugin install:
SRC=$(dirname "$(find ~/.claude -path '*/hpc/scripts/hold-node.sh' 2>/dev/null | head -1)")
cp "$SRC"/hold-node.sh "$SRC"/positron-node.sh ~/bin/
chmod +x ~/bin/hold-node.sh ~/bin/positron-node.sh
```

> `scripts/hold-node.sh` and `scripts/positron-node.sh` are the single source of truth — copying
> from them (rather than maintaining a second inline copy here) keeps the two from drifting. `~/bin`
> does **not** need to be on your `PATH`; the alias and ProxyCommand call the scripts by full path.
> Copy into the stable `~/bin/` rather than pointing the alias at the skill dir directly, so a
> plugin update can't move the scripts out from under a running alias. (When Claude is doing this
> setup it already knows the skill's path and can skip the `find`.)

#### b. `~/.ssh/config` — ControlPersist + keepalives + hardened ProxyCommands

This **extends** the Tier 1 config. Replace **`<netid>`**:

```sshconfig
# --- Login nodes: Duo ONCE, reused, and the master SURVIVES brief drops ---
Host *.ycrc.yale.edu
    User <netid>
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 30m            # master outlives the foreground ssh (key for reconnect)
    ServerAliveInterval 30        # detect a dead master and fail fast instead of hanging
    ServerAliveCountMax 3

# --- Default key for all hosts ---
Host *
    AddKeysToAgent yes
    UseKeychain yes               # macOS only — see Platform notes
    IdentityFile ~/.ssh/id_ed25519

# --- Shared options for every Positron compute-node target (set ONCE) ---
Host bouchet-day* bouchet-devel* mccleary-ycga
    User <netid>
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

# --- Per-target: only the unique ProxyCommand differs (job name passed to positron-node.sh) ---
Host bouchet-day
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron'"
Host bouchet-devel
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron-devel'"
Host mccleary-ycga
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh ycga'"
```

Notes:
- `ControlMaster` matches the host *alias* you type, not the `HostName`. Because both the
  alias (`ssh bouchet.ycrc.yale.edu …`) and the ProxyCommand (`ssh bouchet.ycrc.yale.edu …`)
  use the same name, they share one master socket — and that socket implicitly **pins** all
  reused connections to whichever login node it first landed on (see "How ControlMaster works").
- Setting the shared `ServerAliveInterval`/`ForwardAgent`/`User` once in the
  `Host bouchet-day* bouchet-devel* mccleary-ycga` block avoids repeating them per target; SSH
  merges options across all matching blocks (first value wins per option, and these don't
  conflict with the per-target `ProxyCommand`).
- Raise `ControlPersist` (e.g. `4h`, or `yes` for indefinite) if you want the master to outlive
  longer offline gaps.
- The two `ServerAliveInterval` values are deliberate, not a typo: the **master** (login hop) uses
  `30` so a dead master is detected fast on reconnect; the **compute-node** targets use a looser
  `60` because that tunnelled hop is steadier and needn't probe as often. Both are fine.

#### c. `~/.zshrc` — tmux-wrapped aliases

```bash
# Each alias wraps salloc in a tmux session NAMED AFTER THE JOB. The salloc resources live
# in the alias; hold-node.sh just adds the job name + idempotency.
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "tmux new-session -A -s positron \"~/bin/hold-node.sh positron --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=12:00:00\""'
alias bouchet-devel='ssh bouchet.ycrc.yale.edu -t "tmux new-session -A -s positron-devel \"~/bin/hold-node.sh positron-devel --nodes=1 --cpus-per-task=2 --mem=16G --partition=devel --time=06:00:00\""'
alias mccleary-ycga='ssh mccleary.ycrc.yale.edu -t "tmux new-session -A -s ycga \"~/bin/hold-node.sh ycga --nodes=1 --cpus-per-task=2 --mem=16G --partition=ycga --time=12:00:00\""'

# Handy: list your live tmux sessions on the login node
alias bouchet-ls='ssh bouchet.ycrc.yale.edu -t "tmux ls"'
alias mccleary-ls='ssh mccleary.ycrc.yale.edu -t "tmux ls"'
```

`tmux new-session -A` attaches to the session if it exists, else creates it and runs the
command. So re-running an alias **reattaches** (no duplicate `salloc`); a fresh start
**allocates**.

### Each work session — order of operations

1. **Run the alias** (e.g. `bouchet-day`). **Duo once.** It creates the tmux session and (first
   time) requests the node; you land in your `salloc` allocation.
2. **Detach or just leave it.** `Ctrl-b` then `d` detaches cleanly; or simply close the
   terminal — the allocation survives because tmux holds it on the login node.
3. **Connect Positron** to the matching host (`bouchet-day`). It reuses the master (no second
   Duo), and `positron-node.sh` finds your node.

### Managing it & reconnecting after a drop

**What survives a laptop/VPN drop:** the `salloc`, the tmux session, the held compute node, and
Positron's remote server (it lives in your job's cgroup on the node). Only the laptop-side SSH
master dies.

**To reconnect (the one thing to remember):**
1. Reconnect the VPN.
2. **Run the alias once** (e.g. `bouchet-day`) → answer Duo → this rebuilds the master *and*
   reattaches the tmux session (you'll see your `salloc` still there = proof the node survived).
3. Positron usually reconnects on its own within a few seconds; if it sits there, **Reload
   Window** or reconnect from Remote Explorer.

Why step 2 is required: Positron's ProxyCommand runs `ssh …` *non-interactively* and can't
answer Duo — it needs a live master to ride. So you re-auth one interactive SSH first, then
Positron reuses it.

**If the alias hangs instead of prompting Duo** (stale half-open master after an ungraceful
drop): `ssh -O exit bouchet.ycrc.yale.edu`, then run the alias again.

**Cheat sheet:**
```bash
squeue --me                              # jobs + nodes (NODELIST) + time used
bouchet-ls                               # your tmux sessions on the login node
bouchet-day                              # connect / reconnect (reattaches if alive)
#   inside tmux:  Ctrl-b then d          # detach WITHOUT killing the allocation
ssh -O check bouchet.ycrc.yale.edu       # is the master alive?
ssh -O exit  bouchet.ycrc.yale.edu       # kill a wedged master
scancel -n positron                      # release the node when done
```

**Where your work runs:** **do all real compute in Positron's terminal** — it always runs on the
compute node. The **alias/tmux terminal only holds the allocation**: depending on the cluster's
SLURM config it may leave you on a **login node** (where heavy work violates the no-compute-on-login-nodes
policy) or drop you onto the compute node, so treat it as allocation-management only and check with
`hostname` if unsure. If `tmux ls` errors *inside* the session shell, that's expected (its `$TMUX`
socket lives on the login node) — list sessions with `bouchet-ls` from your laptop.

**When you're done:** close the Positron remote window, then `scancel -n positron` (or `exit`
the salloc shell) — otherwise the node is held idle until walltime, which wastes your
fairshare/priority. Optionally `ssh -O exit bouchet.ycrc.yale.edu` to drop the master.

### What still ends the node (tmux does NOT protect against these)

- **Walltime** (`--time`). When it expires mid-work, the node is released, Positron's server
  dies with it, and Positron can't reconnect. **This is your real deadline — save often.**
  Re-run the alias for a fresh node.
- **`scancel`, or typing `exit`** in the salloc shell.
- **Login-node reboot/maintenance** (rare) — takes the tmux with it. (Variant B survives this.)
- **Node failure.**

### Variant B — detached batch placeholder (most robust)

Instead of `salloc`-in-tmux, hold the node with a **batch job** that just sleeps. It lives in
the scheduler, fully detached — survives the laptop drop *and* a login-node reboot — with no
tmux at all. Trade-off: no interactive shell, and you must release it manually.

```bash
alias bouchet-hold='ssh bouchet.ycrc.yale.edu "sbatch --job-name=positron --partition=day --nodes=1 --cpus-per-task=8 --mem=32G --time=12:00:00 --output=/dev/null --wrap=\"sleep infinity\""'
alias bouchet-free='ssh bouchet.ycrc.yale.edu "scancel -n positron"'
```

Positron connects exactly as in Tier 2 (the `bouchet-day` ProxyCommand finds the `positron`
job regardless of how it's held). Requires the same `ControlPersist` config. Don't run a
placeholder and a `salloc`-in-tmux with the **same** job name at once.

### Multiple simultaneous sessions

The ProxyCommand finds nodes by job name. For a second concurrent node, give it a **distinct
job name**, a matching tmux session name, a matching SSH `Host` entry, and a matching alias:

```bash
alias bouchet-day2='ssh bouchet.ycrc.yale.edu -t "tmux new-session -A -s positron2 \"~/bin/hold-node.sh positron2 --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=12:00:00\""'
```
```sshconfig
Host bouchet-day2
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron2'"
```
(Add `bouchet-day2` to the shared `Host bouchet-day* …` options block via the `bouchet-day*`
glob.) Never run two with the **same** job name simultaneously.

---

## Troubleshooting (both tiers)

### Fails in ~5 s with `ERR_STREAM_PREMATURE_CLOSE`, no `Trying publickey authentication` line
The outer ProxyCommand hop can't get past Duo — no live authenticated master to reuse.
- Confirm the `Host *.ycrc.yale.edu` ControlMaster block is in `~/.ssh/config`.
- Confirm you have an **open, Duo-authenticated** connection — i.e. you ran the alias and
  (Tier 1) left it open, or (Tier 2) it's within the `ControlPersist` window. If not, run the
  alias (or `ssh <cluster>.ycrc.yale.edu`) to create a master.
- Clean manual pipe test (returns an `SSH-2.0-…` banner confirms keys/squeue/nc are fine and
  Duo on the non-interactive spawn is the only blocker):
  `ssh <cluster>.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n <jobname> -h -o %N | head -1) 22'"`

### `ssh: connect to host login1.<cluster>.ycrc.yale.edu port 22: Operation timed out`
You pointed at an **individual login node**, which isn't reachable from off the cluster (the
timeout is at the TCP layer, before Duo — that's why you never got an MFA prompt). Use the
**round-robin** name `<cluster>.ycrc.yale.edu` everywhere (alias, ProxyCommand, ControlMaster).
You don't need to pin a login node: ControlMaster keeps reused connections on one node, and the
cluster-wide `squeue` check in `hold-node.sh` prevents a duplicate allocation even if a fresh
connection lands on the other login node.

### `Error server did not start successfully` / `Error server log file not found`
The pipe works; this is the **Positron server install** on the compute node — almost always an
NFS timing race.
- **Just reconnect 1–3 times.** The ~400 MB binary is cached after the first download.
- If it persists, check quota (`getquota`); clear stale `~/.positron-server` /
  `~/.positron-server.trash`. Force a clean reinstall:
  `mv ~/.positron-server ~/.positron-server.trash`, reconnect, then `nohup rm -rf …trash &`.
- Read the real reason on the node: `cat ~/.positron-server/.*.log` (a GLIBC error means the
  node OS is too old for that Positron version — use the other cluster).

### The alias hangs, or a reconnect doesn't recover (Tier 2)
Stale half-open ControlMaster after an ungraceful drop. `ServerAliveInterval` usually kills it
within ~90 s; otherwise force it: `ssh -O exit <cluster>.ycrc.yale.edu` (or
`rm -f ~/.ssh/cm-*<cluster>*`), then run the alias again.

### "Connection refused" / timeout to the compute node, or blank node
- Is the allocation still running? `squeue --me`. Did it hit walltime? Re-run the alias.
- Blank node from squeue → the job is PENDING (wait) or the name doesn't match
  (alias `--job-name` ↔ config `-n`/`positron-node.sh` argument).

### `remote.SSH.showLoginTerminal` setting doesn't exist
Positron uses **open-remote-ssh**, which doesn't expose it. Use **Output → "Remote - SSH"** for
the connection log instead.

### Connection works in a terminal but not in Positron
Almost always the Duo/ControlMaster issue: your terminal holds an authenticated connection the
GUI-spawned ProxyCommand can't see. Ensure ControlMaster is configured and a master is live.

### Git operations fail on the compute node
`ForwardAgent yes` must be in the SSH config entry; `ssh-add -l` on the node should list your
key (if not, `ssh-add` locally first).

### `tmux ls` errors *inside* the session shell (Tier 2)
Expected — `$TMUX` points at the login node's socket, not visible from the compute node. List
sessions with `bouchet-ls` from your laptop (it runs `tmux ls` on the login node).

---

## How ControlMaster works here (why one Duo is enough)

`ControlMaster auto` makes the first connection to a host a "master"; later connections reuse
its socket (`ControlPath`) without re-authenticating.

- **Tier 1:** your allocation alias (`ssh <cluster> -t "salloc …"`) keeps an authenticated
  connection open for the whole allocation — so it *is* the master. Positron's ProxyCommand
  finds that socket and reuses it, skipping Duo. Close the terminal and you lose both the master
  and the allocation.
- **Tier 2:** `ControlPersist` makes the master a **separate background process** that outlives
  the foreground ssh, so the allocation (held by tmux) and the master are independent. A
  reconnect re-establishes the master with one Duo; the allocation was never at risk.
- **Implicit node pinning:** reused connections ride the master's existing TCP session rather
  than re-resolving DNS, so they all stick to whichever login node the master first landed on —
  no need to address an individual login node by name. After the master dies and `ControlPersist`
  expires, a fresh connection may land on the other login node; the cluster-wide `squeue` guard
  in `hold-node.sh` keeps that from creating a duplicate allocation.
- **`ControlPath` must be consistent** so the alias and the Positron ProxyCommand resolve to the
  *same* socket. Keep the full path under ~104 chars (a macOS unix-socket limit).