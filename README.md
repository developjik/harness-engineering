# Harness Engineering

**PDCA 기반 AI 소프트웨어 개발 워크플로우를 위한 Claude Code 플러그인**

`bkit-claude-code`, `oh-my-openagent`, `superpowers`의 아이디어를 참고해 만든 개인용 하네스 엔지니어링 저장소입니다. 이 저장소는 실행 애플리케이션보다는 Claude Code에서 바로 사용할 수 있는 플러그인 리소스 모음에 가깝습니다.

## 핵심 개념

- **PDCA 워크플로우**: Plan → Do → Check → Act 흐름으로 설계, 구현, 검증, 문서화를 나눕니다.
- **에이전트 분업**: Architect, Engineer, Guardian, Librarian이 각각 역할을 맡습니다.
- **스킬 재사용**: 요구사항 정리, 구현, 리뷰, 문서화를 스킬 단위로 분리합니다.
- **훅 자동화**: 세션 시작, 입력 제출, 서브에이전트 시작/종료, 편집 후속 처리 등을 자동화합니다.

## 현재 구조

```text
harness-engineering/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── architect.md
│   ├── engineer.md
│   ├── guardian.md
│   └── librarian.md
├── skills/
│   ├── brainstorm/SKILL.md
│   ├── implement/SKILL.md
│   ├── review/SKILL.md
│   └── document/SKILL.md
├── hooks/
│   ├── setup.sh
│   ├── validate-input.sh
│   ├── post-edit.sh
│   └── on-*.sh
├── hooks.json
├── docs/
├── DESIGN.md
└── README.md
```

런타임 중에는 아래 디렉터리가 필요 시 자동 생성됩니다.

- `logs/`: 세션 로그 저장
- `state/`: 현재 활성 에이전트 상태 저장

## 빠른 시작

### 1. 플러그인 설치

```bash
/plugin install https://github.com/developjik/harness-engineering
```

### 2. 플러그인 활성화

```bash
/plugin enable harness-engineering
```

### 3. 에이전트 사용

```bash
/architect
/engineer
/guardian
/librarian
```

일반적인 흐름은 다음과 같습니다.

1. `Architect`: 요구사항 분석과 설계 문서 작성
2. `Engineer`: 설계 기반 구현과 TDD 진행
3. `Guardian`: 코드 리뷰와 품질 검증
4. `Librarian`: 문서 정리와 결과물 문서화

## 주요 구성 요소

### Agents

| Agent | 역할 | 파일 |
| :--- | :--- | :--- |
| `architect` | 요구사항 분석, 설계 옵션 제안, 설계 문서 작성 | `agents/architect.md` |
| `engineer` | TDD 기반 구현, 리팩터링, 진행 보고 | `agents/engineer.md` |
| `guardian` | 기능/품질/보안/성능 리뷰 | `agents/guardian.md` |
| `librarian` | README, 가이드, API 문서 등 문서화 | `agents/librarian.md` |

### Skills

| Skill | 목적 | 경로 |
| :--- | :--- | :--- |
| `brainstorm` | 요구사항 정리와 설계 초안 도출 | `skills/brainstorm/SKILL.md` |
| `implement` | RED-GREEN-REFACTOR 기반 구현 | `skills/implement/SKILL.md` |
| `review` | 코드 품질과 보안 검토 | `skills/review/SKILL.md` |
| `document` | 사용자/개발자 문서 작성 | `skills/document/SKILL.md` |

### Hooks

현재 플러그인은 [hooks.json](./hooks.json)에 정의된 다음 이벤트를 사용합니다.

| Hook | 목적 |
| :--- | :--- |
| `SessionStart` | 세션 시작 로그 기록 및 기본 상태 준비 |
| `UserPromptSubmit` | 사용자 입력 길이 검사 및 로그 기록 |
| `PostToolUse` | 파일 편집 후 변경 파일 로그 기록 |
| `SubagentStart` | 현재 활성 에이전트 상태 저장 |
| `SubagentStop` | 에이전트 종료 로그 기록 |
| `SessionEnd` | 세션 종료 로그 정리 |

## 운영 파일

- `logs/session.log`: 세션 시작, 파일 수정, 에이전트 전환 기록
- `state/current-agent.txt`: 마지막으로 활성화된 에이전트 이름

## 문서

- [DESIGN.md](./DESIGN.md): 설계 배경과 아키텍처 개요
- [CLAUDE_CODE_PLUGIN_GUIDE.md](./CLAUDE_CODE_PLUGIN_GUIDE.md): 플러그인 사용 가이드
- [docs/IMPLEMENTATION_GUIDE.md](./docs/IMPLEMENTATION_GUIDE.md): 구현/적용 가이드
- [docs/PDCA_WORKFLOW_DIAGRAM.md](./docs/PDCA_WORKFLOW_DIAGRAM.md): PDCA 다이어그램

## 참고 프로젝트

- `bkit-claude-code`: PDCA와 컨텍스트 엔지니어링
- `oh-my-openagent`: 에이전트 오케스트레이션 패턴
- `superpowers`: 설계 우선 접근과 TDD 워크플로우

## 라이선스

MIT License
