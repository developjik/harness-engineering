---
name: design
description: Plan 문서를 기반으로 실제 코드의 생성·수정·삭제 계획을 수립합니다. 파일 단위로 변경 사항을 구체화합니다.
user-invocable: true
argument-hint: <기능명 또는 Plan 문서 경로>
allowed-tools: Read, Grep, Glob, Bash
---

# Design Skill — PDCA 2단계

Plan 문서를 기반으로 **"코드를 어떻게 바꿀 것인가?"** 를 구체화합니다.

## 프로세스

### 1. Plan 문서 로드
$ARGUMENTS 에서 `<feature-slug>`를 식별하고, **`docs/specs/<feature-slug>/plan.md`** 파일(기존 산출물)을 읽습니다.

### 2. 현재 코드베이스 분석
- 관련 파일 구조 파악
- 기존 패턴과 컨벤션 확인
- 의존성 관계 분석

### 3. 변경 계획 문서 작성
`docs/templates/design.md` 템플릿을 읽고 내용을 채운 뒤, **`docs/specs/<feature-slug>/design.md`** 경로에 설계 문서를 저장합니다.
(별도 포맷을 지어내지 않고 템플릿의 항목을 모두 채워야 합니다)

## 출력

```
✅ Design 완료

📐 변경 요약:
- 생성: X개 파일
- 수정: Y개 파일
- 삭제: Z개 파일
- 📄 산출물: docs/specs/<feature-slug>/design.md

➡️ 다음 단계: /implement <feature-slug> 로 TDD 구현을 시작하세요.
```
