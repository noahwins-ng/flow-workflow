# Per-harness notes

The one place harness-specific facts live. Skills state the *discipline* (what to do when a
capability exists / doesn't resolve); this file holds the per-harness *nouns* — so adding a harness
means updating one matrix, not sweeping every skill.

## Capability matrix

| Harness | Bundled-agent dispatch name | Named subagents | Hooks | Status |
|---------|-----------------------------|:---------------:|:-----:|--------|
| Claude Code | **namespaced `flow:<agent>`** — e.g. `flow:flow-code-reviewer`, `flow:flow-investigator` (verify with `/agents`) | ✅ | ✅ opt-in (`hooks/`, inert until `FLOW_HOOKS=1` / `.flow-hooks`) | ✅ validated |
| Cursor | TBD on validation | TBD | ❌ (no port yet) | ☐ unvalidated |
| Codex | TBD on validation | TBD | ❌ | ☐ unvalidated |
| opencode | **flat names, no prefix** — `flow-code-reviewer`, `flow-investigator` (registered by `.opencode/plugin/flow.ts`; matches profile default) | ✅ (`mode: subagent`, description-driven auto-dispatch + manual `@mention`; dispatch runtime-verified) | ✅ via plugin: `tool.execute.before` shells out to `hooks/protect-repo.sh` (opt-in `FLOW_HOOKS=1` / `.flow-hooks`, same as Claude Code). No session-close hook — `check-uncommitted.sh` not ported (known gap) | ✅ validated (1.18.21) — see [opencode.md](opencode.md) |
| pi | TBD on validation | TBD | ❌ | ☐ unvalidated |

## The dispatch rule (universal)

When a skill dispatches a bundled agent by the name configured in the profile
(`review.fresh_eyes_agent`, or `flow-investigator` by convention):

1. Dispatch the configured name.
2. **If it doesn't resolve, retry with the other namespace form** — add the harness's plugin prefix
   if the name is bare, strip it if it's namespaced — then fix the profile to the form that worked.
3. **Never silently degrade** to self-review / inline diagnosis because a name didn't resolve
   (the FAIL-1 trap). Degrading is only correct when the harness has no subagents at all — and then
   say so in the output.

On a **generic-subagent-only** harness, dispatch a general-purpose subagent with the corresponding
`agents/*.md` file as the prompt template. On a **no-subagent** harness, do the work in a single
pass yourself and note it.

## Tracker-endpoint quirks

- **claude.ai Linear MCP**: the relay's WAF **rejects POSTs whose body contains literal shell
  pipelines** (e.g. `curl … | jq …`) — issue descriptions and comments must reference commands as
  defanged prose ("read the health endpoint's version field"), never literal pipe chains. Reads
  are unaffected. Also: `list_projects` 400s when `includeMilestones` is combined with a team
  filter — fetch milestones separately.

## opencode quirks

- **Skills register via plugin, not placement**: `.opencode/plugin/flow.ts` pushes the repo's
  `skills/` onto `config.skills.paths` in its `config` hook (the superpowers pattern — they
  migrated off symlink farms). No symlinks, no vendoring; the repo stays a unit so `adapters/`
  and `method/` resolve. Validated on 1.18.x.
- **`AGENTS.md` beats `CLAUDE.md`**: if a project has both, opencode reads only `AGENTS.md`.
  For opencode-targeted projects, symlink (`ln -s CLAUDE.md AGENTS.md`) or the generated
  instructions are invisible there. The plugin's bootstrap also teaches the model this mapping.
- **Local plugins load by file path**, not directory: `"plugin": ["<repo>/.opencode/plugin/flow.ts"]`.
- **Skills auto-expose as slash commands**: every discovered skill becomes `/skill-name` in the
  TUI — no command registration needed at all. Quirks: expansion is TUI-only (`opencode run`
  passes slash text through literally), and plugin config-hook mutations to `config.command`
  are ignored (commands read static config + dirs only) — moot given auto-exposure.
- **Git-backed plugin specs get cache-pinned** by Bun; clear `~/.cache/opencode/node_modules/`
  when updates don't appear.

See [opencode.md](opencode.md) for the full validated writeup.

## Adding a harness

Validate per `VALIDATION.md` on a throwaway project, then fill this row in with what the harness
*actually* registered (don't guess from its docs) — and only then flip its manifest status in
`install/README.md`.
