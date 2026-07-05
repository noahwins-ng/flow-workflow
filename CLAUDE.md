# Working Approach

## 1. Think Before Coding
Don't assume. State assumptions; if uncertain, ask. Present multiple interpretations rather than
picking silently. If a simpler approach exists, say so.

## 2. Simplicity First
Minimum that solves the problem. This is a *skills* package — prose, not product code. Every skill
should be the shortest set of instructions that reliably produces the behavior. No speculative
skills, no config nobody asked for. **Don't add features before the validation pass** (`VALIDATION.md`)
— unrun surface is negative value.

## 3. Surgical Changes
Touch only what you must. Match the existing skill voice and structure. When you rename or move a
skill, sweep every cross-reference (frontmatter `name`, README, ROADMAP, sibling read-and-follow refs).

## 4. Goal-Driven Execution
Turn changes into verifiable goals. For anything structural, the verify step is a slice of
`VALIDATION.md` — don't call a change done because it reads right.

---

# flow — Project Conventions

This repo is a **portable, structured dev-workflow skill suite** (orba/gstack-style). It was
generalized from a real Claude-Code slash-command workflow; the source repo lives at
`../equity-data-agent` and remains the reference implementation for conventions.

## Core philosophy: spine + profile
- **Spine** = the invariant discipline inside the skills (phase order, hard gates, AC classification
  with evidence, recovery, rituals). Never changes between projects.
- **Profile** = every project-specific noun, in a per-consumer `workflow-profile.yaml`. Skills read
  `profile.<key>` and **never hardcode** a tracker, command, path, or host.
- If you're about to bake a project fact into a skill, it belongs in the profile instead.

## Skill authoring rules
- Skills live in `skills/flow-<name>/SKILL.md`. Frontmatter `name:` **must equal** `flow-<dir>`.
  The `description:` carries the trigger phrases (natural language + the `/flow-<name>` slash form).
- **Every skill is prefixed `flow-`** — the portable namespace (no universal scheme across harnesses;
  the prefix is baked into name + dir). The lone exception is the `flow` index skill.
- **Cross-skill references use read-and-follow**, not "invoke the skill": *"read
  `skills/flow-sync-plan/SKILL.md` and follow it"*. Skill-tool invocation isn't portable across harnesses.
- **Package-internal paths are package-root-relative** (`adapters/…`, `method/…`, sibling skills).
  Root resolution chain (authoritative copy in `AGENTS.md`): `${CLAUDE_PLUGIN_ROOT}` → `$FLOW_ROOT`
  → the directory holding `AGENTS.md`.
- The three-class **AC discipline** (`skills/flow-ship-issue/references/ac-classification.md`) and the
  evidence-receipt / audit-comment contracts are load-bearing — preserve them when editing ship/sanity/review.

## Tracker = capability
Linear is the default tracker, resolved **native-MCP-first**, with `adapters/linear.sh` (curl+jq) as
the universal fallback. A skill describes the *operation* (`get_issue`, `set_in_progress`, …); the
profile wires it. Creation ops (project/milestone/issue) currently need native Linear MCP — the
adapter doesn't implement them yet.

## Layout
- `skills/flow-*/` — the skills. `flow` (index), inception (`flow-init/plan-project/gen-claudemd`),
  delivery (`flow-ship-issue`, `flow-fix`), cadence, scope, ops, meta (`flow-doctor`).
- `method/` — `conventions.md`, `project-setup-playbook.md`, `claude-md-template.md`, `guidelines/`
  (debugging / scoping / verification), `docs-skeleton/` (scaffolded by `flow-init`).
- `adapters/linear.sh` — tracker fallback. `profile.template.yaml` — the schema. `examples/` — filled profiles.
- `install/` — per-harness guides (Claude Code supported; others placeholder).

## Git workflow
- Own repo. Conventional commits (`feat:` / `fix:` / `docs:` / `refactor:` / `chore:`).
  **No `Co-Authored-By` trailer, no generated footer.**
- `VERSION` (semver) + `CHANGELOG.md` (Keep-a-Changelog). Bump `VERSION` + move `[Unreleased]` → a
  version section when cutting a release; the spine version is what a consuming project pins to.
- Adding/renaming a skill is a docs-touch too: update README skill list, ROADMAP status, CHANGELOG.

## Quality gates (this repo)
- `scripts/check.sh` green (frontmatter, YAML, shellcheck, cross-refs, profile-key drift) — CI runs
  it on every PR. It mechanizes `VALIDATION.md` Phase 6.
- The real proof is `VALIDATION.md` — run it on a throwaway project before trusting a change.

## Working docs
`README.md` (overview), `QUICKSTART.md` (first run), `ROADMAP.md` (status + coupling + what's
aspirational), `VALIDATION.md` (the runbook), `method/conventions.md` (the method the skills assume).
