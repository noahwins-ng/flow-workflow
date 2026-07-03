# 🗺️ Roadmap

> **At a glance:** 16 `flow-*` skills built · on GitHub (`noahwins-ng/flow-workflow`, private) ·
> distribution decided (multi-manifest plugin) · **not yet validated end-to-end**.

**Goal:** a personal, opinionated dev-workflow skill package (orba/superpowers-style) that runs
across Claude Code, Codex, Cursor, opencode, and pi — generalized from the `equity-data-agent`
`.claude/commands/` workflow **without touching that working workflow**.

---

## 🧱 The idea — coupling layers

Every skill sits on one or more layers. The profile absorbs (1) and (2); (3) is what makes the
package *opinionated*.

1. **Stack** — toolchain (lint/test/deploy commands) → profile.
2. **Tracker** — Linear (the constant) → capability, native-MCP-first, `adapters/linear.sh` fallback.
3. **Methodology** — docs skeleton (plan / spec / ADRs / retros), cycle+milestone model, the
   invariant-guard practice, memory capture → *a way of working*, not a swappable command.

## ✅ Skills — all 16 built

All skills are prefixed **`flow-`** to namespace them across harnesses (no universal namespace
scheme exists, so the prefix is baked into each skill's `name:` + directory — `flow-init`/`flow-status`
would otherwise shadow Claude Code built-ins).

| Skill | Layers | State |
|-------|--------|:-----:|
| `flow-ship-issue` — pick→implement→sanity→review→ship *(the old /go)* | stack + tracker | ✅ |
| `flow-fix` — recover a broken ship run: diagnose→fix→resume | git + tracker | ✅ |
| `flow-init` — scaffold docs skeleton + profile (PRD-aware) | — | ✅ |
| `flow-plan-project` — PRD → phases → Linear project/milestones/issues + plan | tracker + methodology | ✅ |
| `flow-gen-claudemd` — generate CLAUDE.md in house style | methodology | ✅ |
| `flow-doctor` — profile + env preflight | — | ✅ |
| `flow-session-check` | git + tracker | ✅ |
| `flow-status` | git | ✅ |
| `flow-sync-issue-status` *(was sync-linear)* | git + tracker | ✅ |
| `flow-cycle-start` | tracker + cadence + plan | ✅ |
| `flow-cycle-end` | tracker + cadence + plan + status-update | ✅ |
| `flow-sync-plan` *(was sync-docs)* | plan + ADR + tracker | ✅ |
| `flow-change-scope` | 4 doc surfaces + ADR + tracker | ✅ |
| `flow-retro` — invariant→guard audit + lessons | all + memory + retros | ✅ |
| `flow-server-audit` — deploy-topology template | infra (Compose/ssh default) | ✅ |
| `flow` — index/help | — | ✅ |

**Inception flow:** `flow-init` (import PRD) → `flow-doctor` → `flow-plan-project` →
`flow-gen-claudemd` → `flow-cycle-start`. Operationalizes `method/project-setup-playbook.md`.
⚠️ Tracker *creation* ops (project/milestone/issue) need native Linear MCP — the shell adapter
doesn't implement creation yet (candidate extension).

## 🧭 Decisions

**Methodology scope & docs model** *(resolved)* — full opinionated suite + `flow-init` bootstrap;
the package ships `method/docs-skeleton/` and `flow-init` scaffolds it. `flow-init` is
non-destructive: greenfield scaffolds everything, mid-project gap-fills and points the profile at
existing docs. (Profile honors "empty = skip" so a skill degrades gracefully if a surface is absent.)

**Distribution** *(2026-07-04)* — **multi-manifest plugin/marketplace**: one `skills/` source + a thin
manifest per harness, modeled on [obra/superpowers](https://github.com/obra/superpowers) +
[wshobson/agents](https://github.com/wshobson/agents). Installs the repo as a **unit per harness**, so
the shared root (`adapters/`, `method/`, cross-skill refs) survives.
❌ Rejected Vercel `npx skills` CLI — scatters skills into self-contained folders, breaking the shared
root. Manifests: `.claude-plugin/` ✅; `.cursor-plugin/` / `.codex-plugin/` / `.opencode/` /
`.pi/extensions/` to add one at a time after Claude Code is validated. See [`install/`](install/).

## 🧪 Validation

The suite is written but **unrun**. [`VALIDATION.md`](VALIDATION.md) is the end-to-end runbook
(install → adapter smoke test → inception → daily loop → cadence → mid-project adoption → self-checks)
with a watch-list of untested seams. Run it on a throwaway Claude Code + disposable Linear project first.

## 📋 Not yet done

- [ ] Validate the Claude Code plugin install end-to-end (the gating step).
- [ ] Smoke-test `adapters/linear.sh` against the live API (harnesses without Linear MCP).
- [ ] Make the repo public before real distribution.
- [ ] Add + validate per-harness manifests (Cursor / Codex / opencode / pi), one at a time.
- [ ] Extend the adapter with Linear *creation* ops (for `flow-plan-project` without native MCP).
- [ ] Decide whether deploy/verify should be capability-resolved for shell-sandboxed harnesses.
