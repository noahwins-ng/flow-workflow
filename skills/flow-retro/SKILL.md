---
name: flow-retro
description: >-
  End-of-milestone retrospective: review what shipped across the milestone, run the invariant→guard
  audit, capture lessons to memory, feed insights into upcoming phases, and write a retro report.
  Use when a milestone/phase completes, or when the user says "retro", "/flow-retro", or "retrospective".
---

# retro

Milestone retrospective. Optional argument: milestone name (else the most recently completed one).
Reads `profile.cadence`, `profile.docs.*`. The distinctive, portable value here is **Step 3
(invariant→guard audit)** and **Step 4 (lessons to memory)** — not the doc plumbing.

## Step 1 — Gather
Identify the milestone. List its issues (title, status, cycles taken, PR link via `gh pr list
--state merged --search "<id>"`). For each, `git log --oneline --grep="<id>"` — multiple commits
hint at rework. Note the timeline (first start → last close).

## Step 2 — Analyze
What shipped (count + deliverables); velocity (issues/cycle, any that dragged); surprises (reopened,
descoped, split, or debug-heavy commit histories); blockers (external APIs, tooling).

## Step 3 — Invariant & guard audit  (the point of the retro)
For every incident/outage/surprise this period, ask: *"what invariant did this violate, and is it
now enforced by CI or a ship hard-gate?"*
1. List the incidents — closed reliability/ops tickets in this window (incidents from
   `profile.cadence.perpetual_milestones` count even if outside the retro's milestone) + Step 2
   surprises.
2. For each, one line: `<id>: <one-sentence invariant> — guard: <file path | "NONE — propose <id>">`.
   An *invariant* is a claim you assumed true that drifted (e.g. "prod SHA == merged commit").
3. If no guard exists: either draft a new reliability ticket now, **or** explicitly mark "accepted
   risk — <reason>". Never leave an invariant without a disposition.
4. **Same-shape clustering** — if two incidents violated invariants of the same shape, flag it; one
   deeper guard may replace two narrow ones.

## Step 4 — Capture lessons to memory
For each non-obvious lesson (what to repeat / avoid / what surprised us), save it to your memory
system so future sessions benefit. This is how ceremony compounds.

## Step 5 — Prep + review next phase
Show the next milestone's issues. Cross-reference each upcoming phase against this retro's lessons
for: invalidated requirements, underspecified ones, discovered dependencies, missing requirements,
complexity mismatches. Apply `method/guidelines/scoping-and-tickets.md` when re-sizing (the sizing
trap, cut-don't-rescope-thrice, bundle follow-ups, reactive-is-half-of-scope). Draft concrete `[add|drop|modify] <id>: <one line> — Reason: <lesson>`
recommendations **grounded in findings, not speculation**. **Pause for approval.** For each approved
one, **read `skills/flow-change-scope/SKILL.md` and follow it** (read-and-follow, not skill-invocation).
If nothing's warranted, say so.

## Step 6 — Update architecture overview
Update `profile.docs.architecture` against what actually shipped (new stores, surfaces, components,
infra). Skip if nothing changed.

## Step 7 — Cleanup
**Read `skills/flow-sync-plan/SKILL.md` and follow it** to reconcile the plan with the tracker.

## Step 8 — Project status update
Post a `project` status update on `profile.cadence.project`: health onTrack if the milestone shipped
mostly as planned, atRisk if >30% rolled over/descoped; body = shipped / what went well / lessons /
up next.

## Step 9 — Report + save
Report (timeline, shipped, went-well, harder-than-expected, lessons, invariant guards, phase-review
actions, next up). Then write it to `<profile.docs.retros_dir>/phase-<n>-<name>.md` and commit
`docs: add retro for <milestone>`.
