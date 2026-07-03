# Installing the flow suite

| Harness | Status | Guide |
|---------|--------|-------|
| Claude Code | ✅ supported | [claude-code.md](claude-code.md) |
| Codex | 🚧 aspirational (placeholder) | [codex.md](codex.md) |
| Cursor | 🚧 aspirational (placeholder) | [cursor.md](cursor.md) |
| opencode | 🚧 aspirational (placeholder) | [opencode.md](opencode.md) |
| pi | 🚧 aspirational (placeholder) | [pi.md](pi.md) |

The four placeholders are honest stubs — the skill *bodies* are written to avoid harness-specific
assumptions, but each harness needs an install adapter that satisfies the contract below, and none
is verified yet. Do the Claude Code validation pass first; port the others from what it teaches.

## The adapter contract (what every harness install must provide)

1. **Skill discovery** — the harness must find and register the `flow-*` SKILL.md files, or convert
   them to the harness's own command/rule/prompt format. Descriptions carry the trigger phrases.
2. **Package integrity** — keep the package as a single unit so internal references resolve:
   `adapters/linear.sh`, sibling `skills/flow-*/SKILL.md` (read-and-follow), `method/…`. The harness
   must expose a **stable root path** the skills can resolve these against (Claude Code uses
   `${CLAUDE_PLUGIN_ROOT}`). Copying individual skill folders out breaks this.
3. **Shell access** — the ship/verify/adapter paths shell out (git, gh, ssh, curl, jq). A harness
   that sandboxes the shell will limit those skills.
4. **Tracker** — native Linear tool if the harness has MCP; otherwise `adapters/linear.sh` +
   `LINEAR_API_KEY` + `curl`/`jq`.
5. **Subagent (optional)** — for `profile.review.fresh_eyes_agent`; leave empty if unsupported and
   the review phase does a single self-pass.
6. **Explicit invocation (optional)** — map `flow-*` to the harness's slash/command mechanism if you
   want literal invocation beyond description-triggered use.
