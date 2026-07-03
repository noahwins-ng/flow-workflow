---
name: flow-plan-project
description: >-
  Decompose a PRD / project-requirement spec into phases, then create the tracker project, phase
  milestones (+ a perpetual Ops & Reliability milestone), and issues with three-class acceptance
  criteria — following the existing Linear structure — and write the matching project-plan.md. Use
  after flow-init, or when the user says "plan the project", "unpack the PRD into phases", "create
  the Linear project and issues", or "/flow-plan-project".
---

# flow-plan-project

Turn the spec into a tracked plan. Operationalizes `method/project-setup-playbook.md`. Reads
`profile.docs.spec` (or a PRD the user points at), `profile.cadence.*`, `profile.taxonomy.*`.
**Propose first, create only on approval** — this writes real tracker state.

> Creation ops (project / milestone / issue) use your **native Linear tool** — `save_project`,
> `save_milestone`, `save_issue` or equivalents. The shell adapter does not implement creation yet;
> if you have no native Linear tool, stop and tell the user to run this on a harness that does.

## Step 1 — Read the anchor
Read the spec (`profile.docs.spec`) or the PRD path the user gives. Extract: the product summary,
the non-negotiable principles, and any phasing the author already implied.

## Step 2 — Propose the decomposition (no writes yet)
Draft, and present for approval:
1. **Phases** — a small ordered set (Phase 0 Foundation … Phase N), each with a one-line goal. Map
   1:1 to milestones. Always include a separate **"Ops & Reliability"** perpetual milestone.
2. **Issues per phase** — each with: title, one-paragraph scope, deliverables, and **acceptance
   criteria written in the three-class taxonomy** (code / dev-execution / prod-execution — see
   `skills/flow-ship-issue/references/ac-classification.md`). Keep issues shippable in ~1 cycle;
   split anything bigger. Suggest a label per issue from `profile.taxonomy.labels`.
3. **Cycle 1 pick** — which Phase 0/1 issues seed the first cycle.

Present as a phase-by-phase outline. **Pause for approval.** The user may edit phases, issues, AC,
or labels before anything is created. Do not proceed until confirmed.

## Step 3 — Create in the tracker (after approval)
Using native Linear tools, in order:
1. **Project** — create/ensure `profile.cadence.project` under team `profile.cadence.team` (skip if
   it already exists; never duplicate).
2. **Milestones** — one per phase, in order, + the "Ops & Reliability" milestone.
3. **Issues** — for each approved issue: set project, milestone, label, priority, and the AC in the
   description. **Always set the project** (issues without it fall out of the project view). Assign
   the Cycle 1 picks to the active cycle and set their status **Todo** (Backlog issues don't show on
   the cycle board); leave the rest in Backlog.
   - If a Linear state name collides with a type word, set state by its UUID, not its name.

## Step 4 — Write project-plan.md
Populate `profile.docs.plan` to mirror what you created: a `### Phase N — <name>` section per
milestone with a `- [ ] <ISSUE-ID>: <title>` line per issue (+ deliverable sub-bullets), and an
`### Ops & Reliability` section. This is the narrative twin of the tracker — every issue appears in
both. Commit `docs: seed project-plan.md from initial plan`.

## Step 5 — Report
```
Planned <project>: N phases, M issues

Phase 0 — <name>        (milestone created)
  <ID> <title>   [<label>]   → Cycle 1 (Todo)
  ...
Ops & Reliability       (perpetual milestone created)

project-plan.md seeded (M items).
Next: run flow-gen-claudemd, then flow-cycle-start to begin.
```
