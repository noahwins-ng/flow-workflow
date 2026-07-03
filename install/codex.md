# Installing the flow suite in Codex (placeholder)

> **Status: aspirational, unverified.** This is a stub. Do the Claude Code pass first, then fill this
> in from what actually works. Everything below is a starting hypothesis to be confirmed.

## What needs verifying
- **Instruction/skill mechanism.** Codex reads `AGENTS.md` for project instructions and supports
  custom prompts. Confirm how (or whether) it registers reusable, description-triggered "skills" vs.
  requiring each `flow-*` to be a named prompt referenced from `AGENTS.md`.
- **Package root.** Confirm a stable path the skills can resolve `adapters/`, `method/`, and sibling
  skills against (the equivalent of `${CLAUDE_PLUGIN_ROOT}`).
- **Tracker.** Does the session have a Linear MCP? If not, confirm shell access for
  `adapters/linear.sh` + `LINEAR_API_KEY`.
- **Subagent.** Is there a fresh-eyes-reviewer equivalent? If not, leave `review.fresh_eyes_agent` empty.

## Likely install shape (to confirm)
1. Vendor the package somewhere stable and record its root.
2. Reference the flow skills from `AGENTS.md` (or the prompts dir), preserving the trigger phrases
   from each SKILL.md description.
3. Run `flow-init` → `flow-doctor` in the target repo.

See [README.md](README.md) for the common adapter contract.
