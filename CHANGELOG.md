# Changelog

All notable changes to the `flow` dev-workflow skill suite. Format loosely follows Keep a Changelog.
The **spine** ships from this repo; each adopting project keeps its own `workflow-profile.yaml`, so
"updating" a project = pulling a new spine version here (the profile schema is backward-additive).

## [Unreleased]
### Added
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
