---
name: flow-cycle-end
description: >-
  End-of-cycle wrap-up: summarize what shipped, roll incomplete issues into the next cycle, compute
  velocity, check milestone completion, sync the plan, and post a project status update. Use at the
  end of a work cycle, or when the user says "cycle end", "/flow-cycle-end", or "wrap up the cycle".
---

# cycle-end

Wrap a work cycle. Reads `profile.cadence` and `profile.docs.plan`. Cadence + status-update
operations use your Linear tool native-first (see the note in flow-cycle-start).

## Steps

1. **Fetch the active cycle** (`profile.cadence.team`).

2. **Summarize what shipped** — issues marked Done this cycle, with titles and PR links
   (`gh pr list --state merged`, matched by branch name).

3. **Roll over incomplete issues** — any still Todo / In Progress / In Review. For each: note status
   and any open branch/PR, then move it to the next cycle with status **Todo** (not Backlog). If no
   next cycle exists yet, note it and skip reassignment.

4. **Velocity** — issues closed this cycle vs planned.

5. **Milestone completion** — for each milestone with issues in this cycle, check the *full*
   milestone issue list (not just this cycle's slice). If all are Done, prompt:
   *"<milestone> is complete — run flow-retro when ready."* Do **not** auto-run flow-retro.
   - **Exception:** skip the prompt for any milestone in `profile.cadence.perpetual_milestones` —
     those are catch-alls that never "complete"; a drained queue is not a finished phase.

6. **Sync the plan** — checkout the default branch first (`git checkout <default_branch> && git
   pull`) so doc commits don't land on a stale feature branch, then **read `skills/flow-sync-plan/SKILL.md`
   and follow it** (read-and-follow, not "invoke a skill" — portable to harnesses without a Skill tool). Its
   gap sweep is **mechanical** (grep every tracker id against the plan), not scan-by-eye — tickets
   created mid-cycle for follow-up polish routinely slip a shallow pass. Zero gaps on a cycle where
   new tickets were created ⇒ re-run; you probably missed some.

7. **Post a project status update** (`profile.cadence.project`, type `project`):
   - `health`: onTrack if velocity ≥ `profile.cadence.health_on_track_min`, atRisk if ≥
     `health_at_risk_min`, else offTrack.
   - `body`: markdown — shipped (linked), rollover count, velocity, milestone progress.

8. **Report:**
   ```
   Cycle N (<start> — <end>)
   ✓ Shipped: X    → Rolled over: Y

   Milestones:
     <phase> — Z% complete   (all milestones with issues this cycle)

   Next: run flow-cycle-start to kick off the next cycle.
   ```
