# Changelog

All notable changes to the `flow` dev-workflow skill suite. Format loosely follows Keep a Changelog.
The **spine** ships from this repo; each adopting project keeps its own `workflow-profile.yaml`, so
"updating" a project = pulling a new spine version here (the profile schema is backward-additive).

## [Unreleased]
### Added (universality across project types)
- **Ship hard gates reframed as topology-neutral contracts** — what each gate *proves* (identity /
  runtime-load / health) is spine; the probe is profile. `05-ship.md` + the template's `deploy:`
  section now carry per-topology probe examples (VPS · serverless/PaaS · k8s · published package)
  and an explicit **no-deploy path**: all three empty ⇒ pipeline ends at merge and the report says
  which gates were profile-skipped — visible, never silent.
- **`examples/profile.library-cli.yaml`** — the no-deploy archetype (npm/PyPI package), proving the
  "empty = skip" degradation story end-to-end.
- **flow-doctor degradation report** (check 8) — lists every empty profile key and exactly what it
  turns off (ship gates, security gate, server-audit, fresh-eyes review, …), plus a contradiction
  heuristic (e.g. `audit.host` set but `deploy.health` empty). "Off" becomes a seen decision.
- **check.sh check 6** — example profiles must match the template schema; immediately caught the
  Node/Vercel example carrying `perpetual_milestones`/`health_*` under `cadence:` (template:
  `taxonomy:`) and missing `verify.security` — fixed.

### Added
- **Universal ticket structure** (`method/conventions.md` "Ticket structure") — the canonical issue
  shape (commit-shaped title; Context → Scope → Out of scope → Acceptance Criteria → References;
  `- [ ] AC<n> (<label>, <class>) -- <claim>` lines; metadata rules), codified from the reference
  project's live tickets. flow-plan-project + flow-change-scope now anchor on it — structure is
  spine, team presentation is mirrored on top (the FAIL-2 sampling step remains for rendering only).
- **`AGENTS.md`** — harness-neutral entry point (skill index, per-project setup, tracker resolution)
  so any agent that reads the repo can use the suite without a plugin manifest.
- **Package-root resolution chain**, documented once in `AGENTS.md` and echoed by the install docs:
  `${CLAUDE_PLUGIN_ROOT}` → `$FLOW_ROOT` → the directory holding `AGENTS.md`.
- **`install/harness-notes.md`** — the one home for per-harness facts (agent dispatch naming,
  subagent/hook support) + the universal dispatch rule; review / fix / server-audit prose now
  reference it instead of inlining Claude-Code specifics.
- **`scripts/check.sh` + a GitHub Actions `check` workflow** — mechanizes VALIDATION.md Phase 6:
  frontmatter (name==dir, description ≤1024 chars), YAML parses, shellcheck, package-internal
  cross-references resolve, and profile-key drift (skills reading keys the template doesn't define).

### Fixed
- **Profile-key drift caught by the new checker:** skills read `profile.cadence.perpetual_milestones`
  / `.health_on_track_min` and `profile.verify.deployed_sha` / `.runtime_id`, but the template defines
  them under `taxonomy.*` and `deploy.*` — the skills now read the template's real keys (this was
  silent-degradation drift of the FAIL-1 class).
- Bundled-subagent dispatch now resolves the agent name **symmetrically** — if the configured name
  doesn't resolve it retries with the other form (add/strip the `flow:` namespace), never silently
  falling back to self-review. Applied to the review dispatch + the `flow-investigator` dispatch in
  `flow-fix` / `flow-server-audit`; fixed a stale `install/claude-code.md` line that named the bare
  default.

## [0.2.0] — 2026-07-05
### Validated
- **First end-to-end validation pass** (2026-07-04, Claude Code, disposable Node sandbox) — all 8
  runbook phases exercised for real: CI ran green, hooks fired, test-first RED→GREEN, subagents
  dispatched, inception created a real Linear project, cadence + retro worked. PASS with 2 defects
  (below). Report: `flow-sandbox/test-report.md`.

### Fixed
- **FAIL-1: bundled subagents dispatched under the wrong name.** Claude Code registers plugin agents
  namespaced (`flow:flow-code-reviewer` / `flow:flow-investigator`) but shipped defaults used the bare
  name → review silently degraded to self-review. Profile default is now the namespaced form; review /
  fix / server-audit prose is namespace-aware; `flow-init` verifies it per-harness.
- **FAIL-2: flow-plan-project ignored the team's ticket convention.** Added Step 2a — sample 1–2
  existing issues and mirror their section layout + AC numbering; clarified in `ac-classification.md`
  that the `[class]` tags are semantic shorthand, not the rendered ticket format.

### Added
- **Repo-config scaffolds** (`method/scaffolds/`, dropped in by `flow-init`, placeholders filled from
  the profile): GitHub Actions **CI** (lint/format/types/test/security) + **CD** carrying the three
  hard gates (prod-SHA==merge, runtime-load, post-deploy smoke); a **commit-msg** git hook enforcing
  `vcs.commit_format`; a `Makefile` mapped to `verify.*`; `dependabot.yml`; a PR template. Plus an
  **ops-runbook** stub in the docs-skeleton (referenced by flow-investigator / flow-server-audit).
  Closes the loop: the ship skill *verified* the gates; CI now *enforces* them.
- **Optional Claude Code hooks bundle** (`hooks/`) — `protect-repo` (force-push / main-push /
  hard-reset / `rm -rf` guardrail) + `check-uncommitted` (session-end reminder), generalized from the
  source repo. Registered on install but **inert until enabled** (`FLOW_HOOKS=1` or a `.flow-hooks`
  marker) so installing flow never silently adds global git guardrails. Claude-Code-only.
- **Bundled `flow-investigator` subagent** (`agents/`) — read-only diagnostician (root-cause
  hypothesis + confidence + next-step commands, never remediates), generalized from the source repo's
  `ops-investigator`. Dispatched by `flow-fix` (complex/multi-signal failures — parallel per domain
  for multiple independent failures) and `flow-server-audit` (incident triage). Carries the
  debug-state-not-logs discipline.
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
