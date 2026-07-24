---
name: flow-status
description: >-
  Quick local glance at the current work state — branch, commits ahead of the default branch, and
  uncommitted changes. No tracker or network calls. Use when the user says "status", "/flow-status",
  "what's my git state", or wants a fast snapshot without the fuller flow-session-check.
---

# Status

Fast, local-only snapshot. No tracker/API calls (that's flow-session-check's job). Reads
`profile.project.default_branch` if a profile is present; otherwise assumes `main`.

## Steps

1. `git branch --show-current`
2. `git log --oneline <default_branch>..HEAD` — commits ahead of the default branch
3. `git status --short` — uncommitted + untracked

## Report
**Emit this block in full** — every line, placeholders substituted. Never summarize, compress, or collapse it to prose.
```
Branch:      <branch>
Ahead:       <N commits> vs <default_branch>
  <sha> <subject>
Uncommitted: <N modified, M untracked>   (or "clean")
```
