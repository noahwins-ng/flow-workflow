<div align="center">

# 🚀 Quickstart

**Get `flow` running in a project in ~5 minutes.**
Claude Code is supported today — see [`install/`](install/) for the aspirational others.

</div>

---

## 1 · Install

Install this repo as a **plugin** — not loose skills. (The skills reference package-internal paths
that only resolve when the package stays intact; see [`install/claude-code.md`](install/claude-code.md).)

```bash
/plugin marketplace add noahwins-ng/flow-workflow
/plugin install flow@flow
```

✅ **Verify:** ask **`/flow`** — you should get the suite index.

## 2 · Tracker access

| You have… | Do this |
|---|---|
| A **Linear MCP** in your session | Nothing — the skills use it natively |
| No Linear MCP | Export `LINEAR_API_KEY` (a Linear personal API key); the `adapters/linear.sh` fallback uses it (needs `curl` + `jq`) |

## 3 · Set up your project

**Existing project**
```bash
flow-init      # gap-fills docs + generates workflow-profile.yaml (never clobbers)
flow-tailor    # derives + PROVES the project-specific values (deploy probes, verify, AC surfaces)
flow-doctor    # confirms the profile's commands / paths / tracker resolve
```
Review anything `flow-doctor` still flags, then jump to the daily loop.

**New project from a PRD** — drop your brief in the repo, then:
```
flow-init  →  flow-tailor  →  flow-doctor  →  flow-plan-project  →  flow-gen-claudemd  →  flow-cycle-start
   │             │               │                 │                     │                    │
 reads PRD,   derives +      sanity-       phases → Linear        CLAUDE.md in           start
 seeds spec   proves the     checks        project + issues       house style            building
 + profile    bespoke fit    setup         (approve first)
```

## 4 · The daily loop

```bash
flow-session-check      # start of session — "where was I?"
flow-ship-issue <ID>    # take one ticket to merged-and-verified
flow-fix <ID>           # if a ship run broke: diagnose (from git) → fix → resume
```

**Weekly:** `flow-cycle-start` / `flow-cycle-end`  ·  **Milestone done:** `flow-retro <phase>`

---

<div align="center">

**Lost?** Ask **`/flow`** for the full index, or read the [README](README.md).

</div>

> ⚠️ **Status:** the suite is written and internally consistent but **not yet run end-to-end**.
> Treat your first real project as the validation pass — see [`VALIDATION.md`](VALIDATION.md).
