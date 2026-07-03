# Influences

`flow` was generalized from a private slash-command workflow, then sharpened by studying the best
public agent-workflow packages. Credit where due.

## [obra/superpowers](https://github.com/obra/superpowers) (MIT)

The reference for both the distribution model and several disciplines.

**Adopted:**
- **Test-driven development** → `flow-ship-issue` implement phase now works test-first
  (red → green → refactor), with the key insight *"watch it fail for the right reason — a test you
  never saw fail proves nothing."*
- **Verification-before-completion** → the *gate function* ("no completion claim without fresh
  evidence, run in this session") and the anti-rationalization framing now live in
  `ac-classification.md` and `method/guidelines/verification-and-durability.md`.
- **Brainstorming HARD GATE** → a lightweight *confirm-the-approach* step before implementation
  (implement Step 2b). Ours is calibrated smaller because issue-level AC already exist; full
  design work lives upstream in `flow-plan-project`.
- **Multi-manifest distribution** (one `skills/` + a thin manifest per harness) → our
  packaging/install model. See `install/README.md`.
- **Receiving-code-review** → review phase (`04-review.md` Step 4) now processes findings with rigor
  (restate → verify against the code → fix or push back with reasoning → one at a time, test each),
  and forbids reflexive agreement in place of verifying.
- **Writing-plans (partial)** → for multi-file/non-trivial issues, implement Step 2b now maps the
  files-to-touch (one responsibility each) and breaks work into bite-sized, independently testable
  steps. We adopted the decomposition discipline, not the separate-plan-doc workflow.

**Candidate future borrows (not yet adopted) — the "parallelism/scale" cluster (harness-dependent):**
- *subagent-driven-development* — dispatch a fresh implementer subagent per task (per-task + broad
  review). Fit: an optional execution mode / a `flow-execute-plan` skill.
- *dispatching-parallel-agents* (partial) — `flow-fix` now dispatches one `flow-investigator` per
  independent failure domain in parallel. Not yet a general parallel-execution primitive.
- *requesting-code-review* (partial) — we now bundle a `flow-code-reviewer` and dispatch it
  (by name, or via `agents/flow-code-reviewer.md` as a prompt template on generic-subagent harnesses,
  superpowers-style). Not yet adopted: the per-request precisely-crafted context + severity triage.
- *using-git-worktrees* — isolated workspace; only pays off alongside subagent/parallel execution.

## [wshobson/agents](https://github.com/wshobson/agents)

Confirmed the multi-manifest, one-source-of-truth marketplace pattern across five harnesses.
