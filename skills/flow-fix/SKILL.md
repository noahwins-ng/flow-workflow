---
name: flow-fix
description: >-
  Recover a stalled delivery: diagnose where the flow-ship-issue pipeline failed (from git state,
  not tracker status), fix it, and resume from the failed phase. Use when a ship run died mid-way,
  or when the user says "fix", "/flow-fix <ISSUE>", "resume the pipeline", or "the pipeline broke".
---

# flow-fix

Diagnose → fix → resume a broken `flow-ship-issue` run. The issue id is given by the user. Reads
`profile.*`. The diagnosis is driven by **git state** (always reliable), cross-checked against the
tracker (which may have drifted) but never overridden by it.

## Step 1 — Diagnose the failure point (from git state)

Gather: `git branch --show-current`, `git log --oneline <default_branch>...HEAD`, `git status`,
`gh pr list --head <branch> --state open`, `gh pr list --head <branch> --state merged`.

Map to a phase using this hierarchy (in order):

| Git state | Failed at |
|-----------|-----------|
| No commits on branch | pick done, **implement** never started |
| WIP commits + `profile.verify.*` checks fail | **implement** incomplete (lint/type/test) |
| WIP commits + checks pass + unfinished AC | **implement** incomplete (missing AC) |
| WIP commits + checks pass + all AC done | **sanity-check** or early **ship** failed |
| One clean squashed commit | **ship** failed post-squash (push / PR / CI / merge) |
| Open PR exists | **ship** failed at CI or merge |
| Merged PR exists | **ship** failed at post-deploy verification |

Cross-check the tracker status; if it disagrees with git, note the drift — do **not** let it override
the git-based diagnosis. Report the diagnosis (branch, tracker status + drift note, WIP count,
uncommitted, PR state, inferred failed phase + reason).

**When the failure is complex or multi-signal** (post-deploy failure, conflicting signals, an
unclear root cause), optionally dispatch the read-only **`flow-investigator`** subagent (dispatch
name + resolution rule per `install/harness-notes.md` — e.g. `flow:flow-investigator` on Claude
Code; if the name doesn't resolve, retry the other namespace form) for an
independent root-cause hypothesis before you fix — it keeps this session's context clean and won't
touch anything. For **multiple independent failures** (e.g. 3+ unrelated failing test files),
dispatch **one `flow-investigator` per failure domain in parallel** (harness permitting). For a
straightforward git-state diagnosis, do it inline — don't over-orchestrate.

## Step 2 — Fix

- **implement**: commit salvageable uncommitted work as WIP; run `profile.verify.lint/format/types`
  and the targeted test, fixing each; re-check the AC and finish any unfinished ones; WIP-commit.
- **sanity-check**: read the failing check output, fix the specific issue, WIP-commit.
- **ship**: if an open PR failed CI, read the error, fix, push; if a merge conflict, **stop and hand
  to the user** — do not auto-resolve; otherwise the fix is done and resume handles the rest.

Track attempts per `skills/flow-ship-issue/references/recovery.md` (WIP "fix attempt" commits, the
two-attempt ceiling). If the fix itself fails twice, report the specific error and stop.

## Step 3 — Resume

Resume by **reading and following** the remaining `flow-ship-issue` phase files in order (read-and-
follow, not skill-invocation — portable):
- fixed at implement → `references/03-sanity-check.md` → `04-review.md` → `05-ship.md`
- fixed at sanity-check → re-run `03-sanity-check.md` fresh → `04` → `05`
- fixed at review → re-run `04-review.md` fresh → `05`
- fixed at ship → `05-ship.md` (it detects the existing PR/merge state and continues)

## Step 4 — Record + report

Post a tracker comment (`profile.tracker.add_comment`): what failed, the fix, and where it resumed
from. Then report:
```
Fixed <id>: <title>
Problem:  <what failed>
Fix:      <what was done>
Resumed:  from <phase> → ship
Status:   <final tracker state>
```
