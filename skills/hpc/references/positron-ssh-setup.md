# Working on HPC Compute Nodes with Positron / Claude Code

Two ways to use Claude Code on a Bouchet **or** McCleary compute node:

1. **CLI over plain SSH** — SSH into the compute node and run `claude` in the terminal.
   No IDE setup required. Use one of the allocation aliases below, then `cd` to your
   project and run `claude`.
2. **Positron / VS Code Remote SSH** — full IDE with file browser, git integration, and
   Claude Code in the integrated terminal. Requires the SSH config below.

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
Positron's ProxyCommand — **reuses** it instead of re-authenticating. The allocation alias
below doubles as that master connection: `ssh <cluster> -t "salloc …"` holds an
authenticated connection open for the whole life of your allocation, so with `ControlMaster`
configured, Positron just rides on it. (This is why a setup that works in a terminal can
still fail in Positron — the terminal has an authenticated/agent connection the GUI spawn
can't see.)

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
- **Shell rc:** put the `salloc` aliases in `~/.bashrc` (bash) instead of `~/.zshrc`. If you
  run zsh on Linux, `~/.zshrc` is fine as-is.
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
[hang](https://github.com/microsoft/WSL/issues/3370).

> The per-connection-Duo fallback that **VS Code** users rely on —
> `"remote.SSH.showLoginTerminal": true`, then approve each Duo push in the surfaced terminal
> (also YCRC's documented [OOD-VS-Code](https://docs.ycrc.yale.edu/clusters-at-yale/access/ood-vscode/)
> approach) — **does not exist in Positron** (its open-remote-ssh extension doesn't expose that
> setting). So on native Windows + Positron there is no good substitute; WSL is the path.

---

## Setup — do these in order

### 1. `~/.ssh/config` — ControlMaster + per-session compute-node entries

Paste this template, replacing **`<netid>`** with your Yale NetID (every occurrence):

```sshconfig
# --- Login nodes: authenticate Duo ONCE, reuse everywhere (ControlMaster) ---
# Covers the outer ProxyCommand hop to bouchet.ycrc.yale.edu / mccleary.ycrc.yale.edu.
Host *.ycrc.yale.edu
    User <netid>
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    # ControlPersist 30m   # optional — keep the master alive 30 min AFTER you close the
    #                       # terminal. Not needed if your allocation terminal stays open
    #                       # (the salloc connection is already a live master).

# --- Default key for all hosts ---
# Point IdentityFile at the key you actually generated. ed25519 is the modern default;
# if you made an RSA key instead, use ~/.ssh/id_rsa.
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

# --- Interactive compute-node sessions (these are your Positron Remote-SSH targets) ---
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
- `ForwardAgent yes` passes your key to the compute node so git works there.
- The `Host -n <name>` in the ProxyCommand **must match `--job-name` in the alias** below.

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
`-n` in the corresponding SSH config entry (`positron` ↔ `bouchet-day`, `positron-devel` ↔
`bouchet-devel`, `ycga` ↔ `mccleary-ycga`).

### 3. Each work session — order of operations

1. **Run the alias** (e.g. `mccleary-ycga`) in a terminal. **Authenticate Duo once** when
   prompted. Wait for the allocation — you'll see the compute node (e.g. `c22n07`).
   **Leave this terminal open.** This connection is your ControlMaster master *and* it holds
   the allocation; closing it releases both.
2. **Connect in Positron:** Remote Explorer (monitor icon, left sidebar) → connect to the
   matching host (`mccleary-ycga` / `bouchet-day`). It reuses the master — **no second Duo
   prompt** — opens the pipe, and installs the Positron server on the node.
3. **First connect installs the server** (~400 MB over NFS, a few minutes). If it fails with
   `Error server did not start successfully` or `Error server log file not found`, just
   **reconnect 1–3 times** — see troubleshooting (NFS race).
4. **Use "Open Folder"**, not "New Window** — navigate to your project (e.g.
   `/nfs/roberts/project/pi_jm284/<project>/`). Open Folder gives Positron full project
   context (git, file tree, terminal at the right path); New Window drops you at `~/`.

---

## Troubleshooting

### Fails in ~5 s with `ERR_STREAM_PREMATURE_CLOSE`, no `Trying publickey authentication` line
The outer ProxyCommand hop can't get past Duo. Either ControlMaster isn't set up, or there's
no live authenticated master to reuse.
- Confirm the `Host *.ycrc.yale.edu` ControlMaster block is in `~/.ssh/config`.
- Confirm you have an **open, Duo-authenticated** connection to that login node — i.e. the
  allocation alias terminal is still running. If you started the allocation *before* adding
  ControlMaster, that connection isn't a master; re-run the alias (or open
  `ssh <cluster>.ycrc.yale.edu` and complete Duo) so a master socket gets created.
- Diagnose the underlying Duo requirement with:
  `SSH_AUTH_SOCK= ssh -v -i ~/.ssh/id_ed25519 <cluster>.ycrc.yale.edu "echo OK"` — you'll see
  `partial success` → `keyboard-interactive` (that's Duo).
- A clean manual pipe test (returns an `SSH-2.0-…` banner) confirms keys/squeue/nc are fine
  and the only blocker is Duo on the non-interactive spawn:
  `ssh <cluster>.ycrc.yale.edu "bash -lc 'nc \$(squeue -u <netid> -n <jobname> -h -o %N | head -1) 22'"`

### `Error server did not start successfully` / `Error server log file not found`
The pipe works; this is the **Positron server install** on the compute node, and it's almost
always an NFS timing race — the server writes its log a beat after the install script polls
for it on the slow NFS home.
- **Just reconnect 1–3 times.** The ~400 MB binary is cached after the first download, so
  retries are fast and usually win the race.
- If it persists, check quota (these dirs are tens of thousands of small files):
  `getquota` on the login node — clear space/inodes if near a limit, including any stale
  `~/.positron-server` or `~/.positron-server.trash`.
- To force a clean reinstall, rename the dir aside (instant, vs. a slow NFS `rm -rf`):
  `mv ~/.positron-server ~/.positron-server.trash`, reconnect, then
  `nohup rm -rf ~/.positron-server.trash &` in the background.
- Read the real reason directly, on the compute node:
  `cat ~/.positron-server/.*.log` or run the binary with `--version` (a GLIBC error there
  means the node OS is too old for that Positron version — use the other cluster).

### `remote.SSH.showLoginTerminal` setting doesn't exist
Positron uses the open-source **open-remote-ssh** extension, which doesn't expose that
setting (neither does its `connectTimeout` in all versions). Use **Output → "Remote - SSH"**
channel for the connection log instead — same information.

### Connection works in a terminal but not in Positron
Almost always the Duo/ControlMaster issue above: your terminal holds an authenticated (or
agent-backed) connection the GUI-spawned ProxyCommand can't see. Set up ControlMaster and
keep the allocation terminal open.

### "Connection refused" or timeout
- Is the allocation still running? `squeue --me` on the login node.
- Did it expire? Re-run the alias.
- NetID mismatch? Both `User` and the `squeue -u` in the config must be your NetID.

### "No matching host" / blank node in squeue
- Job may still be pending — wait for the allocation prompt.
- The job name must match: alias `--job-name` ↔ config `-n`.

### Git operations fail on the compute node
- `ForwardAgent yes` must be in the SSH config entry.
- `ssh-add -l` on the compute node should list your key; if not, `ssh-add` locally first.

### Session disconnects after idle period
- `ServerAliveInterval 60` should prevent it. If it still drops, the SLURM allocation likely
  timed out — check `squeue --me`.

---

## How ControlMaster works here (why the alias is enough)

`ControlMaster auto` makes the first connection to a host a "master"; later connections reuse
its socket (`ControlPath`) without re-authenticating. Your allocation alias
(`ssh <cluster> -t "salloc …"`) keeps an authenticated connection to the login node open for
the entire allocation — so it *is* the master. Positron's ProxyCommand outer hop finds that
socket and reuses it, skipping Duo.

- **`ControlPersist` is optional.** Without it, the master lives only while some connection
  holds it open — which your allocation terminal already does. Add `ControlPersist 30m` only
  if you want the master to survive *after* you close the terminal (do Duo once, close it,
  still connect for 30 more minutes).
- **`ControlPath` must be consistent** within your config so the alias connection and the
  Positron ProxyCommand resolve to the *same* socket. `~/.ssh/cm-%r@%h:%p` is fine (keep the
  full path under ~104 chars — a macOS unix-socket limit).

---

## Running multiple sessions simultaneously

The ProxyCommand finds nodes by job name (`-n`). Two allocations with the same job name make
`head -1` always pick the same one. For simultaneous sessions, give each a distinct job name
and a matching SSH config entry:

```bash
alias bouchet-day='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron"'
alias bouchet-day2='ssh bouchet.ycrc.yale.edu -t "salloc --nodes=1 --cpus-per-task=8 --mem=32G --partition=day --time=6:00:00 --job-name=positron2"'
```

```sshconfig
Host bouchet-day2
    User <netid>
    ProxyCommand ssh bouchet.ycrc.yale.edu "bash -lc 'nc $(squeue -u <netid> -n positron2 -h -o %%N | head -1) 22'"
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 5
```

Connect to whichever host matches the session you want. Add more (`positron3`, etc.) as
needed. The shared `Host *.ycrc.yale.edu` ControlMaster covers them all.