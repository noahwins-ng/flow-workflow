# Acceptance-Criteria Classification & Evidence

Shared by the sanity-check (phase 3) and review (phase 4) phases. This is the discipline that
prevents shipping unverified work. Read it whenever a phase tells you to classify AC.

> The reasoning behind this discipline — why aggregate "green" doesn't prove durability, why deploy
> success isn't code-running, why liveness isn't durability — lives in
> `method/guidelines/verification-and-durability.md`. Read it if a gate feels like ceremony.

## The core rule

**"Needs manual verification" is NOT an acceptable state.** It has been used as a loophole to
ship work before it was actually verified. Every acceptance criterion is exactly one of three
kinds, and each kind has a required form of proof.

**Evidence must be FRESH.** Run the proving command *in this session* and read its actual output —
a prior run, "should pass", or "looks right" is not evidence. Words like **"should", "probably",
"seems to"** are banned as proof: they signal you're asserting, not verifying. If you haven't run
the command, you cannot claim it passes.

## The three kinds

> **Presentation vs. semantics.** The `[code AC]` / `[dev execution AC]` / `[prod execution AC]` tags
> below are the *semantic classification* — internal shorthand for how each criterion is proven. They
> are **not** a required rendering. When you **write** a ticket, follow the project's own AC format
> (many teams use a numbered list like `- [ ] AC1 (short-label, code AC) -- <text>`); the tag just
> records which class it is. When you **verify** (sanity/review), classify by these three kinds
> regardless of how the ticket rendered them.

### [code AC] — verifiable by reading the implementation
Example: "handles rate limits with exponential backoff", "uses an idempotent table engine",
"validates the ticker against the registry".
- **Proof:** a **passing test that pins it** (preferred — cite `test::name`; you wrote it test-first
  in implement Step 3). If the behavior is genuinely not unit-testable, cite the `file:line`. Mark
  PASS / FAIL. A code AC with a testable behavior and no test is a gap, not a pass.

### [dev execution AC] — must actually run locally before ship
Example: "backfill ran successfully", "endpoint returns 200", "no duplicates on re-run",
"asset visible in the lineage graph".
- **Proof (required):** run the command and paste literal output.
  ```
  ✓ <AC text>  [dev execution AC]
    Command: <exact command you ran>
    Output:  <actual output — the value/line that proves it, not a paraphrase>
  ```
- If you cannot show command + output, mark `✗ BLOCKED` and state the exact command the user
  must run. **This blocks ship.**

### [prod execution AC] — only confirmable in the deployed environment after merge
Example: "prod service healthy after deploy", "prod can trigger the asset", "prod endpoint
responds correctly".
- **Proof:** mark `⏳ PENDING — verify post-deploy`. Does **not** block ship, but **blocks the
  tracker → Done** transition. The ship phase resolves each one with post-deploy evidence.

## Keyword trigger (forces execution classification)

If an AC contains any word in `profile.ac_execution_keywords`, it is **always** a dev/prod
execution AC — never a code AC — regardless of how it's phrased. This stops "returns 200" style
criteria from being waved through by inspection.

## Implicit AC from changed files

If `profile.docs.ac_templates` is set, run `git diff --name-only <default_branch>...HEAD` and, for
any changed file matching a template's trigger list (e.g. CI/compose/Dockerfile/build files → the
infra-PR template), append that template's AC items. Treat them as required even when the issue
author omitted them.

## The evidence-shortcut discipline

Some projects have a shortcut where a local command reaches prod (e.g. an SSH tunnel makes local
queries hit the prod database). If your profile documents one, it is valid **only** for the
narrow claim it actually proves (e.g. "this row count exists in prod") — never for runtime,
routing, schedule/daemon state, or "the right code is deployed". Those need a real
deployed-environment check (`profile.deploy.deployed_sha` / `runtime_id` / `health`).

## Audit comment contract

When a phase posts a tracker comment, it must be **auditable at a glance** (per-AC, literal
evidence) AND **carry what you learned**. Two non-negotiable blocks:

1. **Per-AC receipts.** Every execution AC gets its literal `Command:` + `Output:`. Code AC names
   the file/line or test. Never collapse an execution AC to a bare ✓.
2. **Findings.** One bullet each for: a corrected assumption ("the ticket said X was safe;
   verified empirically it is not — <evidence>"), a latent bug found, a judgement call and why, or
   a scope shortcut taken. If genuinely nothing deviated, write one explicit line saying so —
   omitting the block is not allowed.
