---
name: flow-server-audit
description: >-
  Audit a production deploy for durability / host / security / drift gaps, classify findings
  (healthy / advisory / gap), and propose tracker tickets for gaps — filed only on approval.
  Read-only on prod. Use for a periodic health snapshot, after an incident, or when the user says
  "server audit", "/flow-server-audit", or "check prod for gaps".
---

# server-audit

**Tier-3 deploy-topology template.** The *ceremony* (probe → classify → de-dupe → propose → file on
approval) is reusable; the **probes are topology-specific**. The default set below assumes a single
VPS running Docker Compose over ssh — the shape this was extracted from. If your deploy is
serverless / k8s / PaaS, **rewrite Step 1's probes** for that topology and keep everything else.

Reads `profile.audit`. If `profile.audit.host` is empty, this skill does not apply — say so and stop.
Read-only: never modifies config or restarts anything. Fixes go through the normal ship pipeline.

**Incident vs. routine.** If you're here in response to a **specific symptom** (a Discord alert, a
`check-prod` failure, a user report) rather than a routine snapshot, first dispatch the read-only
**`flow-investigator`** subagent (Claude Code: **`flow:flow-investigator`**; if the name doesn't
resolve, retry with the other form — add the `flow:` prefix if it's bare, strip it if it's namespaced)
with the symptom — it returns a root-cause hypothesis + confidence
+ next-step commands. Verify its findings against the collection below. For a routine audit, skip
straight to Step 0.

## Step 0 — Orient
`ssh <audit.host> 'echo ok'` — if it fails, stop (nothing else is reachable). Read
`profile.audit.compose_file` for the expected service list. `git rev-parse origin/<default_branch>`
locally for the drift check.

## Step 1 — Collect (default: Docker-Compose-over-ssh probes — rewrite per topology)
- **A. Containers** — `docker ps -a` (every expected service `Up`); `docker inspect` for
  restart policy / healthcheck / mem limit / log driver. Flag `restart=no`, `health=no`, `mem=0`,
  or unbounded `json-file` logs.
- **B. Host** — `uptime && uname -r`; `df -h` (flag partitions with less free than
  `profile.audit.expected_min_health_partition_free_pct`); `free -h` + swappiness/overcommit;
  `/var/run/reboot-required` (pending reboot).
- **C. Auto-updates** — unattended-upgrades config + timers + log. Flag `Automatic-Reboot=true`
  without mail = silent reboots.
- **D. Security** — firewall status, fail2ban, sshd `PermitRootLogin`/`PasswordAuthentication`.
  Flag password auth on, root login on, no firewall.
- **E. App surface** — `curl -sf <profile.audit.health_url>` (200 + JSON); compare its reported
  deploy SHA to local `origin/<default_branch>` (drift); compare any runtime-identity counts to
  expected minimums (a load failure hides behind an Up container).
- **F. Repo drift** — `cd <profile.audit.repo_path> && git status --short`; anything beyond known
  runtime artifacts = an SCP'd/uncommitted change = deploy-blocking drift.

## Step 2 — Classify
✓ **Healthy** (one-line mention) · ⚠ **Advisory** (note, no ticket) · ✗ **Gap** (propose a ticket).

## Step 3 — De-dupe against the tracker
For each ✗ Gap, search `profile.cadence.project` for an open ticket covering the same scope before
proposing a new one. If covered, reference it (`covered by <id>`) and don't duplicate. When unsure a
duplicate exists, ask rather than filing.

## Step 4 — Report
```
Server Audit — <host> @ <UTC>
Healthy (N):  ✓ <finding>
Advisory (N): ⚠ <finding> — <why non-blocking today>
Gaps (tracked):   ✗ <finding> — covered by <id>
Gaps (untracked): 1. <title> [<label>/<priority>] — <one-line why>
Summary: N healthy, N advisory, N gaps (N tracked, N new).
```

## Step 5 — Confirm + file
Ask: *"File all N proposed tickets? (y / n / pick numbers)"*. On approval, create each in
`profile.cadence.project` with an appropriate label, priority (High for security/outage-class,
Medium for observability), status Todo, and the reliability/perpetual milestone. List the new ids +
URLs. Suggest the highest-priority new one as the next ship target.
