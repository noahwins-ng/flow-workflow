# Phase 2 — Implement

Write the minimal code that satisfies the issue, checkpointing as you go and self-assessing every
acceptance criterion. (`<id>` = the issue identifier.)

## Step 1 — Load context
1. Fetch the issue (`profile.tracker.get_issue`) — title, description, AC, milestone.
2. `git branch --show-current`. If on `profile.project.default_branch`, stop:
   *"You're on the default branch — run phase 1 (pick) first to checkout the feature branch."*
3. Identify the system area from the title/description.
4. If `profile.docs.architecture` is set, read it to see where this fits.
5. If `profile.docs.patterns` is set, read it and look for a recipe matching the area **before**
   exploring the codebase.

## Step 2 — Explore patterns
Before writing code:
1. If a matching recipe exists in the patterns doc, follow it step by step; read the example files
   it references.
2. If none, fall back to exploration: read the relevant package/module, find 1–2 similar existing
   files in the same area, and read the project's shared config/schema module.

## Step 2b — Confirm the approach (Think Before Coding)
Before writing code, state your approach in 1–2 sentences. If there's a real design fork, name 2–3
options with a recommendation. If the issue is ambiguous, or your approach deviates from the ticket's
stated intent, **confirm with the user before implementing** — a cheap course-correction beats a wrong
build. (For a genuinely new or large piece, that design work belongs upstream in `flow-plan-project`;
this is a quick approach check, not a full design session.)

## Step 3 — Implement test-first, with AC checkpoints
Work in **red → green → refactor** cycles. For each verifiable acceptance criterion (or logical group):
1. **Write the test first.** For a **bug**, write a test that reproduces it and **watch it fail for
   the right reason** — a test you never saw fail proves nothing. For a **feature / behavior change**,
   write tests that pin the AC. *Exceptions* (note them, ask if unsure): throwaway prototype, generated
   code, pure config.
2. **Write the minimal code** to make it pass. Follow Step 2's patterns; respect
   `profile.architecture_rules`; use the project's config object for all hosts/ports/credentials
   (never hardcode); nothing speculative.
3. **Refactor** while the tests stay green.
4. **Quick-lint the changed files** — `profile.verify.lint` + `profile.verify.format` (full type
   check is Step 7).
5. **WIP commit** each meaningful chunk via `profile.vcs.wip_commit` (respect
   `profile.vcs.commit_hook_note`). WIP commits enable crash recovery + attempt counting; squashed at ship.

## Step 4 — Wire up
Ensure the new code is actually reachable: exported/registered where the project expects, and any
new dependency declared in the project's manifest (and the lockfile refreshed if the project uses
one).

## Step 5 — Targeted tests
Run `profile.verify.test_targeted` with `{path}` set to the changed package/dir. If tests fail,
**read the error, fix the code, re-run** — do not defer to the sanity check. If no tests exist for
this area, note it and skip. When a failure is non-obvious, apply
`method/guidelines/debugging-and-investigation.md` (debug state not logs; classify the variant
before fixing; fix the pattern, not just the failing example).

## Step 6 — AC self-assessment
Classify per `references/ac-classification.md` and mark each AC **DONE / PARTIAL / BLOCKED**:
- PARTIAL → go back to Step 3 and finish it.
- BLOCKED → you MUST name the **exact command** to unblock it. If you cannot name a specific
  command, the AC is ambiguous — stop and ask the user. "Needs manual verification" is not a valid
  state.
- Proceed only when all AC are DONE or BLOCKED-with-a-specific-command.

## Step 7 — Type check
Run `profile.verify.types` on the project. Fix all type errors before reporting.

## Step 8 — Report
```
Implemented: <id> — <title>

Files written:
  <path>  (new|modified)

Acceptance Criteria:
  ✓ <criterion> — implemented in <file:line>
  ✗ <criterion> — BLOCKED: run `<exact command>` to verify

Checks:  ✓ Lint  ✓ Format  ✓ Types  ✓ Tests (N) | skipped (no tests)
WIP commits: N (squashed at ship)

Ready for phase 3 (sanity check).
```

## Done when
All AC are DONE or BLOCKED-with-command, checks pass, WIP commits exist. Proceed to phase 3.
