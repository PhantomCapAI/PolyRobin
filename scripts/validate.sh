#!/usr/bin/env bash
# Validate the PolyRobin skill definition and sample config.
# - Checks SKILL.md has YAML frontmatter with all required fields.
# - Checks the example config parses as YAML.
# Exits non-zero on any failure so CI can gate on it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/SKILL.md"
CONFIG="$ROOT/examples/config.yaml"

fail() { echo "❌ $1" >&2; exit 1; }
pass() { echo "✅ $1"; }

[ -f "$SKILL" ]  || fail "SKILL.md not found at $SKILL"
[ -f "$CONFIG" ] || fail "examples/config.yaml not found at $CONFIG"

PY="$(command -v python3 || command -v python || true)"
[ -n "$PY" ] || fail "python3 (or python) is required to validate YAML"

"$PY" - "$SKILL" "$CONFIG" <<'PYEOF'
import sys, re

skill_path, config_path = sys.argv[1], sys.argv[2]

try:
    import yaml
except ImportError:
    print("❌ PyYAML is required: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

# --- SKILL.md frontmatter ---------------------------------------------------
text = open(skill_path, encoding="utf-8").read()
m = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
if not m:
    print("❌ SKILL.md is missing YAML frontmatter (--- ... ---)", file=sys.stderr)
    sys.exit(1)

try:
    fm = yaml.safe_load(m.group(1))
except yaml.YAMLError as e:
    print(f"❌ SKILL.md frontmatter is not valid YAML: {e}", file=sys.stderr)
    sys.exit(1)

required = ["name", "description", "tags", "version", "author"]
missing = [k for k in required if k not in fm or fm[k] in (None, "", [])]
if missing:
    print(f"❌ SKILL.md frontmatter missing required fields: {missing}", file=sys.stderr)
    sys.exit(1)

if fm["name"] != "PolyRobin":
    print(f"❌ Expected name 'PolyRobin', got {fm['name']!r}", file=sys.stderr)
    sys.exit(1)

if not isinstance(fm["tags"], list) or len(fm["tags"]) < 3:
    print("❌ 'tags' must be a list of at least 3 entries", file=sys.stderr)
    sys.exit(1)

if not re.match(r"^\d+\.\d+\.\d+$", str(fm["version"])):
    print(f"❌ 'version' must be semver (x.y.z), got {fm['version']!r}", file=sys.stderr)
    sys.exit(1)

print(f"✅ SKILL.md frontmatter OK (name={fm['name']}, version={fm['version']}, tags={len(fm['tags'])})")

# --- Required sections ------------------------------------------------------
body = text[m.end():]
for heading in ["Overview", "Safety Model", "Supported Markets",
                "Example Commands", "Integration Hooks", "Edge Cases",
                "Auditability"]:
    if not re.search(rf"^#+\s+.*{re.escape(heading)}", body, re.MULTILINE):
        print(f"❌ SKILL.md missing required section: {heading}", file=sys.stderr)
        sys.exit(1)
print("✅ SKILL.md has all required sections")

# --- Sample config ----------------------------------------------------------
try:
    cfg = yaml.safe_load(open(config_path, encoding="utf-8"))
except yaml.YAMLError as e:
    print(f"❌ examples/config.yaml is not valid YAML: {e}", file=sys.stderr)
    sys.exit(1)

for key in ["risk", "venues", "rails", "execution"]:
    if key not in cfg:
        print(f"❌ examples/config.yaml missing top-level key: {key}", file=sys.stderr)
        sys.exit(1)
print("✅ examples/config.yaml parses and has expected keys")
PYEOF

pass "All validations passed"
