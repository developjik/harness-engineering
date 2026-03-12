# Harness Engineering

**AI-native 소프트웨어 개발을 위한 통합 하네스 시스템**

`bkit-claude-code`, `oh-my-openagent`, `superpowers`의 장점을 결합하여 만든 개인화된 AI 하네스 엔지니어링 프레임워크입니다.

## 🎯 핵심 철학

- **PDCA 기반 워크플로우**: Plan → Do → Check → Act의 반복을 통해 품질을 보장
- **컨텍스트 엔지니어링**: 프롬프트 + 도구 + 상태를 결합하여 LLM에게 최적의 컨텍스트 제공
- **멀티 에이전트 오케스트레이션**: 전문화된 에이전트들의 협업으로 복잡한 과업 수행

## 📁 디렉토리 구조

```
harness-engineering/
├── .harness/                 # 하네스 핵심 시스템
│   ├── agents/              # 전문 에이전트 정의
│   ├── skills/              # 재사용 가능한 스킬 셋
│   ├── hooks/               # 생명주기별 자동화 스크립트
│   ├── state/               # 작업 상태 및 PDCA 이력 관리
│   └── templates/           # 프롬프트 및 설정 템플릿
├── docs/                    # 상세 문서
├── examples/                # 사용 예제
├── DESIGN.md               # 시스템 설계 문서
└── README.md               # 이 파일
```

## 🚀 빠른 시작

### 설치

```bash
git clone https://github.com/developjik/harness-engineering.git
cd harness-engineering
npm install
```

### 기본 사용

```bash
# PDCA 워크플로우 시작
npm run pdca:start

# 특정 에이전트 실행
npm run agent:architect

# 전체 자동화 실행 (ultrawork 스타일)
npm run ultrawork
```

## 🤖 에이전트 시스템

### 주요 에이전트

| 에이전트 | 역할 | 모델 |
| :--- | :--- | :--- |
| **Architect** | 요구사항 분석 및 설계 문서 작성 | Claude Opus 4.6 |
| **Engineer** | 실제 코드 구현 및 TDD 수행 | GPT-5.3 Codex |
| **Guardian** | 코드 리뷰 및 보안/품질 점검 | Claude Opus 4.6 |
| **Librarian** | 문서화 및 지식 관리 | Claude Sonnet 4.6 |

### 에이전트 협업 방식

```
사용자 입력
    ↓
Architect (설계 단계)
    ↓
Engineer (구현 단계)
    ↓
Guardian (검증 단계)
    ↓
Librarian (문서화 단계)
    ↓
완성된 산출물
```

## 🛠️ 스킬 시스템

스킬은 재사용 가능한 작업 단위입니다. 각 스킬은 다음을 포함합니다:

- **SKILL.md**: 스킬 설명 및 사용 가이드
- **prompt.md**: 에이전트를 위한 프롬프트 템플릿
- **eval/**: 스킬 품질 검증을 위한 테스트

### 기본 스킬

- `brainstorming`: 요구사항 정제 및 설계 아이디어 도출
- `test-driven-development`: RED-GREEN-REFACTOR 사이클
- `code-review`: 체계적인 코드 리뷰 프로세스
- `documentation`: 자동 문서화 생성

## 🔗 훅 시스템

생명주기별 자동화 포인트:

| 훅 | 트리거 | 용도 |
| :--- | :--- | :--- |
| `SessionStart` | 세션 시작 | 초기화 및 상태 복구 |
| `UserPromptSubmit` | 사용자 입력 | 인텐트 감지 및 라우팅 |
| `PreToolUse` | 도구 실행 전 | 검증 및 컨텍스트 준비 |
| `PostToolUse` | 도구 실행 후 | 결과 처리 및 상태 업데이트 |
| `Stop` | 세션 종료 | 정리 및 저장 |

## 📊 PDCA 상태 관리

`.harness/state/` 디렉토리에 현재 작업 상태가 저장됩니다:

```json
{
  "session_id": "uuid",
  "phase": "plan",
  "pdca_cycle": 1,
  "timestamp": "2026-03-12T12:00:00Z",
  "context": {
    "user_intent": "...",
    "design_doc": "...",
    "implementation_plan": "..."
  }
}
```

## 🎓 학습 자료

- [DESIGN.md](./DESIGN.md) - 시스템 아키텍처 상세 설명
- [docs/](./docs/) - 각 컴포넌트별 상세 가이드
- [examples/](./examples/) - 실제 사용 예제

## 📝 참고 자료

이 프로젝트는 다음 세 가지 오픈소스 프로젝트를 분석하여 개발되었습니다:

1. **bkit-claude-code** (popup-studio-ai)
   - PDCA 방법론 및 Context Engineering 개념
   - 5단계 훅 시스템 아키텍처

2. **oh-my-openagent** (code-yeongyu)
   - 멀티 모델 오케스트레이션
   - `ultrawork` 명령어 패턴
   - 병렬 에이전트 실행

3. **superpowers** (obra)
   - TDD 강조 및 Red-Green-Refactor 사이클
   - 서브에이전트 기반 개발
   - 설계 우선 접근 방식

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포할 수 있습니다.

## 🤝 기여

이슈 및 풀 리퀘스트는 언제든 환영합니다!

---

**Made with ❤️ for AI-native development**
