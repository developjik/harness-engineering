# Task Format

`tasks.json`은 `implement` 단계가 읽는 실행 계약입니다.

## 현재 구현 기준 스키마

현재 `hooks/lib/planning.sh`가 생성하는 `tasks.json`은 아래 구조를 따릅니다.

```json
{
  "schema_version": 1,
  "ticket_key": "FE-123",
  "generated_from": {
    "plan": "docs/specs/FE-123/plan.md",
    "design": "docs/specs/FE-123/design.md"
  },
  "tasks": [
    {
      "id": "FE-123-T1",
      "title": "Implement Checkout 페이지 개선",
      "phase": "implement",
      "parallel_safe": false,
      "target_files": [],
      "acceptance": [
        "설계 노트",
        "Implementation should stay aligned with plan.md and design.md."
      ]
    }
  ]
}
```

## 필드 의미

- `schema_version`
  task schema 버전
- `ticket_key`
  이 task set이 속한 Jira key
- `generated_from.plan`
- `generated_from.design`
  upstream artifact 참조
- `tasks[]`
  실제 구현 단위 목록

각 task는 현재 아래 필드를 가집니다.

- `id`
  ticket 기준 유일한 task id
- `title`
  사람이 읽는 구현 단위 이름
- `phase`
  현재는 `implement`를 사용
- `parallel_safe`
  제한된 병렬 실행 가능 여부
- `target_files`
  변경 예상 파일 목록
- `acceptance`
  구현 완료 판단 기준

## 현재 스캐폴드의 제약

- 기본 generator는 현재 최소 1개 task를 생성합니다.
- `parallel_safe`는 있지만 parallel group id까지는 아직 없습니다.
- TDD 세부 step, test command, dependency graph는 아직 schema에 들어 있지 않습니다.
- `target_files`는 현재 placeholder로 빈 배열일 수 있습니다.

## 목표 방향

문서 계약상 `tasks.json`은 더 풍부해질 수 있습니다.

- TDD step 명시
- test command 명시
- 파일 ownership 명시
- task dependency와 병렬 group 표현
- richer acceptance criteria

하지만 현재 구현을 설명할 때는 위의 실제 생성 스키마를 기준으로 보는 것이 맞습니다.
