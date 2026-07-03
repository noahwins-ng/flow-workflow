# Installing the flow suite

## Distribution model: multi-manifest plugin/marketplace

One source of truth (`skills/`) + **a thin manifest per harness**. Each harness points its own
discovery mechanism at the same markdown. This is the pattern used by
[obra/superpowers](https://github.com/obra/superpowers) and
[wshobson/agents](https://github.com/wshobson/agents) — model our manifests on theirs.

**Why this pattern (not `npx skills`):** the marketplace/plugin route installs the **whole repo as a
unit** per harness, so our shared `adapters/`, `method/`, and cross-skill read-and-follow references
resolve. The Vercel `npx skills` CLI copies skills as **self-contained folders** and drops anything
outside a skill's own directory — which would break our shared root. So: plugin pattern fits our
architecture; skills-CLI fights it. (If we ever want the skills-CLI channel, it needs a flatten/build
step first — see ROADMAP.)

## Per-harness manifests

| Harness | Manifest | User install | Status |
|---------|----------|--------------|--------|
| Claude Code | `.claude-plugin/` (plugin.json + marketplace.json) | `/plugin marketplace add noahwins-ng/flow-workflow` → `/plugin install flow@flow` | ✅ manifest present, **unvalidated** |
| Cursor | `.cursor-plugin/` | `/add-plugin` / plugin marketplace | ☐ to add ([cursor.md](cursor.md)) |
| Codex | `.codex-plugin/` | `/plugins` → search → install | ☐ to add ([codex.md](codex.md)) |
| opencode | `.opencode/` (+ `INSTALL.md`) | follow `.opencode/INSTALL.md` | ☐ to add ([opencode.md](opencode.md)) |
| pi | `.pi/extensions/` | `pi install git:github.com/noahwins-ng/flow-workflow` | ☐ to add ([pi.md](pi.md)) |

Add each manifest by copying the shape from superpowers' corresponding file, pointing it at our
`skills/`. **Sequence: validate Claude Code first, then add + validate one harness at a time** — don't
mass-produce unvalidated manifests.

## The adapter contract (what every harness manifest must satisfy)

1. **Skill discovery** — register the `flow-*` SKILL.md files (descriptions carry trigger phrases).
2. **Package integrity** — install the repo as a unit so internal refs resolve: `adapters/linear.sh`,
   sibling `skills/flow-*/SKILL.md` (read-and-follow), `method/…`. Expose a **stable root** the skills
   resolve against (Claude Code: `${CLAUDE_PLUGIN_ROOT}`).
3. **Shell access** — ship/verify/adapter paths shell out (git, gh, ssh, curl, jq).
4. **Tracker** — native Linear tool if the harness has MCP; else `adapters/linear.sh` + `LINEAR_API_KEY`.
5. **Subagent (optional)** — for `profile.review.fresh_eyes_agent`; empty ⇒ single self-review pass.
6. **Bootstrap (optional)** — superpowers injects a small session-start doc so skills auto-trigger; a
   thin bootstrap could point the agent at `flow` (the index) on session start.
