---
name: security-setup
description: >
  Review and configure native agent-client security boundaries for credentials, sensitive data,
  project source, and retained outputs. Use for a security setup or permissions review. Add a
  project-specific guard only when a concrete gap remains after native sandboxing and approvals.
---

# Security Setup and Review

Use the client's native sandbox, filesystem scope, network controls, and approval prompts as the
primary boundary. This public skill does not install hooks, read credentials, grant blanket shell
access, or copy a default settings file. Client capabilities differ, so inspect the active client
and host before proposing a change.

## 1. Establish the boundary

Ask what must be protected and what work must remain possible. Cover, as relevant:

- credential stores, tokens, private keys, browser or application session state;
- regulated, student, personnel, collaborator, or otherwise confidential data;
- scientific inputs, curated data, retained outputs, and source code with distinct ownership;
- destructive commands, writes outside the project, network access, and external publication.

Record path names and ownership rules without opening secret contents. A directory name, an
environment-variable name, or a harmless fixture is enough to configure and test most boundaries.
Do not search the whole home directory for possible secrets unless the user explicitly requests
that broader audit.

## 2. Inspect native controls

Identify the active client, trusted workspace roots, filesystem sandbox, network policy, approval
rules, and any project instructions. Inspect read and write scope separately: a write-restricted
sandbox may still allow broad reads. Read only the settings needed for this review. Separate the
current observed state from a proposed change, and say when a capability is unavailable or has not
been tested on this host.

Prefer the smallest native configuration that supports the work:

- restrict writes to declared workspace or output roots;
- keep credential stores and client account/session state outside readable scope when the client
  supports that boundary; otherwise state the read exposure and avoid accessing those paths;
- require approval for writes outside the project, destructive operations, and external effects;
- enable network access only for workflows that need it and at the narrowest useful scope;
- preserve existing project-specific data and source protections.

Never add blanket grants for shell, filesystem, network, credentials, or account state as a
convenience default. Preserve unrelated client settings, plugins, connectors, and trust state.

## 3. Add a targeted guard only for a demonstrated gap

A project-specific guard is optional. Propose one only when a concrete consequential failure is
not covered by the native client controls, such as confusing immutable inputs with producer-owned
outputs. Keep the guard with the project or client adapter that owns the behavior; this core skill
ships no generic hook bundle.

Keep any working real guard unchanged until the replacement has demonstrated equivalent coverage
on the active client. A native sandbox setting, a file-edit guard, and a shell-command guard can
cover different invocation paths.

A proposed guard must state:

1. the exact action and paths it covers;
2. the plausible failure and consequence;
3. which direct file tools and shell/script writes can bypass each other;
4. how missing helpers, parse failures, and unsupported clients are reported;
5. one harmless allowed case, one harmless blocked case, and one failure-path check;
6. its removal or rollback path.

Do not encode scientific judgment as filename matching. Protect project inputs and retained
results according to their declared ownership; generated or ignored files are not automatically
disposable.

## 4. Review before changing settings

Before a settings or guard write, show the exact resolved destination, complete proposed diff,
expected user-visible effect, and rollback. Obtain the user's confirmation when the current task
does not already authorize that exact change. Back up a settings file before replacement and
preserve every unrelated entry. A public package install is not permission to change live client
settings.

## 5. Verify with harmless fixtures

After an approved change, verify the active client path rather than only reading configuration:

- an ordinary project source read or write that should remain allowed;
- a harmless temporary fixture placed inside an actually configured protected boundary, tested
  through each relevant file and shell tool; a credential-like filename alone proves nothing;
- a protected input or retained-output fixture if the project declares one;
- the important failure path for an optional guard.

Never test by opening a real credential or attempting a destructive command. Report which checks
ran, which client and host they exercised, and which protections remain unverified. Installation,
configuration readback, direct fixture checks, and natural use are separate evidence.

## Returning reviews

For an existing setup, inspect the current native controls and any project-owned guards, compare
them with the declared boundary, and propose only the smallest needed correction. Re-run the
focused allowed, blocked, and failure-path fixtures after an approved change. Do not replace a
working client configuration with a generic template.

## Limits

Native sandboxes and approvals reduce accidental access and damage; their capabilities differ by
client. A write sandbox does not imply a read restriction. They do not prove that every client
tool, subprocess, remote service, or already-running session is covered. Optional guards cover
only their tested invocation paths. State those limits directly rather than calling the system
secure because a file exists or a package is installed.
