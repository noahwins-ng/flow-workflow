---
name: flow-tailor
description: >-
  Derive the project-specific workflow layer on top of the flow spine: study the repo, interview
  the user against the gate contracts, fill the judgment-call profile values (deploy probes,
  verify commands, AC keywords, AC-templates, architecture rules), and PROVE every derived command
  by running it. Use after flow-init, when the stack or deploy topology changes, or when the user
  says "tailor the workflow", "/flow-tailor", "fit the workflow to this project", or "derive the
  profile".
---

# flow-tailor

flow-init scaffolds files and pre-fills what a repo scan can detect. **This skill derives the rest
— the judgment calls** — so the project gets a bespoke, fit-for-purpose workflow instead of a
generic one with VPS-flavored defaults. The spine (gates, AC discipline, phase order) never
changes; what you derive here is *how this project satisfies the spine's contracts*.

The question bank lives in `method/guidelines/tailoring.md` — read it first.

**The one rule: a derived value you haven't run is a guess, not a derivation.** Empty-and-flagged
beats plausible-and-fake, always (an empty key degrades visibly; a fake one fails silently
mid-ship).

## Step 1 — Study (repo evidence first)

Read the repo before asking anything: manifests/lockfiles (stack), CI configs (what's already
gated), `Dockerfile`/`compose`/`vercel.json`/k8s manifests/`Procfile` (topology), test layout
(single suite vs monorepo packages), release machinery (publish scripts, tags, changelogs), and
any existing `CLAUDE.md`/docs for stated invariants.

State what you found as **assumptions to confirm**, not conclusions:
`"This looks like a Next.js app deploying to Vercel on merge — right?"`

## Step 2 — Interview (only what the repo can't answer)

Ask against the **gate contracts** (see the guideline's question bank):
- **identity** — where does merged code end up, and what command reads back *which commit/version
  is live there*?
- **runtime-load** — what proves the running process *loaded* it (not just files landed)?
- **health** — what one cheap real operation proves the main path works?
- Plus: the project's **dangerous surfaces** (for AC-templates), its **invariants** (for
  architecture_rules), and the runtime-claim words its tickets use (for ac_execution_keywords).

If a contract genuinely has no answer here ("it's a library, nothing runs"), the answer is
**empty** — that's a valid topology, and flow-doctor will report what it turns off.

**Owner unavailable** (unattended/delegated run): do NOT answer on their behalf. For each
unanswerable question, leave the value empty with a `# TO-ASK: <the exact question>` comment and
collect all of them as a numbered list in your report — the run is *complete-pending-interview*,
not failed. The owner's answers get applied as a follow-up pass (diff-and-confirm as usual).

**Greenfield / pre-build repo**: deriving from a *committed spec* is valid derivation — AC-template
triggers and architecture rules may name paths that don't exist on disk yet; they're proven the
first time a matching file lands. And distinguish empty's two meanings: **"no such concept"**
(permanent — the library archetype) vs **"not built yet"** (temporary). Annotate temporary empties
`# TO-DERIVE(after <milestone>): <what it becomes>` so flow-doctor reports them as *deferred*, not
off — and re-run tailor when that milestone lands.

## Step 3 — Derive

Fill the judgment-call surfaces, one at a time, showing your reasoning:
`verify.*` (must mirror CI exactly; `test_targeted` with `{path}`), `deploy.*` (probes satisfying
the contracts for *this* topology), `ac_execution_keywords`, `docs.ac_templates` content (implicit
AC triggered by this repo's actual dangerous paths), `architecture_rules`, `audit.*` (or empty),
`cadence`/`taxonomy` tracker nouns.

**Never silently overwrite a value the user set by hand** — propose a diff and confirm. Template
defaults are fair game.

## Step 4 — Prove (the hard gate)

Run **every** derived command now, in this session, and show the output:
- `verify.*` — each runs and exits cleanly (or fails for a real, explained reason).
- `deploy.deployed_sha` / `runtime_id` / `health` — each returns a **live value from the real
  environment** (an actual SHA, an actual healthy response). If you can't reach the environment,
  the value stays marked `UNPROVEN — run flow-doctor after first deploy`; do not present it as done.
- Tracker ops — one read call resolves.

No "should work". No accepting a probe because it looks right. This is the same fresh-evidence
gate the ship pipeline uses (`skills/flow-ship-issue/references/ac-classification.md`), applied to
the workflow itself.

## Step 5 — Document the derivation

Above each derived key, a one-line comment: what it was derived from and when it was proven —
`# derived: Vercel deploy on merge; proven 2026-07-06 (returned dpl_abc123)`. The next agent (or
you, re-tailoring in six months) inherits reasoning, not just strings.

## Step 6 — Gate

Read `skills/flow-doctor/SKILL.md` and follow it. The run must end HEALTHY, and you must walk the
**degradation report** with the user line by line: every OFF is either confirmed deliberate or
sent back to Step 2 (owner unavailable → mark each unconfirmed OFF as pending in the report,
alongside the TO-ASK list). Then report:

```
Tailored <project> — <topology> (<stack>)

  Derived + PROVEN: verify.* (4), deploy.deployed_sha, deploy.health, tracker ops
  Derived, UNPROVEN: deploy.runtime_id  (no prod access this session — verify after first deploy)
  Deliberately OFF:  audit.* (serverless), verify.types (plain JS)
  AC-templates:      2 trigger groups (migrations/, .github/workflows/)

  flow-doctor: HEALTHY
```

## Re-tailoring

Re-run whenever the stack, deploy target, or repo shape changes (or a ship run reveals a probe
went stale). Same rules: diff-and-confirm on anything user-set, re-prove anything that changed.
