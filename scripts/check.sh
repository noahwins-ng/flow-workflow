#!/usr/bin/env bash
# Self-consistency gate for the flow package (VALIDATION.md Phase 6, mechanized).
# Checks structure only — the behavioral proof is still VALIDATION.md on a real project.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
FAIL=0
note() { printf '  %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; FAIL=1; }

# 1. Frontmatter: name == dir, description present and <= 1024 chars (agentskills.io spec)
echo "[1/6] skill frontmatter"
python3 - <<'PY' || FAIL=1
import pathlib, re, sys
import yaml
bad = False
for skill_md in sorted(pathlib.Path("skills").glob("*/SKILL.md")):
    dirname = skill_md.parent.name
    text = skill_md.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        print(f"FAIL: {skill_md}: no frontmatter"); bad = True; continue
    fm = yaml.safe_load(m.group(1))
    if fm.get("name") != dirname:
        print(f"FAIL: {skill_md}: name '{fm.get('name')}' != dir '{dirname}'"); bad = True
    desc = fm.get("description") or ""
    if not desc:
        print(f"FAIL: {skill_md}: missing description"); bad = True
    elif len(desc) > 1024:
        print(f"FAIL: {skill_md}: description {len(desc)} chars (spec max 1024)"); bad = True
sys.exit(1 if bad else 0)
PY

# 2. YAML surfaces parse + version lockstep
echo "[2/6] yaml parses + version lockstep"
for y in profile.template.yaml examples/*.yaml hooks/hooks.json .claude-plugin/*.json; do
  [ -f "$y" ] || continue
  python3 -c "import sys,yaml; yaml.safe_load(open('$y'))" 2>/dev/null || fail "$y does not parse"
done
# plugin.json version must match VERSION — Claude Code's plugin cache is keyed by it; a release
# without this bump serves stale content forever (bit us at v0.2.0).
PKG_V=$(tr -d '[:space:]' < VERSION)
PLUGIN_V=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
[ "$PKG_V" = "$PLUGIN_V" ] || fail "VERSION ($PKG_V) != .claude-plugin/plugin.json version ($PLUGIN_V)"

# 3. shellcheck
echo "[3/6] shellcheck"
if command -v shellcheck >/dev/null; then
  # -S warning: info-level SC2016 fires falsely on GraphQL '$var' strings in the adapter
  shellcheck -S warning adapters/*.sh hooks/*.sh scripts/*.sh || FAIL=1
else
  note "shellcheck not installed — skipped (CI runs it)"
fi

# 4. Package-internal cross-references resolve.
#    Scan prose surfaces for backticked package-root-relative paths; skip globs/placeholders.
#    (docs-skeleton + scaffolds are excluded: their refs point at the CONSUMER repo.)
echo "[4/6] cross-references resolve"
while IFS= read -r ref; do
  case "$ref" in (*'*'*|*'<'*|*'{'*|*'…'*) continue;; esac
  [ -e "$ref" ] || fail "dangling reference: $ref"
done < <(grep -rhoE '`(skills|method|adapters|agents|install|hooks)/[A-Za-z0-9._/-]+`' \
           --include='*.md' skills agents install method/conventions.md ./*.md 2>/dev/null \
         | grep -v 'method/docs-skeleton\|method/scaffolds' | tr -d '`' | sort -u)

# 5. Profile-key drift: every concrete profile.<section>.<key> a skill reads exists in the template.
echo "[5/6] profile keys exist in template"
python3 - <<'PY' || FAIL=1
import pathlib, re, sys
import yaml
tpl = yaml.safe_load(open("profile.template.yaml"))
bad = False
refs = set()
for md in pathlib.Path("skills").rglob("*.md"):
    refs.update(re.findall(r"profile\.([a-z_]+)\.([a-z_]+)", md.read_text()))
for section, key in sorted(refs):
    if section == "template":  # 'profile.template.yaml' the filename, not a key
        continue
    if section not in tpl:
        print(f"FAIL: profile.{section} referenced but not in template"); bad = True
    elif isinstance(tpl[section], dict) and key not in tpl[section]:
        print(f"FAIL: profile.{section}.{key} referenced but not in template"); bad = True
sys.exit(1 if bad else 0)
PY

# 6. Example profiles match the template schema (no section/key an example has that the
#    template doesn't — examples drifting from the schema is how consumers copy stale shapes).
echo "[6/6] example profiles match template schema"
python3 - <<'PY' || FAIL=1
import pathlib, sys
import yaml
tpl = yaml.safe_load(open("profile.template.yaml"))
bad = False
for ex in sorted(pathlib.Path("examples").glob("*.yaml")):
    doc = yaml.safe_load(ex.read_text())
    for section, val in doc.items():
        if section not in tpl:
            print(f"FAIL: {ex}: section '{section}' not in template"); bad = True
        elif isinstance(val, dict) and isinstance(tpl[section], dict):
            for key in val:
                if key not in tpl[section]:
                    print(f"FAIL: {ex}: '{section}.{key}' not in template"); bad = True
sys.exit(1 if bad else 0)
PY

echo
if [ "$FAIL" -ne 0 ]; then echo "check.sh: FAIL"; exit 1; fi
echo "check.sh: all green"
