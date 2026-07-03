---
name: flow
description: >-
  Index and help for the flow dev-workflow suite — list what the skills do and which to run when.
  Use when the user says "flow", "/flow", "flow help", "what can the workflow do", "which flow skill
  do I use", or seems unsure which skill fits their situation.
---

# flow — workflow suite index

Point the user at the right skill for their situation. If they describe a task, name the specific
skill and (briefly) what it will do; if they just want the map, print the sections below.

## By moment

**New project (inception)** — from a PRD to a tracked, documented, ready-to-build repo:
`flow-init` (import PRD, scaffold docs + profile) → `flow-doctor` (verify setup) →
`flow-plan-project` (phases → Linear project/milestones/issues + plan) → `flow-gen-claudemd`
(generate CLAUDE.md) → `flow-cycle-start`.

**Daily / per-issue:**
- `flow-session-check` — restore context at the start of a session.
- `flow-status` — fast local git snapshot, no network.
- `flow-ship-issue <ID>` — the full pipeline: pick → implement → sanity → review → ship. (The old `/go`.)
- `flow-fix <ID>` — a ship run broke; diagnose, fix, resume from the failed phase.
- `flow-sync-issue-status <ID>` — tracker status drifted; reconcile it from git/PR state.

**Weekly / milestone (cadence):**
- `flow-cycle-start` — active cycle, suggested next pick.
- `flow-cycle-end` — shipped summary, rollover, velocity, status update.
- `flow-retro <phase>` — milestone retro: invariant→guard audit + lessons.

**Scope & docs:**
- `flow-change-scope add|drop|modify` — a requirement changed; update spec + plan + overview + tracker + ADR.
- `flow-sync-plan` — reconcile the plan doc with the tracker.

**Ops:**
- `flow-server-audit` — prod durability/security/drift snapshot → tracked tickets.

**Setup / meta:**
- `flow-init` · `flow-doctor` · `flow` (this index).

## Deeper reading
- `README.md` / `QUICKSTART.md` — install + first run.
- `method/conventions.md` — the method the skills assume.
- `method/guidelines/` — debugging, scoping, verification discipline.
- `ROADMAP.md` — status, coupling analysis, what's still aspirational.

Prefer to *do* rather than dump the whole list: if the user's intent is clear, route them to the one
skill and offer to run it.
