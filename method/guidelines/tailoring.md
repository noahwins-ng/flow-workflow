# Tailoring the workflow to a project

The question bank for `flow-tailor`. The spine's gates are **contracts**; every project answers
them differently. This file is how you derive — rather than copy — those answers. Work from repo
evidence first, interview second, and prove everything you derive.

## The three gate contracts

### identity — "the running/published artifact is the merged commit"
1. **Where does merged code end up?** A host? A platform deployment? A container image? A registry
   package? Nowhere (library pre-publish)?
2. **What identifier travels from the commit to that artifact?** A git SHA on disk, a deployment's
   recorded SHA, an image digest/tag, a version string.
3. **What one command reads that identifier back from the live side?** That command is
   `deploy.deployed_sha`. If nothing travels (answer 1 was "nowhere"), the key is empty — a valid
   answer, reported by flow-doctor, never faked.

### runtime-load — "the live process actually loaded that code"
1. **What separates "files landed" from "process runs them" here?** A restart that may not have
   happened, a cold-start cache, a bind-mounted config a container never re-read? (This gate exists
   because of real silent-deploy failures — code on disk, stale process serving.)
2. **What asserts the loaded state?** A version/build-id endpoint, an exec-in-container assertion
   on the loaded module graph, a function returning its bundle hash.
3. If the platform makes identity and load inseparable (immutable deploys — a Vercel deployment
   *is* its code), leave it empty and say so in the derivation note. Don't manufacture a
   distinction the topology doesn't have.

### health — "it works"
One **cheap, real** operation through the main path: an API round-trip, a CLI invocation on an
installed artifact, one row queried. Not a synthetic ping that exercises nothing. If it costs money
per call, pick the cheapest honest probe and note the cost.

## The verify surface

- `verify.*` must **mirror CI exactly** — a local gate that's looser than CI ships surprises; one
  that's stricter makes people skip it. Read the CI config and match it.
- `test` = the fast offline gate. If the full suite hits networks/LLMs/paid APIs, find or create
  the offline subset and put the caveat in `test_note`.
- `test_targeted` needs `{path}` to work for how THIS repo is laid out — monorepo: per-package
  runner; single package: path filter.
- A missing gate is empty + flagged (e.g. no type-checker in plain JS) — never a command that
  doesn't exist in the repo.

## The AC surfaces

- `ac_execution_keywords` — read 3–5 of the team's real tickets (or the spec): which words claim
  **runtime facts**? ("populated", "returns", "renders", "exit code", "published", "visible"...)
  Those words force execution-class AC. Domain-specific ones matter most — a data project's
  "backfilled", a CLI's "exit code".
- **AC-templates** (`docs.ac_templates`) — ask: *"which files, when touched, have historically
  broken prod (or obviously could)?"* Deploy configs, migrations, CI workflows, infra scripts.
  Each answer becomes a diff-path trigger group with default execution AC. Derive triggers from
  this repo's paths, not the skeleton's examples.

## The rules surfaces

- `architecture_rules` — the invariants a reviewer must check every diff against. Sources: the
  spec's non-negotiables, an existing CLAUDE.md, and the interview question *"what must never
  happen in this codebase?"* 3–7 rules; each checkable against a diff. Not style — invariants.
- `audit.*` — only if something long-running is reachable (`host` non-empty). Serverless/library
  ⇒ empty, and flow-server-audit is off; that's the topology speaking, not a gap.

## Anti-patterns (each has bitten)

- **Copying the template's VPS probes onto a non-VPS project** — they parse, they're wired, and
  they fail at first ship. The template values are *one topology's rendering*, not defaults.
- **Inventing a plausible command instead of leaving empty.** Empty degrades visibly (doctor
  reports it); plausible-but-wrong fails silently mid-pipeline.
- **Accepting a probe because the user asserted it works.** Run it. The user's memory of their
  own infra drifts too.
- **Deriving once and never re-proving.** Probes rot when infra changes; re-tailor on topology
  change, and treat a gate failing oddly during ship as "probe stale?" before "deploy broken?".
