# Installing the `flow` suite in Claude Code

Claude Code is the **primary, supported** harness. The other four targets (Codex, Cursor, opencode,
pi) are aspirational until validated — see `../ROADMAP.md`.

## Why install as a plugin (not loose skills)

The skills reference **package-internal paths** — `adapters/linear.sh`, sibling
`skills/flow-*/SKILL.md` (read-and-follow), and `method/docs-skeleton/`. These resolve only if the
package stays intact as a unit. Copying individual skill folders into `~/.claude/skills/` breaks
those sibling references. **Installing the whole package as one plugin keeps the structure together**
and exposes its root as `${CLAUDE_PLUGIN_ROOT}`, which is how skills locate the adapter and the
docs-skeleton.

## Install (plugin)

1. This repo already has `.claude-plugin/plugin.json`, and Claude Code auto-discovers a plugin's
   `skills/` folder — so all `flow-*` skills register on install.
2. Add the repo as a plugin (via a local marketplace entry or a plugin add pointing at this repo).
   All eleven `flow-*` skills + `flow-doctor` become available; the plugin namespaces them, and they
   also keep their baked-in `flow-` prefix for non-plugin/other-harness use.

## Per-project setup

From inside the target project repo:
1. Run **flow-init** — scaffolds the docs skeleton (or gap-fills an existing repo) and writes
   `workflow-profile.yaml`.
2. Run **flow-doctor** — confirms the profile is complete and its commands/paths/tracker resolve.
3. Then: *"ship &lt;ISSUE&gt;"*, *"session-check"*, *"cycle-start"*, etc.

## Tracker access

- If your Claude Code session has a **Linear MCP** server, the skills use it natively — no key needed.
- If not, they fall back to `${CLAUDE_PLUGIN_ROOT}/adapters/linear.sh`, which needs `LINEAR_API_KEY`
  exported (a Linear personal API key) plus `curl` + `jq`.

## Optional extras

- **Explicit `/flow-*` slash commands.** Skills are model-invoked by description. To also trigger
  them as literal slash commands, drop thin wrappers in `.claude/commands/` that say *"invoke the
  flow-ship-issue skill with $ARGUMENTS"*. Not required — asking in natural language already works.
- **Bundled subagents** (in `agents/`, auto-registered on install; both read *this* project's rules
  from the profile + CLAUDE.md):
  - **`flow-code-reviewer`** — fresh-eyes reviewer; `profile.review.fresh_eyes_agent` defaults to the
    namespaced **`flow:flow-code-reviewer`**, so the review phase gets an independent reviewer out of
    the box. Override or empty it for a single self-review pass.
  - **`flow-investigator`** — read-only diagnostician dispatched by `flow-fix` (complex/multi failures)
    and `flow-server-audit` (incident triage). Returns a root-cause hypothesis; never remediates.

## Optional guardrail hooks (Claude-Code-only, opt-in)

The plugin ships two Claude Code hooks in `hooks/` — **`protect-repo`** (blocks force-push, direct
`main`/`master` push, `git reset --hard`, and `rm -rf` on the repo root/home/.git) and
**`check-uncommitted`** (a session-end reminder). They're **registered on install but inert by
default** — installing flow never silently adds global git guardrails.

Enable them when you want the guardrails:
- **Globally:** add `export FLOW_HOOKS=1` to your shell profile.
- **Per-repo:** `touch .flow-hooks` at the repo root.

These align with flow's branch-per-issue + PR-merge model (hence "no direct push to main"). They're
Claude-Code-only; other harnesses have their own event models (not yet ported).

## Package path convention

All internal references (`adapters/…`, `method/…`, `skills/flow-*/…`) are **relative to the package
root**. Under a plugin install that root is `${CLAUDE_PLUGIN_ROOT}`. If you install some other way,
set `$FLOW_ROOT`, or resolve against the directory holding `AGENTS.md` — the full resolution chain
is documented in `AGENTS.md`.
