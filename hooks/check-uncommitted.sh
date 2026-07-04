#!/usr/bin/env bash
# flow plugin — SessionEnd nudge. Warns about uncommitted work at end of session.
# OPT-IN: inert unless enabled (env FLOW_HOOKS=1, or a `.flow-hooks` marker at the repo root).
# Never blocks — just surfaces a reminder.
set -euo pipefail

enabled() {
  [ "${FLOW_HOOKS:-}" = "1" ] && return 0
  root=$(git rev-parse --show-toplevel 2>/dev/null) && [ -f "$root/.flow-hooks" ] && return 0
  return 1
}
enabled || exit 0

DIRTY=$(git status --porcelain 2>/dev/null || true)
if [ -n "$DIRTY" ]; then
  N=$(printf '%s\n' "$DIRTY" | grep -c '.' || true)
  echo "⚠ flow: $N uncommitted/untracked change(s) at session end — commit or stash before you lose context."
fi
exit 0
