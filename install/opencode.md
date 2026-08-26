# Installing the flow suite in opencode

> **Status: validated against opencode 1.18.21** (runtime-tested on a throwaway project).
> Plugin-based install modeled on [obra/superpowers](https://github.com/obra/superpowers)'s
> current opencode integration — which itself migrated off symlink-based installs.

## Mechanism (what the plugin does)

`.opencode/plugin/flow.ts` is a standard opencode local plugin that:

1. **Resolves the package root** by walking up from its own location to the directory holding
   `profile.template.yaml` — satisfying tier 3 of the resolution chain in `AGENTS.md`.
2. **Registers skills** via the `config` hook: pushes `<root>/skills` onto
   `config.skills.paths`. Skill discovery reads the live config after plugin init, so all
   18 `flow-*` SKILL.md files surface through opencode's native `skill` tool with their
   trigger-phrase descriptions intact. No symlinks, no copying — the repo stays a unit, so
   `adapters/`, `method/`, and cross-skill read-and-follow references resolve.
3. **Registers subagents** via the same hook: each `agents/*.md` becomes a flat-named
   `mode: subagent` agent (`flow-code-reviewer`, `flow-investigator`) whose body is the prompt.
4. **Slash-commands come free**: opencode auto-exposes every discovered skill as a
   `/<skill-name>` slash command (verified via the server API — all 18 `flow-*` appear from
   skills discovery alone; no registration needed). Quirk: expansion is **TUI-only** —
   `opencode run "/flow-x"` passes the literal text to the model instead.
5. **Injects bootstrap** into the first user message of every session (via
   `experimental.chat.messages.transform` — user-message injection, not system, following
   superpowers #750/#894): points at the `flow` index skill and provides a Claude Code →
   opencode noun map.
6. **Ports the guardrail**: `tool.execute.before` on bash feeds `hooks/protect-repo.sh` its
   usual JSON stdin and maps exit 2 → block with the script's own message. Opt-in gated exactly
   like Claude Code (`FLOW_HOOKS=1` or `.flow-hooks` at repo root). Single source of truth
   stays in the shell script.

**Not ported:** `check-uncommitted.sh` (SessionEnd nudge). opencode has no session-end hook;
the nearest event (`session.idle`) fires per-turn, not at session close — a literal port would
nag every turn. Known gap; revisit when opencode grows a session-close event.

## Install

See [.opencode/INSTALL.md](../.opencode/INSTALL.md) — one `plugin` line pointing at
`.opencode/plugin/flow.ts` (**file path**, not directory), restart opencode. Git-backed spec
and version pinning covered there too.

## Runtime-verified behavior

| Check | Result |
|-------|--------|
| Plugin loads, root resolves | ✅ log: `flow plugin initialized, root=…` |
| Skills visible to native `skill` tool | ✅ all 18 `flow-*` listed |
| Subagent dispatch by flat name | ✅ `flow-investigator` dispatched via task tool, followed its report format |
| Guardrail blocks force-push (opted-in) | ✅ script's exact "Blocked:" message surfaces as tool error |
| Guardrail inert without opt-in | ✅ git's own error appears, no block |
| Bootstrap injected | ✅ model reports suite + `$FLOW_ROOT` unprompted |
| Slash-commands | ✅ all 18 `/flow-*` auto-exposed from skills (server-API verified); TUI-only expansion |

## Harness notes / quirks

- **Dispatch names are flat** — profile defaults already match; the namespace-retry rule in
  `harness-notes.md` rarely triggers here.
- **AGENTS.md vs CLAUDE.md** — opencode reads `AGENTS.md`, not `CLAUDE.md`. For projects with
  only CLAUDE.md: `ln -s CLAUDE.md AGENTS.md`.
- **Updates** — git-backed plugin specs can be pinned by Bun's cache; clear
  `~/.cache/opencode/node_modules/` if updates don't appear.
- **Tracker** — Linear via native MCP: `mcp.linear: { type: "remote", url: "https://mcp.linear.app/mcp" }`
  (streamable HTTP; **not** `/sse` which 404s — verified 2026-08-24; shows `needs_auth` until
  OAuth is approved in the TUI). No `LINEAR_API_KEY` needed on opencode — the adapter
  (`adapters/linear.sh`) is only the Claude Code / fallback path.

See [README.md](README.md) for the common adapter contract.
