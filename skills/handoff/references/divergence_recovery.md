# Divergence recovery

Recipe for when the handoff gate was NOT held and both sides have already
made divergent commits or uncommitted changes that overlap. This is the
manual three-way merge path used in the 2026-05-07 BUSCO Phase 2 case.

If the gate was held and you're following the normal handoff workflow,
you don't need this — `git pull --ff-only` will fast-forward cleanly.

---

## Diagnosis

Run on both sides:

```bash
git status                       # uncommitted work?
git log --oneline @{u}..HEAD     # local commits not on origin?
git fetch && git log --oneline HEAD..@{u}  # origin commits not local?
```

Divergence is happening if:

- Side A has commits not on origin AND
- Side B has uncommitted changes (or commits) that touch the same files
  side A's commits modified

Plain `git pull --ff-only` will fail. You need the recipe below.

---

## Recipe

### Step 1 — On the side with the more committed work, OR the side ready to push first

Pick one side as "departure." It doesn't strictly matter which — the
merge will happen on the other side either way. Choose based on:
- Which side has more committed work (less to lose if anything goes wrong)
- Which side is the canonical record for sections that conflict (e.g., the
  side with the more recent strategic decisions)

```bash
# Commit any uncommitted work — specific files by name only, NOT git add -A
git add <session files>
git commit -m "<departure-side description>"

# Push to origin
git push
```

After this step, origin/main has departure's commits. The other side
("arrival") still has uncommitted work AND is now behind origin.

### Step 2 — On the arrival side: commit local first, THEN pull

This is the critical ordering. Do not pull before committing local work,
or you'll have to stash and the merge gets harder.

```bash
# Commit arrival's uncommitted work (specific files by name)
git add <arrival session files>
git commit -m "Arrival side: <description>"

# Now pull — git will produce a merge commit (or conflicts)
git pull --no-rebase
```

`--no-rebase` produces a merge commit (vs. rewriting arrival's commit on
top of departure's). Merge is preferred for handoff cases because both
sides represent intentional concurrent work that should be visible in
history, not linearized.

### Step 3 — If conflicts: resolve them

For each conflicted file:

```bash
# Open the file in an editor
$EDITOR <file>

# Find each conflict block:
#   <<<<<<< HEAD
#   <arrival's version>
#   =======
#   <departure's version>
#   >>>>>>> <commit-sha>
#
# Decide what the merged content should be (combine both, take one,
# or rewrite). Replace the entire block (markers and all) with the
# merged content.
```

Verify no markers remain:

```bash
grep -n '<<<<<<<\|>>>>>>>' <file>
# Should print nothing.
# Note: a lone `=======` line is also a markdown header, so don't grep
# for that — only the <<<<<<< and >>>>>>> matter.
```

After all conflicts resolved:

```bash
git add <resolved files>
git commit  # default merge commit message is fine, or write your own
git push
```

### Step 4 — Catch up the departure side

Run on departure (the side that pushed first):

```bash
git pull --ff-only  # should fast-forward to the merge commit cleanly
```

Both sides should now point at the same merge commit.

---

## Conflict resolution strategy

When deciding how to merge each conflict block, these rules of thumb help:

| Pattern | Strategy |
|---------|----------|
| One side redesigned a section (e.g., merged two phases into one) | Strategically newer side wins for that section |
| One side has richer narrative or specific numbers | Fold the detail into the structure of the other side |
| Both sides added rows to a table | Strict superset wins — keep all rows |
| Both sides added an entry on the same date in a session log | Merge into one entry, OR use `(session 1)` / `(session 2)` numbering per the `done` skill convention |
| Tables where one side added columns | Take the wider table; fill missing cells from the other side |
| Status tables where one side marked work Done with detail | Take the Done detail; the other side's "Not started" was older |

---

## Asking the user for help on conflicts

If the conflict is large enough that automatic merging requires judgment
calls (e.g., two different strategic redesigns of the same phase), don't
guess — show the user both sides clearly:

```
Conflict in <file>, around line N:

YOUR LOCAL VERSION (HEAD):
<arrival side content>

OTHER SIDE'S VERSION (commit XXX):
<departure side content>

These differ in <substance>. Which wins, or do we merge?
```

Then apply the user's decision and move on.

---

## Sending the recipe to the OTHER Claude Code session

If divergence happens and the merge needs to be resolved on a different
machine than where you (Claude) currently are, you can hand off to the
other session by giving the user a paste-ready prompt that includes:

1. What the conflicts are (file names, line ranges)
2. The exact replacement text for each conflict block
3. The cleanup commands (`grep`, `git add`, `git commit`, `git push`)

The 2026-05-07 case did this — the cluster Claude wrote a self-contained
prompt the user pasted into local Claude Code, which applied the four
resolutions and pushed. That works reliably; structure your handoff prompt
the same way (each conflict gets its own labeled section with EXACT
replacement text, not "merge these intelligently").
