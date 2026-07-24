# Phase 5 — Ship

Squash → PR → CI → merge → verify deployed identity → resolve prod AC → tracker Done. (`<id>` = issue.)

## Step 1 — Sanity gate
Fetch the issue status.
- **Already In Review** (sanity passed recently): skip the full re-run; re-verify AC from the issue
  with a quick file read, then confirm: *"Already In Review — re-verifying AC only."*
- **Otherwise**: run phase 3 (sanity check). NEEDS FIXES → stop, fix, re-run. READY TO SHIP → continue.

## Step 2 — Plan entry (hard gate, if `profile.docs.plan` is set)
Every shipped ticket must appear in the plan narrative.
```
grep -n "<id>" <profile.docs.plan>
```
No match → **STOP**: *"<id> has no entry in <plan> — ship blocked."* Ask the user to confirm an
entry (or explain why this ticket leaves no product trace — rare). Once it exists, tick its
checkbox `- [ ]` → `- [x]` and stage the file.

## Safety (applies to Steps 3–6)
These steps rewrite history and publish. Guardrails: **never force-push**; if a rebase (Step 3)
hits conflicts, stop and report — do not auto-resolve; before the `git reset --soft` squash, confirm
the branch's commits are all this issue's (a stray commit from another issue means stop and ask);
and never merge on red CI. If anything about the branch state is surprising, surface it instead of
proceeding.

## Step 3 — Squash, commit, push
- `git add -A` if needed.
- Squash all WIP commits into one clean conventional commit (`profile.vcs.commit_format`):
  ```
  git reset --soft $(git merge-base <default_branch> HEAD)
  git commit -m "<id>: type(scope): description"
  ```
- Check the branch isn't behind: `git fetch origin <default_branch>` then
  `git log HEAD..origin/<default_branch> --oneline`. If behind, `git rebase origin/<default_branch>`;
  on conflict, report and stop — do not auto-resolve.
- `git push -u origin HEAD`.

## Step 4 — Open PR
- Reuse an existing open PR for the branch if present.
- Title: `profile.vcs.pr_title`. Body must contain `profile.vcs.pr_body_closes` (the auto-close
  phrase), a Summary, and the AC checklist. Append `profile.vcs.pr_footer` only if non-empty.
- Attach the PR link to the issue while it is still open.

## Step 5 — CI
`profile.deploy.ci_status` (with `{pr}`). No checks → proceed. Failure → report, do **not** merge,
offer to fix.

## Step 6 — Merge
`profile.deploy.merge` (with `{pr}`). Then `git checkout <default_branch> && git pull`.

## Step 7 — Verify deployed identity BEFORE trusting any AC
After merge, deployment runs. Wait for it to propagate (re-check container/deploy age; if the
deploy hasn't triggered, wait ~90s and re-check — don't verify against a stale deployment).

**The gates are topology-neutral contracts; the profile supplies this project's probe.** What each
gate *proves* never changes — how you prove it depends on where the code runs:

| Contract | VPS/Compose | Serverless/PaaS | k8s | Published package |
|---|---|---|---|---|
| identity | `ssh prod git rev-parse HEAD` | deployment SHA from platform API/CLI | image digest/tag == commit | registry version == release |
| runtime-load | exec-in-container asserts loaded module graph | function/route cold-start probe | pod ready + version endpoint | install-from-registry smoke |
| health | health endpoint / `make check-prod` | platform health/status URL | readiness probes green | `npx <pkg> --version` etc. |

**No-deploy project** (all `deploy.deployed_sha`/`runtime_id`/`health` empty — e.g. a library
before publish automation): the pipeline ends at merge + plan tick + tracker close-out. **Say so
in the report** ("no deploy surface — gates (a)/(b)/health skipped by profile") — skipping must be
visible, never silent.

**Hard gates — an AC check against the wrong code is meaningless. If either fails, STOP** (do not
run health or per-AC checks): investigate the deploy, fix, re-trigger.

- **(a) Deployed identity matches the merge commit** (`profile.deploy.deployed_sha`, if set):
  compare what's running/published to the PR's merge-commit sha. Differ ⇒ deploy did not land.
- **(b) Runtime loaded the expected code** (`profile.deploy.runtime_id`, if set): prove the running
  *process* loaded the code you merged — not merely that files are present. Fail ⇒ the process is up
  but did not load cleanly; check deploy logs.

Once both pass, run `profile.deploy.health`. On failure: retry once after 60s; if still failing,
report and do **not** mark Done — offer `profile.deploy.rollback`.

**For each `⏳ PENDING` prod execution AC**, run its verification and paste `Command:` + `Output:`.
- All prod AC pass → move the issue to Done (`profile.tracker.set_done`; do not rely on auto-close).
- Any fail → keep In Review, report what failed and how to fix.

## Step 7b — Ship comment
Post the permanent ship record (`profile.tracker.add_comment`) per the audit-comment contract in
`references/ac-classification.md`: per-AC receipts (every execution AC — dev and now-resolved prod —
with literal command+output), a Findings block carried forward, and a Verification summary (quality
checks, CI, deploy SHA + runtime-id, health). A reader must be able to re-verify every claim.

## Step 8 — Report
**Emit this block in full** — every line, placeholders substituted. Never summarize, compress, or collapse it to prose.
```
Shipped <id>: <title>
PR:      <url> (merged)
Status:  Done
Branch:  deleted
Next up: <profile.tracker.next_issue result, if any>
```
