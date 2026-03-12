#!/bin/bash

# SubagentStart Hook (guardian)
# Guardian 에이전트 시작 시 실행되는 스크립트

LOG_FILE=".claude/logs/session.log"
STATE_FILE=".claude/state/current-agent.txt"

mkdir -p .claude/state

# 현재 에이전트 상태 저장
echo "guardian" > "$STATE_FILE"

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Guardian agent started" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PDCA Cycle: CHECK phase" >> "$LOG_FILE"

# 성공 반환
exit 0
