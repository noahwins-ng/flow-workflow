# Validation Runbook

First end-to-end proof that the suite works. The package is internally consistent but **unrun** —
this runbook is designed to break it on purpose and surface the real bug list. Do it on **Claude
Code** (the supported harness) against a **throwaway repo** and a **disposable Linear project**.

Record PASS / FAIL + notes in the log at the bottom. A FAIL is a success for *this* exercise — it's
the point. Fix or file each, don't power through.

## Prerequisites

- [ ] A scratch git repo pushed to GitHub (`gh repo create flow-sandbox --private`).
- [ ] A disposable Linear **team** (or a clearly-named "Sandbox" project you'll archive after).
- [ ] The package installed as a Claude Code **plugin** (see `install/claude-code.md`).
- [ ] For the adapter path only: `LINEAR_API_KEY` exported + `curl`/`jq` installed. (If your session
      has a Linear MCP, you'll validate the native path instead — do the adapter smoke test anyway,
      it's the one untested executable.)
- [ ] A short PRD in the sandbox repo (`PRD.md`) — 1 page, ~3 phases of made-up scope.

## Watch-list (the parts most likely to break)

These are the untested seams — scrutinize them:
1. **`adapters/linear.sh` GraphQL** — the `ProjectUpdateHealthType` enum name, the `cycle active`
   team-**name** filter, state-UUID resolution, project/issue field names. Never run live before Phase 1.
2. **Native Linear creation in `flow-plan-project`** — project/milestone/issue creation, "always set
   project", Backlog→Todo for Cycle 1, state-by-UUID.
3. **Package-root path resolution** — do cross-skill read-and-follow (`skills/flow-*/SKILL.md`) and
   `adapters/linear.sh` resolve from the consuming repo? (`${CLAUDE_PLUGIN_ROOT}` under plugin install.)
4. **Empty-value skips** — deploy/audit gates with empty profile values must skip cleanly, not error.
5. **Bundled subagent registration + naming** — do `agents/flow-code-reviewer.md` and
   `agents/flow-investigator.md` register on plugin install, and under what name (bare vs. a
   plugin-namespaced form like `flow:flow-code-reviewer`)? If namespaced, update
   `profile.review.fresh_eyes_agent` (and the skills' `flow-investigator` references) to match.

---

## Phase 0 — Install & discoverability

| Step | Assert |
|------|--------|
| Ask **/flow** | Returns the suite index; all 16 skills discoverable by name. |
| Ask "what can the workflow do?" | `flow` skill triggers by description (not just slash). |
| Check the agent registered | `flow-code-reviewer` appears in the harness's subagent list after install. **Note the exact name** (bare vs. `flow:`-namespaced) — if namespaced, update `profile.review.fresh_eyes_agent` to match. |

## Phase 1 — Adapter smoke test (`adapters/linear.sh`)

Run each against a real sandbox issue/team. Paste literal output; confirm no GraphQL errors.
```
LINEAR_API_KEY=… ./adapters/linear.sh issue get SBX-1
LINEAR_API_KEY=… ./adapters/linear.sh issue status SBX-1 'In Progress'
echo "test" | LINEAR_API_KEY=… ./adapters/linear.sh issue comment SBX-1
LINEAR_API_KEY=… ./adapters/linear.sh cycle active 'Sandbox'
echo "**test update**" | LINEAR_API_KEY=… ./adapters/linear.sh project status-update 'Sandbox' onTrack
```
- [ ] `issue get` → normalized JSON with id/title/status/branchName/blockedBy.
- [ ] `issue status` → moves the issue (verify in Linear UI); state resolved by UUID.
- [ ] `issue comment` → comment appears.
- [ ] `cycle active` → cycle + issues JSON (**most likely to fail** — team filter / field names).
- [ ] `project status-update` → update posts (**watch the health enum type name**).

## Phase 2 — Inception (greenfield from PRD)

| Step | Command | Assert |
|------|---------|--------|
| Init | run **flow-init** | Reads `PRD.md`; scaffolds docs skeleton; writes `workflow-profile.yaml` with detected fields; flags the judgment fields. Nothing overwritten. |
| Doctor | run **flow-doctor** | Reports ✓/⚠/✗; catches any missing tool/path; verdict sane. |
| Plan | run **flow-plan-project** | Proposes phases + issues with 3-class AC; **pauses for approval**; on approval creates Linear project + phase milestones + "Ops & Reliability" + issues (verify in UI); Cycle-1 issues are **Todo**; `project-plan.md` seeded to match. |
| CLAUDE.md | run **flow-gen-claudemd** | Emits Working Approach ×4 + Project Conventions filled from profile/spec/repo; drops sections with no basis; doesn't fabricate. |

## Phase 3 — Daily loop

| Step | Assert |
|------|--------|
| **flow-session-check** | Branch → issue → git state → directional AC; fast, no deep verify. |
| **flow-ship-issue &lt;ID&gt;** on a trivial issue (one-line change) | pick → implement → sanity → review → PR → merge. Implement is **test-first**; sanity runs the **security gate**; **review dispatches `flow-code-reviewer`** (confirm it actually spawns + returns findings). With empty `deploy.*`, deploy gates **skip cleanly**. Tracker → Done; audit comment posted with receipts. |
| **flow-fix &lt;ID&gt;** — break on purpose: introduce a lint error mid-run, or a failing test | Diagnoses the failed phase **from git state**; fixes; resumes via read-and-follow; posts fix comment. |

> Deploy-gate validation (SHA match, runtime-id, health) needs a repo with **real CD** — out of
> scope for the sandbox. Validate those on the first real project, or point `deploy.*` at a toy
> deploy and assert the gates fire.

## Phase 4 — Cadence & methodology

| Step | Assert |
|------|--------|
| **flow-cycle-start** | Active cycle + suggested next pick + plan-staleness flag. |
| **flow-change-scope** add/drop/modify | Updates spec + plan + overview + tracker + ADR (as applicable); audit comment. |
| **flow-sync-plan** | Ticks Done, removes Cancelled, mechanical gap sweep finds an unlisted issue. |
| **flow-cycle-end** | Shipped summary, rollover to next cycle (Todo), velocity, project status update. |
| **flow-retro** | Invariant→guard audit runs; lessons captured; scope recs paused for approval; report written to `retros/`. |

## Phase 5 — Mid-project adoption + idempotency

| Step | Assert |
|------|--------|
| Run **flow-init** in a *different* repo that already has `docs/` + a `README` | Gap-fills only; leaves existing files; maps profile at existing docs; never clobbers. |
| Run **flow-init** again | Reports "nothing to do" — idempotent. |

## Phase 6 — Package self-checks (no Linear needed)

```
shellcheck adapters/linear.sh
for f in skills/*/SKILL.md; do head -20 "$f" | grep -q '^name:' && grep -q '^description:' "$f" || echo "MISSING frontmatter: $f"; done
python -c "import yaml,sys; yaml.safe_load(open('profile.template.yaml')); print('profile YAML ok')"
python -c "import yaml; yaml.safe_load(open('examples/profile.node-vercel.yaml')); print('example YAML ok')"
```
- [ ] shellcheck clean (or only known-acceptable warnings).
- [ ] every SKILL.md has name + description frontmatter.
- [ ] profile + example YAML parse.

## Phase 7 — Scaffolds & hooks (after `flow-init` ran in Phase 2)

`flow-init` should have dropped repo config from `method/scaffolds/`, placeholders filled from the profile.

| Check | Assert |
|------|--------|
| `.github/workflows/ci.yml` | Created; **no `__PLACEHOLDER__` left** — `verify.*` commands substituted; toolchain-setup step matches the stack. |
| `.github/workflows/cd.yml` | Present with the 3 hard gates filled from `deploy.*` — **or cleanly skipped** if `deploy.*` is empty (no error, noted in the report). |
| `.githooks/commit-msg` + `core.hooksPath` | Installed and set. **Test it:** a conventional message (`<ID>: feat(x): …`) commits; a garbage message is **rejected**. |
| `Makefile` | `make test`/`lint`/`format` run the `verify.*` commands. |
| `.github/dependabot.yml` | Ecosystem matches the stack. |
| PR template + `docs/guides/ops-runbook.md` | Present. |
| **Gap-fill** | Pre-seed one file (e.g. an existing `Makefile`) *before* `flow-init` → it's left untouched and reported as "found". |
| **CI actually runs** (needs the GitHub sandbox) | Push a PR → `ci.yml` runs and goes green. |

## Phase 8 — Optional hooks (Claude-Code guardrails)

| Check | Assert |
|------|--------|
| Registration | `protect-repo` + `check-uncommitted` register on plugin install (see watch-list #5 for naming). |
| Inert by default | With no `FLOW_HOOKS` / `.flow-hooks`, a `git push --force` is **allowed** (hook no-ops). |
| Opt-in works | After `touch .flow-hooks` (or `export FLOW_HOOKS=1`), `git push --force` / `git reset --hard` are **blocked**; a normal feature-branch push is allowed. |

## Cleanup
- [ ] Archive/delete the sandbox Linear project + issues.
- [ ] Delete the `flow-sandbox` GitHub repo.

## Exit criteria
- [ ] Phases 0–2 fully PASS (install, adapter, inception) — the core loop.
- [ ] Phase 3 PASS through merge (deploy gates deferred).
- [ ] Phase 7 PASS: scaffolds filled correctly + commit-msg hook gates.
- [ ] Every FAIL either fixed or filed with a repro.
- [ ] Watch-list items 1–5 each explicitly confirmed or fixed.

---

## Results log

| Date | Phase | Step | PASS/FAIL | Notes / bug |
|------|-------|------|-----------|-------------|
| | | | | |
