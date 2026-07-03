# Working Approach

## 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.** State assumptions explicitly; if
uncertain, ask. If multiple interpretations exist, present them. If a simpler approach exists, say
so. If something is unclear, stop and name it.

## 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.** No features beyond what was asked, no
abstractions for single-use code, no configurability that wasn't requested, no error handling for
impossible scenarios. If you wrote 200 lines and it could be 50, rewrite it.

## 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.** Don't "improve" adjacent code or
refactor what isn't broken. Match existing style. Remove orphans your change created; leave
pre-existing dead code (mention it, don't delete it). Every changed line should trace to the request.

## 4. Goal-Driven Execution
**Define success criteria. Loop until verified.** Turn tasks into verifiable goals ("add validation"
→ "write tests for invalid inputs, then make them pass"). For multi-step work, state a brief plan
with a verify step each.

---

# <PROJECT NAME> — Project Conventions

<!-- flow-gen-claudemd fills the sections below from the profile + spec + repo. Keep only the
     sections that apply; drop the rest. Match the real repo, don't invent conventions. -->

## Core Philosophy
<The 1–3 non-negotiable rules that define this project — from the spec's Architectural Principles.
 e.g. a hard separation, a boundary that must never be crossed. State them as rules with rationale.>

## Architecture
<How the components relate; the data/request flow. A short diagram or a few lines. From docs.architecture.>

## Stack
<Languages, frameworks, datastores, infra — and why, briefly. From the spec / detected in the repo.>

## Repo Structure
<Where code lives — packages/modules and their responsibilities. Detected from the repo tree.>

## Code Style
<Lint / format / type / test commands — pull verbatim from profile.verify.*.>

## Git Workflow
<Branching (one branch per issue), commit format (profile.vcs.commit_format), PR conventions
 (profile.vcs.pr_*). One PR per issue; squash merge.>

## Environment
<Dev vs prod split, key env vars, how to switch. From .env.example / profile.deploy.*.>

## Working Docs
<Pointer to docs/: architecture (read first), decisions/ (ADRs), patterns.md, guides/. From profile.docs.*.>

## Observability
<What monitors what — tracing, error tracking, health, dashboards. Only if the project has them.>

## Common Commands
<The Makefile / npm-script targets a contributor runs daily. Detected from Makefile / package.json.>
