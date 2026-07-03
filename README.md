# dev-workflow — a portable, opinionated workflow skill suite

A personal orba/gstack-style package of dev-workflow skills, generalized from a Claude-Code
slash-command workflow so they run under any harness that reads files and runs a shell
(Claude Code, Codex, Cursor, opencode, pi). The flagship is **ship-issue** — one tracked issue from
ticket to merged-and-verified (pick → implement → sanity check → review → ship). See `ROADMAP.md`
for the full skill list, coupling analysis, and what's still pending.

## Design: spine + profile

- **Spine** (this package): the invariant discipline — phase sequence, hard gates, acceptance-
  criteria classification with evidence receipts, audit-comment contract, WIP-attempt recovery,
  same-SHA flap detection. Never changes between projects.
- **Profile** (`workflow-profile.yaml`, per project): every substitutable noun — tracker + issue-id
  format, branch/commit/PR conventions, lint/format/type/test commands, deploy-identity and health
  checks, doc paths, architecture rules, AC keywords.

The spine reads the profile at Step 0 and executes using its values. A different stack fills in
`npm run lint` / GitHub Issues / Vercel and the same pipeline runs unchanged.

## Layout

```
profile.template.yaml         copy → workflow-profile.yaml (package-wide config); init generates it
QUICKSTART.md                 5-minute first run
ROADMAP.md                    skill list, coupling analysis, resolved decisions
install/                      per-harness install guides (Claude Code supported; others placeholder)
method/
  conventions.md              the opinionated method the skills assume
  project-setup-playbook.md   inception reference the flow-* inception skills operationalize
  claude-md-template.md       Working Approach (verbatim) + Project Conventions placeholders
  guidelines/                 stack-agnostic discipline: debugging, scoping, verification (skills cite these)
  docs-skeleton/docs/         plan, spec, ADR template, INDEX, architecture, retros, AC-templates, guides — scaffolded by init
skills/                       (all skills prefixed flow- to namespace across harnesses)
  flow/                       index/help: "what can this do?" — routes you to the right skill
  flow-init/                  bootstrap: scaffold docs skeleton + profile (greenfield & mid-project; PRD-aware)
  flow-doctor/                preflight: profile + env health check (read-only)
  flow-plan-project/          inception: PRD → phases → Linear project + milestones + issues + plan
  flow-gen-claudemd/          inception: generate CLAUDE.md in the house style
  flow-ship-issue/            flagship pipeline (SKILL.md + references/ + 2 shared refs) — the old /go
  flow-fix/                   recover a broken ship run: diagnose (from git) → fix → resume
  flow-session-check/         restore context: branch → issue → git state → directional AC
  flow-sync-issue-status/     reconcile one issue's tracker status from git/PR state
  flow-status/                fast local-only git snapshot (no network)
  flow-cycle-start/  flow-cycle-end/   cadence rituals (active cycle, rollover, velocity, status update)
  flow-sync-plan/             reconcile the plan doc with the tracker (mechanical gap sweep)
  flow-change-scope/          formalize add/drop/modify across spec + plan + overview + tracker + ADR
  flow-retro/                 milestone retro: invariant→guard audit + lessons-to-memory
  flow-server-audit/          prod durability/security/drift audit (deploy-topology template)
adapters/
  linear.sh                   tracker fallback — Linear GraphQL over curl+jq (needs LINEAR_API_KEY)
```

All skills share one per-project `workflow-profile.yaml`. Linear is the constant tracker, resolved
native-MCP-first with `adapters/linear.sh` as the universal fallback. **Adopt with `init`** — it
scaffolds the docs skeleton and a pre-filled profile into a new repo, and gap-fills (never clobbers)
an existing one.

## Adopt in a project

1. Install the package for your harness — **Claude Code is supported today**; see
   [`install/claude-code.md`](install/claude-code.md). (Install it as a *plugin*, not loose skills —
   the skills reference package-internal paths that only resolve with the package kept intact.)
2. Run **flow-init** in the target repo. It scaffolds the docs skeleton (or gap-fills an existing
   repo without clobbering), generates `workflow-profile.yaml`, and pre-fills what it can detect —
   leaving judgment-call fields (tracker prefix, `deploy.*`, `cadence.*`, `architecture_rules`)
   flagged for review.
3. Run **flow-doctor** to confirm the profile resolves, then invoke a skill: *"ship &lt;ISSUE&gt;"*,
   *"session-check"*, *"cycle-start"*, etc.

### New project from a PRD (inception)

Have a PRD / requirements brief you wrote with AI? Bootstrap the whole project from it:

1. Import the PRD into the repo, then **flow-init** — reads it, fills the profile + seeds the spec.
2. **flow-doctor** — sanity-check the setup.
3. **flow-plan-project** — decomposes the spec into phases, proposes milestones + issues with
   three-class AC (pause to approve), then creates the Linear **project + phase milestones + Ops &
   Reliability milestone + issues** and writes `project-plan.md`.
4. **flow-gen-claudemd** — generates `CLAUDE.md` in the house style.
5. **flow-cycle-start** — and start building.

The inception method is documented in `method/project-setup-playbook.md`.

## Cross-harness notes

Harness support: **Claude Code — supported.** Codex / Cursor / opencode / pi — *aspirational
targets, not yet validated* (each will need its own install adapter; the skill bodies are written to
avoid harness-specific assumptions). Portability is designed in via:

- **Tracker: native-first, adapter-fallback.** Tracker operations are capabilities, not hardcoded
  calls. If the harness exposes a Linear MCP tool, the agent uses it; otherwise it falls back to
  the bundled `adapters/linear.sh` (curl+jq, needs `LINEAR_API_KEY`). So a harness with Linear MCP
  needs no API key, and one without still works. See SKILL.md "Step 0b".
- **Deploy/verify access** goes through profile shell commands (git, gh, ssh, curl) — no harness
  built-ins assumed.
- **Progressive disclosure instead of sub-command reload.** The original `/go` re-invoked each
  sub-command to reload full instructions; here `SKILL.md` stays lean and the agent reads
  `references/NN-phase.md` on entering a phase — same effect, plain file reads.
- **Fresh-eyes review is optional.** If the harness has subagents, set `review.fresh_eyes_agent`;
  otherwise the agent does a single self-review pass.

## Validation (do this on a SECOND project, never on the source repo)

The source project's working slash-command workflow must not be risked. Prove the generalization
on a different project instead:

1. Fill in a profile for a small, low-stakes repo.
2. Run the pipeline on a trivial issue (a docs typo or one-line fix).
3. Confirm: correct branch, sanity gate blocks on a deliberately-broken AC, review runs, PR opens,
   deploy-identity gate fires, tracker closes with an audit comment carrying real receipts.
4. Only after that passes, use it for real work.
