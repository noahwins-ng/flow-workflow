#!/usr/bin/env bash
# flow plugin — PreToolUse(Bash) guardrail. Blocks dangerous git/shell commands.
# OPT-IN: inert unless enabled (env FLOW_HOOKS=1, or a `.flow-hooks` marker at the repo root).
# Exit 2 = block (stderr becomes feedback); exit 0 = allow.
set -euo pipefail

# --- opt-in gate: do nothing unless the user turned flow hooks on ---
enabled() {
  [ "${FLOW_HOOKS:-}" = "1" ] && return 0
  root=$(git rev-parse --show-toplevel 2>/dev/null) && [ -f "$root/.flow-hooks" ] && return 0
  return 1
}
enabled || exit 0

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
[ -z "$COMMAND" ] && exit 0

# Only treat as a real `git push` at the start of a command or after a shell separator
if printf '%s' "$COMMAND" | grep -qE '(^|[;&|])[[:space:]]*git[[:space:]]+push\b'; then
  if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]].*(--force|--force-with-lease|-f\b)'; then
    echo "Blocked: git push --force is not allowed. Use a regular push (flow ships via branch → PR)." >&2
    exit 2
  fi
  if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+push[[:space:]].*\b(main|master)\b'; then
    echo "Blocked: pushing directly to main/master is not allowed. Push a feature branch and open a PR." >&2
    exit 2
  fi
  # State-aware: a bare `git push` / `git push -u origin HEAD` while HEAD is on main still updates it.
  BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ "$BR" = "main" ] || [ "$BR" = "master" ]; then
    echo "Blocked: HEAD is on '$BR' — this push would update origin/$BR. Switch to a feature branch first (git switch -c <branch>)." >&2
    exit 2
  fi
fi

if printf '%s' "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "Blocked: git reset --hard discards work. Use git stash or git reset --soft." >&2
  exit 2
fi
if printf '%s' "$COMMAND" | grep -qE 'git\s+branch\s+-[dD]\s+(main|master)'; then
  echo "Blocked: cannot delete the main/master branch." >&2
  exit 2
fi
if printf '%s' "$COMMAND" | grep -qE 'git\s+checkout\s+--\s+\.'; then
  echo "Blocked: git checkout -- . discards all changes. Use git stash." >&2
  exit 2
fi
if printf '%s' "$COMMAND" | grep -qE 'rm\s+-rf\s+(\.|/|~|\$HOME|\.git)(\s|/|$)'; then
  echo "Blocked: rm -rf on the repo root / home / .git is not allowed." >&2
  exit 2
fi

exit 0
