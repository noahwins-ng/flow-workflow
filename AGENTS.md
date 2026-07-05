# flow — structured dev-workflow skills

This package is **flow**: a portable, structured dev-workflow skill suite. It takes a tracked issue
from pick → implement → sanity-check → adversarial review → ship, plus the inception, cadence, and
recovery skills around that pipeline. Design: **spine + profile** — the discipline (phase order,
hard gates, three-class acceptance criteria with evidence, recovery) is invariant and lives in the
skills; every project-specific noun (tracker, commands, paths, hosts) lives in that project's
`workflow-profile.yaml`.

If you are an agent reading this file, you can use the suite on **any harness**: every skill is
plain markdown — read the relevant `skills/flow-*/SKILL.md` and follow it. No skill depends on a
harness-specific invocation mechanism; cross-skill references are always *"read that file and
follow it"*.

## Resolving the package root

Package-internal references (`adapters/…`, `method/…`, `skills/flow-*/…`) are relative to the
package root. Resolve it in this order:

1. `${CLAUDE_PLUGIN_ROOT}` — set under a Claude Code plugin install.
2. `$FLOW_ROOT` — set it yourself for a manual / loose install.
3. **The directory containing this `AGENTS.md`** — walk up from any skill file to the directory
   that holds `profile.template.yaml` and `skills/`.

## Skill index

| Skill | What it does |
|-------|--------------|
| `flow` | Index/help — routes "which skill do I use?" |
| **Delivery** | |
| `flow-ship-issue` | The flagship pipeline: pick → implement → sanity → review → ship |
| `flow-fix` | Recover a broken ship run — diagnose the failed phase from git state, resume |
| **Inception** | |
| `flow-init` | Scaffold docs skeleton + `workflow-profile.yaml` (greenfield or gap-fill) |
| `flow-tailor` | Derive + prove the project-specific workflow layer (probes, commands, AC surfaces) |
| `flow-plan-project` | PRD → phases → tracker project + milestones + issues + plan doc |
| `flow-gen-claudemd` | Generate the project's `CLAUDE.md` in house style |
| **Cadence** | |
| `flow-cycle-start` / `flow-cycle-end` | Weekly rituals — kickoff, rollover, velocity, status update |
| `flow-retro` | Milestone retro: invariant → guard audit + lessons |
| **Scope & sync** | |
| `flow-change-scope` | Formalize add/drop/modify across spec + plan + overview + tracker + ADR |
| `flow-sync-plan` | Reconcile the plan doc with the tracker |
| `flow-sync-issue-status` | Reconcile a drifted tracker status from git/PR state |
| **Session & ops** | |
| `flow-session-check` | Restore context: branch → issue → git state → directional AC read |
| `flow-status` | Fast local-only git snapshot |
| `flow-server-audit` | Prod durability/security/drift audit (read-only) |
| `flow-doctor` | Preflight — profile complete, commands/paths/tracker resolve? |

## Per-project setup

From the target project repo: run `flow-init` (scaffolds docs + profile), then `flow-tailor`
(derives + proves the project-specific values), then `flow-doctor` (verifies everything resolves).
Skills read `profile.<key>` from `workflow-profile.yaml`; an empty value means "this project has
no such concept — skip that step".

## Tracker

Linear, resolved **native-MCP-first**: if the harness exposes a Linear tool, use it; otherwise
`adapters/linear.sh` (curl + jq, needs `LINEAR_API_KEY`). The universal ticket structure lives in
`method/conventions.md` ("Ticket structure").

## More

- `README.md` — full overview · `QUICKSTART.md` — first run
- `install/README.md` — distribution model + the per-harness adapter contract
- `install/harness-notes.md` — per-harness differences (agent naming, subagents, hooks)
- `method/conventions.md` — the method the skills assume
