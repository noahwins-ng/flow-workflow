# Installing the flow suite in opencode

> **Status: validated against opencode 1.18.x.** Plugin-based install modeled on
> [obra/superpowers](https://github.com/obra/superpowers)'s current opencode integration
> (they migrated off symlink-based installs; we never built one).

## Install (one config line)

Point the `plugin` array at the plugin **file** (not the directory — opencode loads explicit
local plugins by file path) in your `opencode.json` (global at
`~/.config/opencode/opencode.json`, or per-project):

```json
{
  "plugin": ["/absolute/path/to/flow-workflow/.opencode/plugin/flow.ts"]
}
```

Or, to let opencode install it for you, tell opencode:

```
Fetch and follow instructions from https://raw.githubusercontent.com/noahwins-ng/flow-workflow/main/.opencode/INSTALL.md
```

Then **quit and restart opencode** — config is loaded once at startup.

That's it — slash commands need no extra setup: opencode auto-exposes every skill as a
`/<skill-name>` command, so `/flow-ship-issue`, `/flow-doctor`, etc. work out of the box.

### Pinned / git-backed install

```json
{ "plugin": ["flow@git+https://github.com/noahwins-ng/flow-workflow.git"] }
```

Pin a tag with `.git#v0.4.3`. Note: Bun's plugin cache can pin a resolved git dependency —
if updates don't appear after `git pull`/tag bump, clear opencode's package cache
(`~/.cache/opencode/node_modules/`) and restart.

## What you get

- **All 18 `flow-*` skills**, discovered natively via the plugin's `config` hook pushing the
  repo's `skills/` onto `skills.paths` (runtime-verified on 1.18.21: all skills listed by the
  native `skill` tool). No symlinks, no copying — the repo stays intact so
  `adapters/`, `method/`, and cross-skill references resolve.
- **Bundled subagents**: `flow-code-reviewer`, `flow-investigator` registered as
  `mode: subagent` agents with flat names (no `flow:` prefix — matches the profile default;
  dispatch runtime-verified).
- **Slash commands**: `/flow-ship-issue <ID>`, `/flow-doctor`, etc. — auto-exposed from the
  skills, zero config (note: slash expansion is TUI-only; `opencode run "/flow-x"` passes the
  text through literally).
- **Bootstrap**: every session gets a short injection pointing at the `flow` index skill plus a
  Claude Code → opencode noun map (`CLAUDE_PLUGIN_ROOT` → package root, `CLAUDE.md` → `AGENTS.md`,
  worktree conventions) — runtime-verified.
- **Guardrail hook** (opt-in, runtime-verified): set `FLOW_HOOKS=1` or create a `.flow-hooks`
  marker at the repo root; dangerous git operations are then blocked via the same
  `hooks/protect-repo.sh` used by Claude Code. Inert without the opt-in.

## Verify

```
opencode run "use the skill tool to list skills"     # should include flow-*
opencode run "what flow skills are available?"       # bootstrap-aware answer
```

Inside a TUI session: invoke `/flow-status` or ask "which flow skill do I use to recover a broken
ship run?" (expect: flow-fix).

## Linear

Native MCP only on opencode — no `LINEAR_API_KEY` needed. Add to your global
`~/.config/opencode/opencode.json`:

```json
{ "mcp": { "linear": { "type": "remote", "url": "https://mcp.linear.app/mcp" } } }
```

`/mcp` is streamable HTTP (current Linear endpoint; `/sse` 404s). First tracker call triggers
an OAuth browser flow — approve once. Until then `opencode serve`'s `/mcp` shows `needs_auth`.
`adapters/linear.sh` + `LINEAR_API_KEY` remains only as the Claude Code fallback path.

## Troubleshooting

- **Skills not listed** — check plugin load logs:
  `opencode run --print-logs "hello" 2>&1 | grep -i flow-plugin`.
  Fallback: skip the plugin for skills and add one static line instead:
  `{ "skills": { "paths": ["/absolute/path/to/flow-workflow/skills"] } }`
  (then agents/commands come only if their `.opencode/agent|command` files exist).
- **Subagents don't dispatch by name** — dispatch `@flow-code-reviewer` directly once; opencode's
  subagents are description-driven like Claude Code's.
- **Instructions invisible** — opencode reads `AGENTS.md`, not `CLAUDE.md`. If a target project
  only has CLAUDE.md, symlink it (`ln -s CLAUDE.md AGENTS.md`).
- **Linear MCP shows `needs_auth` / `failed`** — start opencode TUI and trigger any tracker
  skill; approve the OAuth prompt. Check `curl -s http://127.0.0.1:<port>/mcp` → `connected`.

## Harness notes

See `install/harness-notes.md` for the capability matrix row and quirks.
