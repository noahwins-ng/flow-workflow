---
name: flow-sync-plan
description: >-
  Reconcile the plan doc with the tracker: tick Done items, remove Cancelled ones, and surface
  issues not yet in the plan (mechanical gap sweep). Use after scope changes or when docs have
  drifted, or when the user says "sync plan", "sync docs", "/flow-sync-plan", or "reconcile the plan".
---

# sync-plan

Reconcile `profile.docs.plan` against the tracker. No-op with a note if `docs.plan` is empty.
Uses your Linear tool native-first to list project issues.

## Step 1 — Fetch tracker state
List all issues for `profile.cadence.project`. Categorize: **Done**, **Cancelled**, **Active**
(Todo/In Progress/In Review).

## Step 2 — Tick Done
For each unchecked plan item referencing a Done issue: `- [ ]` → `- [x]`.

## Step 3 — Handle Cancelled
For each plan item referencing a Cancelled issue: remove it (and its sub-bullets) so the section
still reads coherently; note it as dropped. Then assess: **does the drop warrant an ADR?** (changes
architecture/data flow? a future reader would ask "why isn't X here?"? affects multiple components?)
If yes and `profile.docs.decisions_dir` is set, create a new numbered ADR from
`profile.docs.adr_template` and list it in `profile.docs.adr_index`.

## Step 4 — Gap sweep (mechanical, not by eye)
Scan-by-eye is how drift accumulates. Build the gap from two sets:
1. **Tracker set** — every issue id in `profile.cadence.project`, excluding Cancelled/Duplicate.
2. **Plan set** — `grep -oE '<identifier_regex>' <profile.docs.plan> | sort -u`.
3. **Gap = tracker − plan.**

For each gap id, report `<id>: Title (Status, milestone)` under "Not in plan". Do **not** auto-add
(plan items carry sub-bullets/context a title can't generate), but prompt inline per gap: *"Add an
entry for <id> under <milestone>? (Y/n)"*. On yes, draft `title + **Triggered by:**` sub-bullet.
Assess the same ADR criteria for any addition that introduces a new pattern.

## Step 5 — Commit
If not on `profile.project.default_branch`, warn that plan ticks will bundle into the current PR.
If anything changed: commit `docs: sync plan with tracker` (and `docs: add ADR-NNN — <title>` if
one was created); push.

## Step 6 — Report
**Emit this block in full** — every line, placeholders substituted. Never summarize, compress, or collapse it to prose.
```
Synced <plan>
Ticked (Done):    [x] <item> — <id>
Removed (Cancelled): [-] <item> — <id>   (ADR: <path> if created)
Not in plan — add manually: <id>: <title> (<status>)
ADR prompted: <id>: <reason>
(or "Nothing to sync")
```
