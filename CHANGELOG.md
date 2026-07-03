# Changelog

All notable changes to the `flow` dev-workflow skill suite. Format loosely follows Keep a Changelog.
The **spine** ships from this repo; each adopting project keeps its own `workflow-profile.yaml`, so
"updating" a project = pulling a new spine version here (the profile schema is backward-additive).

## [Unreleased]
### Added
- **Bundled `flow-code-reviewer` subagent** (`agents/`) — the review phase now ships an independent
  fresh-eyes reviewer, auto-registered on Claude Code plugin install; `profile.review.fresh_eyes_agent`
  defaults to it. Generalized from the source repo's equity-specific `code-reviewer-ediff` — it reads
  project rules from the profile + CLAUDE.md. Also usable as a prompt template on generic-subagent harnesses.

### Enhanced (flow-ship-issue — industry best practice + obra/superpowers)
- **Test-first discipline** — implement phase now works red→green→refactor; bugs get a
  reproducing test ("watch it fail for the right reason") and code AC are test-pinned.
- **Automated security gate** — sanity-check adds a secret scan + dependency CVE audit
  (`profile.verify.security`) triggered on lockfile changes; high/critical CVEs block ship.
- **Fresh-evidence gate** — ac-classification + verification guideline now require evidence run in
  the current session and ban "should/probably/seems" as proof (superpowers' gate function).
- **Confirm-the-approach step** — a lightweight design gate before implementation (Think Before Coding).
- New AC-templates: dependency changes (audit clean) and user-facing changes (docs/changelog).
- `INFLUENCES.md` credits obra/superpowers + wshobson/agents and lists candidate future borrows.
- **Receiving-review discipline** (review phase) — process each finding with rigor (restate → verify
  → fix or push back), no reflexive agreement. From superpowers' *receiving-code-review*.
- **File-mapping + testable micro-steps** (implement Step 2b) for multi-file issues. From
  superpowers' *writing-plans*.

### Decided
- Distribution = multi-manifest plugin/marketplace pattern (one `skills/` + a per-harness manifest,
  modeled on obra/superpowers + wshobson/agents). Keeps the repo a unit per harness so the shared
  root survives. Rejected Vercel `npx skills` CLI (scatters skills, breaks shared root). Per-harness
  manifests (`.cursor-plugin/` etc.) to add one at a time after Claude Code validation.

### Added
- `CLAUDE.md` for the package itself (authoring conventions, dogfooding the house style).
- Publishing: `LICENSE` (MIT), `.claude-plugin/marketplace.json`, `PUBLISHING.md` — installable as a
  Claude Code plugin marketplace from GitHub.
- `VALIDATION.md` — end-to-end runbook to prove the suite on a throwaway project (install, adapter
  smoke test, inception, daily loop, cadence, mid-project adoption, self-checks) + untested-seam watch-list.
- `flow-fix` — recover a broken ship run: diagnose the failed phase from git state, fix, resume
  (ports the source repo's `/fix`; the one parity gap that was missing).
- `flow` — index/help skill routing "what can this do?" to the right skill.
- `QUICKSTART.md` — 5-minute first run.
- `install/` — per-harness install guides: `claude-code.md` (supported) + placeholder stubs for
  Codex / Cursor / opencode / pi, plus the common adapter contract in `install/README.md`.
- `method/guidelines/` — stack-agnostic engineering discipline distilled from the source project's
  memory/feedback log: debugging-and-investigation, scoping-and-tickets, verification-and-durability.
  Cited by flow-ship-issue (implement + ac-classification) and flow-retro.
- Inception flow for bootstrapping a project from a PRD:
  - `flow-init` is now PRD-aware (reads an imported brief, seeds the spec + project fields).
  - `flow-plan-project` — decompose spec → phases → create Linear project + milestones (+ Ops &
    Reliability) + issues with three-class AC, and seed `project-plan.md`. Propose-then-create.
  - `flow-gen-claudemd` — generate `CLAUDE.md` (Working Approach + Project Conventions) in house style.
- `method/project-setup-playbook.md` + `method/claude-md-template.md` — inception references,
  generalized from the source repo's real playbook and CLAUDE.md.
- Profile `taxonomy` section (labels, team_id, ops_milestone); docs-skeleton gains `AC-templates.md`
  and `guides/dev-workflow.md`.

## [0.1.0] — 2026-07-03
### Added
- Initial suite, generalized from a Claude-Code slash-command workflow. 11 skills, all namespaced
  `flow-`: ship-issue (the old `/go` pipeline), session-check, sync-issue-status, status,
  cycle-start, cycle-end, sync-plan, change-scope, retro, server-audit, init.
- `flow-doctor` preflight (profile + environment health check).
- Spine + profile design: invariant discipline in the skills, project nouns in `profile.template.yaml`.
- Tracker as a capability: native Linear MCP first, `adapters/linear.sh` (curl+jq) fallback —
  get/status/comment plus cadence ops (active cycle, project status update).
- Shipped methodology: `method/conventions.md` + `method/docs-skeleton/` scaffolded by `flow-init`.
- Claude Code install layer under `install/`.

### Known gaps
- Not yet run end-to-end (validation deferred to a real Claude Code project).
- `adapters/linear.sh` not smoke-tested against the live API.
- Only Claude Code install is documented; Codex / Cursor / opencode / pi are aspirational targets.
