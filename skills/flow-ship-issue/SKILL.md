---
name: flow-ship-issue
description: >-
  End-to-end delivery pipeline for a single tracked issue: pick a ticket, implement it,
  gate it on a sanity check, review it adversarially, and ship it (PR, CI, merge, deploy
  verification, tracker close-out). Harness-neutral; every project-specific fact (tracker,
  toolchain, deploy target, doc paths, architecture rules) is read from a project profile.
  Use when the user says "ship <ISSUE>", "deliver <ISSUE>", "go <ISSUE>", "/flow-ship-issue <ISSUE>",
  or asks to take a ticket from start to merged.
---

# Ship an Issue

This skill runs a five-phase delivery pipeline for **one** issue, end to end. It is a
**spine** of invariant discipline; all project-specific nouns live in a **project profile**
that you read first. Nothing about a specific stack, tracker, or host is hardcoded here.

## Step 0 — Load the project profile (always first)

Find and read the project profile before doing anything else. Look, in order, for:

1. A path the user gave you.
2. `workflow-profile.yaml` at the repo root.
3. `.workflow/profile.yaml`.

If none exists, stop and tell the user: *"No workflow profile found. Copy
`profile.template.yaml` from this skill, fill it in for this project, and re-run."* Do **not**
guess project facts — a wrong deploy or tracker command is worse than stopping.

The profile supplies every substitutable value referenced below as `profile.<key>`
(tracker + identifier format, branch/commit/PR conventions, lint/format/type/test commands,
runtime-identity + health checks, doc paths, architecture rules, AC execution keywords).
Read the package's `profile.template.yaml` (package root) for the full schema and meaning of each key.

## Step 0b — Resolve tracker access (native-first, adapter-fallback)

The tracker is Linear. Phase files invoke tracker **operations** — `get_issue`, `set_in_progress`,
`set_in_review`, `set_done`, `add_comment`, `next_issue` — written as `profile.tracker.<op>`. Each
is a *capability*, not necessarily a shell command. Resolve it once, at the start, by what your
harness actually has:

1. **Native Linear tool available?** (Claude Code, Cursor, opencode, Codex, pi, etc. may expose a
   Linear MCP.) If your toolset includes a Linear tool that performs the operation, **use it** — it
   is better-authenticated and needs no `LINEAR_API_KEY`. Map each operation to the matching tool.
2. **Otherwise use the shell adapter** — run `profile.tracker.<op>` (which points at
   `adapters/linear.sh`, curl+jq over Linear's GraphQL API; needs `LINEAR_API_KEY`). This is the
   universal fallback that works in any harness with a shell.

Either way, extract the **same logical fields** from a fetched issue, regardless of the tool's
native shape: title, description, acceptance criteria, current status, milestone, branch name, and
blocking relations. The rest of the spine consumes those fields, not any tool-specific format.

## The issue identifier

The user names one issue (e.g. the profile's `tracker.identifier_example`). Carry it through
every phase. If the user gave no identifier, ask for one — never pick a ticket yourself.

## Pipeline

Run these phases **in order**. When you enter a phase, **read its reference file in full**
and follow it — that is how each phase gets its complete instructions without bloating this
file (the portable equivalent of reloading a sub-command).

| Phase | Reference file | One-line purpose |
|-------|----------------|------------------|
| 1. Pick | `references/01-pick.md` | Fetch issue, checkout branch, mark In Progress, surface AC |
| 2. Implement | `references/02-implement.md` | Explore patterns, write minimal code, checkpoint, self-assess AC |
| 3. Sanity check | `references/03-sanity-check.md` | **Hard gate**: quality checks + AC classification with evidence |
| 4. Review | `references/04-review.md` | Adversarial fresh-eyes review of the full diff |
| 5. Ship | `references/05-ship.md` | Squash, PR, CI, merge, deploy-identity verify, tracker close-out |

Two references are shared across phases — read them when a phase tells you to:

- `references/ac-classification.md` — how to classify and **prove** every acceptance
  criterion (code / dev-execution / prod-execution + evidence receipts). Used by phases 3 and 4.
- `references/recovery.md` — what to do when a phase fails: attempt counting via WIP commits,
  the two-attempt ceiling, and same-SHA flap detection. Consult on any failure.

## Gates (do not cross without the stated condition)

- **Sanity check is a blocker.** Verdict must be READY TO SHIP. NEEDS FIXES → fix, re-run the
  phase. Never skip to review or ship on a NEEDS FIXES.
- **Review must return SHIP.** FIX FIRST → fix the blocking items, re-run review.
- **Ship verifies deployed identity before trusting any AC.** After merge+deploy, confirm the
  running code is the code you merged (`profile.deploy.deployed_sha` + `profile.deploy.runtime_id`)
  *before* checking any post-deploy AC. An AC check against stale code is meaningless.

## Failure handling

On any phase failure, read `references/recovery.md`. In short: diagnose, fix, re-run the phase,
and record each fix attempt as a WIP commit so attempt count survives a context reset. After
**two** failed attempts at the same phase, stop and report to the user with the specific error
and which phase to resume from.

## Final report

After all five phases pass, output:

```
Done: <ISSUE> — <title>
PR:      <url> (merged)
Status:  <tracker Done state>
Branch:  deleted

Acceptance Criteria:
  ✓ <criterion>            (one line each)

Pipeline: pick ✓ → implement ✓ → sanity ✓ → review ✓ → ship ✓
Next up:  <highest-priority open issue, if the tracker exposes one>
```
