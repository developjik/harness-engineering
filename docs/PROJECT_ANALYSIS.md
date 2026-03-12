# Harness Engineering 프로젝트 분석

기준일: 2026-03-12

## 요약

`harness-engineering`는 실행형 앱이 아니라 Claude Code 플러그인용 리소스 저장소입니다. 핵심 구현물은 플러그인 매니페스트, 4개 에이전트, 4개 스킬, Bash 기반 훅 자동화이며, 실제 역할은 "PDCA 흐름을 안내하고 작업 흔적을 남기는 플러그인 번들"에 가깝습니다.

## 현재 구성

| 항목 | 내용 |
| :--- | :--- |
| 플러그인 매니페스트 | `.claude-plugin/plugin.json` |
| 에이전트 | `architect`, `engineer`, `guardian`, `librarian` |
| 스킬 | `brainstorm`, `implement`, `review`, `document` |
| 훅 정의 | `hooks.json` |
| 훅 스크립트 | 세션/에이전트 로그, Bash 가드, 편집 전 백업, 편집 후 추적 |
| 보조 문서 | README, 플러그인 가이드, 구현 가이드, 설계 문서, 다이어그램 |

## 실제 동작 분석

### 1. 플러그인 계층

`.claude-plugin/plugin.json`은 플러그인 메타데이터와 에이전트/스킬/훅 연결을 담당합니다. 버전은 `1.1.0`이며, 에이전트와 스킬은 모두 Markdown 기반 정의 파일을 직접 가리킵니다.

### 2. 에이전트 계층

`agents/*.md`는 모두 프롬프트 중심 정의입니다.

- `architect`: 요구사항 정제, 옵션 비교, 설계 문서 작성
- `engineer`: TDD 기반 구현
- `guardian`: 품질/보안/성능 리뷰
- `librarian`: README와 운영 문서 작성

즉, 에이전트는 독립 실행 프로그램이 아니라 Claude Code가 읽는 역할 지침입니다.

### 3. 스킬 계층

`skills/*/SKILL.md`는 에이전트가 활용할 수 있는 재사용 지침입니다. 구현 강도가 가장 높은 것은 `implement`와 `review`이며, 각각 TDD 사이클과 리뷰 체크리스트를 상세하게 제공합니다.

### 4. 훅 계층

훅은 두 부류로 나뉩니다.

- 워크스페이스 로그형: `setup.sh`, `validate-input.sh`, `on-*-start.sh`, `on-*-stop.sh`, `cleanup.sh`
- 홈 디렉터리 보조형: `pre-bash.sh`, `pre-edit.sh`, `post-bash.sh`, `post-edit.sh`

현재 훅의 역할은 자동 오케스트레이션보다는 다음에 가깝습니다.

- 세션 시작/종료 로깅
- 현재 에이전트 기록
- 위험 명령 차단
- 파일 백업
- 편집 후 변경 추적과 선택적 린트

## 분석 중 확인한 핵심 차이

이번 점검에서 다음과 같은 차이를 확인했고, 문서를 현재 구현 기준으로 정리했습니다.

1. 저장소는 앱이 아닌데 일부 문서가 `npm install`, `npm run pdca:start`, `ultrawork` 같은 실행형 앱 흐름을 설명하고 있었습니다.
2. 훅은 단계 자동 전환을 하지 않는데 일부 문서가 자동 PDCA 오케스트레이션이 이미 구현된 것처럼 설명하고 있었습니다.
3. `CLAUDE_CODE_PLUGIN_GUIDE.md`와 `docs/IMPLEMENTATION_GUIDE.md`는 내용뿐 아니라 파일 포맷도 깨져 있어, 실제 Markdown 대신 이스케이프된 `\n`이 포함된 한 줄 문서 상태였습니다.
4. `hooks.json`에는 `hooks/post-bash.sh`가 연결되어 있었지만 스크립트 파일이 존재하지 않았습니다.
5. 런타임 산출물 위치가 문서보다 더 복합적이었습니다. 일부는 저장소 루트(`logs/`, `state/`)에, 일부는 사용자 홈(`~/.harness-engineering/`)에 기록됩니다.

## 이번 최신화에서 반영한 사항

- `README.md`를 현재 저장소 성격과 실제 사용 흐름에 맞게 재작성
- `CLAUDE_CODE_PLUGIN_GUIDE.md`를 정상적인 Markdown으로 복구하고 실제 사용법 기준으로 정리
- `docs/IMPLEMENTATION_GUIDE.md`를 실행형 앱 가이드에서 구조/확장 가이드로 전환
- `DESIGN.md`를 "현재 구현"과 "향후 로드맵"이 구분되도록 정리
- `docs/PDCA_WORKFLOW_DIAGRAM.md`에 개념도 성격을 명시
- 누락된 `hooks/post-bash.sh` 추가
- `hooks.json` 설명을 실제 스크립트 동작에 맞게 조정

## 추천 다음 작업

1. 로그와 상태 저장 위치를 워크스페이스 또는 홈 디렉터리 한쪽으로 통일합니다.
2. 훅별 입력 페이로드 예시를 문서화해 유지보수 난이도를 낮춥니다.
3. 자동 단계 전환이 목표라면 오케스트레이터 스크립트나 상태 머신을 별도 구현합니다.
4. `librarian` 에이전트 문서도 현재 저장소 구조에 맞춰 한 번 더 다듬으면 일관성이 좋아집니다.
