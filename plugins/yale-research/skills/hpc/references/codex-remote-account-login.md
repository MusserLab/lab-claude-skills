# Switch or renew the Codex account on a remote cluster

Use this when someone says “log into my new account on Bouchet,” “switch the
Codex account on the cluster,” or reports expired-token/workspace-routing 401
errors. Walk them through the operation and run the routine commands yourself
where supported. No special phrase, slash command, hook or new allocation is
required. Reuse choices and authorization already settled in the conversation.

## Establish which account is changing

Use context to distinguish the **ChatGPT account used by remote Codex** from
the **cluster Unix/SSH account**. If unclear, ask that one question before
changing credentials. For Codex, establish the desired login and, when relevant,
workspace; separate logins and workspaces within one login are different choices.
Changing a NetID/SSH user belongs to cluster setup, not this credential reset.

Explain that the remote app-server uses remote authentication. A working local
Desktop login does not prove that remote login is current or uses the intended
account. Normal token refresh is automatic; a reused-refresh-token error does
not establish that every account switch causes a fault. Shared cluster home
state can survive compute-node replacement.

## Guided procedure

1. **Inspect the existing remote context.** From a working local chat or an
   independent shell, use the established SSH route. Verify the compute host,
   RUNNING allocation, remote user, installed Codex version, actual app-server
   executable and resolved `CODEX_HOME` (defaulting to that user's `~/.codex`
   only when no override is configured). Match the CLI credential location to
   the server's; inspect only needed path settings, never dump its environment
   or credential file. If controlling this from the affected remote chat,
   arrange an independent control path before stopping its server.

2. **Make the interruption concrete.** Explain that the selected remote Codex
   login and its server will change, while project files, saved chats and the
   allocation are preserved. Check for other Codex clients sharing that home,
   including known active nodes. Have their affected work paused before
   proceeding; a quiet process is not proof that a chat is finished. A request
   to switch accounts authorizes the bounded login operation, not interrupting
   unrelated work. Reuse an already confirmed pause.

3. **Disconnect Desktop from the affected SSH host.** Use a supported control
   if available; otherwise ask the user to disconnect in **Settings → Connections
   → SSH** and wait for confirmation. Keep the allocation and SSH tunnel alive.
   Capture needed error lines before reconnecting: Desktop bootstrap may
   truncate `CODEX_HOME/app-server-control/app-server.log`. Inspect relevant
   excerpts, not full logs; `grep -a` handles observed NUL padding.

4. **Stop only the identified remote server.** Check installed help and whether
   `codex app-server daemon stop` manages this instance. Desktop can launch a raw
   `codex ... app-server --listen unix://` process: on Codex 0.160.0, daemon stop
   refused it as “not managed by codex app-server daemon.” In that case, freshly
   verify the exact PID, owner, executable, host and Slurm cgroup, send SIGTERM
   only to that server, and verify it and the disconnected proxy have exited.
   Investigate remaining clients or a respawn before changing credentials.
   Never reuse a saved PID or use a blanket `pkill codex`.

5. **Renew the login on the verified compute node.** With the CLI using the
   same resolved credential location as that server, check installed login
   options, then run:

   ```bash
   codex logout
   codex login --device-auth
   ```

   Present the current verification URL and one-time code to the user. They
   select the intended account/workspace and complete browser authentication
   and MFA; keep the remote login process waiting and inspect its actual
   completion. Do not save the code in durable records. If device login is
   disabled, follow the currently documented browser/callback-forwarding route
   or report the administrator/user action needed. Do not bypass the restriction.
   Logout removes the saved login; if the new login fails, report that state
   and resume authentication without clearing unrelated files.

6. **Reconnect and verify actual use.** Reconnect the same SSH host, asking
   the user only when Desktop control is unavailable. Let Desktop start its
   server. Confirm the intended identity through a supported account view when
   available, or the user's browser selection, labelling what was verified.
   Verify a real response in an existing remote chat and a fresh remote
   invocation, and inspect for new authentication errors. `codex login status`
   alone reports cached login presence and can succeed with expired credentials.
   If an independent test is needed before reconnecting, one `codex exec
   --ephemeral --skip-git-repo-check --sandbox read-only --cd /tmp` request for
   `AUTH_OK`, explicitly forbidding tools and file inspection, tested fresh
   model access in the observed recovery. It still uses account capacity and
   the installed configuration; do not repeat it after equivalent evidence.

Report the selected host, completed login, actual chat/service result and any
remaining user action. Do not claim the new identity from file timestamps or
infer successful service access from the absence of log errors alone.

## Preservation and evidence

Do not delete `~/.codex`, reset chat databases, replace the allocation or copy
credentials from another host. Its contents can include authentication,
configuration, skills/plugins, chat histories, worktrees, attachments and runtime
state. Use supported logout for the scoped credential change; diagnose any
separate socket problem before considering a targeted runtime repair.

The October 2026 recovery on Bouchet with Codex 0.160.0 exercised disconnect,
exact server termination, remote logout/device login, a successful fresh model
request, reconnect, and an existing working Desktop chat. It did not establish
why the prior refresh token was consumed or test every account/workspace switch.
Recheck current CLI support and live host/process state at each use.

Official references: [authentication](https://learn.chatgpt.com/docs/auth),
[remote connections](https://learn.chatgpt.com/docs/remote-connections), and
[app-server account operations](https://learn.chatgpt.com/docs/app-server).
