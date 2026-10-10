# Research Plugins

Research workflows for Claude Code and Codex, developed in the Musser Lab and available to
anyone working with research code and data.

These plugins help an AI agent plan analyses with you, handle data carefully, write readable
code, preserve how results were produced, and explain its work. They also provide procedures for
specific tasks, including researching single-cell markers, building protein phylogenies, and
preparing figures.

Setup starts with **Research Core**, explains the other packages, and asks which you want to
include. You do not need to belong to the lab or use Yale's computing systems.

[Get started](#get-started) | [Choose your packages](#choose-your-packages) |
[Everyday use](#everyday-use) | [Add packages later](#add-packages-later) |
[Updates](#updates) | [Security](#security-setup) | [Recovery and removal](#recovery-and-removal)

## What the plugins add

A **skill** is a set of instructions for a recurring task. It can include examples, templates,
and helper scripts. A **plugin** packages related skills so you can install and update them
together.

You usually work in ordinary language: "Help me plan this analysis," "Explain this script," or
"Review this workflow for mistakes." The agent can select a relevant installed skill, and you
can ask it to use one explicitly. You do not need to memorize commands.

Research Core also offers **agent collaboration instructions**: guidance for how the agent works
with you, including when to discuss scientific choices, how to preserve existing work, and how
to explain uncertainty and review results. Setup lets you inspect and adopt those instructions
without replacing your personal guidance.

The agent helps with the work; you remain responsible for scientific decisions and interpretation.

## Choose your packages

| Package | What it is for | Included examples |
|---|---|---|
| **Research Core** (`research-core`) | The common toolkit, included in setup. | Planning, data handling, debugging, code explanation and auditing, plotting and figure export, security setup, and session wrap-up. |
| **Single-cell Research** (`single-cell-research`) **In development** | Exploring marker genes and cell-type functions. | Currently includes marker research prompt preparation and report processing. |
| **Genome Annotation** (`genome-annotation`) | Looking up genes, making protein phylogenies, and assessing sequences. | Gene lookup, protein phylogeny, tree formatting, BUSCO, and HMMER. |
| **Yale Research** (`yale-research`) | Guidance for researchers using Yale services. | HPC setup and workflows, Globus transfers, and Yale Lux collections. |

During setup, the agent explains these choices, recommends packages relevant to your work, and
asks which to install. You can choose both scientific packages, add Yale Research if you use Yale
services, or start with Core and add others later.

Single-cell Research currently supports marker research prompts and report processing. A broader
single-cell analysis and plotting workflow is still in development. General plotting and figure
export are in Research Core. Genome Annotation's protein phylogeny workflow can be used on your
own sequences without first running a genome annotation analysis.

Scientific software and databases need their own setup; Yale services require your own authorized
access.

## Get started

### 1. Choose your client

Open Claude Code or Codex and sign in with your own account.

| You use... | Start here |
|---|---|
| **Codex Desktop** | Open a local project or a small setup folder and paste the prompt below. |
| **Claude Code** in a terminal, editor, or Desktop's Code tab | Paste the same prompt into your Claude Code session. |
| **Codex CLI** | Paste the same prompt into your Codex session. |

These instructions cover Claude Code and Codex. Claude Desktop's Chat and Cowork modes use
different plugin routes. Use the client you already have; Desktop setup does not require a
separate CLI installation. Official guidance:
[Claude Code](https://code.claude.com/docs/en/setup),
[Codex Desktop](https://learn.chatgpt.com/docs/app), and
[Codex CLI](https://learn.chatgpt.com/docs/codex/cli).

### 2. Set up your research plugins

Paste this into your chosen agent:

```text
Help me set up Research Plugins from
https://github.com/MusserLab/lab-claude-skills.

Read the README and verify the published release. Explain the available
packages and help me choose which to install. If I already use Lab Skills,
help me switch safely, preserving my customizations.

Show me the proposed changes before applying them. Then help me set up
the agent collaboration instructions and check that everything works.
```

Use the same starting prompt on macOS and Windows. The agent checks your system and follows the
appropriate steps. If a step cannot be completed, it should explain what remains.

Setup walks you through package selection, any transition from Lab Skills, a review of security
settings, and the agent collaboration instructions. It shows proposed changes and keeps a way
to restore your previous setup. Your personal instructions and project files are preserved.

<a id="moving-from-lab-skills"></a>

**Already using Lab Skills?** Setup helps you switch, preserving customizations and checking
replacement skills and security protections before disabling overlapping old copies.

### Agent collaboration instructions

You can choose whether to adopt these instructions. They go in a clearly marked `RESEARCH-CORE`
section of your active user instruction file: `CLAUDE.md` for Claude Code or `AGENTS.md` for Codex.
Setup resolves your actual configured file and shows a separate diff before changing it.
Personal guidance outside the section is preserved. These instructions guide how the agent
works with you; your project's methods and personal preferences stay in place.

### On Windows

Use the same setup prompt. The agent checks whether it runs natively on Windows or in WSL2,
which have separate installation and instruction files.

Native Windows setup uses a reviewed edit of the marked instruction section: show the exact
change, keep a backup, preserve the file's encoding and surrounding text, and verify the result.
This step does not require installing Python. An unavailable safe edit or check remains an unfinished step.

### 3. Check it in a fresh chat

Start a new chat and ask:

> Check that my selected Research Plugins and any agent collaboration instructions I adopted
> are active, and that old overlapping Lab Skills copies are inactive. Do not change anything.

Then try a small task, such as asking the agent to explain an existing script without editing it.

Repeat installation and setup for each client and execution host you use. Installing on your
laptop does not install anything on a cluster, and updating Codex does not update Claude Code.

## Everyday use

<a id="all-skills"></a>

| What you want to do | Something you can ask | Skills used |
|---|---|---|
| Plan an analysis | "Help me plan this analysis. Discuss the scientific choices with me before implementing it." | Core: `planning`. |
| Understand code | "Walk me through this script: its inputs, operations, assumptions, and outputs." | Core: `learn-code`. |
| Audit an analysis script | "Audit this analysis script for errors and explain your findings." | Core: `audit-script`. |
| Make and export an R figure | "Help me make this plot in R, then export it for review." | Core: `r-plotting-style`, `figure-export`. |
| Prepare a cell-type marker report | "Prepare a cell-type marker report: make a research prompt I can run in ChatGPT Pro or Claude Max." | Single-cell: `deep-research-genelist`. |
| Process completed marker reports | "Process these cell-type research reports into readable reports and summary tables." | Single-cell: `deep-research-reports`. |
| Make a protein phylogeny | "Make a protein phylogeny from these sequences." | Genome Annotation: `protein-phylogeny`; `tree-formatting` for display. |
| Finish a session | "Wrap up this work and record what changed and what remains." | Core: `done`. |

For cell-type marker research, the agent prepares a prompt from your dataset or marker results.
You run that prompt in your chosen research session, then bring the report back for processing
and biological review. The plugin does not automatically send your data to another service.

Ask **"How do I use these research plugins?"** for help and more examples. For a new project,
ask it to help record your environment, run commands, and project-specific methods in the
project's own instructions.

## Add packages later

Ask:

> Show me which Research Plugins I have and explain the other available packages.
> Help me add the ones I choose.

Or name the package: **"Add Single-cell Research to my existing setup."** The agent keeps your
existing choices and instructions and adds only what you select. You do not need to start setup
again.

## Updates

### Check what is new

> Check what is new in Research Plugins. Compare the published release with my installed
> versions and agent collaboration instructions, and summarize changes without changing anything.

This checks the published release as well as your installed versions; a cached catalog alone
does not show whether you are current.

### Update your plugins

> Update all Research Plugins I have installed from MusserLab/lab-claude-skills
> and check the agent collaboration instructions.
> Show me what will change first.

This covers every installed Research Plugins package from **this repository**. It also checks any
retained Lab Skills installation affected by the marketplace update. It preserves your
package selections and enabled/disabled choices. It does not install packages you have not chosen
or update unrelated plugins. An intentional release pin stays pinned unless you choose to move it.

An update checks two things:

- **Installed plugins:** their skills, examples, and helpers.
- **Adopted agent collaboration instructions:** changes are shown separately before updating the
  marked section of your user instructions.

The `research-core-setup` skill is the shared entry point for setup, help, adding packages,
checking what is new, and updates. Routine updates preserve personal instructions, do not repeat
completed legacy cleanup, and do not adopt instructions you previously declined.

If a package operation or verification fails, the agent reports what changed, what stayed
unchanged, and what is unknown. It stops before instruction changes until the package state
is resolved with you; it does not silently restore or replace anything.

Automatic package updates depend on your client and settings. Even when plugin files update
automatically, adopted agent collaboration instructions still need a separate check.

## Security setup

Research Core includes **`security-setup`** to help review protections for private folders,
credentials, original research data, and results you need to keep. Setup starts with your
client's native permissions and sandbox, preserves existing protections, and proposes targeted
changes for your approval.

Ask:

> Help me protect the private folders I identify, credentials, original research data,
> and retained results without opening private folders or credential contents.
> Preserve existing protections, show proposed changes, and test them with harmless test files.

Installing the plugin does not automatically block private folders or install security hooks.
Coverage depends on the app and tools being used. The agent should explain those limits,
check the relevant operations with harmless test files, and distinguish tested protections
from anything it could not verify. When moving from Lab Skills, verify replacement coverage
before deactivating old protections.

## Recovery and removal

### Return to a retained release

Ask:

> Help me recover my Research Plugins using a verified retained release.
> Show the affected packages, source, instruction changes, and way back before changing anything.

Recovery can affect several packages sharing a marketplace. Keep personal instructions,
package choices, and intentional pins. Codex reinstallation can re-enable disabled packages,
so their previous states must be recorded and restored through supported configuration.
Preview recovery of adopted agent collaboration instructions separately. Use a verified
retained tag or commit; do not edit installed caches or move an existing tag.

### Remove a package

Ask:

> Help me remove the Research Plugins I choose. Show the package changes and any separate
> removal of adopted agent collaboration instructions before applying them.

If you want the adopted `RESEARCH-CORE` section removed, do that while Core's setup skill is
still available, preserving all surrounding personal instructions. Uninstalling the plugin
does not remove that section, and removing the section does not uninstall the plugin.
Keep the marketplace while another installed package uses it.
Keep Research Core while you use any optional package.

## Report a problem or suggest an improvement

Ask the agent to **draft a plugin feedback report for your review**, or open an issue in the
[public GitHub issue tracker](https://github.com/MusserLab/lab-claude-skills/issues).

Include the plugin and version, client, operating system, what you expected, and what happened.
Use a small non-sensitive example. Remove credentials, personal paths, private data, and
unpublished results before posting.

Release information: [CHANGELOG](CHANGELOG.md),
[GitHub releases](https://github.com/MusserLab/lab-claude-skills/releases),
[maintainer compatibility record](docs/research-plugin-compatibility.md).
Official plugin documentation:
[Claude Code](https://code.claude.com/docs/en/discover-plugins),
[Codex](https://learn.chatgpt.com/docs/plugins).

## Manual commands

These optional terminal commands are for readers who prefer to manage packages themselves.
For guided setup and updates, use the prompts above.

### Manual installation

<details>
<summary>Terminal commands for an existing CLI</summary>

These are terminal commands, not prompts to paste into an agent. They assume a new marketplace
registration in the named client. If `musser-lab` is already registered, ask the agent to check
its source, installed packages, scope, and pins before changing it.
Run them on the host where the agent executes; Claude examples below use user scope.

Both clients use the published moving channel `codex/research-plugins-release`.
Verify the published release and matching inventory before installation.
An intentional fixed-release pin should stay pinned.

For **Codex CLI**:

```bash
codex plugin marketplace add MusserLab/lab-claude-skills --ref codex/research-plugins-release
codex plugin add research-core@musser-lab
codex plugin list
```

For **Claude Code CLI**, user scope:

```bash
claude plugin marketplace add "MusserLab/lab-claude-skills#codex/research-plugins-release" --scope user
claude plugin install research-core@musser-lab --scope user
claude plugin list
```

Install a chosen optional package with another `plugin add` or `plugin install` command,
replacing `research-core` with `single-cell-research`, `genome-annotation`, or `yale-research`.
Core and each selected optional package must be installed explicitly.

Then ask **"Set up Research Core, preserving my existing instructions."**
A different installation scope or client version needs its matching supported route;
check native help when syntax differs. Desktop uses its supported repository marketplace
route, which the agent should establish in your actual client.

</details>

### Manual updates

<details>
<summary>Terminal commands for an existing CLI installation</summary>

Use the matching commands for your existing source and scope. Keep an intentional pin pinned.
Before running them, check whether the shared marketplace operation would also affect a
retained Lab Skills installation and preserve its state.

For **Codex CLI**, the marketplace operation updates installed packages:

```bash
codex plugin marketplace upgrade musser-lab
codex plugin list
```

For **Claude Code CLI**, user scope, refresh the catalog and update every installed selected
package explicitly:

```bash
claude plugin marketplace update musser-lab
claude plugin update research-core@musser-lab --scope user
claude plugin list
```

Repeat Claude's `plugin update` for each installed optional package.

Afterward, ask **"Check whether my adopted agent collaboration instructions need updating."**
Package commands do not update that section of your user file. Start a fresh chat after changes.

</details>

### Manual removal

<details>
<summary>Manual package removal commands</summary>

For **Codex CLI**:

```bash
codex plugin remove research-core@musser-lab
```

For **Claude Code CLI**, user scope:

```bash
claude plugin uninstall research-core@musser-lab --scope user
```

Replace `research-core` with another selected package when removing it. These commands remove
packages only; they do not remove adopted agent collaboration instructions.

</details>
