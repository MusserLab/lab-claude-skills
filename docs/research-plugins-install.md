# Install Research Plugins

> **Research Plugins 0.1.1 for Claude Code and Codex.** Both use the shared release channel.
> Verify the exact release tag and matching inventory before installing.
> No existing installation or student source switch is authorized by this documentation.
> See the [0.1.1 release notes](research-plugins-codex-candidate.md) for scope and evidence.

Research Plugins are shared research procedures for Claude Code and Codex. Start with Research
Core, then select the optional packages you need. All four packages are version `0.1.1` in both
clients, with 33 skills in the selected set.
Optional packages accept Core `0.1.0` or later; Yale Research is optional for users of Yale services.
These new packages and the legacy all-in-one Lab Skills 1.12.1 plugin share one repository.
The legacy plugin stays on the default branch; its users are not migrated by this release.

## Check the release and choose your packages

For either client, verify the `research-plugins-0.1.1` release/tag, selected release ref and matching
[release inventory](../release/first-release.json) before installing.
If the release or ref is missing, stop and ask the maintainer; do not substitute the default branch.
The inventory identifies versions, dependencies and payload hashes. Publication and programme
acceptance are recorded separately from the inventory's build status.

| Item | Selection |
|---|---|
| Repository | `https://github.com/MusserLab/lab-claude-skills.git` |
| Shared moving release channel for ordinary updates in both clients | `codex/research-plugins-release` |
| Shared immutable 0.1.1 ref for a deliberate pin | `research-plugins-0.1.1` |
| Compatible moving alias for existing Codex installations | `codex/research-plugins-codex-release` |
| Retained immutable refs for an existing pin or reviewed recovery | `research-plugins-0.1.0`, `research-plugins-codex-0.1.1` |
| `research-core` | 23 skills: common research workflow, setup, help and updates. Install first. |
| `single-cell-research` | 2 skills: marker research and report processing. Optional. |
| `genome-annotation` | 5 skills: gene lookup, phylogeny, tree formatting, BUSCO and HMMER. Optional. |
| `yale-research` | 3 skills: HPC, Globus and Lux guidance. Optional; requires your own service access. |

The `codex/` prefix in the shared branch name is a historical Git label; that channel serves
both Claude Code and Codex.

This is a custom Git repository marketplace release. GitHub publication does not list it in
OpenAI's universal directory or install it in browser/cloud sessions; those are separate routes.
[Official packaging documentation](https://developers.openai.com/plugins/build/plugins).

## Start in Codex Desktop

Use the desktop client you already have. Current official documentation calls it the **ChatGPT
desktop app**, with **Codex** selected inside it. It is available on macOS and Windows, with a
Linux preview for supported distributions/architectures. Follow the
[desktop quickstart](https://learn.chatgpt.com/docs/app) or
[Linux installation guide](https://learn.chatgpt.com/docs/linux/linux-app) for your computer.
A separate Codex CLI installation is not a prerequisite for the Desktop workflow.

Sign in through the app's normal **Continue to sign in** browser flow using your own ChatGPT
account. Local Desktop, CLI and IDE work also supports API-key sign-in, but API usage is billed
separately and some workspace/cloud/OAuth-dependent features are limited or unavailable. Use your
normal ChatGPT sign-in for this guide; account entitlements and workspace controls still apply.
[Official authentication documentation](https://learn.chatgpt.com/docs/auth).

Open a local project or a small setup folder in Codex and paste this prompt:

```text
Help me install Research Plugins 0.1.1 from
https://github.com/MusserLab/lab-claude-skills.git using the moving release
channel codex/research-plugins-release. First verify the
research-plugins-0.1.1 release/tag, selected ref and matching inventory. I want research-core;
help me choose among optional single-cell-research, genome-annotation,
and yale-research before installing extras.

Identify my actual OS, client version, agent execution environment and
installation scope. Inspect only relevant existing plugin/skill origins
and instruction files, preserve personal edits and relied-on protections,
and explain any overlap. Do not read credential files, copy authentication,
scan unrelated projects or upload private files. Show the exact source/ref,
selected packages, changes, backups and return path before changing my setup.
Use this Desktop client's supported repository marketplace route; do not
install a separate CLI unless this environment actually requires it.
If musser-lab is already installed, inventory every package using it.
Existing Research Plugins installations on the shared moving channel or
Codex moving alias can use an ordinary update without switching sources.
Keep intentional pins pinned. If a source/ref change is needed, show the
exact switch for approval and preserve enabled/disabled choices, unrelated
preferences and any relied-on legacy protections through reinstallation.

Then set up Research Core, preserving my existing instructions. Show the
active instruction destination and complete RESEARCH-CORE block diff for
review. On native Windows, do not run the instruction helper against my real
file; use the documented exact-block manual backup/edit/readback route.
After approved changes, verify installed versions and surrounding instruction
bytes, then help me check discovery in a fresh chat with one small task.
```

The documented Desktop route discovers a reviewed checkout's `.agents/plugins/marketplace.json`
when opened as a project. The agent can prepare the exact release checkout and help install its
selected entries from **Plugins**. A supported native Git marketplace interface is another route;
verify its ref support in the actual client. [Official repository marketplace guidance](https://developers.openai.com/plugins/build/plugins).

Codex plugins are currently available in Desktop and CLI. Official guidance says they are not
available in the IDE extension; an editor terminal running the CLI is a CLI route.
[Official plugin surfaces](https://learn.chatgpt.com/docs/plugins).

## Preserve your current setup and adopt the instructions

The agent inventories old copied/imported skills and installed plugins, compares their origins
and personal changes, and keeps a restorable copy outside active discovery before an approved
switch. The existing `lab-skills` 1.12.1 plugin shares the marketplace name and includes hooks and
security behavior. Review all affected packages and relied-on protections before changing its
source or removing overlap; no blanket switch or uninstall is implied.

Existing Research Plugins installations on `codex/research-plugins-release` can update from 0.1.0
to 0.1.1 through each client's ordinary update route. Existing Codex installations on
`codex/research-plugins-codex-release` can also update normally; there is no required switch to
the shared channel. Keep an intentional tag/commit pin pinned. For a requested Codex source/ref
change, deliberate pin, migration or recovery, use the reviewed
[Codex marketplace source-switch procedure](research-plugins.md#switch-an-existing-codex-marketplace).
Claude Code pinning and recovery use the matching client route in the
[retained-release procedure](research-plugins.md#return-to-a-retained-release).
Review every installed package using `musser-lab` and preserve enabled/disabled preferences;
Codex reinstallation otherwise re-enables disabled packages.

Research Core adopts only the block between `<!-- BEGIN RESEARCH-CORE -->` and
`<!-- END RESEARCH-CORE -->` in the active client's user instruction file. Review the exact
file path and complete diff before writing. Personal and project guidance outside the block
is preserved. Installing a plugin does not itself adopt the block or grant permissions.

**Native Windows:** do not run this release's instruction helper against your real instruction
file. Its POSIX-dependent permission/directory-flush operations are not verified on native Windows.
Use the setup skill's manual-preview route: read the installed collaboration source, prepare the
full exact block diff, retain a byte-for-byte backup, obtain approval, use the client's native
file-editing tools, then verify the block and every surrounding byte. Stop without writing if
exact preservation cannot be verified. This is a reviewed manual adoption, not helper success.
Windows native and WSL2 are separate agent environments; the integrated terminal's shell does not
identify which agent is running. [Official Windows guidance](https://learn.chatgpt.com/docs/windows/windows-app).

Start a fresh chat after installation and adoption. Ask it to explain a small existing script or
review a small table with unchanged inputs, and check which skills and instructions it finds.
The October 5 routing checks used macOS Codex CLI 0.149.0 fixtures, not final 0.1.1 native
installation. They do not establish Desktop, Positron, Windows, Linux or cluster behavior. External
scientific programs, databases, account access and project methods remain separate setup
requirements. Installation alone does not establish scientific validity or toolchain readiness.

## Claude Code, terminal use, updates and recovery

For Claude Code or an existing Codex CLI installation, use the matching
[repository commands](research-plugins.md#release-repository-route). Install Core and each selected
optional package explicitly; dependencies are not automatically installed. Then ask
**“Set up Research Core, preserving my existing instructions.”**

- Ask **“How do I use these research plugins?”** for help.
- Ask **“Update my research plugins, including their collaboration instructions.”** for a full
  update. It checks installed packages and separately previews changes to the adopted block.
  Both clients follow the shared moving channel; existing Codex alias installations can keep it.
  An ordinary marketplace upgrade does not rewrite an adopted `RESEARCH-CORE` block.
  Repeat for each client and host you use; one installation does not update all others.
- If setup fails before a switch, keep the working setup. To undo an approved switch, use its
  recorded instruction backup and package/source restoration steps. Uninstalling a plugin does
  not itself remove the collaboration block.
- For a deliberate 0.1.1 pin in either client, use `research-plugins-0.1.1`. Existing
  `research-plugins-codex-0.1.1` and `research-plugins-0.1.0` pins stay fixed. A requested return
  to a retained tag uses the
  [retained-release procedure](research-plugins.md#return-to-a-retained-release), including
  preference restoration after Codex reinstall. Review every package sharing the marketplace.
  Never move the tag or edit installed caches to recover.
- Review reports before submission and remove private information; the
  [student guide](research-plugins.md#report-a-problem) explains sanitized public reports.

See the [student guide](research-plugins.md) for ordinary workflows and the
[compatibility record](research-plugin-compatibility.md) for dated evidence. Retained 0.1.0 macOS
CLI lifecycles and the October 5 Codex routing fixtures passed. A separate macOS Claude Code
2.1.289 fixture updated Research Core from exact public 0.1.0 to 0.1.1 on the same moving ref,
matching all 38 package files and preserving seeded preferences and adopted instructions.
All four 0.1.1 Claude manifests passed strict validation. Retained-tag recovery and a subsequent
pinned update stayed at 0.1.0; cleanup removed registrations and stopped the fixture server.
The other three packages were not native-installed. Codex final 0.1.1 installation,
broader client/host checks and real scientific acceptance remain separate from public release.
