---
name: research-core-setup
description: Help people set up Research Plugins for Claude Code or Codex, choose packages, add packages later, check what is new without changes, update installed Research Plugins, and use or remove adopted agent collaboration instructions. Use for requests such as how do I use these research plugins, set up Research Core, add Single-cell Research, which research plugins are installed, check what is new, are my agent collaboration instructions current, or update research plugins. Also help with optional Claude subscription delegation permission and route first HPC setup or adding another cluster to installed Yale guidance. Do not run automatically during ordinary research work.
---

# Use and manage Research Plugins

## Choose the requested operation

Read the installed [short help guide](references/help.md), directly at
`<plugin-root>/skills/research-core-setup/references/help.md`, relative to this skill's installed
path. Use the installed resource, not an authoring checkout. If that read fails, report the exact
failure; do not invent package details or search outside the plugin for a replacement.

Distinguish the user's request before entering the workflows below:

- **Explanation only:** "How do I use these research plugins?", "How do updates work?" or "Does it update
  automatically?" Answer from the bundled guide and stop. Do not read personal instruction files,
  run helpers or plugin-management commands, or start setup, refresh or installation. Use any
  already verified installed-package context; otherwise describe optional packages conditionally.
- **Read-only status:** "Which research plugins are installed?" or "Check my plugin versions."
  Use the active client's read-only plugin list and marketplace metadata to report the actual
  packages, versions, source, installation scope and execution host. Do not refresh the catalog
  or treat a cached catalog as proof of the latest release. If the request explicitly includes
  agent collaboration instructions, read the actual named block and installed instruction source
  and report their agreement or differences without helpers or edits. Report unavailable checks as
  unverified.
- **Read-only what's new:** "Check what is new in Research Plugins." Read the published release
  catalog/inventory and release notes from `MusserLab/lab-claude-skills` through a read-only route,
  and compare with actual installed versions, source/ref and pins. Compare agent collaboration
  instructions when requested. Summarize available changes without installing or changing anything;
  do not refresh the installed catalog or use its cached list as evidence of the latest release.
  If the published release cannot be checked, report that limit instead of claiming it is current.
- **Set up:** "Help me set up Research Plugins" or "Set up Research Core." Explain all four
  packages, ask for the optional package selection, and follow initial setup below.
- **Add packages:** "Add Single-cell Research to my existing setup." Follow the later-addition
  workflow, keeping existing choices and agent collaboration instructions.
- **Update:** "Update my Research Plugins." Update all installed Research Plugins from this repository
  **and check the separately adopted agent collaboration instructions**. Show their changes separately.
- **Other action:** "Help me set up cluster access", "Add another cluster", "Change my Claude
  delegation permission" or "Remove the research core instruction block." Use that workflow only.

For an ambiguous request, provide the useful explanation and clarify before an action that would
change the installation or instructions. Ordinary plugin use does not require repeated setup.
Distinguish a package available in the published catalog from one installed and active here.
When installation or refresh cannot run, explain the remaining step without claiming completion.
Use a documented CLI route when its exact client, host and scope are proven; GUI verification is
not required for that operation. Verify the active configuration/home and installation scope before
using a CLI on behalf of an editor or desktop session. CLI success does not prove GUI discovery.
For an unsupported package operation, stop before mutation and explain the missing supported route;
do not substitute cache edits, copied skills, another scope or an unverified client command.

## Set up Research Plugins

Research Core supplies the common procedures and optional agent collaboration instructions.
Explain the available packages before proposing changes:

| Package | Purpose |
|---|---|
| Research Core (`research-core`) | The common toolkit: planning, careful data handling, debugging, code explanation/auditing, plotting, figure export, security setup and session wrap-up. It has 22 procedures plus this setup skill. |
| Single-cell Research (`single-cell-research`) **In development** | Currently two skills for marker research prompts and report processing; not a complete single-cell analysis or plotting workflow. General plotting and figure export are in Core. |
| Genome Annotation (`genome-annotation`) | Gene lookup, protein phylogeny, tree formatting, BUSCO and HMMER. |
| Yale Research (`yale-research`) | Yale HPC, Globus transfers and Lux collections, requiring the user's own authorized access. |

Ask which optional packages to install, with recommendations based on the user's work. Setup
includes Core. Install no additional package by default. Do not infer a choice from the package
table, an HPC mention, or a previous installation on another host.

1. Establish OS, client, terminal/editor/desktop interface, execution host and installation scope.
   Reuse supplied information. Read the published installation guide and native client help as
   needed. Inventory existing Research packages, legacy Lab Skills and relevant copied skills,
   source/ref, pins and enabled/disabled choices. Do not open credentials or scan unrelated files.
2. Explain the selected package changes and any legacy transition, show the exact proposed scope,
   and obtain approval unless the user already approved those unchanged changes. Install Core and
   only the chosen optional packages through the supported route from this repository. Preserve
   current customizations and keep a rollback route. Use the migration workflow below when needed.
3. Review native client protections with `security-setup`, especially before deactivating legacy
   protections. Core installs no hooks or permission grants. Preserve existing protections until
   replacement coverage has been checked in this client.
4. Offer agent collaboration instructions: guidance for how the agent works with the user,
   discusses scientific choices, preserves work and explains uncertainty and results. The user
   chooses whether to adopt them. Existing personal guidance and project methods stay in place.
   Use the separate instruction workflow below if selected; declining is a valid outcome.
5. Read back selected package versions, source/scope and enabled/disabled choices. Start a fresh
   chat and check discovery of the chosen skills and adopted agent collaboration instructions,
   plus inactivity of old overlapping skills when migration is complete. Try a small ordinary
   task. Installation readback alone does not prove the agent follows the instructions.

Offer the HPC route when relevant, asking which clusters the user wants now. Local package setup,
adoption of agent collaboration instructions and cluster access are separate outcomes; a pending
account does not prevent compatible local setup. Report what works and any incomplete portion.

## Migrate from Lab Skills

Initial setup is intended to replace the old `lab-skills` plugin and overlapping copied skills,
with reversible deactivation after verification. It should not leave both overlapping versions
active and then claim migration complete.

1. Inventory the old active skills, relevant customizations and relied-on protections. Compare
   them with the selected replacements; explain missing skills or security coverage. Use
   `security-setup` before removing legacy protections; Core does not automatically replace hooks.
2. Preserve personal customizations and a rollback copy or retained installation. Show the exact
   selected replacements, proposed deactivation and any separately reviewed customization edits.
   Never silently delete the old plugin, copied skills, hooks or personal guidance.
3. Install the chosen packages. Verify replacement skills are available and needed security protections
   work in this client before deactivation. A missing needed skill, unavailable check or coverage
   gap means migration incomplete: explain the gap and leave the affected old component in place
   until it is resolved. Do not conceal remaining overlap or weaken protection to finish setup.
4. Reversibly deactivate Lab Skills and overlapping copied skills through the approved supported
   client/file route. Confirm they are outside active skill discovery; merely renaming
   a file or disabling one package does not establish that copied skills became inactive.
5. Check the new package discovery and old-skill inactivity in a fresh chat. Report the actual
   completed scope, preserved customizations and rollback route, or why migration is incomplete.

## Add packages later

Read the current inventory and explain the other published packages. Ask which to add unless the
user has named them, then preview and install only those chosen packages through the supported
route. Preserve the existing package selection, enabled/disabled choices, pins and personal
instructions. Do not rerun legacy migration or initial instruction adoption for a later addition.
Read back the added versions/source/scope and check discovery in a fresh chat. A requested Yale
package addition may continue to the separate HPC route when the user wants cluster access.

## Adopt or update agent collaboration instructions

Use this workflow only for requested adoption, an adopted block's update, or explicit removal.
Resolve the installed plugin root from this file's path and directly read
`<plugin-root>/instructions/agent-collaboration.md`. A failed direct read is an exact resource
failure; do not search an authoring checkout or invent a replacement.

1. Identify the current client and its actual active user instruction destination. On macOS/Linux,
   defaults are `~/.claude/CLAUDE.md` for Claude Code and `~/.codex/AGENTS.md` for Codex. On native
   Windows, defaults are `$HOME\.claude\CLAUDE.md` and `$HOME\.codex\AGENTS.md` in PowerShell;
   honor Claude's configured home and `$env:CODEX_HOME` for Codex. Never infer the target from the
   project directory or copy one client's settings into the other. If missing, preview a new file.
2. Read the destination and explain the boundary: manage only the section between
   `<!-- BEGIN RESEARCH-CORE -->` and `<!-- END RESEARCH-CORE -->`. Routine setup, update and removal
   preserve every byte outside that section. The user can keep personal guidance outside it,
   including an optional delegation choice made through the separate workflow below.
   Compare existing agent collaboration instructions with the proposed source and show meaningful
   duplication or conflicts. Read an existing section as adopted instructions, including
   any personal changes; do not assume a replacement is harmless merely because it is managed.
   Resolve conflicts that would make the combined instructions ambiguous before applying the block.
   Reviewing overlap does not authorize edits elsewhere.
3. The package includes `<plugin-root>/scripts/install_instructions.py`, a Python 3 helper that
   previews by default, applies with a source/target-bound approval token and keeps a backup.
   On macOS/Linux with a compatible interpreter, directly read the helper, then run it with absolute
   `--target` and `--source` paths. Use `--remove` for removal. Show the complete proposed diff and
   explain its changed behavior before approval; apply only the unchanged approved preview.
   If source or target bytes change, preview again. The helper cannot judge semantic conflicts.
4. On native Windows, use the manual marked-block route unless helper compatibility has been
   verified for that environment. Read the source and destination, then show the complete proposed diff
   using the exact markers above and full source body. Replace one complete existing block or append
   it when absent; refuse duplicate, incomplete or nested markers. For removal, remove only that
   complete block. After approval of the unchanged diff, keep a backup, preserve file encoding,
   newline style and surrounding instructions, and make only the reviewed edit. Do not install Python
   merely for this step. The same manual route is available if shell/Python execution is unavailable.
5. Verify the resulting named block and preservation of surrounding instructions, report the actual
   outcome and backup path, then start a fresh chat. Identical content is a no-op with no new backup.
   If the source, destination, faithful preview, safe edit or verification is unavailable, explain
   what remains pending instead of claiming adoption or inventing an approval token.

## Optional standing permission for Claude delegation

When the user wants to use a Claude subscription from another client, or asks about repeated
file-sharing approvals, explain the optional wording in [the help guide](references/help.md#optional-claude-subscription-delegation).
This is optional; Core works without a second AI account. Do not turn ordinary help or initial
setup into an automatic external transmission or account setup. Check for an existing explicit
choice first and honor it without asking again for the same scope.

For a new choice, explain the destination (Anthropic through the user's authenticated `claude.ai`
subscription), necessary private-file scope, included subscription capacity, exclusions, and the
user's ability to narrow or revoke it. Verify the actual invocation's account, provider and billing
route before any delegated run; do not promise that a particular student interface can launch
Claude or automatically install
another client. Never infer consent from the maintainer's permission, a subscription, the plugin
installation, or approval of the shared RESEARCH-CORE block alone.

If the user chooses standing permission, propose the help guide's personal wording with any scope
limits they requested. Save it only after the exact additional diff is approved, outside the managed
RESEARCH-CORE section in the actual active user instruction file. This is a separate personal edit;
the helper does not manage it. Preserve all other bytes, show the saved wording and target, and
start a fresh task. If no write is possible or the user declines persistence, report that honestly;
do not claim the choice was saved. An explicit current-task approval still covers that task.

Full updates and recovery preserve this personal choice and do not expand, re-enable or renew it.
If an existing choice conflicts with the proposed shared block, resolve the conflict before
adoption. Removing the plugin block leaves personal permission in place; explain that and change
or remove it when the user requests that separate edit, following the exact-diff review above.
Honor a narrower scope or revocation immediately; if saved instructions still contain the old
choice, explain that and propose the correction for later tasks. Never claim that an unsaved change
is persistent. Never require Claude delegation for ordinary research, setup or updates.

## Set up HPC access or add another cluster

Use this route for first cluster setup and for a later request to add a cluster. Establish the
selected cluster, laptop OS, client/interface, actual execution host and existing working state.
Keep working keys, aliases, plugins and instructions. An HPC-only request does not rerun Core
instruction adoption or reset the student's other hosts.

1. Verify whether the active client's installed components include `hpc`. When available, load that
   installed skill and directly read `<hpc-skill-root>/references/student-setup.md`. Follow its
   account, connection, host and verification sequence; Yale procedures belong there. If the
   resource read fails, report the exact failure and the unavailable portion without inventing it.
2. If Yale/HPC is absent, explain that limitation and use the release guide's explicit installation
   route for the chosen client and host. Verify the selected release catalog actually lists the
   package before proposing installation; a proposed name is insufficient. Do not search private
   authoring checkouts, copy skills, change an existing marketplace source, or treat installation
   as part of explanation-only help. If no supported released route is available, use official
   cluster documentation for guidance and leave package installation pending.
3. Keep laptop, cluster login and compute environments distinct. Install each selected client and
   package through its own native route in the environment where the agent will execute. Offer
   agent collaboration instructions there only when the user chooses adoption or updates an
   existing adopted block. Existing shared-home installations can be reused when verified.
   Never copy account state or whole configuration directories.

Return a short account of what works, what remains pending, and the next step. Resume the missing
portion when access is ready; adding another cluster never resets the completed setup.

## One update workflow

"Update my Research Plugins" covers all installed Research Plugins from this repository,
including optional packages: `research-core`, `single-cell-research`, `genome-annotation` and
`yale-research` when installed, not unrelated plugins. It also checks separately adopted agent
collaboration instructions. A question about updates uses explanation-only help; checking what is
new uses the read-only mode. Preserve package selection, enabled/disabled choices, source/ref,
pins and personal instructions. Do not install previously unselected packages.

Do not repeat the initial legacy migration or old-skill cleanup during routine updates, and do not
adopt agent collaboration instructions the user previously declined. An absent `RESEARCH-CORE`
block is not permission to add one. Existing installation state and the actual instruction file
supply the needed context; do not require a separate decision registry.

1. Read the active client's plugin list and marketplace source. Identify the selected installed
   packages, including disabled packages, current versions, execution host and scope. Compare the
   published release inventory/notes with the installed versions and pinned ref. Show proposed
   package changes first. Ask before changing an intentional older pin, source, installation scope
   or automatic-update setting; a routine update does not authorize those changes.
2. For the released Git-backed `musser-lab` marketplace, Codex CLI uses
   `codex plugin marketplace upgrade musser-lab`; Claude Code CLI uses
   `claude plugin marketplace update musser-lab` followed by
   `claude plugin update PACKAGE@musser-lab --scope user` for each installed named user-scope
   package. Verify current client help and actual configuration before executing. Do not use a
   user-scope command for a project/local installation. A catalog-wide command can affect other
   installed packages, including legacy `lab-skills`; enumerate its actual effects and stop if
   the route cannot preserve the agreed scope. A source switch/reinstall is a separate reviewed
   operation and may enable disabled packages; record and restore their states if selected.
   A local development catalog uses maintainer-supplied reinstall instructions instead.
3. Read back all targeted package versions, source/scope and enabled/disabled choices. Report
   each targeted package as changed, unchanged or unknown. If any targeted operation or readback
   failed, preserve the current state and stop before instruction adoption or update until a
   coherent installed target is established. Explain the exact remaining step; do not automatically
   repair/restore packages or claim a successful full update.
4. For an adopted block, directly read the newly installed source of agent collaboration instructions
   and actual `RESEARCH-CORE` section. Make a separate instruction preview using the workflow above.
   Identical content is a no-op. Show meaningful changes, personal edits and conflicts; resolve
   ambiguity and obtain approval of the concrete block diff before applying it. Refreshing packages,
   including automatic refresh, does not rewrite adopted agent collaboration instructions.
5. Verify preservation and report the package results and instruction outcome separately, including
   a declined or unchanged block and any incomplete operation. Start a fresh chat after changes.

For recovery, use the release guide's retained catalog ref or maintainer recovery release. Do not
invent a universal `plugin@version` selector or directly edit installed caches. Preview the prior
release's adopted instruction block separately; retain personal changes and surrounding text.

## Optional review of other personal instructions

At initial setup, or when meaningful overlap appears, offer a separate review of the rest of the
instruction file for duplication, conflicts or possibly outdated guidance. The user can decline
and retain everything outside the plugin section. If they accept, explain each suggested change
and its reason; unfamiliar guidance is not evidence that it is obsolete. Show the exact additional
diff and obtain approval before editing outside the section. Preserve unrelated preferences and
project-specific rules. Move a personal preference out of the plugin section only as an explicit,
reviewed change, so future plugin updates can preserve it. This optional cleanup is not required
for setup when the retained instructions are compatible.

## Removal and unavailable execution

For removal, use the instruction workflow's helper `--remove` or native Windows manual preview.
It removes only the named block.
Uninstalling the plugin separately does not remove the block. Never delete the whole instruction
file, reset permissions, or edit a project to make the uninstall appear complete.

If execution or a supported package-management route is unavailable, state exactly which action
did not run and what remains pending. Manual instruction adoption does not establish package
installation or native discovery. Never invent markers, an approval token, a successful check,
or a write, and do not install a runtime without checking the environment and user preference.
