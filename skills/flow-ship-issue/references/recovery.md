# Failure Recovery

Consult this on any phase failure. The mechanisms here survive a context reset because they are
recorded in git, not in your working memory.

## Attempt counting (durable across context compaction)

After each **failed fix attempt** at a phase, create a WIP commit:

```
<id>: <type>(<scope>): wip - fix attempt — <what was tried and why it failed>
```

(Use `profile.vcs.wip_commit` for the exact shape your commit hook accepts.)

To learn how many attempts have been made at the current phase, count matching commits:

```
git log --oneline <default_branch>...HEAD | grep -c 'fix attempt'
```

Because this reads from git, it is correct even if your conversation was summarized between
attempts.

## The two-attempt ceiling

If a phase fails and cannot be auto-fixed after **two** attempts (two "fix attempt" commits for
the same phase):

1. Commit a WIP checkpoint of any progress made.
2. Report exactly what failed, with the specific error.
3. Name which phase to resume from, so a later run can pick up there.
4. Stop and hand back to the user. Do not keep retrying.

## Same-SHA flap detection (sanity check / review)

If a gate returns different verdicts (e.g. READY TO SHIP ↔ NEEDS FIXES) on two consecutive runs
at the **same branch-tip SHA** — no new commits between runs — the disagreement is not about the
code. Something *upstream* changed between runs (deploy state, CI, a tunnel/host going away,
tracker data, a background process stopping).

When this happens:

1. Do **not** run the gate a third time — retrying does not fix non-deterministic inputs.
2. Pause and ask the user, reporting both verdicts, the SHA, and what looked different between the
   two runs (e.g. "host reachable for run #1, not run #2").

Track each run's `SHA + verdict` in your working context — **not** as a commit. A tracking commit
would move the branch tip and defeat the same-SHA comparison.
