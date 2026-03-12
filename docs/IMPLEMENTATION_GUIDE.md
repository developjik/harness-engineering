# Harness Engineering 구현 가이드

이 문서는 현재 저장소를 "실행형 앱"이 아니라 "Claude Code 플러그인 리소스 번들"로 보고, 구조를 이해하고 직접 수정하거나 확장하는 방법을 설명합니다.

## 1. 구현 범위

현재 저장소에 실제로 구현된 것은 다음과 같습니다.

- `.claude-plugin/plugin.json`: 플러그인 메타데이터와 에이전트/스킬/훅 등록
- `agents/*.md`: 역할별 에이전트 프롬프트
- `skills/*/SKILL.md`: 재사용 가능한 작업 지침
- `hooks.json`: Claude Code 훅 이벤트와 스크립트 연결
- `hooks/*.sh`: 세션 로깅, 상태 추적, 백업, 변경 추적, 명령 차단

현재 저장소에 없는 것은 다음과 같습니다.

- `package.json` 기반 실행기
- `npm run ...` 형태의 워크플로우 명령
- 별도 세션 관리자나 데이터베이스
- 자동 PDCA 단계 전환 엔진
- `ultrawork` 같은 통합 실행 명령

## 2. 핵심 파일

### 플러그인 매니페스트

`.claude-plugin/plugin.json`은 플러그인의 진입점입니다.

- 플러그인 이름, 버전, 설명, 키워드 정의
- `skills` 배열에 스킬 경로 등록
- `agents` 배열에 에이전트 경로 등록
- `hooks.path`로 `hooks.json` 연결

새 에이전트나 스킬을 추가했다면 이 파일도 함께 업데이트해야 합니다.

### 에이전트

`agents/` 디렉터리의 각 Markdown 파일은 YAML 프런트매터와 본문 지침으로 구성됩니다.

- 프런트매터: `name`, `description`, `tools`, `model`, `color`
- 본문: 역할, 체크리스트, 출력 형식, 작업 원칙

현재 정의된 에이전트는 모두 "프롬프트 지침"이며, 별도 실행기 없이 Claude Code가 직접 읽어 사용합니다.

### 스킬

`skills/*/SKILL.md`는 특정 작업 유형을 위한 세부 절차를 담습니다.

- `brainstorm`: 요구사항 정제와 설계 옵션 도출
- `implement`: TDD 기반 구현
- `review`: 리뷰 기준과 피드백 형식
- `document`: README 및 개발자 문서 작성 기준

### 훅

`hooks.json`은 Claude Code 이벤트를 Bash 스크립트와 연결합니다.

| 이벤트 | 구현 목적 |
| :--- | :--- |
| `SessionStart` | 세션 시작 로그 기록 |
| `UserPromptSubmit` | 입력 길이 기록 |
| `PreToolUse` | 위험한 Bash 차단, 편집 전 백업 |
| `PostToolUse` | Bash/편집 후 로깅 및 변경 추적 |
| `SubagentStart` | 현재 에이전트와 PDCA 단계 기록 |
| `SubagentStop` | 에이전트 종료 기록 |
| `SessionEnd` | 세션 종료 기록 |

## 3. 훅 스크립트 상세

### 워크스페이스에 기록하는 훅

- `setup.sh`
- `validate-input.sh`
- `on-architect-start.sh`
- `on-engineer-start.sh`
- `on-guardian-start.sh`
- `on-librarian-start.sh`
- 각 `on-*-stop.sh`
- `cleanup.sh`

이 스크립트들은 저장소 루트 기준 `logs/`와 `state/`를 사용합니다.

### 홈 디렉터리에 기록하는 훅

- `pre-bash.sh`
- `pre-edit.sh`
- `post-bash.sh`
- `post-edit.sh`

이 스크립트들은 `~/.harness-engineering/` 아래에 로그, 백업, 변경 추적 파일을 저장합니다.

## 4. 의존성

저장소 자체에는 패키지 매니저 의존성이 없지만, 훅은 몇 가지 CLI 도구를 기대합니다.

| 도구 | 용도 | 필수성 |
| :--- | :--- | :--- |
| `bash` | 모든 훅 실행 | 높음 |
| `jq` | 훅 입력 JSON 파싱 | 높음 |
| `git` | 현재 브랜치 로깅 | 선택 |
| `md5sum` 또는 `md5` | 파일 해시 계산 | 중간 |
| `eslint` | JS/TS 린트 | 선택 |
| `pylint` | Python 린트 | 선택 |
| `markdownlint` | Markdown 검사 | 선택 |

## 5. 확장 방법

### 에이전트 추가

1. `agents/new-agent.md` 생성
2. YAML 프런트매터와 역할 지침 작성
3. `.claude-plugin/plugin.json`의 `agents` 배열에 등록
4. 필요하면 `hooks.json`에 `SubagentStart`, `SubagentStop` 연결 추가

### 스킬 추가

1. `skills/new-skill/SKILL.md` 생성
2. 사용 가능한 도구와 체크리스트 작성
3. `.claude-plugin/plugin.json`의 `skills` 배열에 등록

### 훅 추가

1. `hooks/your-hook.sh` 생성
2. 실행 권한을 부여합니다.
3. `hooks.json`에 이벤트와 matcher를 연결합니다.
4. 로그 위치와 필요한 환경 변수를 문서에 반영합니다.

## 6. 현재 제약 사항

- 훅은 자동 오케스트레이션이 아니라 보조 자동화에 가깝습니다.
- 세션 상태가 워크스페이스와 홈 디렉터리로 나뉘어 저장됩니다.
- 린트 도구가 없으면 `post-edit.sh`는 검사를 건너뜁니다.
- 에이전트와 스킬은 풍부한 지침을 제공하지만, 실제 코드 생성 품질은 Claude Code 환경과 사용자 입력 품질의 영향을 받습니다.

## 7. 추천 개선 순서

1. 로그/상태 저장 위치를 한 곳으로 통일합니다.
2. 훅 입력 포맷을 문서화한 샘플 페이로드를 추가합니다.
3. 자동 단계 전환이 필요하다면 별도 오케스트레이터 스크립트를 설계합니다.
4. 에이전트와 스킬 간 연결 규칙을 더 명확히 정의합니다.

## 8. 함께 보면 좋은 문서

- [README.md](../README.md)
- [../CLAUDE_CODE_PLUGIN_GUIDE.md](../CLAUDE_CODE_PLUGIN_GUIDE.md)
- [PROJECT_ANALYSIS.md](./PROJECT_ANALYSIS.md)
- [../DESIGN.md](../DESIGN.md)
