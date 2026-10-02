# Research plugin compatibility and evidence

> **Research Plugins 0.1.0, 2026-10-01:** all four public packages contain 33 skills. Phase 1
> was accepted with the limits recorded below; normal public release was subsequently authorized.
> The accepted candidate's four-package macOS CLI install/update/recovery and instruction-preservation
> checks passed. Desktop, Windows/Linux, ordinary student use and real scientific execution remain
> separate evidence targets. Use the [installation quickstart](research-plugins-install.md).

The [release inventory](../release/first-release.json) identifies all four packages at `0.1.0`.
Its SHA-256 is `5cf8048f2b4bfee979e18ec4050a4044b5386dfd743c7ecf59576a7404e37dcf`.
The release build changed eight client manifest versions and the inventory; all 85 procedure/resource
files remained unchanged. Exact build/export checks passed. Candidate hashes below describe their
historical snapshots, not this release inventory. Verify actual GitHub release/tag publication
before installation; build, publication, client use and scientific acceptance are separate records.

Compatibility has two dimensions: the computer/interface where the client runs and the execution
host used for scientific commands. Evidence for one combination does not establish another.

## Current Codex availability and release limits

Official client guidance was fetched on 2026-10-01. Availability is distinct from a lab test:

| Interface | Current official route | Research Plugins evidence/limit |
|---|---|---|
| Desktop on macOS | The current [desktop guide](https://learn.chatgpt.com/docs/app) names the ChatGPT app with Codex mode and an Apple Silicon download. | No package lifecycle test in Desktop; use the quickstart's reviewed repository route. |
| Desktop on Windows | [Native PowerShell/sandbox or WSL2](https://learn.chatgpt.com/docs/windows/windows-app); agent and terminal settings are separate. | No native Windows test. Use manual exact-block instruction adoption; do not execute the helper against real instructions. |
| Desktop on Linux | [Preview](https://learn.chatgpt.com/docs/linux/linux-app) for supported Ubuntu, Debian, Fedora and Arch desktop distributions, x64/ARM64. | No Linux Desktop or helper lifecycle test. |
| Codex CLI | [CLI installation](https://learn.chatgpt.com/docs/codex/cli) and [Windows native/WSL guidance](https://learn.chatgpt.com/docs/windows/windows-sandbox). | 0.149.0 macOS candidate lifecycle passed. Windows, WSL2 and generic Linux remain untested. |
| IDE extension, including a proposed Positron route | [Official plugin guidance](https://learn.chatgpt.com/docs/plugins) currently says plugins are unavailable in the IDE extension. | Use Desktop or CLI for these plugins. An embedded terminal is a CLI route; no Positron integration claim. |
| Browser/cloud | Local Git marketplace installation is a separate distribution context. | No browser/cloud import or execution check; local install supplies no cloud deployment. |

Use your own ChatGPT account through the normal browser sign-in flow. Local Desktop, CLI and IDE
also support API keys, with separate API billing and limited workspace/cloud/OAuth-dependent
features. Codex cloud requires ChatGPT sign-in. [Official authentication](https://learn.chatgpt.com/docs/auth).
No credential copying or authentication-file reads are needed for this release setup.

Custom Git/repo marketplaces are separate from OpenAI's universal directory. Desktop can discover
the checkout's repository catalog; CLI supports named Git refs. The compatibility manifest remains
supported. [Official packaging documentation](https://developers.openai.com/plugins/build/plugins).
Exact minimum OS builds not specified by the fetched overview pages should be checked through the
current installer for the student's computer; no broader hardware compatibility is inferred.

The first interfaces requested in the joint review are Claude Code and Codex terminals, their
requested Positron routes, Codex Desktop and Claude Desktop. No full combination matrix is
implied: prioritize the routes students actually use and record the execution host separately.
Anthropic distinguishes the [Desktop Code tab](https://code.claude.com/docs/en/desktop) from
[Cowork and Chat plugin use](https://support.claude.com/en/articles/13837440-use-plugins-in-claude).
The intended Claude Desktop mode is awaiting clarification; this record does not claim our current
setup helper works in all three. Record account-synced versus directly installed marketplace
plugins explicitly rather than assuming a common installation/update path.

Claude Science is a future target added in the same review, with no confirmed current lab use.
As checked on 2026-09-30, its [skills documentation](https://claude.com/docs/claude-science/connectors-and-skills#skills)
describes custom skill uploads and GitHub imports. That establishes a route to evaluate, not support
for this complete plugin, its instruction helper or native update/recovery workflow. Evaluate before
the first proposed lab adoption; this target does not hold the first release for demonstrated routes.

## Retained candidate checkpoints and interface targets

The following table retains candidate-stage evidence and then-proposed targets. Pending statements
are historical to their checkpoints. The release summary and current availability table above govern
today's claims; no candidate test has been relabelled as a new 0.1.0 Desktop or scientific run.

| Client, interface and host | Status | Evidence now | Smallest next evidence |
|---|---|---|---|
| Codex CLI 0.149.0 and Claude Code 2.1.287, macOS, all four current candidates | Current native lifecycle verified | Both install all 93 package files exactly; changed Git v1→v2 update, same-profile retained-v1 recovery and pin preservation pass. Installed helpers preserve unrelated instructions through setup/update/rollback/removal; registrations removed and loopback service stopped. | Ordinary student/model use, real remote authentication, automatic activation and other interfaces/hosts remain unverified. |
| Claude Code 2.1.287, Core candidate.6 via `--plugin-dir` | Prompted output-review composition verified | Actual Opus 5.5, requested xhigh; data-handling/done read a fixed four-row result, explained input/version choice and newer alternative, saved review/ordinary docs plan with human acceptance pending. Lead ran the producer; restricted Claude shell attempts were denied. | Fully autonomous execution in that harness and ordinary interactive `.claude/` plan editing remain unverified; no student-use claim. |
| Core candidate.6 on macOS | Student-owned delegation guidance built and checked | Existing checks pass; disposable CLAUDE.md and AGENTS.md lifecycle preserves personal permission; native Claude manifest validation and all source/export hashes pass. Bounded Opus wording review informed lead corrections. | Optional-permission discovery, actual student choice and cross-client invocation remain unverified; scoped current Core output-review behavior is recorded above. |
| Genome candidate.2 on macOS | Agreed interpretation/privacy corrections checked | Unknown-taxon classification and explicit upload-mode fixtures pass; BUSCO stops on an unspecified lineage and accepts a configured choice. Source/export agreement and strict Claude manifest validation pass. | Full rendering, real scientific runs, service/API compatibility and complete Phase 1 acceptance remain unverified. |
| Codex CLI 0.149.0 on macOS, Core candidate.5 + Genome candidate.2 | Local install/readback/removal verified | Disposable home, all 67 installed hashes match; both packages and catalog removed. No account/model session. | Model composition, moving-channel update/recovery and intended student interfaces remain unverified. |
| Genome candidate.1 + unchanged Core/Yale/Single-cell on macOS, historical | Build/export and focused repair checks verified | 33 skill headers, 93 package files/96 selected release files; identity/rerun/wrapper fixtures and strict Claude Genome manifest/catalog validation pass. Earlier three package records match exactly. | Resolve BUSCO interpretation, unmatched-taxon labels and anonymous-upload behavior; real scientific runs, full rendering and service compatibility remain unverified. |
| Codex CLI 0.149.0 on macOS, Core candidate.5 + Genome candidate.1, historical | Local install/readback/removal verified | Fresh disposable home; all 67 installed package-file hashes match; both removed and catalog unregistered, with final installed/available lists empty. No account/model session. | Model composition, actual scientific execution and current moving-channel update/recovery remain unverified. |
| Single-cell candidate.1 + unchanged Core/Yale on macOS | Build/export and focused integration verified | 28 skill headers, 64 package files/67 selected release files; metadata preservation and both ordinary family schemas checked against bundled templates; strict Claude manifest/catalog pass. | Real dataset-to-prompt and report rendering/summary workflow; scientific acceptance remains separate. |
| Claude Code 2.1.286 CLI on macOS, Core + provisional genelist component | Marker-prompt behavior exercised | Max Sonnet/xhigh (observed claude-sonnet-5-5) naturally selected genelist. Five synthetic rows became three after filtering, then two annotated rows with both same-name IDs retained. No writes, computation or research service. | Only the genelist component was loaded. Two later routing/profile clarifications were diff-reviewed; full final two-skill composition remains untested. |
| Codex CLI 0.149.0 on macOS, Core candidate.5 + Single-cell candidate.1 | Local install/readback/removal verified | Fresh disposable home; all 48 installed package-file hashes match; both removed and catalog unregistered. No account/model session. | Model behavior, real report execution and moving-channel update/recovery remain unverified. |
| Core candidate.5 + Yale candidate.1 on macOS, earlier same-version check | Build/export verified | 14 existing Core/helper tests; 26 skill headers; 54 package files/57 release files and source hashes match; strict Claude manifests/catalog pass; retained helpers pass syntax checks. | Retain scoped evidence; complete the current lifecycle and intended student-route trial before advertising support. |
| Claude Code 2.1.286 CLI on macOS, Core candidate.5 + Yale candidate.1 via `--plugin-dir` | Incremental onboarding guidance exercised | An ordinary add-McCleary request selected Core setup then HPC and read the bundled onboarding/resource-learning guides. It preserved the fixture's Bouchet setup and left account access pending. Only supplied fixture/resource reads and skill calls occurred; bytes unchanged. | Real account/SSH/compute/client setup requires an authorized host trial. This is no installed-cache or student-use result. |
| Codex CLI 0.149.0 on macOS, Core candidate.5 + Yale candidate.1 | Local install/readback/removal verified | A fresh disposable home installed Core candidate.5 and Yale candidate.1 from the candidate catalog; all 54 cached-file hashes matched. Both were removed and the catalog unregistered. No account/model session ran. | Fresh model behavior and current moving-channel update/recovery remain unverified. |
| Candidate.4 package structure on macOS, historical | Build/export verified | All 14 existing build/helper tests and exact exporter comparison passed; 23 skills and 38 package files match the manifest. No new native structural-validator pass is claimed. | Complete supported structural validation and the remaining installed-cache lifecycle before claiming current native support. |
| Claude Code 2.1.286 CLI on macOS, candidate.4 direct `--plugin-dir`, historical | Natural-language help discovery exercised in a bounded trial | An ordinary help/update question selected `research-core:research-core-setup`, read its bundled guide and explained package plus adopted-instruction updates. No personal instructions loaded and no setup/update/write attempt occurred; only read/skill tools were available. | Test action requests and the native installed-cache lifecycle separately; this does not establish Codex help discovery or ordinary student use. |
| Candidate.3 package structure on macOS, historical | Build/export verified; public validator rerun unavailable | All 14 existing build/helper tests and exact exporter comparison passed. The manifest matches 37 package files and 23 skills. Private-catalog structural validation passed; the validator path was unavailable at the subsequent public check. | Recheck the public wrapper with an available supported validator, then verify an authorized native installation and fresh-task workflow before claiming current native support. |
| Codex candidate.2 package structure on macOS, historical | Structurally validated; native lifecycle unverified | The structural validator accepted the frozen 28-skill, 43-file package. The 14 build/helper tests and exporter `--check` also passed. No fresh candidate.2 native install, prompt or cache trial ran. | Use the current candidate route above; retain these candidate.2 results as historical evidence. |
| Claude Code 2.1.283 CLI on macOS, candidate.2 direct `--plugin-dir` history | Prompted composition exercised; installed-cache lifecycle unverified | Max Sonnet at xhigh showed 28 namespaced skills in `/context` with no personal instructions. After explicit invocation, `research-core:data-handling` and `research-core:done` composed accurately on a committed synthetic producer and preserved source, input and output bytes. The fixture denied automatic plan-record editing, so closeout was partial and acceptance remained pending. | Complete the native installed-cache lifecycle separately. A plan-edit trial needs the supported interactive approval route: an exact file permission alone did not allow this path in restricted mode. |
| Codex CLI 0.149.0 on macOS, candidate.1 history | Historical native lifecycle exercised | Candidate.1 local-catalog install matched all 53 manifest files; prompt input listed all 29 skills. Its helper setup/removal, moving-channel update, immutable-ref return and uninstall passed in disposable profiles. | Do not transfer this result to the current candidate; use the current-candidate check above. |
| Claude Code 2.1.268 CLI on macOS, candidate.1 history | Historical local install/removal exercised; Git update/recovery unverified | Candidate.1 local-catalog install matched all 53 manifest files; component inventory listed 29 skills. Helper setup/removal and uninstall passed. The static Git fixture could not serve Claude's shallow clone. | Do not transfer this installed-cache result to the current candidate; use an authorized Git source for any future update/recovery check. |
| Codex desktop on macOS | Unverified | CLI evidence does not establish desktop marketplace, setup or update behavior. | Use a disposable profile to install from the authorized candidate, verify discovery and instruction destination, update/read back, remove, and confirm no personal library leakage. |
| Claude Code in Positron on macOS | Requested; unverified | Claude CLI evidence does not establish the actual extension/integration, editor UI or reload behavior. | Verify the supported integration and where its agent runs, then exercise isolated install/readback, setup preview, discovery, update, reload and removal. An embedded terminal alone supplies CLI evidence. |
| Codex in Positron on macOS | Requested; unverified | No Codex Positron integration, plugin discovery or instruction-target check. | Verify the actual supported integration/version and execution host, then check discovery, instruction destination, update and recovery in that route. |
| Claude Desktop | Requested; tab/runtime unresolved and unverified | No candidate check in the app. Code, Cowork and Chat have distinct execution and instruction contexts; a CLI pass does not cover them. | Confirm the intended mode, then establish installation source, execution host, available tools and instruction destination before the bounded lifecycle check. |
| Claude Science | Future target; unverified | Official documentation describes custom skill upload and GitHub import; no lab candidate import, bundled-resource, instruction or lifecycle check has run. | Before first proposed lab adoption, check actual import format, resource access, instruction context, execution/provenance behavior and update/recovery. Reuse shared procedure sources; do not assume the Claude Code plugin/setup route applies. |
| Windows native | Selected first trial target; execution unverified | Static review: instruction helper uses os.fchmod (Windows support added in Python 3.13); directory open/flush behavior also needs a real Windows check. No student/native Windows execution evidence. | First identify actual Desktop version, agent environment, Python and old skill origins. Verify the helper on disposable files before instruction adoption, plus install/discovery/update/recovery. |
| Windows with WSL | Unverified | WSL has a separate Linux home, shell, credentials and installed state; native Windows evidence would not cover it. | Test inside the selected WSL distribution and separately record any Windows editor/remote bridge used to reach it. |
| Generic Linux CLI | Unverified | No generic Linux installation or local scientific-runtime check for the current packages. | Install in a disposable Linux profile, verify manifests/resources, instruction path, fresh-task discovery, update and removal without Yale filesystem assumptions. |
| Bouchet | Unverified | No Phase 1 cluster access, installation, authentication or execution check. | With explicit cluster scope, use a disposable profile to test the selected client, marketplace access, instruction path and one package-discovery task; test HPC guidance separately in an appropriate allocation. |
| McCleary | Unverified | Bouchet assumptions have not been shown to carry over. | Repeat the bounded install/discovery/path check on McCleary and verify its own modules, scheduler/resource guidance and storage assumptions. |
| AICR | Unverified | No AICR account, allocation, environment, storage or package route has been checked. | Repeat the bounded install/discovery/path check and verify AICR-specific access and execution assumptions before advertising support. |
| Private Musser Lab Style or Sponge Corpus | Unavailable in this candidate | No private distribution has been selected or released in this candidate. | Select and review an authorized private distribution first; then test member authentication, explicit package install/update, missing-access behavior and private issue routing. |

## Accepted candidate: four-package lifecycle and Core review — 2026-10-01

Tested payload: Core candidate.6, Yale candidate.1, Single-cell candidate.1, Genome candidate.2;
33 skills and 93 package files. Release inventory SHA-256:
`eeba0dbe8cf80908174f8255ed9d32805a076d7b62c553af9ad7e1e3188ee034`.
Both native macOS clients installed all four packages with zero missing, extra or mismatched files.
No model/account request was used for package management and no credentials were copied.

A loopback Git smart-HTTP fixture replaced the earlier unsuitable static server. Claude's shallow
clone worked. Only a fixture Core version and disposable instruction comment differed between v1
and v2. Each client's same existing profile installed v1, updated to changed v2, removed all four
packages/catalog and reinstalled the retained v1 tag while the moving branch stayed at v2. All 93
files matched at each stage; a later update stayed pinned. Codex uses `--ref`; Claude uses the Git
URL `#ref` form. The ref selects the complete catalog, so selected packages were restored coherently.
These fixture tags are not published release refs.

Native updates/recovery left adopted instruction files unchanged until the installed helper's
separate preview/token-approved action. Setup, changed block update, rollback and removal preserved
unrelated instruction bytes and first backups. Unrelated settings values were preserved; Claude
rewrote its settings serialization, so whole-settings-file byte identity is not claimed. Final
registrations were empty. Claude retained inactive orphan cache files in the disposable profile;
the loopback listener was stopped. No normal student/personal profile changed.

The separate Core model check used actual Opus 5.5 through Claude Max with native plugin loading.
A fixed, checkpointed four-row producer yielded A n=2 mean=3 and B n=2 mean=8. Restricted/dontAsk
refused its Claude shell execution, including one corrected exact-command attempt; the lead ran
the producer under the authorized fixture scope. Claude then used data-handling and done to review
the actual inputs/outputs, explain why frozen v1 remained appropriate despite an unadopted newer
calibration proposal, and save/read back an ordinary docs review/plan. Human acceptance remained
pending. This is prompted composition plus lead execution, not a fully autonomous Claude run.
The earlier `.claude/` restricted-mode plan-edit limit remains separate.

Codex's isolated model trial still needs the user's supported native sign-in. No credentials are
copied or linked to make it pass. Broad desktop/IDE/Windows/cluster support and real domain science
remain outside this evidence. Jacob subsequently accepted Phase 1 on 2026-10-01 with these limits.
Normal public release was subsequently authorized. Student adoption and later scientific phases
retain their own scope and acceptance; the technical trial did not itself authorize them.

## Retained Core candidate.6 evidence

Core remains 23 skills and 38 package files. The four-package export remains 33 skills,
93 package files and 96 selected release files. Manifest SHA-256:
`eeba0dbe8cf80908174f8255ed9d32805a076d7b62c553af9ad7e1e3188ee034`.
Only Core's version, collaboration body and setup/help changed; the instruction helper,
other package payloads/versions, catalogs and legacy plugin are unchanged. Optional-package
release records now name the tested Core candidate.6 dependency.

The existing 60 checks passed. A focused disposable fixture used the unchanged helper to set up,
update, repeat, recover and remove the managed block in both CLAUDE.md and AGENTS.md, preserving
the exact personal-permission text outside it. The fixture used the initial draft collaboration
body; later wording corrections do not change the helper or preservation mechanism.
Final setup metadata parses and includes the new request. Claude Code 2.1.287 strict Core manifest
validation passes; the exporter and all recorded source/release hashes match.

A bounded no-tools review through Claude Max observed Opus 5.5 against the three draft guidance
files. Its consent, persistence, revocation and billing-route suggestions were adjudicated and
narrowly incorporated by the lead. This was static text review, not installed skill discovery or
execution. No final native model trial, actual student instruction adoption or cross-client launch
is claimed. Reuse earlier installation and helper evidence only within its stated scope; complete
current update/recovery and intended student-interface checks remain ahead.

## Retained Genome candidate.2 evidence

The preceding Core candidate.5 / Genome candidate.2 manifest SHA-256 was `fdcf0f1cb4f5a6bea8bd21583e4affaa4800ba9ddcd00fd4bf80c690f1c65a36`.
Genome candidate.2 implements the three approved corrections: appropriate-lineage completeness
interpretation, visible Unclassified taxonomy, and explicit anonymous iTOL selection. Focused checks
exercise the actual R classification and Python upload control flow with local stubs; no network or
scientific computation is involved. Two BUSCO setup-choice checks failed before repair and passed
afterward, stopping before any environment or download work when no lineage is selected.

That export had 33 skills, 93 package files and 96 selected release files. In that increment only Genome
changed version/content; Core, Yale and Single-cell remain identical. Claude's strict Genome manifest
validation and exact export comparison pass. Codex installed Core plus Genome candidate.2 in a fresh
disposable home, matched all 67 files, then removed both and unregistered the catalog. The three
review choices are resolved; the full updated Phase 1 acceptance and broader compatibility remain
open. Existing odb10 examples and tool environments are preserved; newer BUSCO/dataset compatibility
is not inferred from refreshed documentation.

## Retained Genome candidate.1 evidence

The earlier manifest SHA-256 was `f0cd7b7a6f89859dde5614262057307f1c447818e91f7bd1bb29e179d997e3ea`.
Genome candidate.1 adds five skills and 29 package files; the complete candidate contains 93 package
files and 96 selected release files. Core, Yale and Single-cell package records and bytes are
unchanged. Claude Code 2.1.286 strict validation passed for the Genome manifest and current catalog.
Codex CLI 0.149.0 installed Core plus Genome in a disposable home, matched all 67 file hashes, then
removed both and unregistered the catalog. No model/account trial or normal-profile mutation ran.

Eight identity/preview checks passed, including actual R-template consumers of missing, duplicate
and numeric accession labels. Three phylogeny checks passed for fresh output, occupied-output refusal
and a separate second run. Fourteen initial BUSCO/HMMER fixture checks passed; five overlapping
changed-path checks passed after privacy/example-order corrections. These use small fixtures and
stubbed external tools, not real scientific execution. Published Python blocks and relevant R/shell
code parse. No full tree rendering, BUSCO/HMMER/phylogeny run, external database download or iTOL
upload/API trial ran. BUSCO interpretation, unmatched-taxon labels and anonymous-upload behavior
were open review points in candidate.1 and are resolved by the candidate.2 correction above.
Technical packaging evidence does not establish scientific validity or service compatibility.

## Retained Single-cell evidence

The earlier three-package manifest SHA-256 was
`fb1b452677acf954cece5962d0ee714b9c73f93bcd50878f5b4e6c87efa36c9c`.
Single-cell candidate.1 contains two skills and ten package files. Focused fixtures exercise actual
report-cleaning code and headers derived from the bundled cluster/family templates, including legacy
family compatibility and explicit rejection of ambiguous metadata. These checks establish metadata
preservation and mechanical compatibility, not the truth of cell-identity or evolutionary claims.

The Claude trial used a completed synthetic marker table, not an atlas calculation. Four tested
resources match the final package; the main genelist instruction subsequently received two narrow
profile/routing clarifications. No full final two-skill model trial, report rendering or summary-file
execution is claimed. Codex verified the final local installation and removal, with all 48 Core and
Single-cell file hashes matching. Reuse the separate unchanged Yale lifecycle evidence below.

## Retained Core/Yale evidence

Core candidate.5 keeps 23 skills and 38 package files. Yale candidate.1 adds HPC, Globus Transfer
and Lux Collections with 16 package files; the combined export has 57 selected release files.
Core setup/help routes first cluster setup and later additions to the HPC guide. Conditional Core
closeout and HPC job guidance capture useful resource observations in project/private records.
The helper and collaboration body are unchanged from candidate.4.

The earlier Core/Yale-only manifest SHA-256 was
`11eaf14b9f75e1a5647e8f80b745fbd62c57dc93db8ed79c991b906f067de4ee`.
Both native clients received the same selected resources. The Codex local-cache test established
current package installation, byte agreement and removal. The Claude Max rehearsal requested
Sonnet/xhigh, observed claude-sonnet-5-5, and used only read/skill tools with personal instructions
excluded. It followed the incremental onboarding route while keeping pending account access,
remote client setup and actual installation state explicitly unverified. These checks do not prove
real SSH, key registration, a running job or scientific tool behavior.

YCRC partition/GPU documentation was refreshed on 2026-10-01. Static resource requests remain
starting estimates. Inherited Positron version/platform observations and YCGA policy facts were
not freshly validated; use the referenced current site/client guidance before those operations.
Globus and Lux external services were not exercised. Full current update/recovery, Codex model
behavior, native editor/desktop, Windows/WSL and cluster routes remain unverified.

## Historical candidate.4 evidence

Candidate.4 is `research-core` version `0.1.0-candidate.4`: the same 23 skills, now with 38 package
files and 41 selected release files. One bundled help resource and setup-skill routing implement
the agreed distinction between explanations, status inspection and full updates. The collaboration
body, instruction helper and other procedures are unchanged from candidate.3.

All 14 existing build/helper tests and exporter `--check` passed. The manifest matches the selected
payload; legacy contents are unchanged. A native Claude Code 2.1.286 Max trial discovered the setup
skill from ordinary help wording and read the actual bundled help resource. Only read and skill
tools were exposed, and no personal instructions were loaded. The agent explained ordinary use,
full updates of packages plus adopted collaboration instructions, and automatic-update limits.
This checks the explanation route, not real update execution, installed caches, every possible
wording or ordinary student use. No fresh Codex model trial or public structural-validator pass ran.

Historical manifest SHA-256: `74c244531bb88d075295e673af860b33706f21a42a882bb55a1d33d89fb142c5`.

## Historical candidate.3 evidence

Candidate.3 is `research-core` version `0.1.0-candidate.3`: 23 skills, comprising 21 selected
procedures plus `plugin-feedback` and `research-core-setup`, with 37 package files and 40 selected
release files. It defers advisor-feedback walkthrough, collaborator setup, book setup/publication
and sequential host handoff. It also strengthens review of actual input choices and agent autonomy.
All 14 existing build/helper tests and exporter `--check` passed. Private-catalog Codex
structural validation passed; the same validator path was unavailable when checking the public
export, and a bounded search found no installed replacement. Public wrapper schemas are unchanged
apart from the version field; their contents match the exporter. This is not a new public-validator
pass or native-client trial. The manifest matches all 37 package files; legacy payloads are unchanged.
The candidate.3 manifest SHA-256 was
`a8a10db2402fc164f0512cd00bed1c5e687364ea2603f85b44eaf39c6d30c05e`.

## Historical candidate.2 evidence

Candidate.2 was `research-core` version `0.1.0-candidate.2`: 28 skills, comprising 26 selected
canonical procedures plus `plugin-feedback` and `research-core-setup`. The package contains 43 files;
the exporter selected 46 release files across the package, catalogs and release inventory. All 14
build/helper tests passed, exporter `--check` matched the frozen destination, and the Codex structural
validator passed. Its historical first-release manifest had SHA-256
`b412fc61117525aa02ca6df6a2507e48111de0cc41de9cd0e826c5c15674866f`.
`scientific-manuscript` and its resources are absent from this generated candidate; that does not
remove the legacy-plugin copy or the separately maintained personal source.

Claude Code 2.1.283 ran Max Sonnet at xhigh directly against candidate.2 with `--plugin-dir`.
`/context` showed all 28 namespaced skills and no personal instructions. The first synthetic run
did not use the Skill tool, so it is not evidence of spontaneous skill invocation. It nevertheless
executed the committed producer correctly: group A had `n=2`, mean `3`; group B had `n=2`, mean `8`.
Documentation and plan saves were denied because the disposable fixture's permission syntax was
wrong.

In a corrected continuation, the prompt explicitly invoked `research-core:data-handling` and
`research-core:done`. The agent read the skill sources, producer, inputs and outputs; saved an
accurate `docs/phase-review.md`; preserved all source, input and output bytes; and left acceptance
pending. An exact Edit allowance succeeded for `docs`, while `.claude/ACTIVE_PLAN.md` remained
denied under `--restricted`/`dontAsk`. This demonstrates prompted skill composition and an honest
partial closeout. It does not verify automatic plan updating, a fully passing native workflow,
installed-cache behavior, or natural student use. No live permission setting was changed or bypassed.

Historical candidate.1 evidence remains relevant only to that payload. On 2026-09-27, both native
CLI clients installed `research-core` version `0.1.0-candidate.1` from a local catalog in disposable
profiles. Each installed cache matched all 53 files in its then-current manifest, with no missing,
extra or mismatched file. The candidate.1 manifest SHA-256 was
`cbea199545a9757288c281c36209f6765f3c2178413b20bc10dc34a2a1f7366f`.

Both installed instruction helpers added the block to a fixture containing unrelated preferences,
preserved those bytes and the file mode, and removed the block to restore the exact original file.
Codex prompt rendering listed 29 unique candidate.1 skills with personal skill paths explicitly disabled;
Claude's candidate.1 component inventory listed 29 skills and no agents, hooks, MCP or LSP servers. These checks
made no model or authentication request and copied no credentials. Normal profiles were not modified.
The candidate.1 14 build/helper checks and native manifest validators also passed.

A separate loopback Git fixture used the same payload with two synthetic versions and a marker.
Codex upgraded from fixture v1 to v2 on a moving branch. The same existing v2 profile then removed
the package/catalog registration, re-added the catalog at the retained immutable v1 ref and
reinstalled v1. Version and marker readback confirmed the return; unrelated fixture instructions
and independent settings were unchanged. A pinned v1 profile stayed pinned when upgraded.
This checks native ref behavior without publishing a release or changing a student's installation.

Claude's Git test stopped at `dumb http transport does not support shallow capabilities`: the
minimal static fixture could not serve its shallow clone. Claude Git update/recovery was therefore
unverified at that checkpoint; the final four-package smart-HTTP check above now closes that gap. After cleanup, both clients had no active plugin/catalog registration; Claude
retained a native orphaned cache in its disposable profile. The loopback service was stopped.

The instruction helper and data-handling procedure are unchanged through candidate.6. Their earlier
focused evidence remains applicable within its stated scope. The collaboration body and done
routing changed, so earlier model trials do not establish the updated wording's behavior. The bounded
candidate.4 help trial above does not establish the revised collaboration wording. Current Codex
local installation/removal and final native update/recovery are verified above. The current Core
output-review check adds bounded model evidence; ordinary student use remains unobserved.

These results do not establish editor/desktop behavior, Windows, a cluster, private repository
access, observed automatic updates, or scientific validity of every bundled method. The current manifest
selects `research-core`, `yale-research`, `single-cell-research` and `genome-annotation`,
as the then-current candidate inventory. Phase 1 was subsequently accepted as recorded above.
A plugin installation also does not install its external scientific tools or make a local machine
suitable for a remote workflow.

## Evidence to record for each demonstrated route

Record enough context to reproduce the claim:

- package names, versions, candidate identity, and the named moving release channel or immutable recovery ref;
- client version and CLI, desktop, editor or remote interface;
- operating system and computer architecture when relevant;
- execution host, installation scope and actual instruction destination;
- marketplace source and authentication route, without tokens or credential contents;
- install/list readback, selected resource hashes or inventory, and fresh-task discovery;
- setup/update/removal outcome, preservation of surrounding instructions and recovery result;
- scientific runtime dependencies checked, plus routes that remain untested.

Use credentials already available to the client through its supported authentication route. Never
copy tokens between profiles or hosts to make a test pass. A blocked target stays unverified; it
does not invalidate a separately demonstrated combination.

## Claim boundaries

- A CLI check supports only that CLI/version/OS combination.
- A local installation does not establish desktop, remote-editor or cluster behavior.
- Package discovery does not validate a scientific method or its external toolchain.
- Setup manages only the named `RESEARCH-CORE` block and preserves the rest of the instruction file.
- Optional resources must fall back to project instructions or official documentation when absent;
  the agent must not pretend a missing package loaded.
- The legacy `lab-skills` 1.12.1 plugin remains available. Switching requires a per-student overlap,
  hook and security review plus a demonstrated return path.
- The explicit full-update workflow checks packages and adopted instructions. Automatic-update
  descriptions are documentation/versioned-source evidence, not observed student behavior; no
  editor support claim is made.
- Routine updates require a maintainer-named moving release branch/channel. Immutable tags or
  commits are for intentional pinning/recovery and must not be moved silently.

## Native Windows instruction adoption

The current [official Windows documentation](https://learn.chatgpt.com/docs/windows/windows-app)
distinguishes Windows native from WSL2 and configures the integrated terminal separately. Record
the agent's actual environment; a terminal choice alone is insufficient.

The accepted candidate inspection found an unconditional `os.fchmod` call and a directory
open/fsync after replacement in the instruction helper. Native Windows support for those operations
has not been demonstrated. **Do not run this helper against real native Windows instructions.**
Use the [quickstart's manual route](research-plugins-install.md#preserve-your-current-setup-and-adopt-the-instructions):
exact installed block, complete diff, byte-for-byte backup, approval, native edit and preservation
readback. If exact preservation cannot be verified, stop without writing. A WSL2 or macOS result is
not native Windows evidence, and the setup must not silently change the student's chosen environment.

The public 0.1.0 release retains the reviewed helper; a future compatibility repair can be delivered
through a normal package update. Manual adoption is a separate verified result, not helper success.
