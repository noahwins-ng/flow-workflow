# Phase 4 — Review (adversarial)

Read the full branch diff with fresh eyes and look for defects before shipping. Verdict must be
**SHIP**. (`<id>` = issue.)

## Step 0 — Orient
1. If an issue id was given, fetch it for context (title, description, AC).
2. `git branch --show-current`. If on the default branch: *"Nothing to review — you're on the
   default branch."*

## Step 1 — Gather the diff
- `git diff <default_branch>...HEAD` — full diff
- `git diff --stat <default_branch>...HEAD` — files changed
- `git log --oneline <default_branch>...HEAD` — commits
- If uncommitted changes exist, warn: review covers committed state only.

## Step 2 — Review
**2.0 — Fresh eyes first (optional).** If `profile.review.fresh_eyes_agent` is set and the harness
supports subagents, dispatch it on the diff only (no author context) and use its findings as your
starting point. Do not skip your own pass. If it is empty, do a single self-review pass.

**2.1 — Your own pass.** Read the diff as if you did not write it. Check each category:

- **Logic** — off-by-one, inverted conditions, missing null/absent-data checks, ordering/race
  assumptions, overly broad `except`/swallowed errors.
- **Security** — injection via string-built queries/commands with external input; hardcoded
  secrets/hosts/credentials (should use the project config object); missing input validation on
  API surfaces; path traversal / command injection in shell calls.
- **Architecture** — check the diff against every rule in `profile.architecture_rules`; check for
  incorrect cross-package/module coupling and for hardcoded values that belong in a shared
  registry/config.
- **Edge cases** — empty data, retry/idempotency, network failures/timeouts, rate limits.
- **Execution-AC evidence** — re-read the AC list. For each AC containing a word from
  `profile.ac_execution_keywords`, confirm a verification command was actually run with output
  pasted. Include implicit AC from `profile.docs.ac_templates` when the diff touches trigger paths.
  An execution AC marked ✓ without command+output is a **BLOCKING** review issue.
- **Code quality** (flag only significant issues, not style) — dead/unreachable code, misleading
  names that invite future bugs, missing types on public functions, needless complexity.

## Step 3 — Report
```
Review: <id> — <title>
Files reviewed: N files, +X -Y

  🔴 BLOCKING:
    - [file:line] <issue>
  🟡 ADVISORY:
    - [file:line] <issue>
  ✅ CLEAN: Logic · Architecture · Idempotency

Verdict: SHIP / FIX FIRST
```
SHIP = no blocking issues. FIX FIRST = blocking issues exist (list with file:line + suggested fix).

## Step 4 — If FIX FIRST
Fix each blocking item (show problem → fix → apply; auto-apply when running the full pipeline).
After fixing, re-read the changed lines to confirm no new issue was introduced, then re-run review.

## Step 5 — If SHIP
`Review passed — ready for phase 5 (ship).`
