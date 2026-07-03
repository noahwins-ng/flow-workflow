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
one command that makes the opinionated skills usable in a project.

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
     profile's `docs.plan` at the existing file and note the mapping in your report. When unsure
     whether an existing file is the equivalent, ask the user rather than guessing.
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
   - `tracker.identifier_regex` / `identifier_example` → **ask the user** for their Linear team
     prefix (e.g. `QNT`); don't guess.
   - Leave `deploy.*`, `cadence.*`, `audit.*`, `architecture_rules`, `ac_execution_keywords` as
     template defaults with a note that the user should review them — these are judgment calls.

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
     NEEDS YOU:  tracker prefix, deploy.*, cadence.team/project, architecture_rules

   Tracker: Linear MCP <detected | not detected — export LINEAR_API_KEY for adapters/linear.sh>

   Next: review the NEEDS-YOU fields in workflow-profile.yaml, then run flow-doctor to verify.
   New project from a PRD? → flow-plan-project (phases + Linear), then flow-gen-claudemd.
   Existing project? → flow-session-check or flow-ship-issue.
   ```

## Idempotency
Running `init` again must be safe: it re-detects, fills any new gaps, and changes nothing that
already exists. A second run on a fully-set-up repo reports "nothing to do".
