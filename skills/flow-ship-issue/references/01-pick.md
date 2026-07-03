# Phase 1 — Pick

Start work on the issue: read it, checkout its branch, mark it In Progress, surface the
acceptance criteria. (Reference `<id>` = the issue identifier carried from Step 0.)

## Steps

1. **Fetch the issue.** Run `profile.tracker.get_issue` with `{id}` substituted. Read: title,
   description, acceptance criteria, current status, milestone, and relations.
   - If any **blocking** relation is not Done, warn before proceeding:
     *"Blocked by <id> (<title>) — status: <status>. Proceed anyway?"* Wait for the user.

2. **Determine the branch name.**
   - If `profile.tracker.branch_from_issue` names a field present in the issue output, use that
     value verbatim (trackers like Linear supply a canonical branch name — prefer it).
   - Otherwise construct one from `profile.tracker.branch_template`.

3. **Checkout the branch.**
   - `git checkout <branch>` if it exists, else `git checkout -b <branch>`.
   - Do not use any shortcut that produces a differently-named branch.

4. **Move the issue to In Progress.** Run `profile.tracker.set_in_progress`.
   - If the issue is already In Review or Done, warn first:
     *"<id> is already <status> — move back to In Progress?"*
   - If your tracker has an active-cycle/sprint concept, assign the issue to the current one so it
     is visible on the board.

5. **Report:**
   ```
   Picked up: <id> — <title>
   Milestone: <milestone>
   Branch:    <branch>
   Status:    <previous status> → In Progress

   Acceptance Criteria:
     ○ <criterion 1>
     ○ <criterion 2>

   Ready to implement.
   ```

## Done when
Branch is checked out, tracker shows In Progress, and the AC are surfaced. Proceed to
phase 2 (`references/02-implement.md`).
