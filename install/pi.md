# Installing the flow suite in pi (placeholder)

> **Status: aspirational, unverified.** Stub — I don't yet have confirmed details on pi's extension
> model. Fill this in from the docs / a real setup after the Claude Code validation pass.

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
