---
name: flow-integrate
description: >-
  Serially merge branches parked by parallel flow-ship-issue --park runs: rebase each on the
  default branch, re-run the sanity gate, ship it (PR, CI, merge), then verify deployed identity
  once and close out every issue. Runs from the main checkout, one branch at a time — a merge
  queue, not an orchestrator. Use when parked branches exist, or when the user says "integrate",
  "/flow-integrate", "merge the parked branches", or "land the parallel work".
---

# Integrate parked branches

Serial integration for parallel work. N ship sessions ran `flow-ship-issue <ID> --park` in separate
worktrees (phases 1–4 passed, nothing merged); this skill lands them **one at a time**. It is
deliberately serial and restartable — if it dies, re-run it: already-merged branches are skipped,
still-parked ones are picked up again.

## Step 0 — Load the profile and orient

1. Read the project profile exactly as `skills/flow-ship-issue/SKILL.md` Step 0/0b describes
   (profile discovery, tracker capability resolution). Same rules: no profile → stop.
2. **Run from the main checkout, on `profile.project.default_branch`, clean tree.** If you're in a
   worktree or on a feature branch, stop and say so — integrate owns the default branch.
3. `git fetch origin` and pull the default branch up to date.

## Step 1 — Collect the parked set

Build the list of parked branches, in this order of authority:

1. Branches the user named.
2. Otherwise: issues **In Review** whose latest comments contain a `PARKED at <branch> @ <sha>`
   marker (written by ship's park mode).

For each, confirm the branch exists (`git branch --list <branch>` / `git ls-remote`). Show the set
— `<issue> · <branch> · parked sha` — and the order you'll process them (oldest park first), and
**pause for user confirmation**. Never invent a parked branch from naming conventions alone.

## Step 2 — Per branch, serially (the queue)

For each parked branch, in order — **finish or skip one completely before touching the next**.
Run merge/PR commands **from the main checkout** (not the branch's worktree): a merge command with
`--delete-branch` fails its local-checkout step when the default branch lives in another worktree.
Branch/worktree deletion belongs to Step 3 regardless.

1. **Rebase** onto the current default branch tip: `git rebase <default_branch>` on the parked
   branch. Conflicts → do **not** auto-resolve: mark this branch **SKIPPED (rebase conflict)**,
   `git rebase --abort`, leave it parked, and move on to the next branch. (Its fix is a normal
   `flow-fix` / manual session later.)
2. **Re-run the sanity gate** — read `skills/flow-ship-issue/references/03-sanity-check.md` and
   follow it. The pre-park sanity ran against pre-rebase code; only a post-rebase pass counts.
   NEEDS FIXES → apply `references/recovery.md` discipline (two attempts max); still failing →
   mark **SKIPPED (sanity)**, leave parked, continue with the next branch.
3. **Ship it through merge** — read `skills/flow-ship-issue/references/05-ship.md` and follow
   Steps 1–6 (plan-entry gate, squash, push, PR, CI, merge) with one modification: **defer Step 7
   (deploy-identity verify) and per-issue prod ACs to Step 3 below.** Set the issue's PR link as
   usual. Never merge on red CI; a red-CI branch is SKIPPED, not forced.
4. Record the merge commit sha for this issue.

Each later branch rebases onto a default branch that now contains the earlier merges — that is the
point of the serial queue.

## Step 3 — Verify the deployment once, then close out every issue

After the last merge, deployment runs once. Follow `05-ship.md` Step 7 exactly — identity gate
(deployed sha == **final** merge commit), runtime-load gate, health — with its no-deploy-project
handling. Both hard gates apply unchanged: fail ⇒ stop, no issue moves to Done.

Once the deployment is verified:
- For **each merged issue**, run the full close-out (integrate owns 05-ship Step 7b's triple in a
  parallel run — no one else will do it), in order:
  1. Resolve its ⏳ PENDING prod-execution ACs (command + output receipts).
  2. Post the ship record — **one** self-contained comment in the audit-comment contract's
     mandatory checkbox shape (`ac-classification.md` → "Comment rendering"), with its pre-post
     check. Follow-up detail comments are fine; the record must stand alone.
  3. Tick every proven AC `- [ ]` → `- [x]` in the **issue description**.
  4. Move the issue to Done.
  An issue whose prod AC fails stays In Review (skip 2–4 for it) — report it; the others still close.
- **Close-out verify (before the final report):** re-fetch each closed issue and confirm the
  triple — ship record present in checkbox shape, description ACs all ticked, status Done. Fix
  any miss now; the report may only claim Done for issues that pass this check.
- Delete merged branches and their worktrees (`git worktree remove <path>`, `git branch -d`) —
  park-mode worktrees live at `.claude/worktrees/<id-lower>` in this repo (`git worktree list`
  shows them all). Never delete a SKIPPED branch or its worktree.

## Step 4 — Report

**Emit this block in full** — every line, placeholders substituted. Never summarize, compress, or
collapse it to prose.

```
Integrated: N of M parked branches

  ✓ <issue> — <title>   PR <url> (merged)   Done
  ✗ <issue> — SKIPPED (<rebase conflict | sanity | red CI | prod AC failed>) — still parked

Deploy:  sha <final merge sha> verified · runtime ✓ · health ✓   (or: no deploy surface — skipped by profile)
Cleanup: <k> worktrees removed, <k> branches deleted
Next:    <for each skipped issue: the one command / session to resume it>
```

## Failure handling

A failure on one branch never blocks the queue — skip and continue (rebase conflict, sanity after
two attempts, red CI). A failure of the **shared deploy verification** blocks everything after the
merges: stop, report, and do not close any issue. If the run dies mid-queue, just re-run this skill
— Step 1 re-collects whatever is still parked.
