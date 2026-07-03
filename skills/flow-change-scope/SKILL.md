---
name: flow-change-scope
description: >-
  Formalize a requirement change (add / drop / modify): update the spec, the plan, the architecture
  overview, and the tracker, and file an ADR if the change is architecturally significant. Use when
  the user says "change scope", "/flow-change-scope", "drop <ISSUE>", "add a requirement", or describes a
  requirement changing.
---

# change-scope

Formalize a scope change across the docs surfaces + tracker. The user gives the type + description
(e.g. `drop <ISSUE> — switching to RSS instead of the paid API`). Reads `profile.docs.*` and
`profile.cadence.project`. Skip any doc step whose profile path is empty.

## Step 1 — Identify the change type
**add** / **drop** / **modify**. If unclear from the argument, ask before proceeding.

## Step 2 — Update the spec (`profile.docs.spec`)
- **add**: insert the requirement into the right phase — the *what* and *why*, plus constraints.
- **drop**: remove/mark it dropped; fix surrounding context so the spec still reads coherently.
- **modify**: change only what changed; update rationale if it shifted.

## Step 3 — Update the architecture overview (`profile.docs.architecture`)
Only if the change touches data flow, component responsibilities, external surfaces, or infra.
Otherwise skip.

## Step 4 — Update the plan (`profile.docs.plan`) inline
- **add**: draft a new plan entry (checkbox, id, sub-bullets) in the right phase — now, don't wait
  for flow-sync-plan.
- **drop**: remove the entry and its sub-bullets.
- **modify**: update the entry's text/sub-bullets (flow-sync-plan only handles status, not text).

## Step 5 — Update the tracker
- **add**: create a new issue in `profile.cadence.project` — title, description, AC, milestone,
  priority.
- **drop**: cancel the issue.
- **modify**: update the issue description + AC.
Then post an audit comment on the issue (all three types):
```
Scope change [add|drop|modify] — YYYY-MM-DD
What changed: <one line>
Reason: <from the user>
Spec: <profile.docs.spec> — <section>
ADR: <path> | none
```

## Step 6 — ADR check
Warrants an ADR if it changes architecture/data flow/responsibilities, a future reader would ask
"why?", or it affects multiple phases. If yes and `profile.docs.decisions_dir` is set: create a
numbered ADR from `profile.docs.adr_template`, list it in `profile.docs.adr_index`.

## Step 7 — Report
```
Scope change: [add|drop|modify]
Spec:     updated <spec> — <section> | none
Overview: updated <architecture> — <section> | none
Plan:     <added|removed|text updated> | none
Tracker:  <id> [created|cancelled|updated] — <title>
ADR:      <path> | none
```
