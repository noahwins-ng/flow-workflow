# Project Setup Playbook (inception reference)

The generic, tracker-agnostic distillation of how a project gets bootstrapped from a PRD. The
inception skills (`flow-init` → `flow-plan-project` → `flow-gen-claudemd`) operationalize this.
Companion to `conventions.md` (which covers the ongoing method). Derived from a battle-tested
Linear + Claude Code setup; the war stories behind each invariant live in the source repo's
`docs/guides/project-setup-playbook.md`.

## Order of operations

1. **PRD / requirements** — a human+AI-authored brief. The anchor. Import it into the repo.
2. **`flow-init`** — read the PRD, fill the profile's project fields, seed `docs/project-requirement.md`
   (the spec) from it, propose an issue prefix. Confirm.
3. **`flow-plan-project`** — decompose the spec into phases → milestones + issues → create them in the
   tracker + write `project-plan.md`.
4. **`flow-gen-claudemd`** — generate `CLAUDE.md` from the profile + spec + repo conventions.
5. Repo foundation (Makefile, `.env.example`, `.gitignore`, commit-msg hook, CI/CD) — outside these
   skills' scope, but the playbook lists them; see the checklist below.
6. `flow-cycle-start` and begin building.

## Tracker structure (the taxonomy to follow)

- **One project** per repo (`cadence.project`).
- **Milestones = phases.** One milestone per phase (Phase 0, Phase 1, …). Finite.
- **One cross-cutting "Ops & Reliability" milestone** alongside the phases — reactive
  hardening/incident follow-ups land here, not forced into a phase. Perpetual (never "completes"),
  listed in `cadence.perpetual_milestones`.
- **Issues = deliverables** within a phase. Each carries scope, deliverables, and acceptance
  criteria written against the three-class taxonomy (see below).
- **Labels** — a small fixed set (e.g. `ai` / `backend` / `frontend` / `infra`), from
  `taxonomy.labels`. Ops findings → `infra`.
- **Cycles = 1-week.** Pull the first milestone's issues into Cycle 1 and set them **Todo** (Backlog
  issues don't appear on the cycle board).

## Three-class AC taxonomy (bake in from day one)

Every acceptance criterion is **code** / **dev-execution** / **prod-execution**. This is the same
discipline `flow-ship-issue` enforces (`skills/flow-ship-issue/references/ac-classification.md`).
Write issue AC in these terms at creation time so they're verifiable later. Keyword-triggered
runtime claims ("populated", "returns", "deployed", "visible") are never code AC.

## CLAUDE.md sections (what flow-gen-claudemd emits)

Working Approach (project-agnostic, shipped in `method/claude-md-template.md`): Think Before Coding ·
Simplicity First · Surgical Changes · Goal-Driven Execution. Then Project Conventions (filled per
project): Core Philosophy · Architecture · Stack · Repo Structure · Code Style · Git Workflow ·
Environment · Working Docs · Observability · Common Commands.

## Production invariants (before first real deploy — abbreviated)

1. Aggregate "green" (CI + CD + /health 200) does not prove durability — each proves a narrow claim.
2. Chaos-test what you claim survivable (a "survives reboot" AC is a failure injection, not a ping).
3. Runtime state must be declarative (schedules, restart policies, flags — in code, not toggled in a UI).
4. `restart: unless-stopped` on every prod service from day one (Docker's default is `no`).
5. Pending-reboot visibility wired in before the first outage, not after.
6. Document rejected alternatives (ADRs for architecture; bootstrap guide for ops choices).
7. The three-class AC taxonomy is load-bearing, not ceremony.
8. Reactive tickets are ~50% of true scope — budget a retro-sweep after every substantive phase.

## Inception checklist
```
[ ] PRD imported            [ ] docs/ structure (architecture, decisions, guides, retros)
[ ] profile filled          [ ] AC-templates.md (implicit AC per diff-path trigger)
[ ] spec (requirement.md)   [ ] Tracker: project + phase milestones + Ops & Reliability + cycles
[ ] project-plan.md         [ ] CLAUDE.md
[ ] CI (lint+type+test)     [ ] CD hard gates: prod SHA == merge, runtime-load, post-deploy smoke
```
