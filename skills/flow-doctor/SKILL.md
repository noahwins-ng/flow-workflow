---
name: flow-doctor
description: >-
  Preflight health check for the flow workflow suite: verify the project profile is complete and
  its referenced commands, doc paths, and tracker access actually resolve — before a skill fails
  mid-run. Read-only. Use after flow-init, when a skill errors on config, or when the user says
  "flow doctor", "/flow-doctor", "check my workflow setup", or "is my profile valid".
---

# flow-doctor

Read-only diagnosis of a project's flow setup. Changes nothing. The whole point is to turn a
silent mid-pipeline failure (a half-filled or drifted `workflow-profile.yaml`) into an upfront
report. Run it anytime; run it first when a skill complains about config.

## Checks

Load `workflow-profile.yaml` from the repo root (or the path the user gives). Then:

1. **Profile parses** — valid YAML, present. ✗ if missing → tell the user to run flow-init.

2. **Required sections present** — `project`, `tracker`, `vcs`, `verify`. ✗ any missing.
   Judgment-call fields that are still template defaults (`architecture_rules`,
   `ac_execution_keywords`, `deploy.*`, `cadence.*`) → ⚠ "review before relying on it", not ✗.

3. **`verify.*` commands resolve** — for each non-empty `lint/format/types/test/build/test_targeted`,
   take the first token and check it's on PATH (`command -v <tok>`). ✗ if a referenced tool is missing
   (e.g. profile says `uv run ...` but `uv` isn't installed). Note the limit: "resolves" ≠ "passes" —
   if the profile carries flow-tailor derivation comments, trust PROVEN ones and flag UNPROVEN ones.

4. **`deploy.*` commands resolve** — same first-token check for `ci_status/merge/deployed_sha/
   runtime_id/health/rollback`. Empty = skip (no such concept). ⚠ if `ssh`/`gh` referenced but not
   installed.

5. **`docs.*` paths exist** — each non-empty path (`plan/spec/patterns/architecture/decisions_dir/
   adr_template/retros_dir`) exists on disk. ✗ if a path is set but missing (a skill that needs it
   will break). Empty = intentional skip.

6. **Tracker reachable** — is a native Linear tool available in this harness? If yes → ✓ (native).
   If no → check the adapter path exists, `curl` + `jq` are installed, and `LINEAR_API_KEY` is set.
   ✗ if the fallback can't work (no native tool AND no key/deps). Do NOT make a live tracker call —
   just verify the preconditions.

7. **Cadence sanity** — if `cadence.*` is populated, confirm `team` and `project` are set (empty
   ⇒ cycle-start/cycle-end/retro can't run). ⚠ if the suite's cadence skills are unusable.

8. **Degradation report — what this profile turns OFF.** Empty values are legal ("no such
   concept"), but each one disables specific behavior downstream; the consumer must *see* that
   contract, not discover it mid-ship. List every empty key that gates something, with its effect:
   - `deploy.deployed_sha` / `runtime_id` / `health` empty → ship gates (a)/(b)/health **off**;
     pipeline ends at merge + close-out (the no-deploy archetype — fine for a library, alarming
     for a service).
   - `verify.security` empty → no automated CVE gate on lockfile changes.
   - `docs.plan|spec|patterns|ac_templates` empty → the corresponding plan-gate / change-scope /
     implement-context / implicit-AC step no-ops.
   - `review.fresh_eyes_agent` empty → single self-review pass, no independent reviewer.
   - `audit.host` empty → flow-server-audit disabled.
   - `tracker.next_issue` empty → no "next up" suggestion after ship.
   These are ℹ lines, not ⚠ — unless the combination looks contradictory (e.g. `deploy.health`
   empty but `audit.host` set: something runs somewhere, yet ship never health-checks it → ⚠).

## Report
```
flow-doctor — <project> @ <profile path>

  ✓ Profile parses
  ✓ Required sections present
  ✗ verify.types — `pyright` not on PATH (profile: "uv run pyright")
  ⚠ deploy.* — still template defaults; review before shipping
  ✓ docs paths — all present
  ✓ Tracker — native Linear tool detected
  ⚠ cadence.team empty — cycle/retro skills disabled

  Profile turns OFF (empty = intentional; confirm each is deliberate):
  ℹ deploy.deployed_sha/runtime_id/health — ship ends at merge (no-deploy archetype)
  ℹ audit.host — flow-server-audit disabled
  ℹ review.fresh_eyes_agent — single self-review pass

Verdict: NEEDS ATTENTION (1 blocking, 2 advisories)
  Fix the ✗ items before running flow-ship-issue; ⚠ items are safe to defer.
```
Verdict = HEALTHY if no ✗, else NEEDS ATTENTION with the blocking count. The ℹ degradation lines
never affect the verdict — they exist so "off" is a decision the user has seen, not a surprise.
