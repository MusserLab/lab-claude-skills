# Research plugins: student guide

> **Opt-in trial toolkit:** Core candidate.6, Yale candidate.1, Single-cell candidate.1 and Genome
> candidate.2 contain the four-package result accepted in Phase 1 on 2026-10-01. Start with the
> [trial quickstart](research-plugins-trial.md), which names the exact channel and release to verify
> before installation. This local preparation is not proof that publication has happened.
> Both macOS CLI package lifecycles passed; ordinary student use, Windows/Desktop and other
> interfaces remain trial targets. See the [compatibility record](research-plugin-compatibility.md).

Research plugins provide shared research procedures for Claude Code and Codex. Research Core adds
the common collaboration, integrity, reproducibility and setup behavior. Optional packages add
scientific or institutional procedures without replacing project instructions, accepted methods,
styles, credentials or host configuration.

The [first-release manifest](../release/first-release.json) is the exact authority for packages,
versions, files and dependencies in a built candidate or release. Native evidence from
earlier candidates remains historical. Core retains 21 shared procedures plus `plugin-feedback`
and `research-core-setup` (23 skills); Yale adds `hpc`, `globus-transfer` and `lux-collections`.
Single-cell adds `deep-research-genelist` and `deep-research-reports`; Genome adds five sequence
analysis and display procedures. There are 33 skills across the four candidates. Only packages
listed in the manifest and both client catalogs are available for an authorized local trial.

| Package | Purpose | Present status |
|---|---|---|
| `research-core` | Twenty-one shared research procedures, `plugin-feedback`, and `research-core-setup`; no hooks or permission grants. | Candidate.6 accepted in Phase 1; macOS CLI lifecycle checked; use the opt-in trial quickstart and recorded route limits. |
| `single-cell-research` | Dataset-derived marker prompts and general research-report processing. | Candidate.1: two skills; expression reports and specialized family workflows deferred. |
| `genome-annotation` | Gene lookup, protein phylogeny, tree formatting, BUSCO and HMMER. | Candidate.2: all five accepted in Phase 1 with the agreed interpretation/privacy corrections; trial scope applies. |
| `yale-research` | HPC setup and resource learning, Globus transfer and Lux collection search. | Candidate.1; remote onboarding and student compatibility remain unverified. |
| `lab-skills` | Existing legacy plugin, version 1.12.1. | Remains available during the transition. |

Private Musser Lab Style and Sponge Corpus packages are planned separately. No private distribution
has been selected or released in this candidate, so neither has an installation or
issue-submission route here.

For students, Research Core is the common working toolkit: it helps start and plan projects, protect
inputs and retained outputs, use declared environments, keep reviewable Git checkpoints, diagnose
problems before patching, explain code, review analyses, prepare figures and close out work. New work
uses `planning`; `new-plan` remains only as a small compatibility entry for older projects and calls.

Several procedures are intentionally conditional. `quarto-docs` applies when the project uses
executable Quarto analysis documents. `sync-project` reconciles an arriving project's Git and declared
environments; departure work follows the project's closeout procedure. Environment modules, paths
and other site details come from project instructions or an optional explicitly adopted site
profile. Research Core does not transfer credentials or silently select a Yale configuration.

The first release defers `feedback-walkthrough`, `collaborator-setup`, `quarto-book-setup`,
`quarto-publish` and `handoff`. These specialized mentoring, collaboration, publishing and sequential
host-transition procedures need a clearer audience or workflow case. Their exclusion does not
prevent ordinary collaboration, publishing or host changes under project instructions.

`scientific-manuscript` and its resources remain excluded. Jacob's personal authoring
source is preserved separately; its personal use and candidate.1 presence do not make its scientific
claim-strengthening advice an appropriate student default.

## Ask for help and work normally

Ask **“How do I use these research plugins?”** The existing `research-core-setup` skill has a
help route and a short guide bundled with the installed package. It explains what the toolkit
does, ordinary task examples, setup, full updates, support and recovery. Asking for help does not
start installation, inspect personal instructions or change anything.

Use ordinary requests such as “Help me plan this analysis,” “Explain this script,” or “Review
this workflow.” You do not need to memorize skill names or exact phrases. The agent should use
relevant available procedures; ask it which skill it used when that matters. Optional packages
are separate selections, and their presence must be checked before claiming they are installed.

**“Update my research plugins, including their collaboration instructions”** requests the full
update workflow below. “How do updates work?” asks for an explanation; “Am I up to date?” asks
for a status check without installing an update. The setup skill handles all three intents.

## Use the same toolkit in Claude and Codex

Install the same selected released packages in each client you use, then run Core setup for each.
Both receive procedures from the shared distribution; each maintains its own installed state and
adopted instructions: CLAUDE.md for Claude Code and AGENTS.md for Codex. Updating one client does
not establish that the other is current. Ask for the full update, including collaboration rules,
in each client, or explicitly name both installations when the agent can access and verify them.
Apply the same principle to a separate laptop or cluster installation.

Plugin updates do not synchronize personal instruction additions, project files, accounts,
credentials, histories or client settings. Project files follow the project's normal version-control
workflow. Keep personal guidance outside RESEARCH-CORE; deliberate alignment of personal guidance
is a separate reviewed edit. Students need no copy of the maintainer's personal claude-sync system
merely to receive shared skills. If old loose/imported skills overlap with the packages, inspect
origins and unique changes before migration, including any refresh that might restore duplicates.

## Before your first agent session

If you do not have a client yet, choose the interface you intend to use and follow its official
installation and sign-in guide: [Claude Code](https://code.claude.com/docs/en/setup) or
[Codex CLI](https://learn.chatgpt.com/docs/codex/cli). Use your own account and the intended service;
[Codex authentication](https://learn.chatgpt.com/docs/auth) explains supported sign-in options.
A terminal client is the simplest initial route; use the actual desktop/editor's documented setup
when that is your choice. A successful terminal check does not validate an editor integration.

Once the client works locally, follow the package path below. Cluster account approval can happen
in parallel; you do not need to rebuild a working local setup when access arrives later.

## Main path

Use an installed client signed in through its native account flow, Git for repository catalogs,
and an available Python 3 interpreter for the instruction helper. Use the project environment
where appropriate; setup does not install a runtime or scientific toolchain. If helper execution
is unavailable, request a faithful manual preview without treating it as a completed installation.

1. Confirm the package is present in the manifest and that the maintainer has authorized the
   candidate trial, named the moving release channel, or supplied an intentional recovery pin.
2. Add the `musser-lab` marketplace once for this client and host.
3. Install Research Core and every selected optional package explicitly.
4. Ask the agent: **“Set up research core.”** Review the exact instruction destination and diff.
5. Approve only the shown `RESEARCH-CORE` block change, then start a fresh task.
6. Work normally. If an optional resource is absent, use the project's declared instructions or
   official documentation and say that the package was unavailable.

Installing on another client or execution host is a separate installation with that client's home,
credentials and instruction file. A laptop installation does not install anything on Bouchet or
another cluster.

## Set up a cluster, or add another later

With Core and Yale Research installed, ask **“Help me set up Bouchet”** or **“Add McCleary to my
existing cluster setup.”** The setup skill routes to the installed HPC onboarding guide. If the
Yale package is missing, it explains how to select/install the released package before continuing.
Asking how setup works gives an explanation; it does not change your files or start a login.

The agent checks your laptop OS, chosen cluster and client, existing access and working connections.
It guides only the missing steps: account/VPN and public-key registration, SSH, a suitable compute
connection, client/plugins/instructions on the actual execution host, and your project/lab
resources. You handle account sign-in, key passphrases and MFA yourself. The agent previews scoped
configuration changes and preserves existing keys, aliases, instructions and installations.

Use simple names such as `bouchet` for login and `bouchet-devel` for the development connection;
keep existing names that already work. Bash/Zsh aliases are optional conveniences. Windows/WSL
needs its own documented route and is not established by the macOS examples. Each added cluster
gets its own checked setup; do not copy another cluster's paths, limits or authentication blindly.

Setup recommends the lab's shared storage/database locations and NAS archive model, checks access,
and confirms any project-specific alternative. It can also configure a small private resource
profile outside the plugin cache. Completed-job evidence improves future comparable requests;
plugin updates preserve that record. No background monitor is installed.

Finish with a small job, output readback and a fresh agent session that finds the expected skills
and instructions. Pending account approval or an unavailable interface remains a named unfinished
step; later ask to continue. Adding a cluster preserves working earlier connections and installed
packages. These are candidate procedures: see the compatibility record for what has actually been
exercised on each interface and host.

Globus needs your own CLI authentication and collection access; the package supplies procedures,
not credentials or access grants. Lux includes catalog interpretation and query guidance. Its
agent-driven query route needs the documented optional Lux MCP tools; without them use the public
Lux interface with explicit limits, rather than claiming an automated query ran.

## Prepare marker research and process its reports

With Core and Single-cell Research available, ask “Prepare research prompts for the clusters in
this atlas.” The agent first checks the project's current dataset, grouping and marker producer.
It calculates markers through the established project method or reuses matching completed tables,
applies the lab cutoff (adjusted p < 0.05 and expression in more than 10% of target cells), and
reports input identities and selection counts. A new dataset's unresolved statistical choices need
scientific discussion; the package does not bundle a universal marker calculator.

Prompts retain original gene IDs beside readable names and distinguish inferred orthology,
group-derived labels and unresolved annotations. Unannotated markers remain in the local record;
missing annotation alone is not treated as evidence of lineage specificity. The researcher uses
the completed prompt in the chosen research service and reviews the resulting biological claims.
No research-service account or subscription is supplied by the plugin.

Then ask “Process these research reports.” The processor preserves original reports and structured
headers, checks expected nested fields, and produces readable HTML/PDF and summary tables. Invalid
or ambiguous metadata remains an explicit held report; a successful parse does not validate its
biological claims. The runtime needs Python with PyYAML plus Quarto/Pandoc; PDF additionally needs
an available LaTeX engine. Use the declared project environment, with HTML as a reported fallback
when PDF support is unavailable.

General cluster, ordinary family and nonmetazoan reports are supported. The specialized
`family_report1/2` workflow is deferred. Expression Report, cell-type tree/family and WGCNA
computation skills are also deferred from this candidate; installation does not make them available.

## Investigate sequences and display trees

With Core and Genome available in an authorized trial, use ordinary requests such as “Look up these
accessions,” “Build a protein phylogeny,” “Format this tree,” “Assess sequence completeness,” or
“Search these sequences for the chosen protein profiles.” The agent checks the actual sequence/tree
inputs and the project's established lineage, translation code, profiles, thresholds and tree choices.
It preserves input identities; a UniProt entry mnemonic is not used as a gene symbol. Missing gene
names retain their accessions, and repeated gene names keep distinct original tree-tip IDs.

Phylogeny and HMMER runs use fresh output destinations to preserve retained results. BUSCO and HMMER
include local/batch/setup and environment examples, not installed databases or scientific software.
Set the database cache explicitly and adapt scheduler/module settings for the execution site.
Starting resource estimates need measurement on the actual input. BUSCO aggregation uses one mode
per report and requires a separately available Quarto/Python rendering environment.

BUSCO uses an appropriate primary lineage; broader or distant-lineage comparisons need their own
purpose and interpretation. Its setup stops until a lineage is selected. Unknown tree taxa remain
explicitly Unclassified, with counts/examples for investigation, rather than acquiring a biological
category through a default.

iTOL previews the exact upload files and destination. Uploading remains an external write requiring
approval of data, destination and visibility. A missing API key no longer selects anonymous upload;
anonymous use requires an explicit choice. Verify sharing/retention in the service before approval.
These agreed corrections are implemented, but no real phylogeny, completeness/profile search, full
figure rendering or iTOL service compatibility is established by the package checks.

## Install an authorized local candidate

This route is for a maintainer-scoped trial in a disposable or otherwise reviewed profile. Replace
the placeholder with the exact absolute worktree root supplied by the maintainer. Do not guess a
path, point at the private authoring repository, or replace an existing `musser-lab` source without
reviewing the affected installed packages.

Codex CLI:

```bash
codex plugin marketplace add /absolute/path/supplied-by-maintainer --json
codex plugin add research-core@musser-lab --json
codex plugin list --marketplace musser-lab --available --json
```

Claude Code CLI, user scope:

```bash
claude plugin marketplace add /absolute/path/supplied-by-maintainer --scope user
claude plugin install research-core@musser-lab --scope user --json
claude plugin list --json
```

Repeat the `plugin add` or `plugin install` command once for each additional package actually named
in the selected manifest. Do not substitute a proposed package name.

These commands installed candidate.1 in isolated macOS profiles for Codex CLI 0.149.0 and Claude
Code 2.1.268; its 29 skill entries and 53 installed files matched the candidate.1 manifest. That is
historical technical evidence, not validation of the current candidate. It does not establish editor, desktop,
Windows or cluster support. See the [dated evidence](research-plugin-compatibility.md).

Candidate.2 passed its build and structural checks. In its bounded Claude trial, explicitly invoked
data-handling and closeout skills produced an accurate synthetic review, but restricted mode denied
the plan update. That partial result does not establish a complete student workflow. Candidate.4
passed a bounded Claude help-discovery check. Native installed-cache lifecycle and ordinary student
use remain open; the compatibility record above gives the exact versions, evidence and limits.

## Trial repository route

Use the [trial quickstart](research-plugins-trial.md) first. Its moving channel is
`codex/research-plugins-trial`; the initial immutable recovery ref is `research-plugins-trial-1`.
Verify the published prerelease and its target before using these commands. A local candidate or
this document alone does not prove that the remote refs exist. Review an existing `musser-lab`
source and all its installed packages before changing it.

Codex CLI command shapes, when the actual client supports them:

```bash
codex plugin marketplace add MusserLab/lab-claude-skills --ref codex/research-plugins-trial --json
codex plugin add research-core@musser-lab --json
codex plugin list --marketplace musser-lab --available --json
```

Claude Code CLI, user scope:

```bash
claude plugin marketplace add "MusserLab/lab-claude-skills#codex/research-plugins-trial" --scope user
claude plugin install research-core@musser-lab --scope user --json
claude plugin list --json
```

Install a selected optional package with its own explicit command using `yale-research`,
`single-cell-research` or `genome-annotation`. Install Core first; there is no implied dependency
installation. Desktop/editor and Windows routes must be checked in the actual client, not inferred
from macOS CLI command success. The immutable tag is for an intentional pin or recovery; routine
updates follow the named moving channel and never silently change a student's pin.

## Set up Research Core

Say **“Set up research core.”** The setup skill resolves the installed plugin and the active
client's user instruction file. It manages only:

```text
<!-- BEGIN RESEARCH-CORE -->
...
<!-- END RESEARCH-CORE -->
```

The agent reads the existing instruction file, explains meaningful overlap or conflicts, and shows
the complete proposed diff before writing. The helper binds approval to the exact source and target
bytes, keeps the first backup of an existing file, and preserves every byte outside the named block.
Personal and project guidance outside the block remains in place. Reviewing or installing Research
Core does not authorize cleanup elsewhere in the instruction file.

After the verified change, start a fresh task so the client reads the new instructions and skills.
Installation and readback alone do not establish that the agent follows them in ordinary work.

## Optional permission to delegate to Claude

Research Core supports your own standing permission for bounded Claude subscription work. If you
want it, ask "Help me set up standing permission to delegate to my Claude subscription." Review
which task-relevant files may be sent to Anthropic, your authenticated subscription route and
included capacity, then the exact personal-instruction diff. Private code and unpublished research
material can be included when you are allowed to share them. Within that approved scope, the agent
should not ask again for each file or run.

This is optional: installing Core or adopting its shared rules does not grant permission, supply
an account or establish that an interface can launch Claude. The choice stays outside the managed
RESEARCH-CORE block in your active CLAUDE.md or AGENTS.md, so updates and recovery preserve it.
You can limit or revoke it; removing the plugin block alone does not remove personal instructions.
Paid API calls, credits, other destinations and wider scopes need separate approval. See the
[bundled explanation and sample wording](../plugins/research-core/skills/research-core-setup/references/help.md#optional-claude-subscription-delegation).

## Transition from `lab-skills`

Keep `lab-skills` 1.12.1 available while the new packages are evaluated. It shares the
`musser-lab` marketplace and overlaps with new package procedures. It also carries existing hook
and security behavior that Research Core does not replace automatically.

The candidate.3 membership selection changes the proposed new package contents; it does not switch an existing
installation, remove a legacy skill or hook, or demonstrate a student migration.

Before any student switch, inspect that student's installed scope, overlapping skills,
instructions, hooks and relied-on protections. Decide which legacy components remain necessary and
demonstrate the return path. There is no blanket default to run both complete sets or uninstall the
legacy plugin. A marketplace catalog/ref change can affect the legacy plugin and several new
packages, so enumerate the affected installed set first.

## Update with one request

Ask **“Update my research plugins, including their collaboration instructions.”** Shorter wording
such as “Update research plugins” also requests the full workflow. These are examples, not required
command phrases. Research Core's setup skill coordinates package contents and the separately
adopted agent collaboration instructions in the active client's `CLAUDE.md` or `AGENTS.md`.
Package updates alone do not replace those adopted instructions. The agent checks both, applies
approved instruction changes and reports the outcome of each part; an unchanged block needs no edit.

For a released Git-backed marketplace, the CLI path is:

```bash
# Codex
codex plugin marketplace upgrade musser-lab --json
codex plugin list --marketplace musser-lab --available --json

# Claude Code: update the catalog, then every selected user-scope package explicitly
claude plugin marketplace update musser-lab
claude plugin update research-core@musser-lab --scope user --json
claude plugin list --json
```

The agent first reads the actual marketplace source, installation scope and installed package
versions. For Claude Code, it repeats `plugin update` for each selected package. It then reads back
the versions and previews the newly installed collaboration block against the adopted block. An
identical block is a no-op; a changed block needs review before application. Start a fresh task
after a successful update.

These commands are not the update route for a local development catalog, a project/local-scope
Claude installation, an editor/desktop interface, or another host. Resolve the actual supported route
before acting; do not silently change scope, refs or automatic-update settings.

### Automatic updates and full updates

Native package updates and adopted collaboration instructions are separate:

- **Claude Code:** third-party marketplaces such as this one have automatic updates off by default.
  Students can enable them in `/plugin` → Marketplaces → select the marketplace → Enable auto-update.
  With that setting enabled, startup refreshes the marketplace and downloads plugin updates; the
  running session keeps its loaded version until reload or a later session.
  See the [official update documentation](https://code.claude.com/docs/en/discover-plugins#keep-plugins-updated).
- **Codex:** the reviewed 0.149.0 implementation refreshes configured Git marketplaces at startup and
  refreshes installed packages when those sources change. This is versioned source evidence, not
  an observed automatic-update trial on a student's installation or a guarantee for every interface.
  See the [reviewed implementation](https://github.com/openai/codex/blob/rust-v0.149.0/codex-rs/core-plugins/src/manager.rs#L2011-L2205).

An intentionally pinned release stays on its selected reference. A package refresh does not rewrite
the collaboration block copied into a student's own instruction file. Ask for the **full update**
to check both layers, even when native automatic package updates are enabled. Meaningful changes to
adopted instructions are shown for review; personal guidance is preserved. The agent verifies the
actual client, source, versions and outcome rather than assuming an automatic update succeeded.
No plugin-specific updater or automatic change to a student's update preference is required.

## Report a problem

Ask the agent to draft a research-plugin report. It should show the exact destination, title and
full body before submission.

For a fully shareable public-package report, the destination is
<https://github.com/MusserLab/lab-claude-skills/issues>. Use a minimal synthetic example and remove
credentials, home paths, private repository names, unpublished results and unrelated conversation.

```markdown
Package/version:
Client/version and interface:
OS / execution host / installation scope:
Action and minimal reproduction:
Observed:
Expected:
Checks already tried:
```

If the report needs private package content, private identities, lab paths or unpublished science,
keep the exact draft private and ask the maintainer for its destination. The private distribution
has not been selected or released in this candidate. Never fall back to the public tracker or invent
a private URL. If a report already has a selected private destination, preserve it through
follow-ups rather than silently redirecting the report.

### Synthetic sanitized example — not observed or submitted

**Destination:** <https://github.com/MusserLab/lab-claude-skills/issues>

**Title:** `[research-core-setup] Document recovery after a malformed managed marker`

**Body:**

```markdown
Package/version: research-core 0.1.0-candidate.1
Client/version and interface: Codex CLI 0.149.0
OS / execution host / installation scope: synthetic macOS example / local / user
Action and minimal reproduction: In a disposable AGENTS.md fixture, leave a
  <!-- BEGIN RESEARCH-CORE --> marker without its matching end marker, then ask for setup preview.
Observed: The helper refuses to write because the managed markers are malformed.
Expected: The refusal is correct. Please add student-facing setup help explaining how to preserve
  the file and ask the maintainer to repair a malformed block before retrying.
Checks already tried: Confirmed this draft contains only synthetic text; no user file or log attached.
```

This is an example of a shareable setup-help request, not evidence of an actual defect. It has not
been submitted. If the same request depended on an unpublished result, a private style asset or a
lab-only path, keep the exact draft private while no private distribution is selected in this
candidate.

## Remove a package

Remove adopted instructions before uninstalling Research Core, while its setup skill and helper are
still available. Ask **“Remove the research core instruction block.”** Review the helper's
`--remove` preview and apply only the named-block deletion. The rest of the instruction file remains
byte-for-byte intact.

Then uninstall each selected package explicitly:

```bash
# Codex
codex plugin remove research-core@musser-lab --json

# Claude Code, user scope
claude plugin uninstall research-core@musser-lab --scope user --json
```

Repeat for each optional package being removed. Do not remove the `musser-lab` marketplace while
`lab-skills` or another selected package still uses it. Uninstalling a package does not remove its
persistent instruction block, and removing the block does not uninstall the package.

## Return to a retained release

Use only a maintainer-named immutable catalog/release ref and the client-specific recovery steps.
Changing a catalog ref can move multiple installed packages, so preview the affected installed set
and expected versions first. Neither current CLI provides a universal `plugin@version` recovery
command; do not edit plugin caches directly.

Routine installations instead follow the maintainer-named moving release branch/channel so an
explicit marketplace update can receive later releases. Do not silently move an installation from
that channel to another branch, tag or commit. For an intentional pin or return, the maintainer must
name the immutable tag/commit and the exact client-specific source/ref change; review all packages
that share the catalog before applying it. A pinned installation stays pinned; an ordinary update
must not move the pin or convert it back to the moving channel.

The isolated macOS CLI check demonstrated uninstalling the affected selected packages, removing
and re-adding their catalog at the immutable ref, and reinstalling that coherent package set in
the same profile. Codex uses `marketplace add <git-url> --ref <retained-ref>`; Claude uses
`marketplace add <git-url>#<retained-ref> --scope user`. These are command shapes, not a released
ref or permission to change an installation. The maintainer supplies the exact approved source,
ref, affected package list and scope; preserve any legacy installation sharing that catalog.

After package recovery, preview the prior release's Research Core block with the setup helper.
Preserve surrounding text and reconcile personal edits before applying it. Start a fresh task and
read back package versions and the installed block.

A maintainer recovery release is different: the maintainer publishes known-good contents as a new,
forward version through the normal reviewed release process. Students then use the ordinary update
route. It does not rewrite old tags, undo project outputs, or instantly change every installation.

See [compatibility and evidence](research-plugin-compatibility.md) before treating any client/host
route as supported.

## Command sources

- [Claude Code: install and manage plugins](https://code.claude.com/docs/en/discover-plugins) —
  marketplace source forms, `owner/repo#branch-or-tag`, installation, update and removal.
- [Claude Code: create a marketplace](https://code.claude.com/docs/en/plugin-marketplaces) —
  marketplace/plugin naming, relative package sources, validation and hosted distribution.
- Codex command forms in this guide were checked against the installed `codex plugin --help` and
  subcommand help. Recheck native help when the client version differs.
