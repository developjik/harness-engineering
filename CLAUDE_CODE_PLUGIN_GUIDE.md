# Harness Engineering Plugin Guide

Harness Engineering는 Claude Code 안에서 PDCA 기반 개발 흐름을 운영하기 위한 플러그인 리소스 모음입니다. 현재 저장소는 에이전트, 스킬, 훅을 제공하며, 별도의 앱 서버나 npm 실행 명령은 포함하지 않습니다.

## 설치

```bash
/plugin install https://github.com/developjik/harness-engineering
/plugin enable harness-engineering
```

플러그인 설치 후 Claude Code를 다시 열거나 플러그인을 다시 로드하면 에이전트와 훅이 반영됩니다.

## 시작 방법

가장 단순한 시작 방법은 `architect`부터 수동으로 진행하는 것입니다.

```text
/architect
요구사항 설명
/engineer
설계 문서 기준 구현
/guardian
리뷰 요청
/librarian
문서 정리 요청
```

현재 구현은 단계 자동 전환을 하지 않으므로, 다음 단계로 넘어갈 때는 사용자가 직접 적절한 에이전트를 선택해야 합니다.

## 에이전트

| Agent | 역할 | 파일 |
| :--- | :--- | :--- |
| `architect` | 요구사항 분석, 옵션 비교, 설계 문서 작성 | `agents/architect.md` |
| `engineer` | TDD 기반 구현, 리팩터링, 진행 보고 | `agents/engineer.md` |
| `guardian` | 기능/품질/보안/성능 리뷰 | `agents/guardian.md` |
| `librarian` | 사용자/개발자 문서 정리 | `agents/librarian.md` |

## 스킬

| Skill | 목적 | 파일 |
| :--- | :--- | :--- |
| `brainstorm` | 요구사항 정제와 설계 초안 도출 | `skills/brainstorm/SKILL.md` |
| `implement` | RED-GREEN-REFACTOR 기반 구현 | `skills/implement/SKILL.md` |
| `review` | 코드 품질과 보안 검토 | `skills/review/SKILL.md` |
| `document` | README, 가이드, 운영 문서 작성 | `skills/document/SKILL.md` |

스킬은 매니페스트에도 등록되어 있으며, Claude Code가 컨텍스트에 맞게 활용할 수 있습니다.

## 훅 동작

### 세션 및 에이전트 추적

- `hooks/setup.sh`: 세션 시작 시 `logs/session.log`를 만들고 Git 브랜치를 기록합니다.
- `hooks/on-*-start.sh`: 활성 에이전트를 `state/current-agent.txt`에 기록하고 PDCA 단계 로그를 남깁니다.
- `hooks/on-*-stop.sh`: 에이전트 종료 로그를 남깁니다.
- `hooks/cleanup.sh`: 세션 종료 로그를 남깁니다.

### 안전 장치와 편집 보조

- `hooks/pre-bash.sh`: 위험한 명령과 `sudo` 사용을 차단합니다.
- `hooks/pre-edit.sh`: 편집 전 백업을 `~/.harness-engineering/backups/`에 생성합니다.
- `hooks/post-edit.sh`: 변경 파일 해시를 기록하고 가능하면 `eslint`, `pylint`, `markdownlint`를 실행합니다.
- `hooks/post-bash.sh`: Bash 훅 페이로드를 `~/.harness-engineering/logs/`에 저장합니다.

## 필요 도구

- `jq`: 입력 JSON 파싱
- `bash`: 모든 훅 스크립트 실행
- `md5sum` 또는 `md5`: 편집 후 파일 해시 계산
- `git`: 세션 시작 시 브랜치 로그 기록
- 선택 사항: `eslint`, `pylint`, `markdownlint`

## 로그와 상태 파일

| 위치 | 용도 |
| :--- | :--- |
| `logs/session.log` | 세션 시작/종료, 프롬프트 제출, 에이전트 전환 로그 |
| `state/current-agent.txt` | 마지막으로 시작한 에이전트 |
| `~/.harness-engineering/backups/` | 편집 전 파일 백업 |
| `~/.harness-engineering/logs/` | `pre-bash`, `post-bash`, `post-edit` 로그 |
| `~/.harness-engineering/state/changes.txt` | 편집 후 변경 파일 해시 기록 |

## 문제 해결

### 에이전트가 보이지 않는 경우

- 플러그인이 활성화되어 있는지 확인합니다.
- Claude Code를 재시작하거나 플러그인을 다시 로드합니다.

### 훅이 조용히 실패하는 경우

- `jq` 설치 여부를 먼저 확인합니다.
- Bash 관련 로그는 `~/.harness-engineering/logs/`에서 확인합니다.
- 세션/에이전트 로그는 워크스페이스의 `logs/session.log`에서 확인합니다.

### 편집 후 해시 추적이 되지 않는 경우

- `md5sum` 또는 `md5`가 사용 가능한지 확인합니다.
- `~/.harness-engineering/state/changes.txt` 생성 여부를 확인합니다.

## 관련 문서

- [README.md](./README.md)
- [docs/IMPLEMENTATION_GUIDE.md](./docs/IMPLEMENTATION_GUIDE.md)
- [docs/PROJECT_ANALYSIS.md](./docs/PROJECT_ANALYSIS.md)
