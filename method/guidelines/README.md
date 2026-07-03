# Guidelines

Stack-agnostic engineering discipline distilled from a real project's hard-won lessons — the
reusable "how to work" that complements the CLAUDE.md Working Approach. Skills point here; read the
relevant one when you hit the situation it covers.

- [debugging-and-investigation.md](debugging-and-investigation.md) — investigate before you fix:
  state-not-logs, classify-the-variant, don't-dismiss-the-first-anomaly, fix-the-pattern,
  verify-before-asserting, read-`--help`-first.
- [scoping-and-tickets.md](scoping-and-tickets.md) — size/split/bundle work: reactive-is-half-of-scope,
  the-sizing-trap, cut-don't-rescope-thrice, bundle-follow-ups, template-pattern-PRs, calibration-window.
- [verification-and-durability.md](verification-and-durability.md) — the *why* behind the ship gates:
  green-hides-invariants, deploy≠running, liveness≠durability, evidence-over-assertion, sample-broadly,
  real-domain-bounds, declarative-runtime-state.

## Optional appendices (add when a project needs them)
- **Data pipelines** — domain-bound asset checks, sensor batching from day one, idempotent
  re-ingestion. (Currently lives in `../project-setup-playbook.md`; promote to a file for a data project.)
- **AI engineering** — eval false-positives sharpen the eval (don't loosen the contract), verify
  before recommending AI changes, domain conventions in reports not prompts, observability at the
  request boundary. (Not yet written — add for an LLM project.)
