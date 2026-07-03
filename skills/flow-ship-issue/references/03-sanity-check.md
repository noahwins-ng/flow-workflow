# Phase 3 — Sanity Check (HARD GATE)

Pre-PR quality gate. Verdict must be **READY TO SHIP** before review or ship. (`<id>` = issue.)

## Step 0 — Uncommitted work
Run `git status`. If there are uncommitted/untracked changes, warn: *"Uncommitted work detected —
checks run on the committed state. Commit first to include it."* Proceed, but flag it in the report.

## Step 1 — Code quality
Run each and report pass/fail:
- `profile.verify.lint`
- `profile.verify.format`
- `profile.verify.types`
- `profile.verify.test` — the offline/fast gate that mirrors CI. Honor `profile.verify.test_note`
  (e.g. do not use a bare test runner that pulls in live/integration suites).

## Step 1b — Security & dependencies (automated gate)
Manual security review is phase 4; this is the automated pre-PR gate.
- **Secret scan.** `git diff <default_branch>...HEAD` — no committed credentials, keys, tokens, or
  `.env` values. Any hit → **NEEDS FIXES** (and rotate the exposed secret).
- **Dependency audit.** If the diff changed a dependency manifest/lockfile (`git diff --name-only`
  hits `package.json`/`package-lock.json`/`pyproject.toml`/`uv.lock`/`requirements*.txt`/`go.mod`/…),
  run `profile.verify.security` (e.g. `npm audit` / `pip-audit` / `uv pip audit`). **High/critical
  CVEs block ship** — bump the dep in the same PR (don't split it into a separate ticket). If
  `profile.verify.security` is empty, note the gap and check the lockfile diff by eye.

## Step 2 — Acceptance criteria
1. Fetch the issue (`profile.tracker.get_issue`) and extract its Acceptance Criteria.
2. Add implicit AC from changed files if `profile.docs.ac_templates` is set (see
   `references/ac-classification.md` → "Implicit AC from changed files").
3. Classify and **prove** every AC per `references/ac-classification.md`:
   - **[code AC]** → PASS/FAIL, cite `file:line` or `test::name`.
   - **[dev execution AC]** → run the command, paste `Command:` + `Output:`. No receipt → `✗ BLOCKED`.
   - **[prod execution AC]** → `⏳ PENDING — verify post-deploy` (carried into ship).
   - Any word from `profile.ac_execution_keywords` forces execution classification.
4. Any `✗ BLOCKED` dev execution AC ⇒ **NEEDS FIXES**.

## Step 3 — Report
```
Sanity Check: <id> — <title>

Warnings: ⚠ <if any>

Code Quality:  ✓ Lint  ✓ Format  ✓ Types  ✓ Tests (N)  ✓ Security (secrets/deps)

Acceptance Criteria:
  ✓ <crit>  [code AC — <file:line>]
  ✓ <crit>  [dev execution AC]
    Command: <exact>
    Output:  <literal>
  ✗ <crit> — BLOCKED  [dev execution AC — run: <command>]
  ⏳ <crit> — PENDING  [prod execution AC — verify post-deploy]

Verdict: READY TO SHIP / NEEDS FIXES
  (READY = all code AC ✓ + all dev execution AC ✓; prod-pending is acceptable)
```

## Step 4 — If READY TO SHIP
1. Move the issue to In Review (`profile.tracker.set_in_review`).
2. Post an audit comment (`profile.tracker.add_comment`) following the **audit comment contract**
   in `references/ac-classification.md`: per-AC literal receipts + a Findings block (a corrected
   assumption, a latent bug found, a judgement call, or a scope shortcut — or one explicit line
   saying nothing deviated). Never collapse an execution AC to a bare ✓.

## Step 5 — If NEEDS FIXES
List the specific failures and fix them, then re-run this phase. Do not proceed to review/ship.
If verdicts flap across runs at the same SHA, consult `references/recovery.md` (do not re-run a
third time).
