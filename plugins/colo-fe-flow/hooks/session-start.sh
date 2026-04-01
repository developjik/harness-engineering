#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/hook-runtime.sh
source "$SCRIPT_DIR/lib/hook-runtime.sh"

PAYLOAD="$(cat || true)"
PROJECT_ROOT="$(cff_hook_project_root "$PAYLOAD")"

cff_state_init_index "$PROJECT_ROOT"

ACTIVE_TICKET="$(cff_state_get_active_ticket "$PROJECT_ROOT")"
cff_log_append_runtime "$PROJECT_ROOT" "session" "SESSION_START active_ticket=${ACTIVE_TICKET:-none}"

if [[ -n "$ACTIVE_TICKET" ]]; then
  cff_log_append "$PROJECT_ROOT" "$ACTIVE_TICKET" "SESSION_START active_ticket=$ACTIVE_TICKET"
fi
