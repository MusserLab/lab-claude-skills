---
name: globus-transfer
description: >-
  Use when copying, staging, restoring, or verifying files between Globus
  collections, including NAS, Bouchet, McCleary, Wasabi, and Yale Google Drive
  or Shared Drives. Covers scoped preflight, direct CLI transfer, task status,
  and complete destination checks. Do not use to decide retention, local
  removal, vendor QC, or scientific suitability.
---

# Globus transfer

Copy an exact, approved file selection between collections and establish what
arrived. The owning project or domain skill defines the intended file universe
and where durable custody evidence belongs. This skill creates no wrapper,
timer, ledger, or receipt file by default. Loading it approves no write.

## Before a write

Identify the source and destination collection IDs, exact paths, selected
files or directory, expected relative-path mapping, and whether the operation
is an archive, stage, or restore. Do not infer paths by swapping cluster or
NAS root prefixes. A directory copy can nest differently from a file copy;
review its final destination layout. Globus follows a selected source symlink
but silently skips links inside a recursive tree; inspect links and explicitly
select any linked content the intended universe requires.

Use the saved CLI session for read-only `globus ls`, `globus stat`, and task
checks within the selected scope. On Bouchet, load the pinned Globus module in
the **same Bash invocation** as each direct command. If Yale reauthentication,
MFA, or collection consent is required, the researcher completes it in their terminal;
never request a code or token in chat. An unchanged write approval survives an
authentication refresh.

### Yale Google Drive collections

Yale exposes Google Workspace storage through mapped Globus collections:

- `Yale Google Drive` (the researcher's personal Drive).
- `Yale Google Shared Drives` (lab and project Shared Drives).

Discover and verify their actual public collection IDs by name with endpoint search; no account's
collection inventory or unverified fixed ID is distributed here.

Use the Shared Drives collection for a lab project stored in a Shared Drive.
Globus addresses it by path, not Google Drive file or folder ID; discover the
path with read-only `globus ls`, beginning at the collection root. On the
current CLI, confirm the collection names and IDs when needed with
`globus endpoint search 'Yale Google Drive' --limit 100 -F json`; do not guess
an ID or path.

These are high-assurance mapped collections. Test access with `globus ls`, not
the legacy `activated` field in endpoint-search output: endpoint activation has
been removed, and `activated: false` does not establish that a collection is
unavailable. If access reports missing consent or a session policy, the researcher runs
the exact `globus session consent ...` or `globus session update ...` command
printed by the CLI and completes the browser/MFA flow. Consent granted to the
Globus web app does not necessarily grant it to the CLI. Never request or copy
the resulting code or token in chat.

Use this Globus route when a connected Google Drive uploader cannot accept a
large file. The usual exact-write approval, collision preflight, encryption,
checksum verification, complete destination comparison, and no-delete rules
still apply.

Inventory the entire selected source universe using its existing manifest or
a fresh scoped listing. Check the selected destination paths immediately before
submission. The default is absent destinations and no overwrite; a collision
refuses the whole selection. Account for unrelated existing destination files
without deleting them. Include any parent directories the transfer will create
in the reviewed destination scope.

Show the literal direct CLI action and obtain the researcher's explicit approval of its
exact source, destination, selection, and overwrite behavior **before each
remote write**. One approval may cover several planned actions only when each
is individually exact and its execution condition is stated. Reuse that
approval only for unchanged actions; an intake request, login, read, or a new
destination is not approval. Standalone `globus mkdir`, `globus rename`, and
metadata/access writes need the same exact approval.

## Transfer

Issue a direct `globus transfer ...` command, never a write hidden in a
wrapper, interpreter, another host, or API. Use `--encrypt-data` and
`--verify-checksum`; if required verification is unavailable, stop before
transfer. Never use Globus delete/purge or destination-deletion options,
including `--delete-destination-extra`; never move or rename to evade that ban.
Do not use `--skip-source-errors` or an exclusion that silently shrinks the
approved universe.

For an absent destination, use `--sync-level exists` after the collision
preflight. Treat any file skipped because it appeared meanwhile as a collision
and incomplete result, not success. A failed task may leave partial files;
inspect them before a retry. A checksum-level restart or replacement can write
existing files and needs exact approval of that scope and overwrite behavior.
Do not use size or mtime sync to restart a failed transfer.

Use a literal reviewed batch selection only when one directory transfer does
not express the intended scope. For file batch entries, put `--no-recursive`
on applicable lines, not at the top-level `--batch` command. Do not preserve
timestamps when the lab Synology NAS is the destination: that path has rejected
timestamp writes after transferring file content.

## Verify and report

A returned task ID means submitted, not archived. Use `globus task wait` and
`globus task show` for terminal status and options,
`globus task show --successful-transfers` for transferred paths,
`globus task show --skipped-errors` for error-skipped paths, and
`globus task event-list --filter-errors` for faults. These views do not prove
the complete selected universe or enumerate files skipped because they already
existed. Recheck the destination against **every** intended mapped path and
size; that complete comparison remains authoritative. Compare the source
universe again if it could have changed during the transfer. Do not delete
destination extras or call an additive copy an exact mirror.

Checksum verification covers files actually transferred. An existing file
skipped by `exists` has not been content-verified by that option. For a custody
claim, demonstrate checksum equivalence of any pre-existing skipped files
separately, or report the affected files unverified. A pending/failed task,
missing or changed intended file, unresolved fault, unavailable destination
check, or ambiguous outcome is not complete custody. Re-inventory before any
retry. The owning workflow decides whether the verified selection constitutes
a complete archive; transport integrity is not scientific suitability or
permission to remove a working copy.

Report the exact source/destination, selection, task ID and terminal state,
options, file/byte coverage, faults/skips, and any uncertainty. Routine stages
and restores do not automatically add a permanent case file. When the copy
supports an irreplaceable archive or later removal decision, promptly retain
the exact request and full mapped destination comparison in the owning
workflow's **existing** record. If a YCGA or other owner workflow prescribes its own run record
and execution evidence, preserve that requirement; this transport package does not implement
specialized intake or removal authority. Detailed Globus per-file task
history is retained for 30 days, so do not defer capturing required evidence.

Official references: [CLI transfer options](https://docs.globus.org/cli/reference/transfer/),
[task status and history](https://docs.globus.org/api/transfer/task/), and
[high-assurance sessions](https://docs.globus.org/cli/high-assurance/).
