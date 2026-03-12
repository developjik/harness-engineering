#!/bin/bash

# SubagentStart Hook (architect)
# Architect 에이전트 시작 시 실행되는 스크립트

LOG_FILE="logs/session.log"
STATE_FILE="state/current-agent.txt"

mkdir -p logs state

# 현재 에이전트 상태 저장
echo "architect" > "$STATE_FILE"

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Architect agent started" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PDCA Cycle: PLAN phase" >> "$LOG_FILE"

# 성공 반환
exit 0
