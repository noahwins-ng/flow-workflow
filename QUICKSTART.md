# Quickstart

Get the `flow` suite running in a project in ~5 minutes. (Claude Code is the supported harness
today — see `install/` for the aspirational others.)

## 1. Install (Claude Code)

Install this repo as a **plugin** (not loose skills — the skills reference package-internal paths
that only resolve with the package intact). See [`install/claude-code.md`](install/claude-code.md).
Verify: ask *"/flow"* — you should get the suite index.

## 2. Tracker access

- Have a **Linear MCP** in your session? Nothing to do — the skills use it natively.
- Otherwise export `LINEAR_API_KEY` (a Linear personal API key); the `adapters/linear.sh` fallback
  uses it (needs `curl` + `jq`).

## 3a. Existing project

```
flow-init         # gap-fills docs + generates workflow-profile.yaml (never clobbers)
flow-doctor       # confirms the profile's commands/paths/tracker resolve
```
Review the fields `flow-doctor` flags, then work: `flow-session-check`, `flow-ship-issue <ID>`.

## 3b. New project from a PRD

Drop your PRD/requirements brief in the repo, then:
```
flow-init            # reads the PRD, seeds the spec + profile
flow-doctor
flow-plan-project    # PRD → phases → Linear project + milestones + issues + plan  (approve before it creates)
flow-gen-claudemd    # generates CLAUDE.md in the house style
flow-cycle-start     # and start building
```

## 4. The daily loop

```
flow-session-check           # start of session — where was I?
flow-ship-issue <ID>         # take one ticket to merged-and-verified
flow-fix <ID>                # if a ship run broke: diagnose → fix → resume
```
Weekly: `flow-cycle-start` / `flow-cycle-end`. Milestone done: `flow-retro <phase>`.

## Lost?
Ask **/flow** for the full index, or read `README.md`.

> Status: the suite is written and internally consistent but **not yet run end-to-end**. Treat your
> first real project as the validation pass — see `ROADMAP.md`.
