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

## Step 3 — Implement with AC checkpoints
For each acceptance criterion (or logical group):
1. **Write the code** that satisfies it. Follow the patterns from Step 2. Respect every rule in
   `profile.architecture_rules`. Use the project's config object for all hosts/ports/credentials —
   never hardcode them. Keep it minimal: implement exactly what the AC requires, nothing
   speculative.
2. **Quick-lint the changed files only** (save the full type check for Step 7):
   run `profile.verify.lint` and `profile.verify.format` scoped to the files you touched.
3. **WIP commit** after each meaningful chunk, using `profile.vcs.wip_commit` (respect
   `profile.vcs.commit_hook_note` so the commit hook doesn't reject it). WIP commits protect
   against session loss and make recovery (attempt counting) possible; they are squashed at ship.

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
