<div align="center">

# ⚡ flow

**An opinionated, portable dev-workflow skill suite.**
Take one tracked issue from *ticket → merged-and-verified* — and bootstrap whole projects from a PRD — with the same discipline on any agent harness.

![version](https://img.shields.io/badge/version-0.1.0-blue)
![license](https://img.shields.io/badge/license-MIT-green)
![status](https://img.shields.io/badge/status-pre--validation-orange)
![harness](https://img.shields.io/badge/harness-Claude%20Code-8A63D2)
![tracker](https://img.shields.io/badge/tracker-Linear-5E6AD2)

</div>

```
pick  →  implement  →  sanity check  →  review  →  ship
         ↑ hard gate ────────────┘        │          │
         AC classified + evidence         │          └─ verify deployed identity → tracker Done
         └────────── flow-fix: diagnose from git → resume ──────────┘
```

---

## What it is

`flow` is a suite of **16 skills** that encode a full delivery workflow — generalized from a
battle-tested Claude Code slash-command setup so the *discipline* travels to any project or harness.
It's opinionated on purpose: hard gates, evidence-backed acceptance criteria, and an audit trail,
not vibes.

> **Status — honest:** the suite is written and internally consistent but **not yet run end-to-end**.
> Treat your first real project as the validation pass (see [`VALIDATION.md`](VALIDATION.md)).

## The core idea: spine + profile

| | |
|---|---|
| **Spine** (this package) | The invariant discipline — phase order, hard gates, AC classification with evidence receipts, the audit-comment contract, WIP-attempt recovery, same-SHA flap detection. *Never changes between projects.* |
| **Profile** (`workflow-profile.yaml`, per project) | Every substitutable noun — tracker + issue-id format, branch/commit/PR conventions, lint/format/type/test commands, deploy-identity & health checks, doc paths, architecture rules. |

The spine reads the profile and runs. A Python/Hetzner project and a Node/Vercel project fill in
different commands — the same pipeline runs unchanged.

## The skills

**Delivery**
| Skill | Does |
|---|---|
| `flow-ship-issue` | The flagship pipeline: pick → implement → sanity → review → ship *(the old `/go`)* |
| `flow-fix` | Recover a broken ship run — diagnose the failed phase **from git state**, fix, resume |

**Inception** — bootstrap a project from a PRD
| Skill | Does |
|---|---|
| `flow-init` | Scaffold docs skeleton + `workflow-profile.yaml` (greenfield or gap-fill; PRD-aware) |
| `flow-plan-project` | PRD → phases → create Linear **project + milestones + issues** + seed the plan |
| `flow-gen-claudemd` | Generate `CLAUDE.md` in the house style |

**Cadence**
| Skill | Does |
|---|---|
| `flow-cycle-start` / `flow-cycle-end` | Weekly rituals — active cycle, rollover, velocity, status update |
| `flow-retro` | Milestone retro: **invariant → guard audit** + lessons-to-memory |

**Scope & docs**
| Skill | Does |
|---|---|
| `flow-change-scope` | Formalize add/drop/modify across spec + plan + overview + tracker + ADR |
| `flow-sync-plan` | Reconcile the plan doc with the tracker (mechanical gap sweep) |

**Session & status**
| Skill | Does |
|---|---|
| `flow-session-check` | Restore context: branch → issue → git state → directional AC |
| `flow-status` | Fast local-only git snapshot (no network) |
| `flow-sync-issue-status` | Reconcile a drifted tracker status from git/PR state |

**Ops & meta**
| Skill | Does |
|---|---|
| `flow-server-audit` | Prod durability/security/drift audit (deploy-topology template) |
| `flow-doctor` | Preflight — is the profile complete and do its commands/paths/tracker resolve? |
| `flow` | Index/help — *"what can this do?"*, routes you to the right skill |

## Quickstart

```bash
# 1. Install as a Claude Code plugin (keeps the package intact — see install/claude-code.md)
/plugin marketplace add noahwins-ng/flow-workflow
/plugin install flow@flow
```

**Existing project:** `flow-init` → `flow-doctor` → work with `flow-ship-issue <ID>`.

**New project from a PRD:** drop your brief in the repo, then
`flow-init` → `flow-doctor` → `flow-plan-project` → `flow-gen-claudemd` → `flow-cycle-start`.

Full walkthrough in [`QUICKSTART.md`](QUICKSTART.md).

## Harness support

Distributed as a **multi-manifest plugin** (one `skills/` source + a thin manifest per harness), the
pattern used by [obra/superpowers](https://github.com/obra/superpowers). This keeps the package a
**unit per harness**, so shared `adapters/`, `method/`, and cross-skill references resolve.

| Harness | Status |
|---|---|
| **Claude Code** | ✅ supported (`.claude-plugin/` present) |
| Cursor · Codex · opencode · pi | 🚧 aspirational — manifest per harness, added after Claude Code is validated |

Portability is designed in: tracker access is **native-MCP-first with a `curl`+`jq` fallback**,
deploy/verify goes through profile shell commands, phases load by plain file reads (progressive
disclosure), and the fresh-eyes reviewer is optional. Details: [`install/`](install/).

## Repo layout

<details>
<summary>Expand the tree</summary>

```
profile.template.yaml    package-wide config schema; flow-init generates a filled copy per project
QUICKSTART.md            5-minute first run
ROADMAP.md               skill list, coupling analysis, decisions, what's aspirational
VALIDATION.md            end-to-end runbook + watch-list of untested seams
CLAUDE.md                conventions for working ON this package
skills/                  the 16 flow-* skills (all prefixed to namespace across harnesses)
method/
  conventions.md         the method the skills assume
  project-setup-playbook.md   inception reference
  claude-md-template.md  Working Approach + Project Conventions placeholders
  guidelines/            debugging · scoping · verification discipline (skills cite these)
  docs-skeleton/         plan, spec, ADRs, retros, AC-templates — scaffolded by flow-init
adapters/linear.sh       tracker fallback (Linear GraphQL over curl+jq)
examples/                filled example profiles (Python, Node/Vercel)
install/                 per-harness install guides
.claude-plugin/          Claude Code plugin + marketplace manifests
```

</details>

## Documentation

- [`QUICKSTART.md`](QUICKSTART.md) — install + first run
- [`ROADMAP.md`](ROADMAP.md) — status, coupling analysis, decisions
- [`VALIDATION.md`](VALIDATION.md) — the runbook to prove it works
- [`PUBLISHING.md`](PUBLISHING.md) — how it's distributed
- [`method/conventions.md`](method/conventions.md) — the opinionated method

## License

[MIT](LICENSE) © 2026 Noah Ng
