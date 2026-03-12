#!/bin/bash

# PostToolUse Hook (Write|Edit)
# 파일 수정 후 실행되는 스크립트

LOG_FILE="logs/session.log"
mkdir -p logs

# 입력 데이터 읽기
INPUT=$(cat)

# 수정된 파일 정보 추출
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path' 2>/dev/null)

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] File modified: $FILE_PATH (tool: $TOOL_NAME)" >> "$LOG_FILE"

# 파일이 존재하는지 확인
if [ -f "$FILE_PATH" ]; then
  FILE_SIZE=$(wc -c < "$FILE_PATH")
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] File size: $FILE_SIZE bytes" >> "$LOG_FILE"
fi

# 성공 반환
exit 0
