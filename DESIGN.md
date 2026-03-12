# AI Harness Engineering Design

본 문서는 `bkit-claude-code`, `oh-my-openagent`, `superpowers` 레포지토리를 분석하여 `harness-engineering`에 구현할 AI 하네스 시스템의 설계를 정의합니다.

## 1. 핵심 철학 (Core Philosophy)
- **PDCA 기반 워크플로우**: 계획(Plan), 수행(Do), 점검(Check), 조치(Act)의 반복을 통해 품질을 보장합니다.
- **컨텍스트 엔지니어링 (Context Engineering)**: 단순 프롬프트를 넘어, 도구와 상태를 결합하여 LLM에게 최적의 컨텍스트를 제공합니다.
- **멀티 에이전트 오케스트레이션**: 전문화된 에이전트(Planner, Executor, Reviewer)들이 협업하여 복잡한 과업을 수행합니다.

## 2. 참조 레포지토리 분석 결과

| 레포지토리 | 핵심 특징 | 도입 요소 |
| :--- | :--- | :--- |
| **bkit** | PDCA 방법론, 5단계 훅 시스템 | PDCA 워크플로우, 상태 관리 체계 |
| **oh-my-openagent** | `ultrawork`, 멀티 모델 오케스트레이션 | 병렬 에이전트 실행, 인텐트 게이트 |
| **superpowers** | TDD 강조, 서브에이전트 기반 개발 | Red-Green-Refactor, 설계 우선 접근 |

## 3. 시스템 아키텍처

### 3.1. 디렉토리 구조
- `.harness/`: 하네스 핵심 설정 및 스크립트
  - `agents/`: 전문 에이전트 정의 (JSON/MD)
  - `skills/`: 재사용 가능한 스킬 셋
  - `hooks/`: 생명주기별 자동화 스크립트
  - `state/`: 현재 작업 상태 및 PDCA 이력 관리

### 3.2. 주요 에이전트 구성
- **Architect (Prometheus)**: 요구사항 분석 및 설계 문서 작성
- **Engineer (Hephaestus)**: 실제 코드 구현 및 TDD 수행
- **Guardian (Oracle)**: 코드 리뷰 및 보안/품질 점검

## 4. 구현 로드맵
1. **Phase 1**: 기본 PDCA 스켈레톤 및 디렉토리 구조 생성
2. **Phase 2**: 핵심 에이전트 프롬프트 및 스킬 정의
3. **Phase 3**: 작업 자동화를 위한 훅(Hooks) 시스템 구현
4. **Phase 4**: `ultrawork` 스타일의 통합 실행 스크립트 작성
