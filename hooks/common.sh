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
