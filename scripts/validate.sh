#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: claude CLI is required to validate this plugin." >&2
  exit 1
fi

echo "==> Validating Claude plugin manifest"
claude plugin validate .

echo "==> Checking hook shell syntax"
bash -n hooks/*.sh

if command -v jq >/dev/null 2>&1; then
  echo "==> Validating hooks.json"
  jq empty hooks.json
fi

echo "Validation passed"
