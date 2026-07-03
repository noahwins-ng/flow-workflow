# Roadmap — workflow suite

Goal: a personal, opinionated dev-workflow skill package (orba/gstack-style) that runs across
Claude Code, Codex, Cursor, opencode, and pi. Extracted and generalized from the equity-data-agent
`.claude/commands/` workflow — **without touching that working workflow**.

## Coupling layers

Every candidate skill sits on one or more layers. The profile handles (1) and (2); (3) is what
makes a package "opinionated" and needs a decision (see Pending forks).

1. **Stack** — toolchain (lint/test/deploy commands). → profile.
2. **Tracker** — Linear (the constant). → capability, native-MCP-first, `adapters/linear.sh` fallback.
3. **Methodology** — a docs skeleton (plan / spec / ADRs / retros), a cycle+milestone model, the
   invariant-guard practice, memory capture. → a *way of working*, not a swappable command.

## Status — all skills ported ✅

All skills are prefixed **`flow-`** to namespace them across harnesses (no universal namespace
scheme exists across Claude Code / Codex / Cursor / opencode / pi, so the prefix is baked into each
skill's `name:` + directory). `flow-init` and `flow-status` would otherwise shadow Claude Code
built-ins; others collided with the source repo's own commands.

| Skill | Layers | State |
|-------|--------|-------|
| flow-ship-issue (pick→implement→sanity→review→ship) — the old /go | stack+tracker | ✅ |
| flow-session-check | git+tracker | ✅ |
| flow-sync-issue-status (was sync-linear) | git+tracker | ✅ |
| flow-status | git | ✅ |
| flow-cycle-start | tracker+cadence+plan | ✅ |
| flow-cycle-end | tracker+cadence+plan+status-update | ✅ |
| flow-sync-plan (was sync-docs) | plan+ADR+tracker | ✅ |
| flow-change-scope | 4 doc surfaces+ADR+tracker | ✅ |
| flow-retro | all + memory + retros | ✅ |
| flow-server-audit | deploy-topology template (Compose/ssh default) | ✅ |
| **flow-init** (bootstrap: scaffold docs skeleton + profile) | — | ✅ |

## Forks — RESOLVED (user chose 1A + 2A)

1. **Method scope → A**: full opinionated suite + `init` bootstrap.
2. **Docs model → A**: package ships `method/docs-skeleton/`; `init` scaffolds it.
   Nuance from the user: greenfield is the primary case, but `init` must also adopt **mid-project**
   — non-destructive, gap-fill only, point the profile at existing docs rather than duplicating.
   (The profile still honors "empty = skip" so a skill degrades gracefully if a surface is absent.)

## Not yet done
- Smoke-test `adapters/linear.sh` with a real `LINEAR_API_KEY` (harnesses without Linear MCP).
- Validate the whole suite on a SECOND low-stakes repo — never the source repo.
- Decide whether deploy/verify access should also be capability-resolved (native-first) for
  harnesses that sandbox shell / lack ssh.
