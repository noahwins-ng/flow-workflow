# The method this suite assumes

The workflow skills are *structured*: they encode one way of working. `init` scaffolds the docs
that make that method real. This file is the reference for the conventions the skills expect.

## Tracker model (Linear)

- **Project** — one Linear project per repo. All issues + status updates attach to it.
- **Milestones = phases** — a milestone is a finite chunk of the roadmap (e.g. "Phase 2 — API").
  A milestone completing triggers a retro.
- **Perpetual milestones** — deliberate catch-alls (e.g. "Ops & Reliability") that never "complete";
  work lands there continuously. cycle-end/retro never auto-prompt a retro for these
  (`taxonomy.perpetual_milestones` in the profile).
- **Cycles = weeks** — the unit of cadence. cycle-start kicks one off; cycle-end wraps it and rolls
  incomplete issues forward. An issue must be **Todo** (not Backlog) to appear on the cycle board.
- **One branch + one PR per issue.** Branch name comes from the tracker.

## Ticket structure (universal)

Every issue the suite creates (plan-project, change-scope) follows **one canonical shape**,
regardless of project. The *content* is project-specific; the *structure* never is.

**Title** — commit-shaped: `type(scope): imperative summary`, with `type` from the project's
commit format (`feat|fix|test|docs|refactor|chore`) and `scope` the touched area.

**Body** — these sections, in this order (Markdown `##` headings):

```markdown
[Optional one-line lead-in linking the parent issue / ADR this follows from.]

## Context
Why this exists: the problem, prior-issue/ADR links, evidence. Enough for a
cold reader to judge the AC.

## Scope
What to do — the deliverables, as bullets.

## Out of scope
Explicit non-goals (omit the section only when there's genuinely nothing to fence off).

## Acceptance Criteria
- [ ] AC1 (<short label>, <class>) -- <one verifiable claim>
- [ ] AC2 (<short label>, <class>) -- ...

## References
- Related issues / ADRs / files / docs (omit if none).
```

**AC lines** — numbered `AC<n>`, one verifiable claim each, tagged with a short label plus the
**class** from the three-class taxonomy (`code` / `dev execution` / `prod execution` — semantics in
`skills/flow-ship-issue/references/ac-classification.md`). The class tag is what lets sanity-check
and ship enforce the right kind of evidence.

**Metadata** — always set the **project** (issues without it fall out of the project view); set the
**milestone** (a phase, or the perpetual Ops milestone for reactive/hardening work); one **label**
from the project's fixed set; a **priority**. When picked into a cycle, status goes **Todo**.

If an adopted team already has its own house format, mirror their *presentation* (heading names,
AC numbering style) — but the canonical elements above (context, scope, classed + verifiable AC,
references, metadata rules) must all still be present. Structure is spine; rendering is profile.

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

## Guidelines

Beyond this method, `guidelines/` holds stack-agnostic engineering discipline (debugging &
investigation, scoping & tickets, verification & durability) distilled from real project lessons.
Skills reference the relevant one when they hit its situation — see `guidelines/README.md`.
