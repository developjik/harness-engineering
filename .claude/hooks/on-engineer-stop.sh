#!/bin/bash

# SubagentStop Hook (engineer)
# Engineer 에이전트 종료 시 실행되는 스크립트

LOG_FILE=".claude/logs/session.log"

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Engineer agent stopped" >> "$LOG_FILE"

# 성공 반환
exit 0
