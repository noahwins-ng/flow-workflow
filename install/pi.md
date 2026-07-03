# Installing the flow suite in pi (placeholder)

> **Status: aspirational, unverified.** Stub — fill in from a real setup after the Claude Code pass.
>
> **Concrete path:** add a `.pi/extensions/` manifest over the same `skills/`, modeled on
> [obra/superpowers](https://github.com/obra/superpowers)'s `.pi/extensions/` (superpowers explicitly
> supports Pi); users install via `pi install git:github.com/noahwins-ng/flow-workflow`. See
> `install/README.md` for the per-harness table + adapter contract.

## What needs verifying (open questions)
- **Skill/command mechanism.** How does pi register reusable, description-triggered instructions? Is
  there a skills/commands/prompts concept, or only a single instruction file?
- **Package root.** Is there a stable path (an env var or convention) the skills can resolve
  `adapters/`, `method/`, and sibling skills against?
- **Shell access.** Does pi allow shelling out (git, gh, curl, jq)? The ship/verify/adapter paths need it.
- **Tracker.** Native Linear MCP available? If not, does the shell path support `adapters/linear.sh`
  + `LINEAR_API_KEY`?
- **Subagent.** Any fresh-eyes-reviewer equivalent? Else leave `review.fresh_eyes_agent` empty.

## Next step
Answer the questions above from pi's docs, then write the concrete install steps here, mirroring
[claude-code.md](claude-code.md). See [README.md](README.md) for the common adapter contract.
