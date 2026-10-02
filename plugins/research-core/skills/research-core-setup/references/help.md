# Use Research Core

Research Core supplies reusable research procedures and optional agent collaboration instructions.
After setup, start a fresh task and describe your work normally. The agent uses relevant procedures
when their purpose matches your request; you can also name one explicitly. Project instructions and
agreed scientific methods still guide the work.

## Ordinary requests

- "Help me plan this analysis; discuss the choices that could change the result first."
- "Use data-handling to check this table before joining it to the annotation."
- "Walk me through this code and the assumptions it makes."
- "Review the analysis and show me the actual outputs."
- "Close out this session and tell me what remains unfinished."

The agent should orient you, investigate routine problems, preserve inputs and retained outputs,
and bring consequential scientific choices and substantive results back for discussion. Installing
a procedure does not validate its scientific method for your project or replace your acceptance.

Optional scientific, Yale or private packages extend this toolkit only when actually installed and
accessible. Ask "Which research plugins are installed here?" for a read-only inventory. A package
listed in a guide or marketplace is not evidence that you have it. If one is absent, use project
guidance or official documentation and discuss whether you need that package.

## Help, status and actions

| Request | What happens |
|---|---|
| "How do I use these plugins?" or "How do updates work?" | Explanation from this guide; no setup, update or personal-instruction inspection. |
| "Which research plugins are installed?" | Read-only package/version/source/scope/host check; no catalog refresh. |
| "Are my Research Core collaboration rules current?" | Read-only comparison of the adopted block with the installed source; no replacement. |
| "Set up research core." | Review and adopt the collaboration block through an exact instruction diff; offer cluster setup when relevant. |
| "Help me set up Bouchet" or "Add McCleary to my setup." | Continue the selected cluster's onboarding using available Yale guidance, preserving the working setup. |
| "Update research plugins." | Perform the full update below, reporting package and instruction outcomes. |
| "Remove the research core instruction block." | Preview and review removal of only that block. |

If a check cannot run, the agent should say what is unverified. A local cached catalog does not
prove that you have the newest release. You can ask for an explanation without authorizing changes.

## Optional Claude subscription delegation

If you also use Claude, you can let your agent send necessary project files to Anthropic through
your own authenticated Claude subscription for bounded reviews or implementation. Core works
without this option. It does not supply a Claude account or guarantee that your current interface
can launch another client. The agent must verify the supported route and account before using it.

You can approve one task or give standing permission for future work within a scope you choose.
That scope can include private code and unpublished research material you are allowed to share.
Once approved, the agent should not ask again for every file or run within that same scope. A
changed destination, wider scope or separate charge needs its own approval. Merely installing or
updating this plugin does not give permission to send files elsewhere.

For example, ask: "Help me set up standing permission to delegate to my Claude subscription."
Review the actual account route and scope, then the exact proposed personal-instruction diff.
This sample is not an active permission grant; adopt it only if it matches your choice:

> I authorize my agent to send necessary task-relevant file contents, including private code,
> project instructions and unpublished research material I am allowed to share, to Anthropic
> through my authenticated claude.ai subscription for bounded work I have approved, using its
> included subscription capacity. Do not ask again per file or run within that scope. Exclude
> credentials, authentication state, secrets, unrelated files and data restricted from external
> sharing. Identify the inputs and destination, preserve task and review boundaries, and ask
> separately before using paid API calls, usage credits, another provider or a wider scope.

You can narrow this wording to a project or data category, decline it, or revoke it later. An
accepted personal choice belongs outside the plugin-managed RESEARCH-CORE section in the active
user CLAUDE.md or AGENTS.md. Updates and recovery preserve it; removing the plugin block does not
remove personal instructions. Ask explicitly to change or remove the choice when you want that.
Tool permissions still apply, and a recorded preference cannot guarantee that every client approval
check will accept a run. If a check blocks it, the agent should explain the actual failure.

## Set up a cluster now or add one later

At first setup, tell the agent which computer, client and interface you use and which clusters you
want to access. You can also ask later to add a cluster. The agent checks what already works and
continues from there: account/network access, your public SSH key and normal login, then the chosen
compute/IDE route, project paths and environments, and client/plugin setup where the agent runs.

Yale's installed HPC guidance owns the detailed procedure. If it is absent, the agent explains the
missing package and uses the release guide's verified installation route or official cluster
documentation. It should not claim a proposed package is installed or supported. Account approval,
browser sign-in, public-key upload authentication and MFA remain your actions; private keys and
client credentials stay on their own hosts.

Review exact SSH or instruction changes before applying them. Existing keys, aliases, installations
and personal instructions are kept; adding another cluster does not restart setup on the others.
Familiar names such as `bouchet` and `bouchet-devel` can be retained. Laptop success does not prove
cluster availability, and a terminal route does not prove an editor or desktop route. End with a
tiny scheduler check and a fresh-session plugin check; if access is pending, keep the working
portion and resume the remaining step later.

## A full update includes your collaboration instructions

**"Update research plugins" covers both your selected installed packages and the separately adopted
agent collaboration instructions.** The agent checks the actual client, host, source and scope,
uses the supported update route, and reads back the selected packages and their versions. It then
compares the newly installed collaboration source with your adopted `RESEARCH-CORE` block.

Identical instructions need no replacement. For a changed block, review the concrete diff, including
personal edits, before applying it. Everything outside the block is preserved. Refreshing packages
does not itself rewrite your adopted instructions. Start a fresh task after successful changes.
An explicit full update remains useful even when automatic package refresh is available, because
it verifies both layers.

Automatic refresh depends on the client and configuration:

- **Claude Code:** third-party marketplace auto-update is off by default. Its marketplace toggle
  is optional; this workflow does not change your preference. When enabled, Claude fetches updates
  at session startup; downloaded changes activate after plugin reload or a subsequent session.
  See [Claude's update documentation](https://code.claude.com/docs/en/discover-plugins#keep-plugins-updated).
- **Codex:** source review of CLI `rust-v0.149.0` shows startup refresh of configured Git-backed
  marketplaces. This is source evidence, not an observed ordinary student workflow or a promise
  for every version or interface. See [the reviewed implementation](https://github.com/openai/codex/blob/rust-v0.149.0/codex-rs/core-plugins/src/manager.rs#L2011-L2205).

The released student guide and compatibility record identify demonstrated routes. Local candidates,
other installation scopes and desktop/editor interfaces may require different steps. Ask the
maintainer for an unverified route; do not change sources, pins, scope or automatic-update settings
to make an update work.

## Support and recovery

Ask "Draft a research-plugin problem report." Include package/client versions, interface, host,
scope, a minimal example, expected/observed behavior and checks tried. Review the destination and
complete draft before submission. Shareable public reports can use
[the public tracker](https://github.com/MusserLab/lab-claude-skills/issues). Keep private paths,
credentials and unpublished work out of it; ask the maintainer for a private destination when needed.

If a release fails, use a maintainer-named retained release and its client-specific recovery steps,
or a new maintainer recovery release. A catalog change can affect several packages. Preview the
matching collaboration block separately and preserve your personal instructions. Do not edit
installed caches or assume a universal `plugin@version` selector. Recovery does not undo outputs
already produced by a research project.

Remove the collaboration block while its setup helper is still available, then uninstall selected
packages explicitly. Uninstalling Research Core does not remove adopted instructions automatically.

Each client and execution host has its own installation, account and instruction file. A laptop
installation does not install anything on a cluster. The toolkit installs no hooks or permission
grants; a legacy package's relied-on protections need their own transition review.
