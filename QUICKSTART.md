<div align="center">

# 🚀 Quickstart

**Get `flow` running in a project in ~5 minutes.**
Claude Code and **opencode 1.18.x** are validated — see [`install/`](install/) for the rest.

</div>

---

## 1 · Install

Install this repo as a **plugin** — not loose skills. (The skills reference package-internal paths
that only resolve when the package stays intact.)

**Claude Code:** see [`install/claude-code.md`](install/claude-code.md)
```bash
/plugin marketplace add noahwins-ng/flow-workflow
/plugin install flow@flow
```
**opencode:** see [`.opencode/INSTALL.md`](.opencode/INSTALL.md)
```json
{ "plugin": ["/abs/path/to/flow-workflow/.opencode/plugin/flow.ts"] }
```

✅ **Verify:** ask **`/flow`** (Claude Code) or `/flow` / `use the flow skill` (opencode) — you should get the suite index.

## 2 · Tracker access

| You have… | Do this |
|---|---|
| A **Linear MCP** in your session (Claude Code or opencode `mcp.linear: https://mcp.linear.app/mcp`) | Nothing — the skills use it natively (opencode: OAuth `needs_auth` → `connected`) |
| No Linear MCP | Export `LINEAR_API_KEY` (a Linear personal API key); the `adapters/linear.sh` fallback uses it (needs `curl` + `jq`) — Claude Code path; not needed on opencode |

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
