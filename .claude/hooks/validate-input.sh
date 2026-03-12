#!/bin/bash

# UserPromptSubmit Hook
# 사용자 입력 검증 스크립트

LOG_FILE=".claude/logs/session.log"

# 입력 데이터 읽기
INPUT=$(cat)

# 입력 길이 확인
PROMPT=$(echo "$INPUT" | jq -r '.prompt' 2>/dev/null)
PROMPT_LENGTH=${#PROMPT}

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] User prompt submitted (length: $PROMPT_LENGTH)" >> "$LOG_FILE"

# 입력 검증
if [ -z "$PROMPT" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Warning: Empty prompt" >> "$LOG_FILE"
fi

# 성공 반환
exit 0
