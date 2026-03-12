#!/bin/bash

# Post-Bash Hook: Bash 명령 실행 후 페이로드 로깅

set -e

LOG_DIR="${HOME}/.harness-engineering/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/post-bash-$(date +%Y%m%d_%H%M%S).log"

INPUT="$(cat)"
COMMAND=""

if command -v jq &> /dev/null; then
    COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .tool_input.cmd // .tool_input.commandLine // ""' 2>/dev/null || true)"
fi

{
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Post-bash hook triggered"

    if [ -n "$COMMAND" ]; then
        echo "Command: $COMMAND"
    fi

    echo "Payload:"
    printf '%s\n' "$INPUT"
} >> "$LOG_FILE"

exit 0
