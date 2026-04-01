#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 -m json.tool .claude-plugin/plugin.json > /dev/null
python3 -m json.tool hooks/hooks.json > /dev/null
python3 -m json.tool .mcp.json > /dev/null

python3 - <<'PY'
import json

with open("hooks/hooks.json", "r", encoding="utf-8") as handle:
    data = json.load(handle)

for rules in data.get("hooks", {}).values():
    for rule in rules:
        for hook in rule.get("hooks", []):
            command = hook.get("command", "")
            if "${CLAUDE_PLUGIN_ROOT}" in command and '"${CLAUDE_PLUGIN_ROOT}' not in command:
                raise SystemExit(f"unquoted CLAUDE_PLUGIN_ROOT in hook command: {command}")
PY

for file in hooks/*.sh hooks/lib/*.sh; do
  bash -n "$file"
done

source hooks/lib/dependency-check.sh
require_declared_mcp_servers "$ROOT_DIR"

for test_file in hooks/__tests__/*.test.sh; do
  [[ -f "$test_file" ]] || continue
  bash "$test_file"
done

echo "colo-fe-flow scaffold validation passed"
