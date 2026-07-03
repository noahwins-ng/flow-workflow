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

**Candidate future borrows (not yet adopted):**
- *subagent-driven-development* / *dispatching-parallel-agents* — dispatch implementation to a fresh
  subagent; we only use a fresh-eyes reviewer today.
- *requesting-code-review* / *receiving-code-review* — the discipline of processing feedback without
  rationalizing; our review phase covers the adversarial pass but not the "receiving" half.
- *writing-plans* — finer 2–5 minute task granularity than our phase/issue decomposition.
- *using-git-worktrees* — parallel branch work.

## [wshobson/agents](https://github.com/wshobson/agents)

Confirmed the multi-manifest, one-source-of-truth marketplace pattern across five harnesses.
