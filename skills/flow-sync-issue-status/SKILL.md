---
name: flow-sync-issue-status
description: >-
  Manual override to reconcile a tracked issue's status with reality (branch / PR / merge state)
  when it has drifted. Normal transitions are automatic in the flow-ship-issue pipeline; use this when
  the tracker is out of sync. Use when the user says "sync status", "fix the Linear status",
  "/flow-sync-issue-status <ISSUE>", or names an issue whose status looks wrong.
---

# Sync Issue Status

Reconcile one issue's tracker status from its git/PR state. Reads the project profile first
(same `workflow-profile.yaml` as the flow-ship-issue skill). The issue id is provided by the user.

## Steps

1. **Fetch the issue** (tracker `get_issue`, native-first per the flow-ship-issue skill's Step 0b).

2. **Determine the correct status** from reality:
   - Active branch with uncommitted/unpushed work → **In Progress**
   - Open PR for the branch → **In Review**
   - PR merged → **Done**
   - No branch yet → **Todo**
   - Branch deleted and no PR ever merged → **Cancelled** (confirm with the user first)

   Check with: `git branch --list '*<id-lower>*'`, `gh pr list --head <branch>`,
   `gh pr list --state merged` (or the profile's VCS equivalents).

3. **Update the tracker** — set the issue to the determined status (tracker `set_*` operation).

4. **Report:**
   ```
   <id>: <title>
   Status: <old> → <new>
   Branch: <branch or none>
   PR:     <url or none>
   ```

5. If the issue is now **Done** and the tracker exposes milestones, note whether all issues in its
   milestone are now Done (milestone complete).
