# Installing the flow suite in opencode (placeholder)

> **Status: aspirational, unverified.** Stub — confirm against a real opencode setup after the Claude
> Code validation pass.

## What needs verifying
- **Skill/command mechanism.** opencode supports custom commands and agents and is fairly
  Claude-Code-like. Confirm the command/agent format and whether descriptions can carry trigger
  phrases for auto-selection.
- **Package root.** Confirm a stable path for resolving `adapters/`, `method/`, sibling skills.
- **Tracker.** opencode supports MCP — use a Linear MCP natively if present; otherwise shell +
  `adapters/linear.sh` + `LINEAR_API_KEY`.
- **Subagent.** Confirm the agent-dispatch story for the fresh-eyes reviewer; else leave empty.

## Likely install shape (to confirm)
1. Vendor the package at a stable path.
2. Register each `flow-*` as an opencode command/agent, preserving trigger phrases.
3. Run `flow-init` → `flow-doctor`.

See [README.md](README.md) for the common adapter contract.
