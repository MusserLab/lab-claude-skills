# Codex Research Plugins 0.1.1

This maintenance release updates the four Codex packages. Their
versions are 0.1.1: Research Core (23 skills), Single-cell (2), Genome (5) and Yale
(3). Optional packages retain minimum Core 0.1.0. The generated
[inventory](../release/first-release.json) identifies exact release payloads. This page retains its
candidate filename so existing review links continue to work.

Claude remains on 0.1.0. Legacy `lab-skills` 1.12.1, default `main`, Claude's existing
`codex/research-plugins-release` source and `research-plugins-0.1.0` ref remain unchanged.
Claude consumer state has not been inspected. Shared procedure sources and both native package
wrappers are retained; separate release refs, not unchanged Claude manifests, keep the held
release isolated.

## Release Sources

The Codex moving ref for ordinary updates is
`codex/research-plugins-codex-release`, with immutable ref `research-plugins-codex-0.1.1`.
Verify the exact release tag and matching inventory before installation. Publication does not
change an installation, migrate a student or update adopted instructions. Do not substitute a
missing ref or silently switch an existing installation.

A student already using the shared 0.1.0 channel needs a separately approved one-time
source switch. Inventory the marketplace's entire installed set, its current ref, enabled and
disabled choices, unrelated preferences and adopted instructions first. Review any legacy
installation sharing the marketplace; an unaccounted-for package is a hold.
Upgrading the held shared branch does not select the new Codex channel. Follow the
[installation guide](research-plugins-install.md) and
[source-switch procedure](research-plugins.md#switch-an-existing-codex-marketplace).

The tested macOS Codex CLI route removes the affected selected packages, removes the marketplace,
re-adds the same repository with the approved `--ref`, and reinstalls the same set. Reinstallation
enables previously disabled packages, so snapshot and explicitly restore those choices through
supported configuration and verify `codex plugin list --json`. Do not edit caches or replace the entire
configuration. Subsequent ordinary marketplace upgrades stay on the selected ref and preserve
the restored disabled choice in the tested client.

Recovery uses the same reviewed source-switch procedure with the retained immutable
`research-plugins-0.1.0` ref and preference restoration. Both switch and upgrade leave the adopted
`RESEARCH-CORE` block unchanged; preview the desired installed block separately before updating
or recovering it, preserving personal instructions outside the block.

## Evidence And Limits

The source-switch, changed-upgrade and immutable-recovery route was exercised in one disposable
macOS profile using Codex CLI 0.149.0 on October 5, 2026. Seven complete 93-file readbacks matched.
It used local fixtures, not a student installation or this release's final content. No model
or account session was used. Registrations were removed and the local fixture service stopped.

This release reuses the unchanged instruction helper and released scientific safeguards.
Exact content/build checks and focused regressions are recorded with the maintainer's accepted
review, separately from client routing. The final 0.1.1 package content was not native-installed.
Neither static packaging nor the earlier CLI trial establishes Desktop, Windows, Linux or
cluster plugin behavior, automatic skill use, real scientific execution or student acceptance.
The existing native Windows manual instruction-adoption limitation remains in force.
