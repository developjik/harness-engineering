---
name: clarify
description: Use when a started ticket needs requirement clarification from Jira, Confluence, Figma, and codebase context before planning.
user-invocable: true
argument-hint: <JIRA-KEY>
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent, AskUserQuestion
---

# clarify

티켓 요구사항을 구체화하고 `clarify.md`를 작성합니다.

- 입력 기준은 `intake.md` 입니다.
- 결과는 `clarify.md` draft 생성과 `approvals.clarify=false`, `phase=clarify-draft` 입니다.
- 승인 이후에만 `plan` 단계로 넘어갑니다.

## 절차

### 1. 컨텍스트 수집

- `intake.md`와 Jira/Confluence/Figma 소스를 분석하여 요구사항 불명확 사항을 식별합니다.
- 코드베이스 구조를 탐색하여 기존 패턴과 제약사항을 파악합니다.

### 2. Open Questions 도출

- 식별된 불명확 사항을 Open Questions로 정리합니다.
- 중복되거나 자명한 질문은 제외하고, 범위 결정에 영향을 미치는 핵심 질문만 남깁니다.

### 3. 사용자 질문 (AskUserQuestion)

- Open Questions를 `AskUserQuestion`으로 사용자에게 직접 질문합니다.
- 질문이 4개 이하면 한 번에, 5개 이상이면 우선순위 순으로 여러 번 나누어 질문합니다.
- 각 질문은 선택지와 함께 구성합니다.

### 4. 답변 반영 및 문서 작성

- 사용자 답변을 Resolved Questions 테이블로 정리합니다.
- Scope, Out of Scope를 답변 기반으로 명확히 작성합니다.
- `cff_planning_write_clarify`로 clarify.md 초안을 생성한 뒤, Resolved Questions와 Scope를 채웁니다.

### 5. 승인 요청

- `AskUserQuestion`으로 clarify 내용 승인 여부를 확인합니다.
- 승인되면 `cff_planning_approve_stage`로 phase를 `clarify-approved`로 전환합니다.
- 수정이 필요하면 피드백을 반영하여 재작성 후 다시 승인을 요청합니다.

## 구현 기준

- `hooks/lib/planning.sh`
- `planning-agent`

Primary agent: `planning-agent`
Support agent: `context-agent`
