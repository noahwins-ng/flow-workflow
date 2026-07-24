---
name: flow-session-check
description: >-
  Restore working context at the start of a session: detect the current branch, map it to its
  tracked issue, show recent commits / changed files / uncommitted work, and give a fast
  directional read of which acceptance criteria look done. Use when resuming work, or when the
  user says "where was I", "session check", "/flow-session-check", or "restore context".
---

# Session Check

Fast, directional context restore for work in progress. Reads the project profile first
(see the flow-ship-issue skill's Step 0; same `workflow-profile.yaml`). Keep it quick — deep
verification is the sanity-check phase's job, not this.

## Steps

1. **Detect the branch** — `git branch --show-current`.
   - Extract the issue id from the branch name using `profile.tracker.identifier_regex`
     (e.g. `user/qnt-41-...` → the QNT-41-style id). If on `profile.project.default_branch`,
     skip to step 5.

2. **Fetch issue context** (tracker operation `get_issue`, native-first per the flow-ship-issue
   skill's Step 0b): title, description, acceptance criteria, current status, milestone.
   - Run `git log --oneline <default_branch>...HEAD`. If no commits yet touch the area this issue
     is about, suggest reading `profile.docs.architecture` (if set) to orient before coding.

3. **Show recent work:**
   - `git log --oneline <default_branch>...HEAD` — commits on this branch only
   - `git diff --stat <default_branch>...HEAD` — files changed vs the default branch
   - `git status` — uncommitted work

4. **Directional AC assessment** — for each acceptance criterion:
   - `git diff --name-only <default_branch>...HEAD`, read the primary implementation files that map
     to AC items (prefer source over tests/config; cap at ~5 files to stay fast).
   - Mark ✓ if clearly present, ○ if partial/uncertain, ✗ if not found. If nothing changed yet,
     mark all "not started". This is a quick read, not proof.

5. **If on the default branch** (no active issue):
   - Check open PRs: `gh pr list --author @me` (or the profile's VCS equivalent).
   - Report them. Do not suggest the next issue — that's flow-cycle-start's job.
   - Prompt: *"No active issue. Run flow-cycle-start to review the cycle, or pick an issue to start."*

6. **Report:** **emit this block in full** — every line, placeholders substituted. Never
   summarize, compress, or collapse it to prose.
   ```
   Resuming: <id> — <title>
   Status:    <status>
   Milestone: <milestone>
   Branch:    <branch>

   Recent commits:
     <sha> <subject>

   Files changed (vs <default_branch>):
     <path>

   Uncommitted: <N modified, M untracked>

   Acceptance Criteria:
     ✓ <criterion>  (committed in <sha>)
     ○ <criterion>  (in progress)
     ✗ <criterion>  (not started)
   ```
