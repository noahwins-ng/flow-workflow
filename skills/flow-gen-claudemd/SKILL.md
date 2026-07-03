---
name: flow-gen-claudemd
description: >-
  Generate a CLAUDE.md for the project following the established convention — the project-agnostic
  Working Approach (Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven) plus a
  Project Conventions section filled from the profile, spec, and repo. Use when the user says
  "generate CLAUDE.md", "write the CLAUDE.md", "/flow-gen-claudemd", or after planning a new project.
---

# flow-gen-claudemd

Emit a `CLAUDE.md` in the house style. Starts from `method/claude-md-template.md` (Working Approach
is shipped verbatim; Project Conventions are placeholders to fill). Reads `profile.*`,
`profile.docs.spec`, `profile.docs.architecture`, and the repo itself.

## Golden rule
**Describe what's actually there — don't invent conventions.** Every claim in the Conventions
section must trace to the profile, the spec, or the repo. If a section has no basis, drop it rather
than fabricate one. If a `CLAUDE.md` already exists, do NOT overwrite — show a diff of proposed
additions and let the user merge.

## Steps

1. **Load the template** — `method/claude-md-template.md`. Keep the Working Approach section as-is
   (it's project-agnostic).

2. **Fill Project Conventions** from these sources, section by section:
   - **Core Philosophy** ← the spec's non-negotiable principles (`profile.docs.spec`) +
     `profile.architecture_rules`. State them as rules with rationale.
   - **Architecture** ← `profile.docs.architecture` (summarize, don't copy wholesale).
   - **Stack** ← the spec + what you detect in the repo (manifests, lockfiles).
   - **Repo Structure** ← the actual repo tree (packages/modules + one-line responsibilities).
   - **Code Style** ← `profile.verify.lint/format/types/test` verbatim.
   - **Git Workflow** ← `profile.vcs.*` (branch-per-issue, commit format, PR conventions, squash).
   - **Environment** ← `.env.example` / `profile.deploy.*` (dev↔prod split, key vars).
   - **Working Docs** ← `profile.docs.*` (pointers to architecture, decisions/, patterns, guides).
   - **Observability** ← only if the project has tracing/error-tracking/health; else drop.
   - **Common Commands** ← Makefile targets / npm scripts detected in the repo.

3. **Drop empty sections.** A short, true CLAUDE.md beats a long one padded with placeholders.

4. **Write** `CLAUDE.md` at the repo root (or show the merge diff if one exists). Report which
   sections were filled vs dropped, and flag anything you inferred and want the user to confirm.

## Report
```
Generated CLAUDE.md

Working Approach: included (standard)
Conventions filled: Core Philosophy, Architecture, Stack, Repo Structure, Code Style, Git Workflow, Common Commands
Dropped (no basis): Observability, Environment
Please confirm: <anything inferred rather than sourced>
```
