---
name: flow-cycle-start
description: >-
  Start-of-cycle kickoff: show the active Linear cycle's issues, milestone progress, and suggest
  the next issue to pick. Use at the beginning of a work cycle, or when the user says "cycle start",
  "/flow-cycle-start", "what's on this cycle", or "what should I work on next".
---

# cycle-start

Kick off a work cycle. Reads `profile.cadence` (team, project) and `profile.docs.plan`.

> Cadence operations (list active cycle + its issues, milestone rollups) use your **Linear tool**
> native-first. The bundled `adapters/linear.sh` implements only get/status/comment — so on a
> harness without Linear MCP, extend the adapter or run these read queries manually.

## Steps

1. **Fetch the active cycle** for `profile.cadence.team` and list its issues in a table:
   Issue id · Title · Status (Todo/In Progress/In Review/Done) · Priority.
   **Filter to `profile.cadence.project`** — cycles are team-level, and a shared team's cycle
   mixes several projects' issues; show only this project's (note the count of others).

2. **Milestone progress** — which milestone (phase) is in flight? How many of its issues are Done
   vs remaining?

3. **Suggest the next issue** to pick, ranked by: Priority (Urgent > High > Medium > Low), then
   dependencies (blocked issues come after their blockers), skipping Done.

3b. **Parallel set (optional)** — if the user wants to run issues in parallel, propose
   **min(3, pairwise-independent ready issues)**: no blocking relation between any pair, and — by
   title/description — no two plausibly touching the same files or subsystem. Be honest when the
   backlog only supports 2 (or 1): a smaller true set beats a padded one that collides at merge.
   Hard cap 3 — beyond that the operator stops reading diffs and the review gate becomes theater.
   Point the user at the parallel recipe: one session per issue, each opened at the repo root,
   running `flow-ship-issue <ID> --park` (park mode creates its own repo-local worktree under
   `.claude/worktrees/`), then one `flow-integrate` run from the main checkout to land and clean up.

4. **If the cycle is empty**, suggest pulling issues from the next milestone's backlog into the
   cycle — and moving them **Backlog → Todo** (Backlog issues don't show on the cycle board).

5. **Plan staleness check** (if `profile.docs.plan` is set) — if there are Done issues in the
   tracker whose plan items are still unchecked, note: *"plan may be out of sync — run flow-sync-plan."*

6. **Report:** **emit this block in full** — every line, placeholders substituted. Never
   summarize, compress, or collapse it to prose.
   ```
   Cycle N (<start> — <end>)

   Issues:
     <id>  <title>   <status>   <priority>

   Milestone: <phase> (<done>/<total> done)
   Suggested next: <id> — <title>  (<priority>)
   ⚠ plan may be out of sync — run flow-sync-plan   (if applicable)
   ```
