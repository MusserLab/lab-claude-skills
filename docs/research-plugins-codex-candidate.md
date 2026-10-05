# Research Plugins 0.1.1 for Claude Code and Codex

This maintenance release updates the four packages for both Claude Code and Codex. Their
versions are 0.1.1: Research Core (23 skills), Single-cell (2), Genome (5) and Yale
(3). Optional packages retain minimum Core 0.1.0. The generated
[inventory](../release/first-release.json) identifies exact release payloads. This page retains its
candidate filename so existing review links continue to work.

Research Plugins and legacy Lab Skills use the same repository. The all-in-one `lab-skills`
1.12.1 plugin, its payload, hooks and security configuration stay on default `main`. Legacy users
are not upgraded or migrated to the new packages; a transition remains a separate reviewed choice.
Shared procedure sources and both native package wrappers are retained. This correction changes
release routing and documentation, with no new package membership or payload selection.

## Release Sources

Both clients use `codex/research-plugins-release` for ordinary updates, with immutable ref
`research-plugins-0.1.1` for a deliberate pin. The existing Codex moving ref
`codex/research-plugins-codex-release` remains a compatible alias at the same shared release commit.
The historical Codex-first `research-plugins-codex-0.1.1` tag/release and the shared
`research-plugins-0.1.0` tag remain unchanged.
Verify the published release/tag, selected ref and matching inventory before installation;
stop if they are missing. Publication does not itself migrate legacy users or rewrite adopted
instructions. Existing Research Plugins installations on a moving ref may receive package updates
through the client's automatic or manual refresh. Read back installed versions and selected
contents; publication alone does not establish that an installation is current. Do not substitute
a missing ref or silently switch an existing installation.

A Research Plugins installation already using the shared 0.1.0 moving channel can receive 0.1.1
through the ordinary update route in either client, without changing its source. Existing Codex
alias installations also update normally without a forced switch. Intentional immutable pins stay
pinned. Follow the
[installation guide](research-plugins-install.md) and
[ordinary update procedure](research-plugins.md#update-with-one-request).

For a requested source/ref change, deliberate pin, migration or recovery, inventory the marketplace's
entire installed set, current ref, enabled/disabled choices, unrelated preferences and adopted
instructions first. Review any legacy installation sharing the marketplace; an unaccounted-for
package is a hold. Preview the exact change and return path before approval. The tested
[macOS Codex CLI route](research-plugins.md#switch-an-existing-codex-marketplace)
removes the affected selected packages, removes the marketplace,
re-adds the same repository with the approved `--ref`, and reinstalls the same set. Reinstallation
enables previously disabled packages, so snapshot and explicitly restore those choices through
supported configuration and verify `codex plugin list --json`. Do not edit caches or replace the entire
configuration. Subsequent ordinary marketplace upgrades stay on the selected ref and preserve
the restored disabled choice in the tested client.

Recovery uses the same reviewed source-switch procedure with the maintainer-named retained immutable
ref and preference restoration. Both switch and upgrade leave the adopted
`RESEARCH-CORE` block unchanged; preview the desired installed block separately before updating
or recovering it, preserving personal instructions outside the block.

## Evidence And Limits

The historical Codex-first source-switch, changed-upgrade and immutable-recovery route was exercised
in one disposable macOS profile using Codex CLI 0.149.0 on October 5, 2026. Seven complete 93-file readbacks matched.
It used local fixtures, not a student installation or this release's final content. No model
or account session was used. Registrations were removed and the local fixture service stopped.

This release reuses the unchanged instruction helper and released scientific safeguards.
Exact content/build checks and focused regressions are recorded in the maintainer's content review,
separately from client routing. A separate October 5 check used Claude Code 2.1.289 on
macOS 14.4.1 arm64, a fresh disposable profile and a loopback Git fixture containing exact public
0.1.0/0.1.1 package bytes. All four 0.1.1 Claude manifests passed strict validation with no warnings.
Research Core updated on the same moving ref from 0.1.0 to 0.1.1; all 38 files and 23 skills matched
the inventory with no missing, extra or mismatched files. Seeded inert preferences and the adopted
CLAUDE.md block stayed unchanged. Retained-tag recovery and a subsequent pinned update stayed at
0.1.0; all four 38-file readbacks matched. Final plugin/marketplace registrations were empty and
the fixture server stopped. The other three packages were not native-installed. Codex's final
0.1.1 payload has not been native-installed.
Neither static packaging nor these bounded CLI checks establish Desktop, Windows, Linux or
cluster plugin behavior, automatic skill use, real scientific execution or student acceptance.
The existing native Windows manual instruction-adoption limitation remains in force.
