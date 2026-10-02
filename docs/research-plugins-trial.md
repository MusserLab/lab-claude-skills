# Start the research-plugin trial

This is an opt-in first trial of the shared Claude Code/Codex toolkit. Keep your working setup
until its replacement has been checked. The repository's default branch and legacy `lab-skills`
1.12.1 plugin are not the trial channel.

## Check that the trial has been published

Use this page only after the maintainer confirms the
[research-plugins-trial-1 prerelease](https://github.com/MusserLab/lab-claude-skills/releases/tag/research-plugins-trial-1)
is available. Before publication that link will not resolve. Verify its tag/commit and the
[first-release inventory](../release/first-release.json); a missing release is a reason to stop,
not to substitute the default branch.

- Repository: `MusserLab/lab-claude-skills`.
- Moving trial channel: `codex/research-plugins-trial`.
- Initial immutable recovery ref: `research-plugins-trial-1`.
- Research Core `0.1.0-candidate.6`: common research workflow, setup, help and updates.
- Yale Research `0.1.0-candidate.1`: optional HPC, Globus and Lux procedures.
- Single-cell Research `0.1.0-candidate.1`: optional marker research and report processing.
- Genome Annotation `0.1.0-candidate.2`: optional gene lookup, phylogeny, tree formatting, BUSCO and HMMER.

The inventory's build-status sentence describes its original isolated build. The published
prerelease and retained programme acceptance record establish delivery and acceptance separately;
package versions and payload hashes in the inventory identify the unchanged accepted contents.

## Begin in the client and project you already use

Ask the agent to help install the trial. First it should identify your actual OS, client version,
execution host, native Windows versus WSL environment, and existing lab skills and instructions.
Read only the relevant current-client and project locations. Do not upload private files, copy
credentials or scan unrelated projects. A Windows terminal choice alone does not identify the
agent's environment. Keep personal skill customization out of this first setup unless existing
changes must be preserved during migration.

For old copied/imported skills or an existing plugin, compare names, origins and personal edits.
Keep a restorable copy outside active discovery before a reviewed switch, and account for any
import/refresh source that could bring duplicate old skills back. Preserve existing project methods
and relied-on protections. Do not simply delete everything or enable overlapping full toolkits.
Show the exact proposed changes and return path for the student's approval.

Install Research Core through the actual client's supported plugin interface or verified CLI.
Use the [repository commands](research-plugins.md#trial-repository-route) only for a matching client
and installation scope. Add the optional packages you need; Yale is included in this release but
HPC accounts, access and scientific programs are not installed merely by adding it. Verify actual
installed versions against the inventory. If the interface cannot install the trial, report that
specific step instead of changing client or host without discussion.

## Adopt the collaboration instructions

Ask **“Set up Research Core, preserving my existing instructions.”** The agent should show the
actual active user instruction destination and the complete diff. The shared block is bounded by
`<!-- BEGIN RESEARCH-CORE -->` and `<!-- END RESEARCH-CORE -->`. Everything outside it stays intact.
Useful existing guidance is retained; any conflict or proposed cleanup is explained separately.

**Native Windows:** do not run this release's instruction helper against your real instruction file.
It contains POSIX-dependent permission/directory-flush operations; Python versions before 3.13 also
lack its `os.fchmod` call. Use the setup skill's existing manual-preview route: read the installed
collaboration source, prepare the full exact block diff, retain a byte-for-byte backup, obtain
approval, then use the client's native file-editing tools and verify the block and every surrounding
byte. Stop without writing if exact preservation cannot be verified. No helper success is implied.
WSL is a separate environment; don't switch into it merely to avoid testing native Windows.
A future helper correction can be delivered through a normal package update.

Start a fresh chat and check that it finds the intended skills and adopted rules. Begin with one
small real task whose result you can inspect, such as explaining an existing script or reviewing a
small table without altering its inputs. Report which skills were used, what worked and what failed.
Broaden ordinary use after that first check; real scientific analyses retain their normal methods,
environments and substantive review.

## Updates, help and recovery

- Ask **“How do I use these research plugins?”** for help.
- Ask **“Update my research plugins, including their collaboration instructions.”** for a full
  update. It checks packages and separately reviews changes to the adopted block. Personal text
  outside it is preserved. Repeat for each client/host you use.
- If setup fails before a switch, keep using the existing setup. If a completed switch must be
  undone, use its recorded backup and package/source restoration steps. Uninstalling a plugin
  does not itself remove the collaboration block.
- Later trial updates can return to the immutable `research-plugins-trial-1` ref through the
  [retained-release procedure](research-plugins.md#return-to-a-retained-release). Preview all
  affected packages sharing the marketplace and preserve personal instructions. Never move the tag
  or edit installed caches to recover.
- Show problem reports to the maintainer before sharing private information. The
  [student guide](research-plugins.md#report-a-problem) explains sanitized public reports.

See [compatibility and evidence](research-plugin-compatibility.md) for actual checks. Both macOS
CLI lifecycles passed. Windows/Desktop, ordinary student use, real domain analyses and cluster
onboarding still need their own evidence; this trial does not claim those already work.
