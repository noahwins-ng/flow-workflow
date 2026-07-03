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

2. **Milestone progress** — which milestone (phase) is in flight? How many of its issues are Done
   vs remaining?

3. **Suggest the next issue** to pick, ranked by: Priority (Urgent > High > Medium > Low), then
   dependencies (blocked issues come after their blockers), skipping Done.

4. **If the cycle is empty**, suggest pulling issues from the next milestone's backlog into the
   cycle — and moving them **Backlog → Todo** (Backlog issues don't show on the cycle board).

5. **Plan staleness check** (if `profile.docs.plan` is set) — if there are Done issues in the
   tracker whose plan items are still unchecked, note: *"plan may be out of sync — run flow-sync-plan."*

6. **Report:**
   ```
   Cycle N (<start> — <end>)

   Issues:
     <id>  <title>   <status>   <priority>

   Milestone: <phase> (<done>/<total> done)
   Suggested next: <id> — <title>  (<priority>)
   ⚠ plan may be out of sync — run flow-sync-plan   (if applicable)
   ```
