# Research Plugin Compatibility and Evidence

> **Release and evidence: October 12, 2026.** Research Core 0.2.0, Genome Annotation 0.1.2 and
> Yale Research 0.1.2 are released for Claude Code and Codex. Single-cell Research remains 0.1.1.

The [README](../README.md) is the user guide. This record distinguishes content checks,
client operations, ordinary use, and scientific acceptance. An untested route is not an
unsupported platform; evidence for one client, version, or host does not establish another.

## Release versions

**Combined release (October 12):** Core 0.2.0 adds analysis distillation and review dashboards
(25 skills), plus readable-analysis/focused-testing guidance in three existing skills. Genome
Annotation 0.1.2 corrects HMMER GA advice; Yale Research 0.1.2 adds guided remote account login.
Single-cell Research remains 0.1.1. The 12 new resource/skill files retain the Dunn Lab license and
exclude private project history. Existing method/output safeguards, minimum Core dependencies,
setup/migration mechanics, catalogs and legacy payload remain unchanged. The optional collaboration
instructions gain the same readability/testing guidance; setup help names the new skills. Instruction
adoption remains a separately previewed operation.

Focused source/resource/link/privacy and refusal-path tests pass. The HMMER correction reuses four
passing HMMER 3.4 runtime cases: both search directions fail with missing required GA and succeed
with deliberately supplied fixture thresholds. These checks do not establish biological cutoffs.
A disposable macOS Codex CLI 0.149.0 profile installed Core/Genome/Yale: all 95 package-file hashes
matched, and the 33 expected namespaced skills appeared. Personal skills were also visible; this
checks package discovery, not isolated model behavior. Claude Code 2.1.290 strictly validated the
three plugin manifests (not all skill contents). The actual updated collaboration block passed
preview/apply, outside-byte/backup preservation, no-op and stale-target refusal checks in a fixture.
No model call or real-profile mutation ran for these release checks.

Earlier dated evidence remains applicable to unchanged behavior. New-skill model execution and
real student/cluster use remain unverified for this release.

| Package | Version | Scope |
|---|---|---|
| Research Core | 0.2.0, 25 skills | Analysis distillation, review dashboards and readable-analysis guidance |
| Single-cell Research | 0.1.1, 2 skills | Unchanged; **In development**, marker prompts and report processing only |
| Genome Annotation | 0.1.2, 5 skills | Corrected HMMER GA guidance |
| Yale Research | 0.1.2, 3 skills | Guided remote account login |

The reviewed release is on `main` and both existing moving research channels:
`codex/research-plugins-release` and `codex/research-plugins-codex-release`.
Its fixed release tag is `research-plugins-0.2.0`; earlier fixed releases retain their history.
Lab Skills 1.12.1 is permanently frozen and remains available for existing users with unchanged
runtime payload and retained releases. Publication does not migrate an installation. See the
[setup note for existing users](../README.md#moving-from-lab-skills).

## Release build - October 12, 2026

The source/export check matched all 108 selected release files, including all 105 package-file
hashes and both clients' wrappers. The reviewed Git index matched the same package hashes.
Single-cell Research, both catalogs, minimum Core dependencies (0.1.0) and legacy payload remain
unchanged. The 27 focused build/resource/source/scope/setup checks passed; unchanged behavior and
native update/recovery evidence were reused.

The current [release inventory](../release/first-release.json) SHA-256 is
`4780052ff7cf9a355f4005eedf49320a071d61ea54040aa176a9d17e60b26d4d`.

## Release build - October 10, 2026

The source/export check passed for four packages and 96 selected release files, including all
93 package-file hashes and both clients' wrappers. Relative to the previous research release,
optional-package records, legacy runtime payload and root catalogs were unchanged.
Main gains the previously released research-package catalog entries. Minimum Core dependencies
remain 0.1.0. Legacy documentation is labelled or redirected; its hooks and settings are unchanged.

The October 10 [inventory](https://github.com/MusserLab/lab-claude-skills/blob/research-plugins-0.1.2/release/first-release.json) SHA-256 is
`94eb4dccd5010b3385b5d31683876d172f6d6f147b0437621017201ac770da0d`.
This is build/content evidence, not a native 0.1.2 installation, setup, update, or discovery trial.

## Client routes and evidence

| Date and route | Demonstrated | Limits |
|---|---|---|
| October 1, 2026; macOS Codex CLI 0.149.0 and Claude Code 2.1.287 | Accepted 0.1.0 candidate: four-package install/update/recovery and instruction-preservation checks. | Disposable lifecycle checks, not ordinary research use or every platform. |
| October 5, 2026; macOS Codex CLI 0.149.0 | Source switching, changed upgrades, and retained 0.1.0 recovery; seven complete 93-file readbacks. Instructions and unrelated preferences preserved. | Routing fixtures, not a final native 0.1.1 installation. Reinstallation re-enabled a disabled package; explicit state restoration was needed. |
| October 5, 2026; macOS 14.4.1 arm64, Claude Code 2.1.289 | Exact public Core bytes updated 0.1.0 to 0.1.1; 38 files/23 skills matched. Retained/pinned recovery stayed 0.1.0; preferences and adopted instructions preserved. All four Claude manifests passed strict validation. | Other three 0.1.1 packages were not native-installed in that check. |
| October 8, 2026; participant-reported native Windows, bundled Codex CLI 0.160.0 | Approved marketplace upgrade succeeded in the verified existing Desktop home. Manifests and native plugin listing showed Core 0.1.1; retained legacy content, disabled choices, instructions, and configuration unchanged. | Participant-reported CLI update, not independent host inspection, Desktop UI operations, fresh-chat discovery, instruction adoption/update, helper execution, or recovery. |
| October 11, 2026; macOS arm64, Codex CLI 0.149.0 and Claude Code 2.1.290 | Exact published Core 0.1.1 → 0.1.2 update from a local Git fixture. All 48 selected Core/Single-cell files matched before/after; disabled choice and complete configuration/instruction bytes preserved. Later all-four install readbacks matched all 93 files per client. Installed helper preview/apply, stale-token refusal and no-op checks passed. | Disposable profiles, no real-account/remote-source installation or student migration. Claude optional installs warned of failed implicit refresh and used an already-current cache; the exact installed bytes were verified. Earlier unchanged immutable-ref recovery evidence was reused. |
| October 11, 2026; Codex CLI 0.149.0, fresh prompt rendering | Native catalog exposes 23 Core, 2 Single-cell, 5 Genome and 3 Yale skills, each matching the released skill hash. Personal skill registrations were excluded for this check. | No isolated model invocation: the disposable profile was not logged in. Catalog visibility alone does not prove instruction following or resource use. |
| October 11, 2026; Claude Code 2.1.290, Opus 5.5, installed-cache session loading | Natural-language Core help/code walkthrough selected the intended skills and read bundled help. Explicit Single-cell invocation refused unsupported `family_report2` before writes. Genome label inspection retained all three synthetic IDs, including an unmatched tip; Yale guidance kept unconfigured host/access facts unverified. | Read-only synthetic tasks through supported `--plugin-dir`; no package management by the model, tree rendering, remote service, scientific inference or student-use claim. A first restricted fixture omitted bundled-resource read access; the corrected Core check passed without denials. |
| October 11, 2026; synthetic supported Single-cell report | Claude selected the installed report skill, read bundled cleaning/CSS resources and wrote a processor. Lead execution produced raw/clean/HTML/TSV; independent readback preserved the original/header bytes, leading-zero ID, both distinct marker IDs with duplicate names, extra metadata, generation date and caveats. | Native Claude shell execution was denied by the restricted fixture; this is lead-executed processing, not autonomous model execution. A fixture assertion falsely failed on HTML line wrapping; parsed visible text confirmed all caveats without changing the outputs. No real biological interpretation was evaluated. |
| October 11, 2026; Claude Code 2.1.290, Opus 5.5 and Codex 0.162.0-alpha.17.2, GPT-6.1 Sol | Seven additional paired synthetic scenarios exercised audits, markers, rendering, project lifecycle, offline genome guidance, service boundaries and maintenance. All 93 installed files remained unchanged. Including earlier cases, 32 of 33 released skills have some paired targeted procedure evidence; the `new-plan` alias remains source-only. | Directed finite examples, not whole-skill certification. Figure rendering needed a different temporary R dependency set. Claude repeated the released HMMER factual error and overstated untested security coverage; those failures remain recorded. |
| October 11, 2026; native HMMER 3.4 in an existing macOS Conda environment | Four GA checks cover `hmmsearch` and `hmmscan`, each with absent and supplied thresholds. Missing required GA produced nonzero exit/diagnostics; supplied fixture GA succeeded with the expected hit. | Synthetic 120-aa fixture, one CPU; no scientific cutoff choice, real search, cluster run or post-correction model behavior test. |
| Desktop and editor interfaces | Use each client's supported repository marketplace route. | UI installation/update/recovery and editor discovery/reload not established by CLI trials. |
| Linux, WSL2, cluster, browser/cloud, or Claude Desktop Chat/Cowork | These need their own supported route and execution-host setup. | No complete Research Plugins lifecycle recorded here for these combinations. |

The October 11 checks establish the stated macOS CLI lifecycle and bounded paired behaviors.
They do not establish general Claude/Codex equivalence, real marker-report production, phylogeny,
BUSCO execution, real HMMER searches, external-service operations or scientific validity.
Rendering evidence applies to the successful temporary runtime, not the original failing setup.

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
