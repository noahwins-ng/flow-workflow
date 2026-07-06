# 🗺️ Roadmap

> **At a glance:** 17 `flow-*` skills · public (`noahwins-ng/flow-workflow`, MIT) · multi-manifest
> plugin · **validated end-to-end on Claude Code 2026-07-04** (other harnesses aspirational).

**Goal:** a personal, structured dev-workflow skill package (orba/superpowers-style) that runs
across Claude Code, Codex, Cursor, opencode, and pi — generalized from the `equity-data-agent`
`.claude/commands/` workflow **without touching that working workflow**.

---

## 🧱 The idea — coupling layers

Every skill sits on one or more layers. The profile absorbs (1) and (2); (3) is what makes the
package *structured*.

1. **Stack** — toolchain (lint/test/deploy commands) → profile.
2. **Tracker** — Linear (the constant) → capability, native-MCP-first, `adapters/linear.sh` fallback.
3. **Methodology** — docs skeleton (plan / spec / ADRs / retros), cycle+milestone model, the
   invariant-guard practice, memory capture → *a way of working*, not a swappable command.

## ✅ Skills — all 17 built

All skills are prefixed **`flow-`** to namespace them across harnesses (no universal namespace
scheme exists, so the prefix is baked into each skill's `name:` + directory — `flow-init`/`flow-status`
would otherwise shadow Claude Code built-ins).

| Skill | Layers | State |
|-------|--------|:-----:|
| `flow-ship-issue` — pick→implement→sanity→review→ship *(the old /go)* | stack + tracker | ✅ |
| `flow-fix` — recover a broken ship run: diagnose→fix→resume | git + tracker | ✅ |
| `flow-init` — scaffold docs skeleton + profile (PRD-aware) | — | ✅ |
| `flow-tailor` — derive + prove the project-specific workflow layer | all (it fits them) | ✅ |
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

**Inception flow:** `flow-init` (import PRD) → `flow-tailor` → `flow-doctor` → `flow-plan-project` →
`flow-gen-claudemd` → `flow-cycle-start`. Operationalizes `method/project-setup-playbook.md`.
⚠️ Tracker *creation* ops (project/milestone/issue) need native Linear MCP — the shell adapter
doesn't implement creation yet (candidate extension).

## 🧭 Decisions

**Methodology scope & docs model** *(resolved)* — full structured suite + `flow-init` bootstrap;
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

**Universality = derived fit, not universal fit** *(2026-07-06)* — we don't chase a schema that fits
every project shape. Instead the ship gates are **topology-neutral contracts** (identity /
runtime-load / health), and **`flow-tailor` guides the agent to derive + prove this project's
bespoke answers** to them (probes, verify commands, AC surfaces, rules) on top of the spine.
`examples/` profiles are reference derivations that seed tailoring, not archetype products.
❌ Rejected the pre-built archetype matrix — always one shape short; the agent derives better than
we pre-enumerate. Portability (per-harness manifests) stays the package's own responsibility.

## 🧪 Validation

**Validated end-to-end 2026-07-04** (Claude Code, disposable Node sandbox) — all 8
[`VALIDATION.md`](VALIDATION.md) phases exercised: CI green, hooks, test-first, subagent dispatch,
real Linear inception, cadence + retro. **PASS with 2 defects, both now fixed** (FAIL-1 subagent
namespacing, FAIL-2 plan-project ticket convention). The live `adapters/linear.sh` GraphQL path is
**intentionally not exercised** — it's the fallback for harnesses *without* Linear MCP, and native MCP
is the primary path. Static-reviewed clean (state-by-UUID, enum values confirmed); not a gap for MCP users.

## 📋 Next (two tracks, 2026-07-06)

**Track 1 — prove the derived-fit model** (universality is the agent's job now; test how well
the package guides it):
- [ ] Run `flow-init → flow-tailor → flow-doctor` on a **real project** — flow-tailor's first
      execution *is* its validation run (the prove-step generates its own evidence). Watch for:
      questions `tailoring.md` should have asked but didn't, values the agent wanted to invent
      instead of leaving empty, and how UNPROVEN behaves when prod isn't reachable.
- [ ] Ship one ticket through the tailored profile end-to-end — the probes surviving a real
      `flow-ship-issue` is the success measure (and the universality n=2).

**Track 2 — portability** (the package's own homework; one harness at a time, validate before
adding the next):
- [ ] **Codex first** — manifest *generated* from the one `skills/` source (model on superpowers'
      `sync-to-codex-plugin.sh` / `package-codex-plugin.sh`, not handwritten). Validate read-only
      skills (`flow-status`, `flow-session-check`), fill the `install/harness-notes.md` row with
      what the harness **actually** registered, then the write-path skills.
- [ ] Cursor second; opencode / pi after — same recipe per harness.

**Backlog (deferred by choice, not gaps):**
- [ ] `method/scaffolds/` topology variants — both field runs correctly *skipped* most scaffolds
      (Vercel needs no cd.yml; husky owned hooks; greenfield had no stack). Improve them from the
      argus Phase-0 VPS run's evidence, not speculatively.
- [ ] Smoke-test `adapters/linear.sh` against the live API (harnesses without Linear MCP).
- [ ] Extend the adapter with Linear *creation* ops (for `flow-plan-project` without native MCP).
- [ ] Decide whether deploy/verify should be capability-resolved for shell-sandboxed harnesses.
- [ ] Pressure-test the load-bearing disciplines (superpowers' writing-skills TDD: baseline an
      agent *without* the skill, watch it fail, verify compliance with it).

**Done since the last refresh:** repo public (MIT) · Claude Code plugin install validated
(marketplace add → install → skills registered) · v0.2.0 released.
