#!/bin/bash

# SessionStart Hook
# 세션 시작 시 실행되는 초기화 스크립트

# 로그 파일 설정
LOG_FILE=".claude/logs/session.log"
mkdir -p .claude/logs

# 세션 시작 로그
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Session started" >> "$LOG_FILE"

# 프로젝트 상태 확인
if [ -f "package.json" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Node.js project detected" >> "$LOG_FILE"
fi

if [ -d ".git" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Git repository detected" >> "$LOG_FILE"
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Current branch: $BRANCH" >> "$LOG_FILE"
fi

# 성공 반환
exit 0
