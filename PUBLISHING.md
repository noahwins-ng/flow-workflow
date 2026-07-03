# Publishing

How to ship this package the way orba / gstack ship — a public GitHub repo that doubles as a Claude
Code **plugin marketplace**, and (optionally) an Agent-Skills entry installable via the skills CLI.

The model in one line: **GitHub is the source of truth; installers just point at it.** You don't
upload to a registry — you push a repo and users add it.

## 1. Push to GitHub (the source of truth)

```bash
cd ~/Dev/dev-workflow-skill
git remote add origin git@github.com:noahwins-ng/flow-workflow.git   # or gh:
gh repo create noahwins-ng/flow-workflow --public \
  --description "Opinionated, portable dev-workflow skill suite" --source . --push
```
Tag the release so consumers can pin a version:
```bash
git tag v0.1.0 && git push origin v0.1.0
```

## 2. Distribute as a Claude Code plugin marketplace

This repo already carries both manifests:
- `.claude-plugin/plugin.json` — declares the `flow` plugin (its `skills/` are auto-discovered).
- `.claude-plugin/marketplace.json` — lists this repo as a one-plugin marketplace.

Users install with:
```
/plugin marketplace add noahwins-ng/flow-workflow
/plugin install flow@flow
```
Then in any project: run `flow-init` → `flow-doctor` (see `QUICKSTART.md`).

> Verify the exact `marketplace.json` schema + install syntax against the current Claude Code plugin
> docs (`/plugin` help) before announcing — the plugin format is still evolving. The fields here
> (`name`, `owner`, `plugins[].source/description`) match the documented shape at time of writing.

## 3. (Optional) Agent-Skills CLI channel

The Anthropic Agent-Skills ecosystem installs skills straight from a git repo, e.g.
`npx skills add <owner>/<repo>`. Our `skills/flow-*/SKILL.md` layout is compatible. Confirm the
current CLI's expected repo layout (top-level `skills/` vs. per-skill root) before advertising this
channel; adjust or add a thin manifest if it wants one.

## 4. Release hygiene

- Bump `VERSION` + move `CHANGELOG.md` `[Unreleased]` into a dated version section.
- `git tag vX.Y.Z && git push --tags`.
- The spine version is what a consuming project effectively pins to; the per-project
  `workflow-profile.yaml` is backward-additive, so minor bumps shouldn't break consumers.

## 5. Before you announce
- Run `VALIDATION.md` end-to-end at least once — don't publish an unrun package as "works".
- Skim the README/QUICKSTART for the placeholder owner/URL (`noahwins-ng`) and fix if wrong.
- Decide public vs. private. Public = anyone can `/plugin marketplace add` it.
