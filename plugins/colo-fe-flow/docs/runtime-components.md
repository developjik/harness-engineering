# Runtime Components

`colo-fe-flow`의 실제 runtime 배선과 helper 파일을 현재 구현 기준으로 정리한 문서입니다.

이 문서는 `docs/`만 읽는 사람도 `hooks/`, `hooks/lib/`, `scripts/`의 역할을 빠르게 파악할 수 있도록 작성합니다.

## 목적

- 어떤 파일이 runtime wiring을 담당하는지 정리
- hook event와 shell entrypoint의 연결 방식 설명
- state mutation이 어디에서 일어나는지 설명
- 현재 스캐폴드의 한계와 목표 계약을 구분

## Hook Wiring

실제 이벤트 연결은 `hooks/hooks.json`이 진실원본입니다.

현재 등록된 이벤트:

| Event | Matcher | Entry Script | 역할 |
|---|---|---|---|
| `SessionStart` | 없음 | `hooks/session-start.sh` | runtime layout 초기화와 session log 기록 |
| `PreToolUse` | `Bash|Write|Edit` | `hooks/pre-tool.sh` | stale approval reset, active ticket state guard |
| `PostToolUse` | `Bash|Write|Edit` | `hooks/post-tool.sh` | artifact exists 반영, tool lifecycle log |
| `SubagentStart` | 5개 workflow agent 이름 | `hooks/on-agent-start.sh` | agent 시작 log |
| `SubagentStop` | 5개 workflow agent 이름 | `hooks/on-agent-stop.sh` | agent 종료 log |

## Hook Entry Script 역할

### `session-start.sh`

- `.colo-fe-flow/.state/index.json`이 없으면 생성
- `.colo-fe-flow/.log/session.log`에 `SESSION_START` 기록
- active ticket이 있으면 ticket별 orchestration log에도 기록

### `pre-tool.sh`

- 현재 active ticket이 있는데 해당 state 파일이 없으면 `block` JSON 출력
- `docs/specs/<JIRA-KEY>/clarify.md`, `plan.md`, `design.md` 편집 전 stale reset 수행
- 편집된 artifact부터 downstream approval을 false로 되돌림
- 해당 ticket phase를 다시 `*-draft`로 되돌림

### `post-tool.sh`

- 편집 또는 작성된 artifact 경로를 보고 `artifacts.<name>.exists=true` 갱신
- ticket 또는 runtime tooling log에 `POST_TOOL` 기록

### `on-agent-start.sh` / `on-agent-stop.sh`

- agent lifecycle을 `.colo-fe-flow/.log/agents.log`와 ticket orchestration log에 남김
- 현재는 lifecycle log만 담당하고 orchestration policy는 담지 않음

## Runtime Helper Inventory

### Core state and routing

- `hooks/lib/state.sh`
  runtime layout 생성, active ticket 관리, ticket state schema 읽기/쓰기
- `hooks/lib/routing.sh`
  자연어 요청을 `resolved_action`으로 정규화하고 `route result JSON` 계산
- `hooks/lib/approval.sh`
  `clarify`, `plan`, `design` approval 관리
- `hooks/lib/verification.sh`
  verification state 기록과 pass helper

### Workflow mutation helpers

- `hooks/lib/bootstrap.sh`
  ticket state seed, worktree 경로 준비, `intake.md` 생성
- `hooks/lib/planning.sh`
  `clarify.md`, `plan.md`, `design.md`, `tasks.json` 생성
- `hooks/lib/execution.sh`
  implement/check/iterate/sync-docs/complete 단계 mutation
- `hooks/lib/utility.sh`
  status/list/switch utility helper

### Cross-cutting helpers

- `hooks/lib/hook-runtime.sh`
  hook payload JSON query, tool name/file path/command 추출, artifact path 추론
- `hooks/lib/dependency-check.sh`
  project root 또는 plugin root의 `.mcp.json`을 읽어 필수 MCP 선언 검증
- `hooks/lib/worktree.sh`
  worktree root/path, branch name helper
- `hooks/lib/cache.sh`
  외부 시스템 캐시 파일 helper
- `hooks/lib/log.sh`
  runtime log와 ticket log append helper
- `hooks/lib/common.sh`
  JSON read/write, timestamp, assertion 같은 공용 유틸

## Scripts And Tests

### Scripts

- `scripts/lint-shell.sh`
  `hooks/*.sh`, `hooks/lib/*.sh`, `scripts/*.sh`에 대해 `bash -n` 수행
- `scripts/validate.sh`
  JSON 형식 확인, hook command quoting 확인, 필수 MCP 선언 확인, `hooks/__tests__/*.test.sh` 실행

### Tests

현재 `hooks/__tests__/`에는 아래 범주의 shell test가 있습니다.

- state
- routing
- route-workflow
- bootstrap
- planning-chain
- execution-loop
- utility
- hook-flow
- dependency-check
- agent-hardening

## Current Behavior Versus Target Contract

혼동하기 쉬운 부분을 현재 구현 기준으로 고정합니다.

### `route-workflow`

목표 계약:

- 다음 skill 선택
- 필요하면 상위 runner가 이어서 자동 실행

현재 스캐폴드:

- `hooks/lib/routing.sh`가 `route result JSON`만 계산해서 반환
- `next_skill`은 "지금 선택된 다음 skill"이지, 이미 실행됐다는 뜻은 아님

### MCP dependency enforcement

목표 계약:

- runtime 진입 시 필수 MCP 누락을 더 이른 레이어에서 막을 수 있음

현재 스캐폴드:

- 필수 MCP 선언은 `.mcp.json`에 존재
- 선언 검증은 `hooks/lib/dependency-check.sh`와 `scripts/validate.sh`에서 수행
- 라우팅 함수 자체는 아직 dependency-check를 직접 호출하지 않음

### Agent orchestration

목표 계약:

- skill이 agent를 자동으로 호출하고 결과를 state mutation에 반영

현재 스캐폴드:

- `agents/*.md` 계약은 존재
- `SubagentStart`, `SubagentStop` hook matcher도 존재
- 하지만 실제 자동 spawn과 상위 orchestration runner 연결은 아직 남아 있음

## 권장 읽기 순서

1. `architecture.md`
2. `workflow.md`
3. `route-workflow-contract.md`
4. `local-runtime-schema.md`
5. 이 문서

그 다음 필요에 따라 `skill-responsibility.md`, `agent-responsibility.md`, `manual-test-checklist.md`를 봅니다.
