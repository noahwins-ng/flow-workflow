# Installing the flow suite in Cursor (placeholder)

> **Status: aspirational, unverified.** Stub — confirm against a real Cursor setup after the Claude
> Code validation pass.
>
> **Concrete path:** add a `.cursor-plugin/` manifest over the same `skills/`, modeled on the one in
> [obra/superpowers](https://github.com/obra/superpowers); users install via `/add-plugin` or the
> plugin marketplace. See `install/README.md` for the per-harness table + adapter contract.

## What needs verifying
- **Skill mechanism.** Cursor has Rules (`.cursor/rules/*.mdc`) and Commands. Confirm which best maps
  a description-triggered skill: Rules for always/auto-attached context, or Commands for explicit
  invocation. The `flow-*` skills are closer to Commands (invoked for a task) than always-on Rules.
- **Package root.** Confirm a stable path for resolving `adapters/`, `method/`, sibling skills.
- **Tracker.** Cursor supports MCP — a Linear MCP would be used natively; otherwise shell +
  `adapters/linear.sh` + `LINEAR_API_KEY`.
- **Subagent.** Confirm whether a fresh-eyes reviewer can be dispatched; else leave the field empty.

## Likely install shape (to confirm)
1. Vendor the package at a stable path.
2. Convert each `flow-*` SKILL.md into a Cursor Command (or a Rule), preserving trigger phrases.
3. Run `flow-init` → `flow-doctor`.

See [README.md](README.md) for the common adapter contract.
