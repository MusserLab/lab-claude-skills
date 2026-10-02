# Set up a student's HPC access

Use for first cluster setup or a later request to add another cluster. Establish a working route
from the student's computer to an appropriate execution host, with the chosen client and research
plugins available there. Reuse completed setup. This is guided configuration, not a new installer
or a request to synchronize whole account directories.

## 1. Choose the route and inspect what already works

Ask which clusters the student wants now, their laptop OS, chosen client and terminal/editor/desktop
interface, NetID/account status and existing connection method. Reuse information already supplied.
Explain where each step runs: the laptop holds the SSH client and editor; the login node provides
access and scheduler commands; the compute node runs the allocated workload. A local app can have
a remote agent, so confirm the actual execution host rather than inferring it from the visible UI.

Inspect only relevant existing aliases, SSH host entries, public-key filenames, client versions,
installed packages and instruction destinations. Do not read or print private keys, tokens or
credential files. Keep working configuration and personal choices. For an added cluster, scope
changes to that cluster and any explicitly needed shared prerequisite; do not reset other hosts.

Check current official guidance for the selected cluster and client before choosing commands:

- [YCRC access](https://docs.ycrc.yale.edu/clusters-at-yale/access/) and
  [SSH access](https://docs.ycrc.yale.edu/clusters-at-yale/access/ssh/).
- [Claude Code setup](https://code.claude.com/docs/en/setup) or
  [Codex CLI](https://learn.chatgpt.com/docs/codex/cli), for the selected runtime/interface.

Use [the Positron reference](positron-ssh-setup.md) for its existing connection methods and helpers,
and [partitions](partitions.md) for site limits, checking their dates and stated evidence. Its
Bouchet route has historical use; McCleary and Windows/WSL examples are not live-tested there,
and Misha is unverified. AICR needs its own current access and execution guidance. Do not claim
these examples establish current support or apply Mac shell fragments to native Windows. Choose
the documented route for the actual OS/client; report a route awaiting verification plainly.

## 2. Establish account, network and normal login

1. If access is missing, guide the student through the current
   [account request](https://research.computing.yale.edu/account-request) and selected cluster's
   network/VPN requirements. Account application, institutional login and MFA are the student's
   actions. Pending approval holds that cluster's connection steps, not unrelated local setup.
2. Reuse a suitable existing SSH key. Identify its exact **public** `.pub` file without exposing
   the private key. If a new key is needed, follow the current official instructions for the
   student's SSH implementation; explain the destination and passphrase choice before creation
   and never overwrite an existing key. Do not copy a private key to a cluster or another client.
3. For YCRC, direct the student to the [public-key uploader](https://sshkeys.ycrc.yale.edu/).
   Authentication and submission remain with the student. Follow the uploader's current campus/
   VPN and propagation guidance; a newly uploaded key may not be usable immediately. Verify
   access to each chosen cluster instead of assuming account membership or successful propagation.
4. Preview the exact local SSH-file change and any shell/editor change, naming the file and scope.
   Preserve existing entries and keep a rollback copy before approved edits. Reuse recognizable
   aliases such as `bouchet` and `mccleary`; when one already works, keep it. New entries target
   only the chosen login hostname/alias and use the student's own account and selected key.
   Do not add global wildcard settings or enable agent forwarding by default.
5. Have the student complete a normal interactive login, including Duo when required. Check the
   actual host and home with harmless commands such as `hostname`, `pwd` and `whoami`. Resolve a
   failed login before attempting an IDE proxy. Authentication success is not compute allocation.

## 3. Connect to an appropriate compute allocation

Use the existing [Positron/SSH sequence](positron-ssh-setup.md) for plain terminal access or the
chosen editor route, rather than creating another allocation/helper implementation. Preserve
working names such as `bouchet-devel` or `mccleary-devel`, along with their matching scheduler job
names. Explain the basic route and the optional tmux-held persistent route; use the student's
existing choice unless a concrete need calls for changing it. Check current cluster limits before
requesting resources, and inspect an existing job before creating another allocation.

When adapting a reference template, add only the selected exact login and compute host entries.
Carry required multiplexing options onto those exact entries instead of copying broad wildcard
blocks. Omit agent forwarding unless a concrete need is discussed and explicitly selected.
Reuse the bundled `hold-node.sh` and `positron-node.sh` for the persistent route, previewing their
installation/update on the selected cluster and preserving any existing modified helper. Do not
point a durable alias into an installed plugin cache that can change on update.

Authenticate interactively before a noninteractive IDE proxy that needs connection reuse. Verify
which host the resulting terminal actually reached; an alias/tmux shell may only hold the
allocation. Run the client on the intended compute host, using the reference's connection step.
Keep substantial work off login nodes. The normal server location is the starting route; the
reference's optional Bouchet `/tmp` workaround is for demonstrated failures, not first setup.

## 4. Resolve project resources and client setup on that host

Confirm the student's project/allocation, home/project/scratch locations, shared database access,
environment names and declared setup commands. Use the student's NetID for personal paths; a lab
root or example environment is not evidence of access or installation. Explain and confirm the
lab's recommended NAS archive policy, or retain a documented project-specific alternative. Keep
lab-only endpoint details and credentials out of public reports. This confirmation authorizes no
transfer or deletion; each retains its own custody and exact-action approval requirements.

Use [resource learning](resource-learning.md) to reuse a declared private resource-profile record.
If none exists, offer one small user-owned record outside the plugin cache; on Unix/WSL, an example
is `~/.local/share/research-plugins/hpc-resource-profiles.md`. This is optional, not a prerequisite
for access. Confirm the actual absolute path and preview any new file plus its pointer in existing
user instructions, outside the replaceable Core block. Preserve an existing pointer when adding
a cluster and check that the record is accessible on the intended host. Project job evidence stays
project-owned; plugin updates must never edit or replace the user's learning record. Do not create
another store or synchronize it silently when a host cannot access the chosen record.

For each environment where an agent will run:

1. Inspect the chosen native client, Git and other dependencies actually needed by the selected
   route. Use official installation guidance for missing components and show the host, paths and
   proposed changes. Python 3 is needed for the Core instruction helper; scientific environments
   remain the project's declared environments. Do not install an unrelated toolchain by default.
2. Confirm the intended model provider and have the student sign in through that client's native
   account flow on that host. A site-hosted model behind a Claude/Codex interface is a different
   service; do not silently substitute it for the student's chosen provider. Marketplace
   repository access is separate from model-account login. Never copy authentication state from
   the laptop, another client or another profile to make access work.
3. Follow the release guide's explicit native plugin installation route for the actual source,
   client and scope. Check its released catalog/manifest for the chosen package names. Reuse
   existing working installations; the laptop's plugins do not establish cluster installation.
4. Use installed `research-core-setup` there for a reviewed collaboration-block change only when
   needed. Preserve personal instructions and never copy `~/.claude/` or `~/.codex/` wholesale.
   Verify whether cluster nodes share that home and installation; reuse it when they do rather
   than reinstalling on every allocated node. Another cluster/client can have separate state.

An integrated terminal provides that terminal client's route. Verify any editor extension or
desktop remote route separately, including where its agent runs and which instructions/plugins
it loads. Do not equate Claude Desktop Code, Cowork and chat, or assume CLI success covers them.

## 5. Verify, report and resume

Use the main HPC skill's tiny first-job example with the selected cluster's verified partition
and limits in a fresh or explicitly disposable directory. Check job completion and its actual
output; record a failed or pending job honestly. Do not overwrite a retained job output.

Start a fresh client session on the intended execution host. Read back client/package versions,
installation source/scope and instruction destination; verify plugin discovery and a harmless
help or code-explanation request. A listing proves presence, not model sign-in or correct behavior.
Label editor/platform/cluster combinations not actually exercised as unverified.

Return a short account of the working aliases and route, verified host/client/packages, relevant
project paths, and any pending approval/authentication/unsupported step with the next action.
Keep this in the student's existing setup notes or conversation; no separate setup-state system
is required. On resume, check the relevant current state and complete only the missing portion.
Adding another cluster follows the same path without replacing working keys, blocks or installs.
