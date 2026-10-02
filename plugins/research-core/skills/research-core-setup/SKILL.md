---
name: research-core-setup
description: Help students use research plugins, explain updates, check installed packages or adopted rules, and set up, fully update, or remove Research Core for Claude Code or Codex. Also help set up, change or remove optional standing permission for Claude subscription delegation, and route first HPC setup or adding another cluster to installed Yale guidance. Use for requests such as how do I use this plugin, how do updates work, which research plugins are installed, are my research core rules current, set up research core, help me connect to Bouchet, add McCleary to my setup, set up standing permission to delegate to my Claude subscription, or update research plugins. Do not run automatically during ordinary research work.
---

# Use and manage Research Core

## Choose the requested operation

Read the installed [short help guide](references/help.md), directly at
`<plugin-root>/skills/research-core-setup/references/help.md`, relative to this skill's installed
path. Use the installed resource, not an authoring checkout. If that read fails, report the exact
failure; do not invent package details or search outside the plugin for a replacement.

Distinguish the user's request before entering the workflows below:

- **Explanation only:** "How do I use this plugin?", "How do updates work?" or "Does it update
  automatically?" Answer from the bundled guide and stop. Do not read personal instruction files,
  run helpers or plugin-management commands, or start setup, refresh or installation. Use any
  already verified installed-package context; otherwise describe optional packages conditionally.
- **Read-only status:** "Which research plugins are installed?" or "Check my plugin versions."
  Use the active client's read-only plugin list and marketplace metadata to report the actual
  packages, versions, source, installation scope and execution host. Do not refresh the catalog
  or treat a cached catalog as proof of the latest release. If the request explicitly includes
  adopted rules, read the actual named block and installed collaboration source and report their
  agreement or differences without helpers or edits. Report unavailable checks as unverified.
- **Action:** "Set up research core", "Help me set up cluster access", "Add another cluster",
  "Update research plugins", "Change my Claude delegation permission" or "Remove the research core
  instruction block." Use the corresponding
  workflow below. A full update includes the selected
  installed packages **and the separately adopted agent collaboration instructions**. Explain
  both outcomes; changing adopted instructions still uses their concrete diff review.

For an ambiguous request, provide the useful explanation and clarify before an action that would
change the installation or instructions. Ordinary plugin use does not require repeated setup.
Only present an optional package as available when its installation is verified; do not infer it
from a package name in a guide or marketplace catalog. When installation or refresh cannot run,
explain the remaining step without claiming completion.

## Set up Research Core

Explain that the plugin supplies reusable procedures and that this step installs the agent
collaboration rules used in every task. These govern the researcher–agent relationship; project
guidance governs collaboration among researchers. The user selects whether to adopt these rules.
Existing project methods, styles and instruction files remain in place. Research Core contains
22 procedures, including plugin feedback, and this setup skill with its helper. Its optional
security-setup procedure reviews native client protections; the package installs no hooks or
permission grants.

If a legacy hook-bearing package such as `lab-skills` is installed, use the release guide's
transition checklist before switching or removing components. Offer `security-setup` when the
change affects or questions protection coverage; do not assume Core replaces those hooks.

At first setup, establish the laptop OS, client and terminal/editor/desktop interface, where the
agent runs, and whether the student uses HPC. Ask which clusters they want now; reuse information
already supplied. Offer the HPC route below when relevant. Core instruction adoption and cluster
access are separate outcomes, so a pending account does not prevent compatible local setup.

1. Resolve the installed plugin root from this file's path:
   `<plugin-root>/skills/research-core-setup/SKILL.md`. The helper is outside the skill directory.
   Directly read both `<plugin-root>/instructions/agent-collaboration.md` and
   `<plugin-root>/scripts/install_instructions.py` at those exact paths. A glob/search miss does not
   establish absence: development build files may be Git-ignored. If a direct read fails, report
   that exact failure and stop setup; do not search outside the plugin or invent a replacement.
2. Identify the current client and resolve its actual user instruction destination: Claude Code's
   `CLAUDE.md` in its active configuration directory, or Codex's `AGENTS.md` in its active Codex home.
   Defaults are `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. Honor configured paths. Never infer the
   target from the project working directory or copy one client's settings into the other.
3. Read the destination and explain the boundary: the plugin manages only the section between
   `<!-- BEGIN RESEARCH-CORE -->` and `<!-- END RESEARCH-CORE -->`. Routine setup, update and removal
   preserve every byte outside that section. The student can keep personal guidance outside it,
   including an optional delegation choice made through the separate workflow below.
   Compare existing agent collaboration guidance with the proposed rules and show meaningful
   duplication or conflicts. Read an existing plugin section as adopted instructions, including
   any personal changes; do not assume a replacement is harmless merely because it is managed.
   Resolve conflicts that would make the combined instructions ambiguous before applying the block.
   Reviewing overlap does not authorize edits elsewhere. The helper cannot judge semantic conflicts.
4. Use an available compatible Python 3 interpreter (the project's environment when applicable).
   Run that verified `<plugin-root>/scripts/install_instructions.py` with absolute `--target` and
   `--source` paths.
   Its default operation previews the exact file and diff without writing. Present the changed
   behavior in plain language and show the diff. Obtain approval of that concrete change unless
   the user already approved the unchanged exact diff.
5. Apply using the preview's approval token and the same inputs. If the target or source changed,
   preview again. Report the actual outcome and backup path. Verify the resulting named block and
   preservation of surrounding instructions. A repeat with unchanged content should be a no-op.
6. Start a fresh task to pick up the new user instructions and plugin skills. Installation readback
   is not proof that the agent follows the rules; an ordinary small task provides that evidence.

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
   package through its own native route in the environment where the agent will execute; perform
   instruction setup above there only if missing or changed. Existing shared-home installations
   can be reused when verified. Never copy account state or whole configuration directories.

Return a short account of what works, what remains pending, and the next step. Resume the missing
portion when access is ready; adding another cluster never resets the completed setup.

## One update workflow

When the user asks to perform a full update, handle both the selected installed packages and the
separately adopted agent collaboration instructions. An update question uses explanation-only
help above. A package refresh, including an automatic refresh, does not rewrite adopted rules:

1. Read the active client's plugin list and marketplace source. Identify the selected installed
   packages, current versions, execution host and scope. Read the release guide/changelog, including
   the legacy-transition guidance above when the update affects retained protections. Do not
   change a source/ref, enable automatic updates or migrate installation scope silently.
2. For the released Git-backed `musser-lab` marketplace, Codex CLI uses
   `codex plugin marketplace upgrade musser-lab`; Claude Code CLI uses
   `claude plugin marketplace update musser-lab` followed by
   `claude plugin update PACKAGE@musser-lab --scope user` for each selected user-scope package.
   Verify current client help when syntax differs. Do not use these user-scope commands for a
   project/local installation; resolve its actual scope first. Editor/desktop interfaces and
   other hosts require their own demonstrated route; CLI success does not establish that route.
   A local development catalog uses maintainer-supplied reinstall instructions instead.
3. Read back installed versions and changed contents. If refresh fails, report the actual state;
   do not claim the instructions now correspond to the new release. A catalog refresh can affect
   several installed packages, including legacy `lab-skills`; enumerate them before a ref change.
4. Read the newly installed collaboration source and compare it to the actual adopted block using
   the helper preview above. Identical content is a no-op. Show meaningful changes and personal
   edits, then obtain approval only for the concrete instruction diff that needs applying.
5. Verify preservation, report both package versions and instruction outcome, then start a fresh
   task. Updating package contents never itself authorizes replacing adopted instructions.

For recovery, use the release guide's retained catalog ref or maintainer recovery release. Do not
invent a universal `plugin@version` selector or directly edit installed caches. Preview the prior
release's instruction block through the same helper; retain personal changes and surrounding text.

## Optional review of the student's other instructions

At initial setup, or when meaningful overlap appears, offer a separate review of the rest of the
instruction file for duplication, conflicts or possibly outdated guidance. The student can decline
and retain everything outside the plugin section. If they accept, explain each suggested change
and its reason; unfamiliar guidance is not evidence that it is obsolete. Show the exact additional
diff and obtain approval before editing outside the section. Preserve unrelated preferences and
project-specific rules. Move a personal preference out of the plugin section only as an explicit,
reviewed change, so future plugin updates can preserve it. This optional cleanup is not required
for setup when the retained instructions are compatible.

## Removal and unavailable execution

For removal, use the helper's `--remove` preview and approval flow. It removes only the named block.
Uninstalling the plugin separately does not remove the block. Never delete the whole instruction
file, reset permissions, or edit a project to make the uninstall appear complete.

If Python or shell execution is unavailable, state that the helper was not run. For a manual
preview, use the helper's exact `BEGIN`/`END` markers and insertion/replacement behavior, the full
unmodified instruction body, and the actual target text. Show the complete diff without ellipses;
never invent markers, an approval token, a successful check, or a write. If a faithful preview is
not possible, explain what remains unavailable. Do not install a runtime without checking the
environment and user preference.
