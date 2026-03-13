---
name: plan
description: 요구사항을 분석하고 목표와 제약사항을 정의합니다. 코드 작성 없이 "무엇을 만들 것인가"를 명확히 합니다. 새 프로젝트나 기능 시작 시 사용하세요.
user-invocable: true
argument-hint: <기능 또는 프로젝트 설명>
allowed-tools: Read, Grep, Glob
---

# Plan Skill — PDCA 1단계

**"무엇을 만들 것인가?"** 를 명확히 합니다. 코드를 작성하지 않습니다.

## 프로세스

### 1. Feature Slug 추출 및 요구사항 정제
$ARGUMENTS 에서 기능명(Feature Slug)을 추출합니다. (kebab-case, 예: `user-auth`)
이후 이하 항목들을 분석하여 명확히 합니다:

- 이 프로젝트/기능의 **핵심 목표**는 무엇인가?
- **성공 기준**은 무엇인가? (측정 가능하게)
- **제약 조건**: 시간, 기술 스택, 예산, 호환성
- 기존 시스템과의 **통합 지점**
- **스코프**: v1에 포함할 것 vs 제외할 것

### 2. 사용자 질문
모호한 부분은 반드시 사용자에게 질문합니다. 가정하지 않습니다.

### 3. 요구사항 문서 작성
`docs/templates/plan.md` 템플릿을 읽고 내용을 채운 뒤, **`docs/specs/<feature-slug>/plan.md`** 경로에 저장합니다.
(직접 마크다운 포맷을 지어내지 말고 반드시 템플릿 구조를 따르세요)

## 출력

```
✅ Plan 완료

📋 요구사항 요약:
- [핵심 요구사항 목록]
- 📄 산출물: docs/specs/<feature-slug>/plan.md

➡️ 다음 단계: /design <feature-slug> 로 코드 변경 계획을 수립하세요.
```
