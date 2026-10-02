# Install Research Plugins 0.1.0

Research Plugins are shared research procedures for Claude Code and Codex. Start with Research
Core, then select the optional packages you need. All four public packages are version `0.1.0`
and contain 33 skills in total; Yale Research is optional for users of Yale services.

## Check the release and choose your packages

Open the [Research Plugins 0.1.0 release](https://github.com/MusserLab/lab-claude-skills/releases/tag/research-plugins-0.1.0)
and verify its tag/commit and [release inventory](../release/first-release.json) before installing.
If the release or ref is missing, stop and ask the maintainer; do not substitute the default branch.
The inventory identifies versions, dependencies and payload hashes. Publication and programme
acceptance are recorded separately from the inventory's build status.

| Item | Selection |
|---|---|
| Repository | `https://github.com/MusserLab/lab-claude-skills.git` |
| Moving release channel for ordinary updates | `codex/research-plugins-release` |
| Immutable first-release ref for a deliberate pin or recovery | `research-plugins-0.1.0` |
| `research-core` | 23 skills: common research workflow, setup, help and updates. Install first. |
| `single-cell-research` | 2 skills: marker research and report processing. Optional. |
| `genome-annotation` | 5 skills: gene lookup, phylogeny, tree formatting, BUSCO and HMMER. Optional. |
| `yale-research` | 3 skills: HPC, Globus and Lux guidance. Optional; requires your own service access. |

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
Help me install Research Plugins 0.1.0 from
https://github.com/MusserLab/lab-claude-skills.git using the moving release
channel codex/research-plugins-release. First verify the published
research-plugins-0.1.0 release and its inventory. I want research-core;
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
Our macOS CLI checks do not establish Desktop, Positron, Windows or Linux behavior. External
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
  Repeat for each client and host you use; one installation does not update all others.
- If setup fails before a switch, keep the working setup. To undo an approved switch, use its
  recorded instruction backup and package/source restoration steps. Uninstalling a plugin does
  not itself remove the collaboration block.
- For deliberate recovery or pinning, use `research-plugins-0.1.0` through the
  [retained-release procedure](research-plugins.md#return-to-a-retained-release). Review every
  package sharing the marketplace. Never move the tag or edit installed caches to recover.
- Review reports before submission and remove private information; the
  [student guide](research-plugins.md#report-a-problem) explains sanitized public reports.

See the [student guide](research-plugins.md) for ordinary workflows and the
[compatibility record](research-plugin-compatibility.md) for dated evidence. The accepted candidate's
macOS CLI lifecycles passed; broader client/host checks and real scientific acceptance remain
separate from public release.
