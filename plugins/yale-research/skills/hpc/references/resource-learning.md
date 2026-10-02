# Learn resource requests from completed jobs

Improve the next comparable allocation using actual job evidence. Run this while monitoring or
finishing the user's work, and when resuming a known job that completed between sessions. This is
an agent procedure, not a background collector. Do not wait for every pending job merely to close
a session, query other people's jobs, install monitoring services or modify running allocations.

## Start with the job and its workload

Use job IDs already associated with the current project/run. Read the producing command, tool and
version, input identities and relevant scale/complexity, meaningful parameters, requested CPUs,
memory, walltime, GPUs and hardware. Reuse existing run records; do not invent missing metadata.
An input file's byte size alone rarely establishes comparability. For example, transcript
complexity can change clustering memory even when two inputs have similar read counts.

Within authorized cluster access, inspect terminal status and measured usage with `jobstats JOBID`,
or the available `seff`/`sacct` summary. Use the command available on that host; do not SSH elsewhere
or acquire new access merely because this step is present. Keep the exact command and evidence
location with the existing run record. Record peak resident memory, elapsed time, CPU utilization
and GPU memory/utilization when actually reported. Distinguish total/per-task/per-node/per-CPU
memory and units; a field's absence is unknown, not zero. For arrays or multi-step jobs, retain the
individual task/step context and variation rather than treating one maximum or average as every
sample's requirement. Do not equate GPU memory with host RAM.

## Interpret before adjusting

- Successful, representative completed runs can support lower or higher future requests. Retain
  sufficient headroom for observed variation, input growth and measurement limits; explain it.
- OOM, timeout, cancellation, truncated output or missing accounting is not evidence that the
  requested allocation was adequate. Keep these observations with their failure status and do not
  lower a request based on a prematurely ended run. Verify analysis completion separately from a
  scheduler success code where outputs matter.
- Compare the tool/version, input complexity, parameters, thread behavior and hardware before
  reusing a profile. Use the starting guidance when the evidence is not comparable, explaining the
  uncertainty. Do not extrapolate a tiny fixture into a production guarantee.
- Low CPU/GPU utilization may reflect I/O, serial stages, device placement or an unsuitable thread
  setting. Diagnose the relevant cause before changing requests. Scaling CPU count can change
  elapsed time; do not reduce both blindly from a single observation.
- Routine reversible resource sizing within the agreed job scale stays with the agent. Changes to
  scientific methods, inputs, precision, seeds, filtering or model parameters require the project's
  scientific decision process. Large aggregate resource increases retain their existing discussion
  boundary. Efficiency is not permission to weaken the analysis.

## Preserve useful observations outside the installed plugin

Keep detailed evidence in the project's existing run/provenance record, with its normal privacy
and source-control rules. Add a concise resource observation there only when it improves future
requests or explains a consequential failure. Retain the old evidence; update a recommendation
without rewriting what earlier jobs actually did.

For reuse across projects, use the user's existing declared private resource-profile record. If
none exists, setup may offer one small Markdown table in user-owned storage outside the plugin
cache (for example `~/.local/share/research-plugins/hpc-resource-profiles.md` on macOS/Linux/WSL).
Confirm its absolute path during setup and record that pointer in the user's existing instructions;
respect platform conventions and do not assume native Windows uses a Unix path. Creating the
record is part of the reviewed setup, not an implicit write to a stranger's project or shared lab
file. Thereafter update the user's own record within the agreed resource-learning scope. When it
is unavailable or read-only, preserve the observation in the project and report the unresolved
profile update; do not create a competing hidden copy.

A compact row is enough: tool/version and workload; input scale/complexity and hardware; observed
usage and completion status; recommended request and rationale; dated project/run evidence link.
Keep project identifiers, raw job reports and private locations out of public feedback. Avoid
adding a row for every repeated job when the recommendation and evidence range have not changed.
No database, duplicated manifest, independent scheduler or global project scan is required.

Before a future comparable job, consult these profiles alongside the bundled starting table.
Project-specific evidence takes precedence when relevant; contradictory observations remain
visible and need investigation. Different hosts may expose different records: use what is
actually available and do not silently synchronize home directories or credentials.

## Improve the maintained defaults deliberately

Installed plugin files are release artifacts, not the student's learning store. Do not rewrite
SKILL.md or the bundled profile table after a job. A maintainer can promote useful, appropriately
sanitized observations into the authoring source and release them through the normal `sync-plugin`
review. A student's cross-project profile can improve their next request immediately without
waiting for a shared release. Updating a plugin must preserve user/project observations.

At the next substantive review, summarize what was learned and any changed resource request, with
its evidence and uncertainty. If no useful new evidence exists, say so briefly or skip the update.
Pending jobs retain their IDs and the normal project resumption cue; there is no claim that a
closed session continues to monitor them.
