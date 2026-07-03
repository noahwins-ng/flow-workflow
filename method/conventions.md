# The method this suite assumes

The workflow skills are *opinionated*: they encode one way of working. `init` scaffolds the docs
that make that method real. This file is the reference for the conventions the skills expect.

## Tracker model (Linear)

- **Project** — one Linear project per repo. All issues + status updates attach to it.
- **Milestones = phases** — a milestone is a finite chunk of the roadmap (e.g. "Phase 2 — API").
  A milestone completing triggers a retro.
- **Perpetual milestones** — deliberate catch-alls (e.g. "Ops & Reliability") that never "complete";
  work lands there continuously. cycle-end/retro never auto-prompt a retro for these
  (`cadence.perpetual_milestones` in the profile).
- **Cycles = weeks** — the unit of cadence. cycle-start kicks one off; cycle-end wraps it and rolls
  incomplete issues forward. An issue must be **Todo** (not Backlog) to appear on the cycle board.
- **One branch + one PR per issue.** Branch name comes from the tracker.

## Docs skeleton (the four surfaces + records)

| File | Role | Who edits it |
|------|------|--------------|
| `project-requirement.md` | The spec — *what* and *why*, per phase | change-scope |
| `project-plan.md` | The narrative tracker — checkbox item per shipped ticket | ship (tick), change-scope, sync-plan |
| `architecture/system-overview.md` | How the system actually works now | change-scope, retro |
| `decisions/` (ADRs) | *Why* we chose X over Y; numbered, immutable | change-scope, sync-plan, retro |
| `retros/` | One report per completed milestone | retro |

Rule of thumb the skills enforce: **Linear is the tracker; `project-plan.md` is the narrative.**
Every shipped ticket exists in both. An architectural decision that a future reader would ask "why?"
about gets an ADR.

## The invariant-guard practice (retro)

Every incident/surprise gets reduced to a one-sentence **invariant** that drifted, and a **guard**
(a CI check or a ship hard-gate) that now enforces it — or an explicit "accepted risk". An invariant
without a guard is still on vibes. This is how ceremony turns into durability.

## Adopting mid-project

`init` is non-destructive: on a repo that already has some of these, it leaves existing files alone,
adds only what's missing, and points the profile at whatever it finds. You are never forced to
reorganize an in-flight project's docs — only to fill the gaps.
