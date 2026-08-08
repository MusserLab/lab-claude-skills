# Working on HPC Compute Nodes with Positron / Claude Code

Two ways to use Claude Code on a Bouchet **or** McCleary compute node:

1. **CLI over plain SSH** — SSH into the compute node and run `claude` in the terminal.
   No IDE setup required. Use one of the allocation aliases below, then `cd` to your
   project and run `claude`.
2. **Positron / VS Code Remote SSH** — full IDE with file browser, git integration, and
   Claude Code in the integrated terminal. Requires the SSH config below.

Examples below cover **Bouchet** and **McCleary**.

**Live-testing status — read before you trust a block:**

| Cluster | Status |
|---|---|
| **Bouchet** | The route in this guide has been exercised here. |
| **McCleary** | **Not live-tested.** The McCleary entries are constructed from McCleary's documented `devel` limits, not from a working session. Treat as a starting point. |
| **Misha** | **UNVERIFIED.** Its route and its `devel` limits have not been checked here. Do **not** assume it behaves identically — confirm Misha's own limits before cloning a block for it. |

> ### ⚠️ Partition policy: IDE sessions belong in `devel`
> **What YCRC states — about VS Code:** *"Only submit VSCode jobs to devel partitions (such as
> `devel` or `gpu_devel`). VSCode jobs found in other partitions may be terminated without
> notice."*
> ([YCRC: VS Code on the clusters](https://docs.ycrc.yale.edu/clusters-at-yale/access/ood-vscode/))
>
> **What this guide infers — not a YCRC statement:** Positron Remote-SSH is the same kind of
> IDE workload as VS Code, so the same rule should be assumed to apply to it. YCRC has **not**
> been asked to confirm that reading, so it is the cautious interpretation, not quoted policy.
>
> On that reading, **`devel` is the default throughout this guide.** Documented limits — the
> CPU and memory figures are **aggregate per user across all your `devel` jobs**, not per job:
> **Bouchet `devel`** — 6:00:00 max walltime (1 h default), 4 CPUs and 60G per user, **maximum
> 2 submitted jobs per user**.
> **McCleary `devel`** — 6:00:00, 4 CPUs and 32G per user, **maximum 1 submitted job per user**.
> One 4-CPU IDE session therefore uses your whole `devel` CPU allowance on either cluster.
> Examples targeting `day`, `ycga`, `week` or private partitions — and any IDE job longer than
> 6 hours — are labelled **UNVERIFIED** below. They are personal experiments, not a supported
> configuration, and should not be used without written YCRC confirmation.

There are **two reliability tiers** — pick one based on how much you'd mind losing the
allocation if your laptop drops:

| Tier | Setup effort | A laptop / VPN drop… | Use for |
|------|--------------|----------------------|---------|
| **Tier 1 — Basic** | ~5 min, laptop only | **kills your allocation** — you re-queue | quick `devel` tests; short sessions |
| **Tier 2 — Persistent** | ~10–15 min, +2 cluster-side scripts | **survives** — reconnect, no re-queue | a full 6 h `devel` session you'd rather not forfeit to a dropped laptop |

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

- **SSH key uploaded to YCRC.** Upload your **public** key once through YCRC's
  [SSH key uploader](https://sshkeys.ycrc.yale.edu/). YCRC's automated system distributes it
  to every cluster your account can reach — *"We use an automated system to distribute your
  public key onto the clusters"* — so you do **not** need to repeat the setup per cluster.
  Allow ~10 minutes to propagate. See
  [YCRC: SSH access](https://docs.ycrc.yale.edu/clusters-at-yale/access/ssh/).
  Verify: `ssh <cluster>.ycrc.yale.edu` should accept your key and then prompt for a Duo
  passcode (not a password).
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
multiplexing. Follow the **Linux** instructions above *inside* WSL and **launch Positron from
within WSL**, so the editor inherits WSL's `ssh`.

> **Do not look for a setting that points Positron at a different ssh binary.** The
> `open-remote-ssh` extension bundled with the installed Positron exposes only ten
> `remoteSSH.*` settings — `configFile`, `connectTimeout`, `defaultExtensions`,
> `enableAgentForwarding`, `enableDynamicForwarding`, `experimental.serverBinaryName`,
> `remotePlatform`, `remoteServerListenOnSocket`, `serverDownloadUrlTemplate`,
> `serverInstallPath`. There is **no `remote.SSH.path`** (that is a VS Code Remote-SSH
> setting). An earlier version of this guide suggested it; that advice was wrong.

One gotcha: keep the `ControlPath` socket on the **Linux** filesystem (`~/.ssh` on ext4),
**not** under `/mnt/c`, or the multiplexed client can
[hang](https://github.com/microsoft/WSL/issues/3370). tmux (Tier 2) runs on the cluster, so it
is unaffected by the Windows client limitation.

**This WSL route is UNVERIFIED** — it is reasoned from the OpenSSH limitation, not tested on a
Windows machine here. Treat it as a starting point, not a supported recipe.

> The per-connection-Duo fallback that **VS Code** users rely on —
> `"remote.SSH.showLoginTerminal": true`, then approve each Duo push in the surfaced terminal
> (also YCRC's documented [OOD-VS-Code](https://docs.ycrc.yale.edu/clusters-at-yale/access/ood-vscode/)
> approach) — **does not exist in Positron** (its open-remote-ssh extension doesn't expose that
> setting). So on native Windows + Positron there is no good substitute; WSL is the path.

---

## The Positron remote server — and what to do if it won't install

Positron installs a **per-commit** remote server (~600 MB download; ~1.6 GB and **50,000 files**
extracted) into `$HOME/.positron-server/bin/<commit>/`. Every Positron update is a new commit and
therefore a **complete fresh install** on the cluster.

On YCRC's NFS home that install is slow: the cost is per-file metadata round-trips rather than
bytes, and Positron can time out before the extract finishes. Separately, the generated install
script gives the server only **2.5 seconds** (five × `sleep 0.5`) to log
`Extension host agent listening on`, which a cold NFS start can also miss.

**NFS home is the supported default, although it may be slow or time out.** Reconnecting a few
times usually gets you there, and once a commit is installed it is reused until the next Positron
update. **If your install succeeds, you are done — skip the rest of this section.**

<details>
<summary><b>Optional · advanced · Bouchet-only — move the server to node-local <code>/tmp</code> after repeated install failures</b></summary>

This is a **workaround for repeated NFS install failures on Bouchet**, not part of the normal
setup. Do not adopt it pre-emptively, and do not hand it to someone whose install is merely slow.

**Bouchet only.** *One-session observation (one Bouchet node, 2026-06):* the download sustained
300+ MB/s and finished in ~2 s, the extract took 20–40 minutes, and that node's `/tmp` was 2.9 TB
ext4 — **not** tmpfs, so it did not count against the job's memory. **That is a single node on a
single occasion, not a property of every node or partition.** **McCleary and Misha have not been
checked at all** — do not extend this to them.

`/tmp` is also **not durable**: it may be cleaned between jobs, and a different node will not have
your copy, so expect occasional reinstalls (automatic). The trade you are making is a repeatedly
failing install for an occasionally repeated one.

#### 1. Give it its own SSH target — never change `bouchet-devel`

Ordinary `bouchet-devel` **stays on NFS**. Add a *second* `Host` entry that is an exact copy of
your `bouchet-devel` entry with only the name changed, so both resolve the same job on the same
node:

```sshconfig
# Tier 1 form — same escaped ProxyCommand as bouchet-devel
Host bouchet-devel-tmp
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n positron-devel -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

```sshconfig
# Tier 2 form — same helper-script ProxyCommand as bouchet-devel
# (the shared options block already matches it via the bouchet-devel* glob)
Host bouchet-devel-tmp
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron-devel'"
```

Use whichever matches the tier you set up. Both point at the same `positron-devel` job — the only
difference is which `serverInstallPath` Positron applies.

#### 2. Map the setting to that exact target only

In Positron's **user** `settings.json`:

```json
"remoteSSH.serverInstallPath": {
    "bouchet-devel-tmp": "/tmp/$USER/positron-server"
}
```

**Use the exact host name as the key — never `bouchet-*`.** A glob would sweep in ordinary
`bouchet-devel`, the Variant B placeholder, and every future Bouchet target, sending them all to
an unchecked `/tmp` path. The whole point of the separate target is that exactly one host opts in.

`$USER` is expanded **on the node**, not by Positron: the extension writes the configured value
into a shell script (`SERVER_DATA_DIR="…"`, then `mkdir -p $SERVER_DIR`) run through `bash -c`, so
the remote shell resolves it. That `mkdir -p` uses **whatever umask the node's login shell has**
and does not `chmod` — which is why the preflight below has to create and lock the directory down
first. *(Verified against the `open-remote-ssh` extension bundled with the installed Positron —
re-check after a major Positron upgrade.)*

#### 3. Run the preflight on every newly allocated node, before connecting

`/tmp` is world-writable and **per compute node**, so a fresh allocation means a fresh check.

**Getting onto the right shell matters more than it looks.** The alias/tmux terminal may leave
you on a **login node** rather than the compute node (this guide says so elsewhere), and every
login node has its own `/tmp`. Running the preflight there would check and lock down the wrong
machine while telling you everything is fine. Use this sequence, minding which terminal each
command belongs in:

**Laptop terminal A** — leave the allocation alias / ControlMaster running. Don't close it.

**Laptop terminal B** — open a second terminal and connect to the compute node:

```bash
ssh bouchet-devel          # rides the existing master; no second Duo
```

**Now in that compute-node shell** (terminal B, after the `ssh` above) run both of these bare —
they are cluster-side commands and need no `ssh` wrapper here:

```bash
hostname -s
squeue --me -n positron-devel -o '%i %T %R'
```

**Confirm the `hostname -s` output is the node listed for the RUNNING `positron-devel` job.**
Only if they positively match, run the preflight **in this same shell**.

**Do not run the preflight if you cannot make that match** — the job is still PENDING (no node
yet), `hostname -s` shows a login node, or the names don't line up. If it is PENDING, wait for
RUNNING and start this sequence again; otherwise connect through ordinary `bouchet-devel` and
stay on NFS for this session.

The preflight itself is fail-closed:

```bash
#!/usr/bin/env bash
# Preflight for /tmp/$USER/positron-server. Run ON THE NEWLY ALLOCATED BOUCHET NODE.
set -u
me=$(id -un); parent="/tmp/$me"; dir="$parent/positron-server"

# 1. Pre-check what already exists — never write through a symlink or another user's directory.
for p in "$parent" "$dir"; do
  if [ -L "$p" ]; then echo "REFUSE: $p is a symlink"; exit 1; fi
  if [ -e "$p" ]; then
    if [ ! -d "$p" ]; then echo "REFUSE: $p exists and is not a directory"; exit 1; fi
    if [ ! -O "$p" ]; then echo "REFUSE: $p is not owned by $me"; exit 1; fi
  fi
done

# 2. Create what's missing, privately.
( umask 077 && mkdir -p "$dir" ) || { echo "REFUSE: cannot create $dir"; exit 1; }

# 3. Enforce mode 700, then VERIFY — never trust the chmod silently.
chmod 700 "$parent" "$dir" || { echo "REFUSE: cannot set mode 700 on $parent / $dir"; exit 1; }
for p in "$parent" "$dir"; do
  if [ -L "$p" ]; then echo "REFUSE: $p became a symlink"; exit 1; fi
  mode=$(stat -c '%a' "$p")  || { echo "REFUSE: cannot stat $p"; exit 1; }
  owner=$(stat -c '%U' "$p") || { echo "REFUSE: cannot stat $p"; exit 1; }
  if [ "$mode" != "700" ] || [ "$owner" != "$me" ]; then
    echo "REFUSE: $p is mode $mode owned by $owner (want 700 $me)"; exit 1
  fi
done
echo "OK: $dir is private (mode 700, owner $me) — safe to connect bouchet-devel-tmp"
```

- **`OK`** → connect Positron to **`bouchet-devel-tmp`**.
- **Anything starting with `REFUSE`** → connect to ordinary **`bouchet-devel`** and stay on NFS
  for this session. Do not work around the refusal; ask.

*(This is a preflight, not a security boundary: it establishes that the directory is yours and
private at the moment it runs. It does not defend against someone actively racing you on a shared
node.)*

After connecting, confirm on the node:

```bash
ls -ld /tmp/$USER /tmp/$USER/positron-server   # still 700 and yours?
ls /tmp/$USER/positron-server/bin              # the installed commit(s)
df -h /tmp; mount | grep ' /tmp '              # is this node's /tmp local, and how big
```

#### Variant B stays on NFS

The detached batch placeholder (Tier 2, Variant B) gives you no shell on the node before Positron
connects, so there is no opportunity to run the preflight first. **Use ordinary `bouchet-devel`
with Variant B and leave it on the default NFS home path.** Because the setting is keyed to the
exact `bouchet-devel-tmp` host, Variant B is unaffected by default — there is nothing to narrow.

</details>

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
Host bouchet-devel
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n positron-devel -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

# McCleary — same shape, same job name. Built from documented devel limits; not live-tested.
Host mccleary-devel
    User <netid>
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n positron-devel -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

<details>
<summary><b>UNVERIFIED variants — non-devel <code>Host</code> entries (personal experiments, not supported)</b></summary>

Pair these only with the matching UNVERIFIED aliases below. Jobs on these partitions **may be
terminated without notice** under YCRC's VS Code rule, on this guide's reading that Positron
Remote-SSH is the same IDE workload.

```sshconfig
# UNVERIFIED — Bouchet day partition
Host bouchet-day
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n positron -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

# UNVERIFIED — McCleary ycga partition
Host mccleary-ycga
    User <netid>
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n ycga -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```
</details>

Notes:
- **`\$(squeue …)` — the backslash is load-bearing.** SSH hands the `ProxyCommand` string to
  your **local** shell. An unescaped `$(squeue …)` is therefore expanded **on your laptop**,
  where `squeue` does not exist: the substitution collapses to an empty string and the remote
  command degrades to `nc  22`, which fails with no useful message. `\$` defers the expansion
  so the literal `$(squeue …)` reaches the login node and runs there. Do not "clean up" the
  backslash. Note that `ssh -G <host>` will **not** catch a mistake here: it prints the
  `ProxyCommand` after config parsing but never *runs* it, so an escaping error only shows up
  when you actually connect.
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
# Bouchet — devel partition. THE DEFAULT CONFIGURATION for IDE sessions.
# Uses your whole per-user devel CPU allowance (4 of 4) while staying well inside the 60G
# memory limit; 32G is a deliberately conservative ask. Max 2 submitted devel jobs.
alias bouchet-devel='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=4 --mem=32G --partition=devel --time=6:00:00 --job-name=positron-devel"'

# McCleary — devel partition. Same job name, at McCleary's documented aggregate per-user caps
# (4 CPUs / 32G / 6:00:00, max 1 submitted devel job). NOT live-tested — see the live-testing
# table at the top.
alias mccleary-devel='ssh mccleary.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=4 --mem=32G --partition=devel --time=6:00:00 --job-name=positron-devel"'
```

<details>
<summary><b>UNVERIFIED variants — non-devel partitions (personal experiments, not supported)</b></summary>

YCRC says VS Code jobs outside `devel`/`gpu_devel` **may be terminated without notice**; this
guide *infers* — YCRC has not confirmed it — that Positron Remote-SSH counts as the same IDE
workload. These are kept only because they were used locally; they are **not** part of the
student setup and should not be adopted without written YCRC confirmation.

```bash
# UNVERIFIED — day partition
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron"'

# UNVERIFIED — McCleary ycga partition
alias mccleary-ycga='ssh mccleary.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=2 --mem=16G --partition=ycga --time=12:00:00 --job-name=ycga"'
```
</details>

Then `source ~/.zshrc` or open a new terminal. The `--job-name` in each alias must match the
`-n` in the corresponding SSH config entry.

### 3. Each work session — order of operations

1. **Run the alias** (`bouchet-devel`, or `mccleary-devel`). **Authenticate Duo once** when
   prompted. Wait for the allocation — you'll see the compute node. **Leave this terminal
   open.** This connection is your ControlMaster master *and* it holds the allocation; closing
   it releases both.
2. **Optional route only — run the `/tmp` preflight now, before connecting Positron.** Skip this
   step entirely unless you have set up the `bouchet-devel-tmp` target. Follow the hostname-match
   sequence in "The Positron remote server" above. **`OK`** → continue to step 3 with
   `bouchet-devel-tmp`. **`REFUSE`, or you can't match the hostname** → continue with ordinary
   `bouchet-devel` and stay on NFS for this session.
3. **Connect in Positron:** Remote Explorer → connect to the host you settled on
   (`bouchet-devel` / `mccleary-devel`, or `bouchet-devel-tmp`). It reuses the master — **no
   second Duo prompt** — and installs the Positron server on the node.
4. **First connect installs the server.** Through ordinary `bouchet-devel` / `mccleary-devel`
   that install goes to **NFS home** (`~/.positron-server`); through `bouchet-devel-tmp` it goes
   to the **node-local path you just checked** (`/tmp/$USER/positron-server`). Either way it can
   take a while and may need a reconnect or two — see Troubleshooting if it keeps failing.
5. **Use "Open Folder"**, not "New Window", and navigate to your project.

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
> up. Worth it for any `devel` session you'd rather not have to re-queue.

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
- **Helper scripts.** `hold-node.sh` guards a normal reconnect: one cluster-wide `squeue` for
  your jobs of that name in `PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING`; if one is found
  it reports it and exits without submitting, if the lookup fails it refuses and exits nonzero,
  and only an empty result leads to `salloc`. `positron-node.sh` hardens the node lookup
  (`-t RUNNING` + fail-on-empty) so Positron is never sent to a pending or stale job.

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
Host bouchet-devel* mccleary-devel*
    User <netid>
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5

# --- Per-target: only the unique ProxyCommand differs (job name passed to positron-node.sh) ---
Host bouchet-devel
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron-devel'"
# McCleary — not live-tested; see the live-testing table at the top.
Host mccleary-devel
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron-devel'"
```

<details>
<summary><b>UNVERIFIED variants — non-devel <code>Host</code> entries (personal experiments, not supported)</b></summary>

Add these to the shared options block too (`Host bouchet-devel* mccleary-devel* bouchet-day mccleary-ycga`)
if you use them.

```sshconfig
# UNVERIFIED
Host bouchet-day
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh positron'"
Host mccleary-ycga
    ProxyCommand ssh mccleary.ycrc.yale.edu "bash -lc '~/bin/positron-node.sh ycga'"
```
</details>

Notes:
- `ControlMaster` matches the host *alias* you type, not the `HostName`. Because both the
  alias (`ssh bouchet.ycrc.yale.edu …`) and the ProxyCommand (`ssh bouchet.ycrc.yale.edu …`)
  use the same name, they share one master socket — and that socket implicitly **pins** all
  reused connections to whichever login node it first landed on (see "How ControlMaster works").
- Setting the shared `ServerAliveInterval`/`ForwardAgent`/`User` once in the
  `Host bouchet-devel* mccleary-devel*` block avoids repeating them per target; SSH
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
# in the alias; hold-node.sh adds the job name + the reconnect guard.
# DEFAULT: devel — the whole per-user CPU allowance (4 of 4), inside the 60G memory limit, 6 h.
alias bouchet-devel='ssh bouchet.ycrc.yale.edu -t "tmux new-session -A -s positron-devel \"~/bin/hold-node.sh positron-devel --nodes=1 --cpus-per-task=4 --mem=32G --partition=devel --time=06:00:00\""'

# McCleary — documented aggregate per-user caps 4 CPUs / 32G / 6:00:00, max 1 submitted job.
# NOT live-tested — see the live-testing table at the top.
alias mccleary-devel='ssh mccleary.ycrc.yale.edu -t "tmux new-session -A -s positron-devel \"~/bin/hold-node.sh positron-devel --nodes=1 --cpus-per-task=4 --mem=32G --partition=devel --time=06:00:00\""'

# Handy: list your live tmux sessions on the login node
alias bouchet-ls='ssh bouchet.ycrc.yale.edu -t "tmux ls"'
alias mccleary-ls='ssh mccleary.ycrc.yale.edu -t "tmux ls"'
```

<details>
<summary><b>UNVERIFIED variants — non-devel partitions and &gt;6 h IDE jobs</b></summary>

Outside the `devel` default this guide adopts; kept only as personal experiments. Under YCRC's
VS Code rule these **may be terminated without notice**, on this guide's inference that Positron
Remote-SSH is the same IDE workload. A persistent IDE job longer than the 6 h `devel` walltime
has **not** been confirmed as acceptable with YCRC either.

```bash
# UNVERIFIED
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "tmux new-session -A -s positron \"~/bin/hold-node.sh positron --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=12:00:00\""'
alias mccleary-ycga='ssh mccleary.ycrc.yale.edu -t "tmux new-session -A -s ycga \"~/bin/hold-node.sh ycga --nodes=1 --cpus-per-task=2 --mem=16G --partition=ycga --time=12:00:00\""'
```
</details>

> ### The two-login-node rule (referenced throughout Tier 2)
> Each YCRC cluster has **two login nodes** behind the round-robin name, and `ssh` may land you
> on either. **tmux servers are login-node-local**, so a session started on one is invisible from
> the other — see
> [YCRC: tmux](https://docs.ycrc.yale.edu/clusters-at-yale/guides/tmux/). Consequences, in one
> place:
>
> **Your `salloc` is held by the original tmux session, on the login node where you started
> it.** What is visible cluster-wide is its *scheduler record*, not the process. So re-running
> the alias does one of two quite different things:
>
> - **Same login node** — `tmux new-session -A` **reattaches the original session** and drops you
>   back in your original `salloc` shell. `hold-node.sh` is **not invoked at all**, so no new
>   `squeue` lookup happens.
> - **Other login node** — there is no session to attach to, so tmux creates a temporary one and
>   runs `hold-node.sh`. It does one cluster-wide `squeue` for your jobs of that name in
>   `PENDING,RUNNING,SUSPENDED,CONFIGURING,COMPLETING`, and then:
>   - **job found** → prints it, **submits nothing, exits**. The temporary tmux session ends with
>     it. `ControlPersist 30m` keeps the authenticated SSH master alive, so Positron can still
>     reconnect.
>   - **lookup failed** → **the allocation state is unknown.** It requests nothing and exits
>     nonzero. **Stop and investigate** rather than re-running blindly.
>   - **nothing found** → it starts a **genuinely new allocation**.
>
> - This is **not an atomic lock.** Two *first* starts fired at the same moment can both see an
>   empty queue and both allocate. Start the alias once and let it settle.
> - Positron reconnects to the compute node through a cluster-wide job lookup, so
>   **reattaching the original tmux is never a prerequisite**.
> - **After any uncertain reconnect, `scancel -n positron-devel` reliably releases the
>   allocation.** `exit` only ends it from the *original* `salloc` shell.
> - An empty `bouchet-ls` / `mccleary-ls` listing means "not on this login node", **not**
>   "allocation gone". Check `ssh <cluster>.ycrc.yale.edu "squeue --me"`.

**If `hold-node.sh` reports the job as PENDING**, it leaves it alone — it does not cancel it and
does not queue a second one. **Nothing can connect yet: a pending job has no node**, so neither
`bouchet-devel` nor `bouchet-devel-tmp` will work. Wait for it to reach RUNNING
(`ssh <cluster>.ycrc.yale.edu "squeue --me"`), then re-run the alias to establish or refresh the
master, then connect normally — running the `/tmp` preflight first if you are using
`bouchet-devel-tmp`. If you would rather re-request different resources, `scancel -n
positron-devel` first and start over.

### Each work session — order of operations

**Pick one cluster and stay on it for every step.** Everything below is written as
`<cluster>-devel` — substitute `bouchet-devel` **or** `mccleary-devel` consistently. Connecting
to `bouchet-devel` after allocating with `mccleary-devel` will not find your job: the two
clusters have separate schedulers, separate login nodes, and separate tmux servers.

1. **Run the alias** — `<cluster>-devel`. **Duo once.** It creates the tmux session and (first
   time) requests the node; you land in your `salloc` allocation.
2. **Wait until the job is RUNNING.** A queued job has no node, so nothing below works yet —
   not the preflight, not Positron. Check with `ssh <cluster>.ycrc.yale.edu "squeue --me"` from
   another laptop terminal.
3. **Detach or just leave it.** `Ctrl-b` then `d` detaches cleanly; or simply close the
   terminal — the allocation survives because tmux holds it on the login node.
4. **Optional route only — run the `/tmp` preflight now, before connecting Positron.** Skip
   unless you have set up `bouchet-devel-tmp`. Follow the terminal-A / terminal-B
   hostname-match sequence in "The Positron remote server" above; it must be re-run after every
   **fresh allocation**, since `/tmp` is per compute node. **`OK`** → continue with
   `bouchet-devel-tmp`. **`REFUSE`, or you can't match the hostname** → continue with ordinary
   `bouchet-devel` on NFS.
5. **Connect Positron** to the host you settled on — `<cluster>-devel`, or `bouchet-devel-tmp`.
   It reuses the master (no second Duo), and `positron-node.sh` finds your node.

### Managing it & reconnecting after a drop

**What survives a laptop/VPN drop:** the `salloc`, the tmux session, the held compute node, and
Positron's remote server (it lives in your job's cgroup on the node). Only the laptop-side SSH
master dies.

**To reconnect (the one thing to remember):**
1. Reconnect the VPN.
2. **Run the same alias you started with** — `<cluster>-devel`, on the cluster that holds the
   job → answer Duo → this rebuilds the master. **Read what it prints; the four outcomes are not
   equivalent** (see the two-login-node rule above):

   | What you see | What it means | What to do |
   |---|---|---|
   | Your original `salloc` shell, reattached | Same login node. Same allocation, same node. | Go to step 3. **No new `/tmp` preflight.** |
   | `an allocation already exists: … state=RUNNING` | Other login node; existing job found. Same allocation, same node. | Go to step 3. **No new `/tmp` preflight.** |
   | `… state=PENDING` | The job is queued and has **no node**. | **Do not connect.** Wait for RUNNING, then re-run the alias and start again. |
   | `no active allocation -- requesting one now` | **This is a brand-new allocation on a possibly different node.** | If using `bouchet-devel-tmp`, **redo the hostname check and preflight** before connecting. Otherwise use ordinary `bouchet-devel` on NFS. |
   | `REFUSING: squeue lookup failed` | **Allocation state unknown**; nothing was requested. | **Stop and investigate.** Do not re-run blindly. |

3. **Reconnect Positron to the same host you were using.** Normally `<cluster>-devel`. **If you
   had been using the optional `bouchet-devel-tmp` target, reconnect to `bouchet-devel-tmp`** —
   not to `bouchet-devel`, or Positron will look for its server in the wrong place and reinstall
   on NFS.
4. Positron usually reconnects on its own within a few seconds; if it sits there, **Reload
   Window** or reconnect from Remote Explorer — to that same host.

**Whenever you do release it, use `scancel -n positron-devel`, not `exit`.**

Why step 2 is required: Positron's ProxyCommand runs `ssh …` *non-interactively* and can't
answer Duo — it needs a live master to ride. So you re-auth one interactive SSH first, then
Positron reuses it.

**If the alias hangs instead of prompting Duo** (stale half-open master after an ungraceful
drop): `ssh -O exit <cluster>.ycrc.yale.edu`, then run the alias again.

**Cheat sheet.** `squeue` and `scancel` are **cluster-side** commands — they do not exist on your
laptop. Wrap them in `ssh` so they can be run from anywhere, or run them bare only from a shell
that is already on the cluster.

```bash
# --- Run from your LAPTOP (aliases + ssh control commands) ---
bouchet-devel                                          # connect / reconnect (reattaches if alive)
bouchet-ls                                             # tmux sessions on WHICHEVER login node this lands on
ssh -O check bouchet.ycrc.yale.edu                     # is the master alive?
ssh -O exit  bouchet.ycrc.yale.edu                     # kill a wedged master
#   inside tmux:  Ctrl-b then d                        # detach WITHOUT killing the allocation

# --- Cluster-side commands, wrapped so they are laptop-safe ---
ssh bouchet.ycrc.yale.edu "squeue --me"                # jobs + nodes (NODELIST) + time used
ssh bouchet.ycrc.yale.edu "scancel -n positron-devel"  # release the node when done

# --- Same two, McCleary form ---
mccleary-devel
mccleary-ls
ssh mccleary.ycrc.yale.edu "squeue --me"
ssh mccleary.ycrc.yale.edu "scancel -n positron-devel"
```

Run `squeue --me` / `scancel -n positron-devel` **bare** only inside Positron's terminal, inside
the tmux/salloc shell, or in an SSH session on a login node — i.e. somewhere already on that
cluster.

**Where your work runs:** **do all real compute in Positron's terminal** — it always runs on the
compute node. The **alias/tmux terminal only holds the allocation**: depending on the cluster's
SLURM config it may leave you on a **login node** (where heavy work violates the no-compute-on-login-nodes
policy) or drop you onto the compute node, so treat it as allocation-management only and check with
`hostname` if unsure. If `tmux ls` errors *inside* the session shell, that's expected (its `$TMUX`
socket lives on the login node) — list sessions with `bouchet-ls` from your laptop.

**If `bouchet-ls` / `mccleary-ls` shows nothing, your session is probably not gone** — see the
two-login-node rule above. Check the allocation itself, which is cluster-wide:
`ssh <cluster>.ycrc.yale.edu "squeue --me"`.

**When you're done:** close the Positron remote window, then release the allocation — otherwise
the node is held idle until walltime, which wastes your fairshare/priority. From the laptop:

```bash
ssh bouchet.ycrc.yale.edu  "scancel -n positron-devel"     # or mccleary.ycrc.yale.edu
```

or run `scancel -n positron-devel` bare from a shell already on that cluster. `exit` also works,
but **only from the original `salloc` shell** — which exists only on the login node where you
started it, and only if you reattached that tmux session. When in doubt, use `scancel`.
Optionally `ssh -O exit <cluster>.ycrc.yale.edu` (laptop-side) to drop the master.
Releasing it also frees your `devel` submission slot — you get **2 on Bouchet, 1 on McCleary**.

### What still ends the node (tmux does NOT protect against these)

- **Walltime** (`--time`). When it expires mid-work, the node is released, Positron's server
  dies with it, and Positron can't reconnect. **This is your real deadline — save often.**
  Re-run the alias for a fresh node.
- **`scancel`** (from anywhere on the cluster), **or typing `exit` in the original `salloc`
  shell** — the one inside the tmux session on the login node where you started it.
- **Login-node reboot/maintenance** (rare) — takes the tmux with it. (Variant B survives this.)
- **Node failure.**

### Variant B — detached batch placeholder (most robust)

Instead of `salloc`-in-tmux, hold the node with a **batch job** that just sleeps. It lives in
the scheduler, fully detached — survives the laptop drop *and* a login-node reboot — with no
tmux at all. Trade-off: no interactive shell, and you must release it manually.

```bash
alias bouchet-hold='ssh bouchet.ycrc.yale.edu "sbatch --job-name=positron-devel --partition=devel --nodes=1 --cpus-per-task=4 --mem=32G --time=06:00:00 --output=/dev/null --wrap=\"sleep infinity\""'
alias bouchet-free='ssh bouchet.ycrc.yale.edu "scancel -n positron-devel"'
```

Positron connects exactly as in Tier 2 (the `bouchet-devel` ProxyCommand finds the
`positron-devel` job regardless of how it's held). Requires the same `ControlPersist` config.
Don't run a placeholder and a `salloc`-in-tmux with the **same** job name at once. The
placeholder is a submitted `devel` job like any other, so it counts against your `devel`
submission limit — **2 on Bouchet, 1 on McCleary** — and its CPUs and memory count against the
same aggregate per-user allowance.

### Two full-sized IDE sessions at once — no supported recipe

**There is no supported configuration for running two full-sized IDE sessions concurrently**, so
this guide does not give one. The `devel` CPU and memory caps are **aggregate per user**, not per
job: on **McCleary** you may have only **1 submitted `devel` job**, and on **Bouchet** the
**4-CPU per-user allowance is fully consumed by a single 4-CPU session**.

**What to do instead: open another window against the *same* allocation.** In Positron, "New
Window" → connect to the same `<cluster>-devel` host, or use "Open Folder" again — both attach to
the compute node you already hold, with no second job and no extra Duo. That gives you a second
workspace at zero scheduler cost.

If you genuinely need more CPUs than one `devel` session provides, that is batch work
(`sbatch`), not an IDE session.

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
You don't need to pin a login node: ControlMaster keeps reused connections on one node, and
`hold-node.sh`'s cluster-wide `squeue` check stops it submitting a second job even if a fresh
connection lands on the other login node (see the two-login-node rule for what that check does
and does not guarantee).

### `Couldn't install Positron server ... install script returned non-zero exit status`
Also appears as `Error server did not start successfully` / `Error server log file not found`. In
current Positron these are **the same generic message**, so it does not tell you which stage failed.
The install script exits non-zero on: `mkdir` failure, `tar` failure, incomplete extraction,
token-file creation failure, or the server not logging `Extension host agent listening on` within
**2.5 s**. A failed *download* exits 66 and produces a different message — so if you see this one,
the download is not the problem.

- **First, just reconnect** — a couple of retries clear most single failures, and a partly
  extracted commit resumes rather than restarting from scratch.
- **Read the real reason on the node:** the log is `.<commit>.log` inside the server install
  directory — `~/.positron-server/.<commit>.log` on the default. (If you adopted the optional
  Bouchet-only `/tmp` route it is `/tmp/$USER/positron-server/.<commit>.log`; when unsure, run
  `ls -d ~/.positron-server /tmp/$USER/positron-server 2>/dev/null` on the node.) A clean
  `Extension host agent listening on` followed ~5 min later by `all consumers inactive, shutting
  down` means the server started fine and the *script* timed out — the 2.5 s race, nothing else.
- **If it fails repeatedly on Bouchet**, the optional node-local `/tmp` route in "The Positron
  remote server" above is the escape hatch. Read its preflight and caveats first — it is not the
  default for a reason.
- A **GLIBC** error means the node OS is too old for that Positron version — use the other cluster.
- **Ignore** `navigator is now a global in nodejs` (`PendingMigrationError`) in the console. Logged
  at extension load, caught internally, unrelated.
- **Manual seed — macOS only as written** (and only if you must stay on NFS home). The URL is
  deterministic:
  `https://cdn.posit.co/positron/releases/reh/x86_64/positron-reh-linux-x64-<version>-<build>.tar.gz`
  extracted with `tar -xf ... --strip-components 1` into `~/.positron-server/bin/<commit>/` (or
  the optional `/tmp` path, if you adopted it). Take `<version>`, `<build>` and `<commit>`
  from `positronVersion`, `positronBuildNumber` and `commit` in the **local** Positron's
  `product.json` — on macOS that is
  `/Applications/Positron.app/Contents/Resources/app/product.json`. **That path is macOS-specific.**
  On Linux or WSL the same three fields live in the `product.json` of that platform's Positron
  installation, but its location has **not been verified here** — locate it yourself rather than
  assuming this path works unchanged. Run the extract as a background job so a stray Ctrl-C cannot
  kill it; in the one session measured it took 20–40 minutes with no output, which is an
  observation rather than an expected duration for every node.
- **Old server builds accumulate under `~/.positron-server/bin/` and nothing removes them**, which
  matters because home is quota-limited on both bytes and file count. (Under the optional `/tmp`
  route they instead consume that node's local disk until `/tmp` is cleaned.) Reclaiming the space
  is a deliberate cleanup task, not part of this setup: **close
  every remote session first, then confirm which commit is live** before deleting anything.
  Deleting "all old versions" blindly is how you pull the server out from under **another Positron
  window still connected under your own account** — the install tree is per-user, so the session
  you break is your own, on any node still running one.

### The alias hangs, or a reconnect doesn't recover (Tier 2)
Stale half-open ControlMaster after an ungraceful drop. `ServerAliveInterval` usually kills it
within ~90 s; otherwise force it: `ssh -O exit <cluster>.ycrc.yale.edu` (or
`rm -f ~/.ssh/cm-*<cluster>*`), then run the alias again.

### "Connection refused" / timeout to the compute node, or blank node
- Is the allocation still running? From the laptop: `ssh <cluster>.ycrc.yale.edu "squeue --me"`
  (bare `squeue --me` only from a shell already on the cluster). Did it hit walltime? Re-run the
  alias.
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
sessions with `bouchet-ls` from your laptop (it runs `tmux ls` on the login node). Remember that
it only sees the login node *that* connection reached — an empty listing does not mean the
allocation is gone; check `ssh <cluster>.ycrc.yale.edu "squeue --me"`.

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
  expires, a fresh connection may land on the other login node; `hold-node.sh`'s cluster-wide
  `squeue` guard stops that from submitting a second job (it is a reconnect guard, not an atomic
  lock — see the two-login-node rule).
- **`ControlPath` must be consistent** so the alias and the Positron ProxyCommand resolve to the
  *same* socket. Keep the full path under ~104 chars (a macOS unix-socket limit). If you hit that
  limit, `ControlPath ~/.ssh/cm-%C` is the short form — `%C` is a hash of
  connection/host/port/user, so it stays a fixed length. **Change it only if you re-verify the
  whole flow afterwards**: the alias and the ProxyCommand must still produce the *same* socket, and
  the `ssh -O check` / `ssh -O exit` commands elsewhere in this guide assume the `%r@%h:%p` form.
