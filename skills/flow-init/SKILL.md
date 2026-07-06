---
name: flow-init
description: >-
  Bootstrap the dev-workflow suite into a repo: scaffold the docs skeleton (plan, spec, ADRs,
  retros) and generate a filled-in workflow-profile.yaml. Idempotent and non-destructive — on a
  repo that already has some of these, it adds only what's missing and points the profile at what
  exists. Use when the user says "init the workflow", "set up the workflow suite", "/flow-init", or
  adopts this package in a new or existing project.
---

# init

Scaffold the method into the current repo. Works both for a **greenfield** repo (create everything)
and **mid-project adoption** (detect what exists, fill only the gaps, never clobber). This is the
one command that makes the suite's skills usable in a project.

## Golden rule

**Never overwrite a file the user already has.** Before writing anything, look at what's there. If a
target exists, leave it and point the profile at it. Report what you created vs. what you found and
left alone. If you would replace something you didn't create, stop and surface it instead.

## Steps

1. **Locate roots.**
   - Package root = where this skill lives (contains `method/docs-skeleton/` and `profile.template.yaml`).
   - Target repo root = `git rev-parse --show-toplevel` (or cwd if not a git repo — warn).

1b. **PRD anchor (if present).** Look for an imported PRD / requirements brief — a path the user
   gives, or a file like `PRD.md`, `prd.md`, `docs/prd.md`, or an existing `docs/project-requirement.md`.
   If found, **read it** and use it to drive the fill:
   - Seed `project.name` and the identifier-prefix suggestion from it (don't guess a prefix — propose
     one from the product name and confirm).
   - Establish the **spec**: if `docs/project-requirement.md` doesn't exist, create it from the PRD
     (either move/rename the PRD into place, or write a spec that references it) so `docs.spec` has a
     home; if it already exists, point `docs.spec` at it. Do not silently discard the PRD.
   - Note that phase decomposition + tracker creation is the **next** skill (flow-plan-project) — do
     NOT create phases/issues here.
   If no PRD exists, proceed with a blank spec skeleton and note it.

2. **Scaffold docs (gap-fill only).** For each file under `method/docs-skeleton/docs/`, compute its
   target path in the repo and:
   - **Target exists** → leave it. Record it as "found" and use its real path in the profile.
   - **A conventional equivalent exists under a different name** (e.g. the repo has `docs/PLAN.md`
     or `ROADMAP.md` instead of `docs/project-plan.md`) → do **not** add a duplicate; point the
     profile at the existing file and note the mapping in your report. **Equivalence = the file
     satisfies the surface's *contract*, not just its name**: `docs.plan` requires a
     checkbox-per-shipped-ticket tracker (the ship hard-gate ticks entries in it) — a
     future-features roadmap matches the name but violates the contract; map it to `docs.spec`
     instead and scaffold a real plan. When unsure, ask the user rather than guessing.
   - **If any skeleton file was mapped rather than copied**, rewrite the affected links in the
     scaffolded `docs/INDEX.md` to the mapped paths — a verbatim INDEX ships dead links.
   - **Missing** → copy the skeleton file in (`cp`), replacing `<Project>` placeholders with the
     repo name.

3. **Generate the profile.** If `workflow-profile.yaml` already exists at the repo root, do NOT
   overwrite it — report that and skip to step 5 (offer to show a diff of new keys the template has
   that the existing file lacks). Otherwise copy `profile.template.yaml` → repo-root
   `workflow-profile.yaml` and pre-fill what you can detect:
   - `project.name` from the repo/dir name; `project.default_branch` from
     `git symbolic-ref refs/remotes/origin/HEAD` (fallback `main`).
   - `verify.*` by sniffing the repo: Python (`pyproject.toml` + ruff/pyright/pytest) → `uv run ruff
     check .` etc.; Node (`package.json` scripts) → `npm run lint|typecheck|test`; a `Makefile` with
     `test`/`lint` targets → `make test`/`make lint`. Leave a value empty and flag it if you can't
     infer it — do not invent a command that won't run.
   - `docs.*` → point each at the file resolved in step 2 (scaffolded or pre-existing); empty for any
     you couldn't establish.
   - `tracker.identifier_regex` / `identifier_example` → **derive from repo evidence first**
     (CLAUDE.md, commit history `[ABC-123]` tags, branch names); cite the evidence. Only if the
     repo carries no trace, ask the user — never guess a prefix from the project name.
   - Leave `deploy.*`, `cadence.*`, `audit.*`, `architecture_rules`, `ac_execution_keywords` as
     template defaults — these are judgment calls, and **deriving them is flow-tailor's job**
     (read `skills/flow-tailor/SKILL.md` and follow it, next). Don't hand-guess them here.
   - `review.fresh_eyes_agent` — the template defaults to the Claude Code namespaced form
     `flow:flow-code-reviewer`. If you're on Claude Code, keep it (verify with `/agents`). On a harness
     that registers bundled agents *without* a namespace, change it to the bare `flow-code-reviewer`.

3b. **Scaffold repo config (gap-fill, after the profile exists).** Copy the templates under
   `method/scaffolds/` into the repo, **filling `__PLACEHOLDERS__` from the profile** (verify.*,
   deploy.*, vcs, tracker.identifier_regex, detected stack/ecosystem). Same non-destructive rule as
   docs: **never overwrite an existing file** — if the repo already has `.github/workflows/`, a
   `Makefile`, `.githooks/`, a PR template, or `dependabot.yml`, leave it and note it as "found".
   - `.github/workflows/ci.yml` — lint/format/types/test/security (from `verify.*`). Add the
     toolchain-setup step for the detected stack; drop the security step if `verify.security` is empty.
   - `.github/workflows/cd.yml` — deploy + the **three hard gates** (from `deploy.*`). Delete any gate
     whose `deploy.*` value is empty (the project has no such concept). If there's no deploy at all,
     skip `cd.yml` entirely and note it.
   - `.githooks/commit-msg` — tune `__ID_REGEX__` to `tracker.identifier_regex`. Run
     `git config core.hooksPath .githooks` (or fold into `make setup`). **First detect an existing
     hook manager** (`git config core.hooksPath` already set, `.husky/`, `lefthook.yml`,
     `.pre-commit-config.yaml`): if one owns the hooks, **skip this scaffold and note it** —
     re-pointing `core.hooksPath` would silently disable the project's existing hooks. (The
     never-overwrite rule doesn't catch this: `git config` overwrites *state*, not a file.)
   - `Makefile` — targets mapped to `verify.*` (skip if the repo already has a task runner).
   - `.github/dependabot.yml` — set the ecosystem from the detected stack.
   - `.github/PULL_REQUEST_TEMPLATE.md`.
   Leave any placeholder you genuinely can't fill and flag it in the report — don't invent a command
   that won't run.

4. **Tracker check.** Note whether the harness exposes a Linear MCP tool. If not, remind the user
   the shell adapter needs `LINEAR_API_KEY` exported.

5. **Report:**
   ```
   Workflow suite initialized in <repo>

   Docs:
     created   docs/project-plan.md, docs/project-requirement.md, docs/decisions/TEMPLATE.md, ...
     found     docs/architecture/system-overview.md  (left as-is)
     mapped    docs.plan → docs/ROADMAP.md            (existing equivalent, no duplicate created)

   Profile: workflow-profile.yaml created
     pre-filled: project.name, default_branch, verify.* (Python)
     TO DERIVE (flow-tailor): deploy.*, cadence.team/project, architecture_rules, ac keywords

   Repo config:
     created   .github/workflows/ci.yml, .githooks/commit-msg, Makefile, PR template, dependabot.yml
     skipped   .github/workflows/cd.yml  (deploy.* empty — no deploy target yet)
     found     Makefile  (left as-is)

   Tracker: Linear MCP <detected | not detected — export LINEAR_API_KEY for adapters/linear.sh>

   Next: run flow-tailor to derive + prove the judgment-call fields, then flow-doctor to verify.
   New project from a PRD? → then flow-plan-project (phases + Linear), then flow-gen-claudemd.
   Existing project? → flow-session-check or flow-ship-issue.
   ```

## Idempotency
Running `init` again must be safe: it re-detects, fills any new gaps, and changes nothing that
already exists. A second run on a fully-set-up repo reports "nothing to do".
