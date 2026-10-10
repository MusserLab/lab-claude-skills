# Research Plugin Compatibility and Evidence

> **Release record, October 10, 2026.** Research Core 0.1.2 is released for Claude Code
> and Codex. The optional packages remain 0.1.1.

The [README](../README.md) is the user guide. This record distinguishes content checks,
client operations, ordinary use, and scientific acceptance. An untested route is not an
unsupported platform; evidence for one client, version, or host does not establish another.

## Release versions

| Package | Version | Scope |
|---|---|---|
| Research Core | 0.1.2, 23 skills | Setup/help and update improvements |
| Single-cell Research | 0.1.1, 2 skills | Unchanged; **In development**, marker prompts and report processing only |
| Genome Annotation | 0.1.1, 5 skills | Unchanged |
| Yale Research | 0.1.1, 3 skills | Unchanged |

The reviewed release is on `main` and both existing moving research channels:
`codex/research-plugins-release` and `codex/research-plugins-codex-release`.
Its fixed release tag is `research-plugins-0.1.2`; earlier fixed releases retain their history.
Lab Skills 1.12.1 remains temporarily available with unchanged runtime payload; publication does not
migrate an installation. See the [setup note for existing users](../README.md#moving-from-lab-skills).

## Release build - October 10, 2026

The source/export check passed for four packages and 96 selected release files, including all
93 package-file hashes and both clients' wrappers. Relative to the previous research release,
optional-package records, legacy runtime payload and root catalogs were unchanged.
Main gains the previously released research-package catalog entries. Minimum Core dependencies
remain 0.1.0. Legacy documentation is labelled or redirected; its hooks and settings are unchanged.

The release [inventory](../release/first-release.json) SHA-256 is
`94eb4dccd5010b3385b5d31683876d172f6d6f147b0437621017201ac770da0d`.
This is build/content evidence, not a native 0.1.2 installation, setup, update, or discovery trial.

## Client routes and evidence

| Date and route | Demonstrated | Limits |
|---|---|---|
| October 1, 2026; macOS Codex CLI 0.149.0 and Claude Code 2.1.287 | Accepted 0.1.0 candidate: four-package install/update/recovery and instruction-preservation checks. | Disposable lifecycle checks, not ordinary research use or every platform. |
| October 5, 2026; macOS Codex CLI 0.149.0 | Source switching, changed upgrades, and retained 0.1.0 recovery; seven complete 93-file readbacks. Instructions and unrelated preferences preserved. | Routing fixtures, not a final native 0.1.1 installation. Reinstallation re-enabled a disabled package; explicit state restoration was needed. |
| October 5, 2026; macOS 14.4.1 arm64, Claude Code 2.1.289 | Exact public Core bytes updated 0.1.0 to 0.1.1; 38 files/23 skills matched. Retained/pinned recovery stayed 0.1.0; preferences and adopted instructions preserved. All four Claude manifests passed strict validation. | Other three 0.1.1 packages were not native-installed in that check. |
| October 8, 2026; participant-reported native Windows, bundled Codex CLI 0.160.0 | Approved marketplace upgrade succeeded in the verified existing Desktop home. Manifests and native plugin listing showed Core 0.1.1; retained legacy content, disabled choices, instructions, and configuration unchanged. | Participant-reported CLI update, not independent host inspection, Desktop UI operations, fresh-chat discovery, instruction adoption/update, helper execution, or recovery. |
| Desktop and editor interfaces | Use each client's supported repository marketplace route. | UI installation/update/recovery and editor discovery/reload not established by CLI trials. |
| Linux, WSL2, cluster, browser/cloud, or Claude Desktop Chat/Cowork | These need their own supported route and execution-host setup. | No complete Research Plugins lifecycle recorded here for these combinations. |

No native 0.1.2 lifecycle is claimed by any row. Package checks also do not establish real
marker-report production, phylogeny, BUSCO/HMMER execution, figure rendering, external-service
operations, or scientific validity.

<a id="participant-reported-windows-update---october-8-2026"></a>

## Native Windows instruction adoption

Native Windows and WSL2 are separate environments. Native instruction-helper compatibility
remains unverified; use the [reviewed manual instruction edit](../README.md#on-windows),
preserving encoding, surrounding text, and a backup with readback. Python installation is not
required for that route. Unavailable editing or preservation checks leave adoption unfinished.

<a id="retained-010-release-evidence"></a>
<a id="codex-routing-fixture---october-5-2026"></a>
<a id="claude-011-same-channel-update---october-5-2026"></a>
<a id="claim-boundaries"></a>

## Retained evidence

[CHANGELOG](../CHANGELOG.md) and the [release-history pointer](research-plugins-codex-candidate.md)
provide release context. Detailed earlier public checks remain at the retained 0.1.1
[compatibility record](https://github.com/MusserLab/lab-claude-skills/blob/research-plugins-0.1.1/docs/research-plugin-compatibility.md).
