#!/bin/bash

# SessionEnd Hook
# 세션 종료 시 실행되는 정리 스크립트

LOG_FILE="logs/session.log"
mkdir -p logs

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Session ended" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] ====================================" >> "$LOG_FILE"

# 성공 반환
exit 0
