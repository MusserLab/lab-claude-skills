# Use Research Plugins

Research Core supplies reusable research procedures and optional agent collaboration instructions.
After setup, start a fresh task and describe your work normally. The agent uses relevant procedures
when their purpose matches your request; you can also name one explicitly. Project instructions and
agreed scientific methods still guide the work.

## Ordinary requests

- "Help me plan this analysis; discuss the choices that could change the result first."
- "Use data-handling to check this table before joining it to the annotation."
- "Walk me through this code and the assumptions it makes."
- "Review the analysis and show me the actual outputs."
- "Distill this settled analysis into a readable workflow I can reproduce."
- "Build a review dashboard from the existing analysis, complete code and saved outputs."
- "Close out this session and tell me what remains unfinished."

The agent should orient you, investigate routine problems, preserve inputs and retained outputs,
and bring consequential scientific choices and substantive results back for discussion. Installing
a procedure does not validate its scientific method for your project or replace your acceptance.

Ask **"How do I use these research plugins?"** for help. `research-core-setup` is the shared entry
point for setup, adding packages, read-only checks, updates and help; there is no separate update
skill to remember.

## Choose packages

| Package | What it adds |
|---|---|
| Research Core (`research-core`) | The common toolkit: planning, careful data handling, debugging, code explanation/auditing, analysis distillation and review dashboards, plotting, figure export, security setup and session wrap-up. Included in setup. |
| Single-cell Research (`single-cell-research`) **In development** | Currently marker research prompt preparation and report processing. It is not a complete single-cell analysis or plotting workflow. General plotting and figure export are in Core. |
| Genome Annotation (`genome-annotation`) | Gene lookup, protein phylogeny, tree formatting, BUSCO and HMMER. |
| Yale Research (`yale-research`) | Yale HPC, Globus transfers and Lux collections; your own authorized access is required. |

Setup explains all four packages and asks which optional packages you want. It installs Core and
only the additions you choose. You can start with Core, choose either or both scientific packages,
and add Yale Research if you use Yale services. No extra package is installed by default.

Ask "Which research plugins are installed here?" for a read-only inventory. A package listed in a
guide or marketplace is available to choose, not proof that it is installed and active here.
Optional packages extend the toolkit only when actually installed and accessible.

## Help, status and actions

| Request | What happens |
|---|---|
| "How do I use these research plugins?" or "How do updates work?" | Explanation from this guide; no setup, update or personal-instruction inspection. |
| "Which research plugins are installed?" | Read-only package/version/source/scope/host check; no catalog refresh. |
| "Are my agent collaboration instructions current?" | Read-only comparison of the adopted block with the installed source; no replacement. |
| "Check what is new in Research Plugins." | Read the published release and compare with installed versions and any requested agent collaboration instructions; no installation or changes. |
| "Help me set up Research Plugins." | Explain package choices, install the selected packages, review legacy migration/security, and offer agent collaboration instructions. |
| "Add Single-cell Research to my existing setup." | Add only the chosen package, keeping existing package choices and instructions. |
| "Help me set up Bouchet" or "Add McCleary to my setup." | Continue the selected cluster's onboarding using available Yale guidance, preserving the working setup. |
| "Update my Research Plugins." | Update all installed Research packages from this repository and check adopted agent collaboration instructions, reporting the outcomes separately. |
| "Remove the research core instruction block." | Preview and review removal of only that block. |

If a check cannot run, the agent should say what is unverified. A local cached catalog does not
prove that you have the newest release. You can ask for an explanation without authorizing changes.

## Initial setup and migration

Tell the agent your operating system, client/interface and where it runs. The
[installation guide](https://github.com/MusserLab/lab-claude-skills/blob/codex/research-plugins-release/docs/research-plugins-install.md)
has client-specific steps. Setup shows package changes before applying them, preserves your
personal instructions and customizations, and keeps a way to restore the previous setup.

The old all-in-one Lab Skills plugin is permanently frozen at 1.12.1. Initial setup is intended to replace it
and deactivate overlapping copied skills after the selected replacements are verified. The agent
checks skills you need and uses `security-setup` to review relied-on protections before deactivating
old components. Core installs no hooks or permission grants and does not automatically replace
the old hooks.

The final migration check confirms that replacement skills are available and old overlapping
versions are inactive in this client, with customizations and rollback preserved. Nothing is
silently deleted. If a needed skill or protection has no suitable replacement, or a required
check cannot run, the agent reports **migration incomplete** and keeps the affected old component
until the gap is resolved.

You may choose the optional agent collaboration instructions. These guide how the agent works
with you, including scientific choices, preserving work and discussing uncertainty and results.
They occupy only the marked `RESEARCH-CORE` section of your existing active user instruction file,
which you review before it changes. They preserve personal guidance and project scientific methods.

On macOS/Linux, a bundled Python helper can preview and apply that section with a backup. On native
Windows, the simple route is manual adoption of the marked section unless helper compatibility has
been verified there. The agent reads the source, resolves Claude Code's active `CLAUDE.md` or Codex's
active `AGENTS.md`, shows the complete diff, keeps a backup and applies only the approved marked
section. In PowerShell the default files are `$HOME\.claude\CLAUDE.md` and
`$HOME\.codex\AGENTS.md`; configured homes, including `$env:CODEX_HOME`, take precedence.
Manual adoption does not require installing Python.

Start a fresh chat to check chosen package discovery, adopted agent collaboration instructions
and any completed old-skill deactivation. Then try a small ordinary task. Package readback does
not prove that the agent follows the instructions; each client and execution host needs its own
setup and verification.

## Add packages later

Ask "Show me which Research Plugins I have and explain the other available packages. Help me add
the ones I choose," or name a package. The agent previews and adds only your selection, preserving
existing packages, enabled/disabled choices, pins and personal instructions. It does not repeat
legacy migration or initial adoption of agent collaboration instructions. Start a fresh chat to
check the added skills.

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

## Updates and agent collaboration instructions

For a read-only check, ask:

> Check what is new in Research Plugins. Compare it with my installed versions and agent
> collaboration instructions, and summarize the changes without installing or changing anything.

The agent checks the published release, not just its cached catalog. It reports any unavailable
comparison rather than claiming the installed version is current.

For an update, ask:

> Update my Research Plugins. Include all the plugins I have installed from MusserLab/lab-claude-skills
> and check the agent collaboration instructions. Show me what will change first.

This includes all installed named Research packages from **this repository**, including optional
and disabled packages, and keeps unselected packages uninstalled. It does not update unrelated
plugins. The agent checks the actual client, host, source and scope, preserves enabled/disabled
choices and pins, and asks before changing an intentional older pin. It shows package changes and
reads back the installed versions after the supported operation. If any targeted operation or
readback fails, it reports each package as changed, unchanged or unknown, preserves the current
state and stops before instruction changes until a coherent installation is established.

It separately compares the newly installed source of agent collaboration instructions with your adopted
`RESEARCH-CORE` block. Routine updates preserve personal instructions, do not repeat initial legacy
migration or broad old-skill cleanup, and do not adopt agent collaboration instructions you previously
declined. They do check relevant personal/project skills for overlap with the selected plugin
skills, including newly added skills and copies left behind by an earlier or automatic update.
The check compares actual instructions and resources, not names alone. Customizations stay intact;
any backup and reversible deactivation needs a concrete preview and your approval. An unavailable
check or unresolved customization is reported as unfinished, not silently removed.

Plugin-manager commands alone do not run this review. After updating from an older setup skill,
start a fresh chat and ask: "Check my Research Plugins for overlapping personal or project skills,
including copies I installed separately. Preserve customizations and show proposed changes first."

Identical instructions need no replacement. For a changed block, review the separate concrete diff,
including personal edits and conflicts, before applying it. Everything outside the block is preserved.
Refreshing packages does not itself rewrite adopted agent collaboration instructions. Start a fresh
chat after successful changes.
An explicit full update remains useful even when automatic package refresh is available, because
it verifies both layers.

For explanation and dashboard improvements, check all three outcomes: the installed package,
your adopted collaboration block, and any dashboard skill copied separately. Package updates do
not rewrite the latter two. The general guidance should make a returning reader understand the
question, relevant inputs, how the result was obtained, main takeaways and uncertainty. Necessary
terms belong where they are used: 'pooled cells' should say which cells were combined and why.
Ask the agent to compare customized copies and show a separate proposal that preserves your
additions. Start a fresh chat after approved changes and try a short explanation of existing work.

Automatic refresh depends on the client and configuration:

- **Claude Code:** third-party marketplace auto-update is off by default. Its marketplace toggle
  is optional; this workflow does not change your preference. When enabled, Claude fetches updates
  at session startup; downloaded changes activate after plugin reload or a subsequent session.
  See [Claude's update documentation](https://code.claude.com/docs/en/discover-plugins#keep-plugins-updated).
- **Codex:** source review of CLI `rust-v0.149.0` shows startup refresh of configured Git-backed
  marketplaces. A contained macOS CLI 0.149.0 trial verified ordinary upgrade and recovery, including
  preservation of disabled choices on ordinary upgrade; a reinstall required explicit restoration
  of those choices. A participant reported a successful native Windows CLI 0.160.0 package update
  for their existing Desktop installation, using process-local `CODEX_HOME` pointed at the existing
  home and checking the native package list and manifests. They reported preservation of legacy
  files, configuration, instructions and package choices; their filesystem was not independently
  inspected. Fresh-chat discovery, instruction-helper use, instruction updates and recovery remain
  untested on Windows. These are version-specific checks, not a promise for every interface.
  See [the reviewed implementation](https://github.com/openai/codex/blob/rust-v0.149.0/codex-rs/core-plugins/src/manager.rs#L2011-L2205).

The installation guide and compatibility record identify demonstrated routes. A documented CLI
route can perform a package operation when the active client, home, host and exact scope are
established; it does not require a separate GUI test. Fresh-chat discovery remains a separate check.
If the operation is unsupported or its scope cannot be established, the agent stops before changing
packages and reports the remaining step. It must not edit caches or change sources, pins, scope or
automatic-update settings to make an update work.

## Support and recovery

Ask "Draft a research-plugin problem report." Include package/client versions, interface, host,
scope, a minimal example, expected/observed behavior and checks tried. Review the destination and
complete draft before submission. Shareable public reports can use
[the public tracker](https://github.com/MusserLab/lab-claude-skills/issues). Keep private paths,
credentials and unpublished work out of it; ask the maintainer for a private destination when needed.

If a release fails, use a maintainer-named retained release and its client-specific recovery steps,
or a new maintainer recovery release. A catalog change can affect several packages. Preview the
matching adopted agent collaboration instructions separately and preserve your personal instructions.
Do not edit installed caches or assume a universal `plugin@version` selector. Recovery does not undo outputs
already produced by a research project.

Remove the adopted `RESEARCH-CORE` section through a reviewed helper or manual diff, then uninstall selected
packages explicitly. Uninstalling Research Core does not remove adopted instructions automatically.

Each client and execution host has its own installation, account and instruction file. A laptop
installation does not install anything on a cluster. The toolkit installs no hooks or permission
grants; a legacy package's relied-on protections need their own transition review.
