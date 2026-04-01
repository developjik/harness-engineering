# Architecture

`colo-fe-flow`는 Jira-first frontend workflow orchestrator입니다.

이 문서는 현재 저장소에 실제로 들어 있는 구성요소를 기준으로 아키텍처를 요약합니다.

## 구조 레이어

### 1. Plugin Metadata

- `.claude-plugin/plugin.json`
  플러그인 이름, 버전, skill 디렉토리, hook 등록 파일을 선언합니다.
- `.mcp.json`
  현재 플러그인이 기대하는 MCP 서버 선언을 담습니다.

### 2. Public Skill Layer

- `skills/route-workflow/`
  public entry controller contract
- `skills/start-jira-ticket/` 부터 `skills/complete-ticket/`
  ticket workflow 단계별 skill contract
- `skills/show-ticket-status/`, `skills/list-tickets/`, `skills/switch-ticket/`
  utility skill
- `skills/reviewing-skill-md/`
  workflow 자체가 아니라 플러그인 maintenance용 보조 skill

skill 본문은 주로 계약과 사용 조건을 담고, 실제 상태 변경 로직은 runtime helper 쪽에 있습니다.

## 3. Hook Wiring Layer

- `hooks/hooks.json`
  Claude hook 이벤트와 shell entrypoint를 연결합니다.
- `hooks/session-start.sh`
  runtime layout 초기화와 session log 기록
- `hooks/pre-tool.sh`
  stale approval reset, missing active ticket state guard
- `hooks/post-tool.sh`
  artifact 존재 상태 반영, tool lifecycle log
- `hooks/on-agent-start.sh`
- `hooks/on-agent-stop.sh`
  agent lifecycle log

## 4. Runtime Helper Layer

`hooks/lib/` 아래 shell helper가 현재 구현의 핵심입니다.

- `state.sh`
  `.colo-fe-flow/.state/` 읽기/쓰기
- `bootstrap.sh`
  ticket bootstrap과 `intake.md` 생성
- `planning.sh`
  `clarify.md`, `plan.md`, `design.md`, `tasks.json` 생성 및 approval 갱신 helper
- `execution.sh`
  implement/check/iterate/sync-docs/complete 단계 state mutation helper
- `routing.sh`
  자연어 요청 정규화와 `route result JSON` 계산
- `hook-runtime.sh`
  hook payload 파싱, 절대 경로 보정, artifact 추론
- `dependency-check.sh`
  `.mcp.json` 해석과 필수 MCP 선언 검증
- `approval.sh`, `verification.sh`, `cache.sh`, `worktree.sh`, `log.sh`, `common.sh`, `utility.sh`
  횡단 관심사 helper

## 5. Agent Layer

`agents/` 아래에는 현재 5개 workflow agent contract가 있습니다.

- `intake-agent`
- `context-agent`
- `planning-agent`
- `implementation-agent`
- `check-agent`

이 레이어는 역할과 입출력 계약을 정의하지만, 현재 스캐폴드에서는 상위 runner가 agent를 자동으로 orchestration하는 단계까지는 연결되지 않았습니다.

## 6. Artifact And Template Layer

- `templates/`
  `intake.md`, `clarify.md`, `plan.md`, `design.md`, `tasks.json`, `check.md`, `wrapup.md` 기본 템플릿
- `docs/specs/<JIRA-KEY>/`
  실제 runtime이 생성하고 추적하는 공식 artifact 위치

## 7. Validation Layer

- `scripts/lint-shell.sh`
  shell syntax 점검
- `scripts/validate.sh`
  JSON 형식, hook command quoting, 필수 MCP 선언, `hooks/__tests__/*.test.sh` 실행

## Current Scaffold Status

현재 구현과 목표 계약을 구분해서 읽어야 합니다.

- 현재 `route-workflow` 구현은 다음 skill을 계산해서 `route result JSON`으로 반환합니다.
- 현재는 `route-workflow`가 실제로 다음 skill을 invoke하지 않습니다.
- 현재 MCP 선언 검증은 `.mcp.json`과 `hooks/lib/dependency-check.sh`, `scripts/validate.sh`에서 수행됩니다.
- bootstrap, planning chain, execution loop는 shell helper 중심으로 먼저 구현되어 있습니다.
- hook은 lifecycle logging과 stale reset까지 구현되어 있지만, richer policy는 여전히 확장 대상입니다.

## Required MCP Servers

- `atlassian`
- `figma`

## 함께 봐야 할 문서

- `workflow.md`
- `route-workflow-contract.md`
- `local-runtime-schema.md`
- `artifact-lifecycle.md`
- `skill-responsibility.md`
- `agent-responsibility.md`
- `runtime-components.md`
