#!/usr/bin/env bash
# on-agent-start.sh — 통합 SubagentStart 훅
# 에이전트 전환 시 PDCA 단계 자동 추적 및 의존성 확인
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/common.sh
source "${SCRIPT_DIR}/common.sh"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PAYLOAD=$(cat)
HARNESS_DIR=$(harness_runtime_dir "$PAYLOAD")
LOG_DIR="${HARNESS_DIR}/logs"
STATE_DIR="${HARNESS_DIR}/state"
PROJECT_ROOT=$(harness_project_root "$PAYLOAD")

mkdir -p "$LOG_DIR" "$STATE_DIR"

AGENT_NAME=$(json_query "$PAYLOAD" '.agent_name // .agent // ""')

# 현재 에이전트 기록
echo "$AGENT_NAME" > "${STATE_DIR}/current-agent.txt"

# 에이전트 → PDCA 단계 매핑
case "$AGENT_NAME" in
  strategist)  PHASE="plan" ;;
  architect)   PHASE="design" ;;
  engineer)    PHASE="do" ;;
  guardian)    PHASE="check" ;;
  librarian)   PHASE="wrapup" ;;
  debugger)    PHASE="debug" ;;
  *)           PHASE="unknown" ;;
esac

echo "$PHASE" > "${STATE_DIR}/pdca-phase.txt"
echo "[$TIMESTAMP] AGENT_START agent=$AGENT_NAME phase=$PHASE" >> "${LOG_DIR}/session.log"

# ============================================================================
# 의존성 확인 (engineer 에이전트가 implement 단계 진입 시)
# ============================================================================
if [ "$AGENT_NAME" = "engineer" ] && [ "$PHASE" = "do" ]; then
  CURRENT_FEATURE=$(cat "${STATE_DIR}/current-feature.txt" 2>/dev/null || echo "")
  
  if [ -n "$CURRENT_FEATURE" ]; then
    if ! check_dependency_conflicts "$PROJECT_ROOT" "$CURRENT_FEATURE"; then
      echo "[$TIMESTAMP] DEPENDENCY_CHECK FAILED for feature=$CURRENT_FEATURE" >> "${LOG_DIR}/dependencies.log"
      echo "[WARNING] Some dependencies for feature '$CURRENT_FEATURE' are not yet completed." >&2
      echo "[WARNING] Please ensure all prerequisite features are marked as 'Completed' in docs/features.md" >&2
    fi
  fi
fi

# ============================================================================
# 기능 레지스트리 존재 확인
# ============================================================================
if ! check_feature_registry "$PROJECT_ROOT"; then
  echo "[$TIMESTAMP] REGISTRY_CHECK FAILED" >> "${LOG_DIR}/registry.log"
  echo "[INFO] Feature registry (docs/features.md) not found. Creating or updating it is recommended." >&2
fi
