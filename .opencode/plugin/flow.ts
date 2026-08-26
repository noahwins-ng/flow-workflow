/**
 * flow plugin for OpenCode
 *
 * Modeled on obra/superpowers' proven integration pattern:
 *  1. Registers the skills directory via the config hook (no symlinks needed).
 *  2. Registers bundled subagents + slash-commands via the config hook.
 *  3. Injects bootstrap context into the first user message of each session.
 *  4. Ports hooks/protect-repo.sh as a bash-tool guard (opt-in, same gating).
 */

import path from "path"
import fs from "fs"
import os from "os"
import { execFileSync } from "child_process"
import { fileURLToPath } from "url"

const __dirname = path.dirname(fileURLToPath(import.meta.url))

// Walk up from the plugin file to the package root (dir holding profile.template.yaml).
// This is tier 3 of the resolution chain in AGENTS.md; also exported as FLOW_ROOT.
function resolveFlowRoot(): string {
  let dir = __dirname
  for (let i = 0; i < 10; i++) {
    if (fs.existsSync(path.join(dir, "profile.template.yaml"))) return dir
    const parent = path.dirname(dir)
    if (parent === dir) break
    dir = parent
  }
  // Fallback: plugin lives at <root>/.opencode/plugin/
  return path.resolve(__dirname, "../..")
}

const FLOW_ROOT = resolveFlowRoot()
const SKILLS_DIR = path.join(FLOW_ROOT, "skills")
const AGENTS_DIR = path.join(FLOW_ROOT, "agents")

// Frontmatter extraction handling plain scalars and block scalars (>- and |).
function parseFrontmatter(content: string): { fm: Record<string, string>; body: string } {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/)
  if (!match) return { fm: {}, body: content }
  const fm: Record<string, string> = {}
  let currentKey: string | null = null
  let blockLines: string[] = []
  const flushBlock = () => {
    if (currentKey && blockLines.length) {
      fm[currentKey] = blockLines.map((l) => l.trim()).join(" ")
    }
    currentKey = null
    blockLines = []
  }
  for (const line of match[1].split("\n")) {
    const m = line.match(/^([A-Za-z_-]+):\s*(.*)$/)
    if (m && !line.startsWith(" ") && !line.startsWith("-")) {
      flushBlock()
      const key = m[1]
      let value = m[2].trim()
      if (/^[>|][+-]?$/.test(value)) {
        currentKey = key
        continue
      }
      fm[key] = value.replace(/^["']|["']$/g, "")
    } else if (line.match(/^\s+\S/) && currentKey) {
      blockLines.push(line)
    }
  }
  flushBlock()
  return { fm, body: match[2] ?? "" }
}

// Module-level bootstrap cache (read once per session; see superpowers #1202).
let _bootstrapCache: string | undefined

function getBootstrapContent(): string | null {
  if (_bootstrapCache !== undefined) return _bootstrapCache
  _bootstrapCache = `<EXTREMELY_IMPORTANT>
You have the **flow** dev-workflow suite installed (${FLOW_ROOT}).

It takes a tracked issue from pick → implement → sanity-check → adversarial review → ship,
plus inception (flow-init/flow-tailor/flow-plan-project), cadence rituals
(flow-cycle-start/end, flow-retro), scope & sync skills, and recovery (flow-fix).

**Start here:** to decide which flow skill fits the situation, use the \`flow\` index skill
(via OpenCode's native \`skill\` tool). Every skill resolves package-internal paths against
the package root above (also available as $FLOW_ROOT).

**Noun mapping** — flow skills were written for Claude Code; substitute OpenCode equivalents:
- \`\${CLAUDE_PLUGIN_ROOT}\` → \`${FLOW_ROOT}\`
- \`CLAUDE.md\` → \`AGENTS.md\` (OpenCode reads AGENTS.md, not CLAUDE.md)
- \`Task\` tool dispatching a named subagent → OpenCode's task/subagent system (\`@mention\` or
  the \`task\` tool); bundled agents are registered flat as \`flow-code-reviewer\` /
  \`flow-investigator\`
- \`.claude/worktrees/<id>\` → park-mode worktrees live at \`profile.vcs.worktrees_dir\` from
  the project's workflow-profile.yaml (default .claude/worktrees)
- Invoke a skill → OpenCode's native \`skill\` tool
</EXTREMELY_IMPORTANT>`
  return _bootstrapCache
}

export const FlowPlugin = async ({ client }) => {
  await client.app.log({
    body: { service: "flow-plugin", level: "info", message: `flow plugin initialized, root=${FLOW_ROOT}` },
  }).catch(() => {})

  // --- Guard: port of hooks/protect-repo.sh, shelling out to the same script ---
  const guardEnabled = (): boolean => {
    if (process.env.FLOW_HOOKS === "1") return true
    try {
      const root = execFileSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" }).trim()
      return fs.existsSync(path.join(root, ".flow-hooks"))
    } catch {
      return false
    }
  }

  return {
    // Register skills dir + bundled agents + slash-commands on the live config.
    // Works because Config.get() returns a cached singleton visible to later discovery.
    config: async (config) => {
      config.skills = config.skills || {}
      config.skills.paths = config.skills.paths || []
      if (!config.skills.paths.includes(SKILLS_DIR)) {
        config.skills.paths.push(SKILLS_DIR)
      }

      // Bundled subagents: agents/*.md -> mode: subagent, body becomes prompt.
      try {
        config.agent = config.agent || {}
        for (const file of fs.readdirSync(AGENTS_DIR).filter((f) => f.endsWith(".md"))) {
          const { fm, body } = parseFrontmatter(fs.readFileSync(path.join(AGENTS_DIR, file), "utf8"))
          if (!fm.name || !body) continue
          config.agent[fm.name] = {
            ...(config.agent[fm.name] || {}),
            description: fm.description || "",
            mode: "subagent",
            prompt: body,
          }
        }
      } catch {}

      // Slash-commands need no registration: opencode auto-exposes every discovered
      // skill as /<skill-name> (verified via server API on 1.18.21 — all 18 flow-*
      // commands appear from skills discovery alone).
    },

    // Inject bootstrap into the first user message of each session
    // (user message, not system — avoids per-turn token bloat and Qwen breakage;
    // see superpowers #750/#894). Fires every agent step, hence cache + idempotence guard.
    "experimental.chat.messages.transform": async (_input, output) => {
      const bootstrap = getBootstrapContent()
      if (!bootstrap || !output.messages?.length) return
      const firstUser = output.messages.find((m) => m.info.role === "user")
      if (!firstUser || !firstUser.parts?.length) return
      if (firstUser.parts.some((p) => p.type === "text" && p.text?.includes("dev-workflow suite installed"))) return
      const ref = firstUser.parts[0]
      firstUser.parts.unshift({ ...ref, type: "text", text: bootstrap })
    },

    // PreToolUse(Bash) equivalent: feed protect-repo.sh its usual JSON stdin,
    // map exit 2 to a block with the script's message as feedback.
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      if (!guardEnabled()) return
      const payload = JSON.stringify({ tool_name: input.tool, tool_input: output.args })
      try {
        execFileSync("bash", [path.join(FLOW_ROOT, "hooks", "protect-repo.sh")], {
          input: payload,
          env: process.env,
          encoding: "utf8",
        })
      } catch (err: any) {
        if (err?.status === 2) {
          throw new Error((err.stderr || err.stdout || "Blocked by flow guardrail").trim())
        }
        // Script crash should not wedge the session; allow but surface via logs.
        console.error("[flow-plugin] protect-repo.sh failed:", err?.message)
      }
    },
  }
}
