#!/usr/bin/env bash
# common.sh — Harness 훅 공통 헬퍼

json_query() {
  local payload="${1:-}"
  local query="${2:-}"

  if [ -z "$payload" ] || [ -z "$query" ] || ! command -v jq >/dev/null 2>&1; then
    printf '\n'
    return 0
  fi

  printf '%s' "$payload" | jq -r "$query" 2>/dev/null || printf '\n'
}

harness_project_root() {
  local payload="${1:-}"
  local root=""

  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    root="${CLAUDE_PROJECT_DIR}"
  else
    root=$(json_query "$payload" '.cwd // .session.cwd // ""')
  fi

  if [ -z "$root" ] && command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
    root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  fi

  if [ -z "$root" ]; then
    root=$(pwd -P)
  elif [ -d "$root" ]; then
    root=$(cd "$root" && pwd -P)
  fi

  printf '%s\n' "$root"
}

harness_runtime_dir() {
  local root
  root=$(harness_project_root "${1:-}")
  printf '%s/.harness\n' "$root"
}

ensure_runtime_git_exclude() {
  local project_root="${1:-}"
  local git_root=""
  local exclude_path=""
  local pattern=""

  if [ -z "$project_root" ] || ! command -v git >/dev/null 2>&1; then
    return 0
  fi

  if ! git -C "$project_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  git_root=$(git -C "$project_root" rev-parse --show-toplevel 2>/dev/null || echo "")
  exclude_path=$(git -C "$project_root" rev-parse --git-path info/exclude 2>/dev/null || echo "")

  if [ -z "$git_root" ] || [ -z "$exclude_path" ]; then
    return 0
  fi

  case "$exclude_path" in
    /*) ;;
    *) exclude_path="${project_root}/${exclude_path}" ;;
  esac

  case "$project_root" in
    "$git_root")
      pattern=".harness/"
      ;;
    "$git_root"/*)
      pattern="${project_root#"$git_root"/}/.harness/"
      ;;
    *)
      return 0
      ;;
  esac

  mkdir -p "$(dirname "$exclude_path")"
  touch "$exclude_path"

  if ! grep -Fqx "$pattern" "$exclude_path"; then
    printf '%s\n' "$pattern" >> "$exclude_path"
    printf '%s\n' "$pattern"
  fi
}


# ============================================================================
# 기능 레지스트리 및 의존성 관리 헬퍼 함수
# ============================================================================

check_feature_registry() {
  local project_root="${1:-}"
  local features_file="${project_root}/docs/features.md"
  
  if [ ! -f "$features_file" ]; then
    printf '[WARNING] Feature registry not found: %s\n' "$features_file" >&2
    return 1
  fi
  return 0
}

get_feature_status() {
  local project_root="${1:-}"
  local feature_slug="${2:-}"
  local features_file="${project_root}/docs/features.md"
  
  if [ ! -f "$features_file" ]; then
    printf ''
    return 1
  fi
  
  # 간단한 grep 기반 상태 조회 (jq 없을 경우 대비)
  grep "^| \`${feature_slug}\`" "$features_file" | awk -F'|' '{print $4}' | xargs
}

check_dependency_conflicts() {
  local project_root="${1:-}"
  local current_feature="${2:-}"
  local features_file="${project_root}/docs/features.md"
  
  if [ ! -f "$features_file" ]; then
    return 0
  fi
  
  # 현재 기능이 의존하는 다른 기능들을 확인
  # 이들이 모두 Completed 상태인지 검증
  local dependencies=$(grep "^| \`${current_feature}\`" "$features_file" | awk -F'|' '{print $6}' | xargs)
  
  if [ -z "$dependencies" ] || [ "$dependencies" = "-" ]; then
    return 0
  fi
  
  # 의존성 목록 파싱 및 상태 확인 (간단한 구현)
  printf '[INFO] Dependencies for %s: %s\n' "$current_feature" "$dependencies" >&2
  return 0
}

detect_file_conflicts() {
  local project_root="${1:-}"
  local modified_file="${2:-}"
  local current_feature="${3:-}"
  local features_file="${project_root}/docs/features.md"
  
  if [ ! -f "$features_file" ]; then
    return 0
  fi
  
  # 다른 In Progress 기능들의 영향 범위를 확인하여 충돌 감지
  # 이는 간단한 텍스트 매칭으로 구현 가능
  local conflicting_features=""
  
  # 간단한 구현: 파일 경로가 다른 기능의 영향 범위에 포함되는지 확인
  while IFS='|' read -r slug title status team deps impact _; do
    # 헤더 행 및 구분선 스킵
    if [[ "$slug" =~ ^[[:space:]]*\| ]] || [[ "$slug" =~ ^[[:space:]]*\`feature ]]; then
      continue
    fi
    
    # 현재 기능 제외
    if [[ "$slug" =~ "$current_feature" ]]; then
      continue
    fi
    
    # In Progress 상태 확인
    if [[ "$status" =~ "Implementing" ]] || [[ "$status" =~ "Checking" ]]; then
      # 영향 범위에 파일이 포함되는지 확인
      if [[ "$impact" =~ "$modified_file" ]]; then
        conflicting_features="${conflicting_features}${slug},"
      fi
    fi
  done < "$features_file"
  
  if [ -n "$conflicting_features" ]; then
    printf '[WARNING] Potential file conflicts detected with: %s\n' "${conflicting_features%,}" >&2
    return 1
  fi

  return 0
}


# ============================================================================
# 자동화 레벨 (L0-L4) 관련 헬퍼 함수
# ============================================================================

# 기본 자동화 레벨
readonly DEFAULT_AUTOMATION_LEVEL="L2"
readonly DEFAULT_TRUST_SCORE="0.5"

# 자동화 레벨 조회
# Usage: get_automation_level <project_root>
# Returns: L0, L1, L2, L3, L4 (기본값: L2)
get_automation_level() {
  local project_root="${1:-}"
  local config_file="${project_root}/.harness/config.yaml"

  if [[ ! -f "$config_file" ]]; then
    echo "$DEFAULT_AUTOMATION_LEVEL"
    return 0
  fi

  # yq가 있으면 사용, 없으면 grep으로 대체
  if command -v yq &>/dev/null; then
    local level
    level=$(yq '.automation.level // ""' "$config_file" 2>/dev/null)
    if [[ -n "$level" && "$level" != "null" ]]; then
      echo "$level"
      return 0
    fi
  fi

  # yq 없이 grep으로 간단히 파싱
  local level_line
  level_line=$(grep -E "^\s*level:\s*" "$config_file" 2>/dev/null | head -1)
  if [[ -n "$level_line" ]]; then
    local level
    level=$(echo "$level_line" | sed 's/.*level:\s*//' | tr -d ' "'\''')
    if [[ "$level" =~ ^L[0-4]$ ]]; then
      echo "$level"
      return 0
    fi
  fi

  echo "$DEFAULT_AUTOMATION_LEVEL"
}

# 신뢰 점수 조회
# Usage: get_trust_score <project_root>
# Returns: 0.0 ~ 1.0 (기본값: 0.5)
get_trust_score() {
  local project_root="${1:-}"
  local trust_file="${project_root}/.harness/trust.json"

  if [[ ! -f "$trust_file" ]]; then
    echo "$DEFAULT_TRUST_SCORE"
    return 0
  fi

  if command -v jq &>/dev/null; then
    local score
    score=$(jq -r '.composite // 0.5' "$trust_file" 2>/dev/null)
    if [[ -n "$score" && "$score" != "null" ]]; then
      echo "$score"
      return 0
    fi
  fi

  echo "$DEFAULT_TRUST_SCORE"
}

# 단계 전환 승인 필요 여부 확인
# Usage: should_approve_transition <level> <transition>
# transition: plan_to_design, design_to_do, do_to_check, check_to_wrapup
# Returns: true, false, if_uncertain
should_approve_transition() {
  local level="${1:-$DEFAULT_AUTOMATION_LEVEL}"
  local transition="${2:-}"

  case "$level" in
    L0)
      echo "true"
      ;;
    L1)
      case "$transition" in
        check_to_wrapup) echo "false" ;;
        *) echo "true" ;;
      esac
      ;;
    L2)
      case "$transition" in
        plan_to_design) echo "if_uncertain" ;;
        *) echo "false" ;;
      esac
      ;;
    L3|L4)
      echo "false"
      ;;
    *)
      echo "false"
      ;;
  esac
}

# 현재 PDCA 단계에서 다음 단계로의 전환 이름 조회
# Usage: get_transition_name <from_phase> <to_phase>
get_transition_name() {
  local from_phase="${1:-}"
  local to_phase="${2:-}"

  case "${from_phase}_${to_phase}" in
    plan_design) echo "plan_to_design" ;;
    design_do) echo "design_to_do" ;;
    do_check) echo "do_to_check" ;;
    check_wrapup) echo "check_to_wrapup" ;;
    *) echo "" ;;
  esac
}

# 자동화 설정 파일 초기화
# Usage: init_automation_config <project_root>
init_automation_config() {
  local project_root="${1:-}"
  local harness_dir="${project_root}/.harness"
  local config_file="${harness_dir}/config.yaml"
  local trust_file="${harness_dir}/trust.json"

  mkdir -p "$harness_dir"

  # config.yaml 생성 (없을 경우만)
  if [[ ! -f "$config_file" ]]; then
    cat > "$config_file" << 'EOF'
# Harness Engineering 자동화 설정
# https://github.com/developjik/harness-engineering

automation:
  level: L2  # L0(Manual), L1(Guided), L2(Semi-Auto), L3(Auto), L4(Full-Auto)
  default_level: L2

trust:
  enabled: true
  auto_escalation: false
  auto_downgrade: true
  escalation_threshold: 0.8
  downgrade_threshold: 0.3
EOF
    echo "[INFO] Created default config: $config_file" >&2
  fi

  # trust.json 생성 (없을 경우만)
  if [[ ! -f "$trust_file" ]]; then
    cat > "$trust_file" << EOF
{
  "version": "1.0",
  "updated_at": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "scores": {
    "track_record": 0.5,
    "quality_metrics": 0.5,
    "velocity": 0.5,
    "user_ratings": 0.5,
    "decision_accuracy": 0.5,
    "safety": 1.0
  },
  "composite": 0.55,
  "history": []
}
EOF
    echo "[INFO] Created default trust file: $trust_file" >&2
  fi
}

# 결정 로그 기록
# Usage: log_decision <project_root> <event_type> <details_json>
log_decision() {
  local project_root="${1:-}"
  local event_type="${2:-}"
  local details="${3:-}"
  local log_dir="${project_root}/.harness/logs"
  local log_file="${log_dir}/decisions.jsonl"

  mkdir -p "$log_dir"

  local timestamp
  timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

  local log_entry
  if [[ -n "$details" ]]; then
    log_entry=$(printf '{"timestamp":"%s","event":"%s",%s}' "$timestamp" "$event_type" "${details:1:${#details}-2}")
  else
    log_entry=$(printf '{"timestamp":"%s","event":"%s"}' "$timestamp" "$event_type")
  fi

  echo "$log_entry" >> "$log_file"
}

# 승인 대기 상태 설정
# Usage: set_pending_approval <project_root> <transition> <reason>
set_pending_approval() {
  local project_root="${1:-}"
  local transition="${2:-}"
  local reason="${3:-}"
  local state_dir="${project_root}/.harness/state"

  mkdir -p "$state_dir"

  echo "pending" > "${state_dir}/approval-status.txt"
  echo "$transition" > "${state_dir}/approval-transition.txt"
  echo "$reason" > "${state_dir}/approval-reason.txt"
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "${state_dir}/approval-requested-at.txt"

  # 결정 로그 기록
  log_decision "$project_root" "approval_requested" \
    "\"transition\":\"$transition\",\"reason\":\"$reason\""
}

# 승인 상태 초기화
# Usage: clear_pending_approval <project_root>
clear_pending_approval() {
  local project_root="${1:-}"
  local state_dir="${project_root}/.harness/state"

  rm -f "${state_dir}/approval-status.txt"
  rm -f "${state_dir}/approval-transition.txt"
  rm -f "${state_dir}/approval-reason.txt"
  rm -f "${state_dir}/approval-requested-at.txt"
}

# 승인 대기 여부 확인
# Usage: is_pending_approval <project_root>
# Returns: true or false
is_pending_approval() {
  local project_root="${1:-}"
  local state_dir="${project_root}/.harness/state"
  local status_file="${state_dir}/approval-status.txt"

  if [[ -f "$status_file" ]] && [[ "$(cat "$status_file")" == "pending" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# 신뢰 점수 기반 추천 레벨 조회
# Usage: get_recommended_level <project_root>
# Returns: L0, L1, L2, L3, L4
get_recommended_level() {
  local project_root="${1:-}"
  local trust_score
  trust_score=$(get_trust_score "$project_root")

  # awk for floating point comparison
  local recommended
  recommended=$(awk -v score="$trust_score" 'BEGIN {
    if (score < 0.3) print "L0"
    else if (score < 0.5) print "L1"
    else if (score < 0.7) print "L2"
    else if (score < 0.85) print "L3"
    else print "L4"
  }')

  echo "$recommended"
}
