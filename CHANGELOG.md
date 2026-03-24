# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-03-25

### Added
- **Automation Levels (L0-L4)**: PDCA 워크플로우 자동화 정도를 5단계로 조절 가능
  - L0 (Manual): 모든 전환에 승인 필요
  - L1 (Guided): 중요 전환만 승인
  - L2 (Semi-Auto): 불확실할 때만 승인 (기본값)
  - L3 (Auto): 품질 게이트만 통과하면 자동
  - L4 (Full-Auto): 완전 자동
- **Trust Score System**: 6개 지표 기반 신뢰 점수 시스템
  - track_record (0.25): 과거 성공률
  - quality_metrics (0.20): 코드 품질 점수
  - velocity (0.15): 작업 속도
  - user_ratings (0.20): 사용자 평가
  - decision_accuracy (0.10): 결정 정확도
  - safety (0.10): 안전 위반 없음
- **Decision Logging**: 모든 PDCA 전환 결정을 JSONL로 기록
- **Recommended Level**: 신뢰 점수 기반 추천 레벨 제공

### Changed
- `hooks/common.sh`: 11개 자동화 관련 함수 추가
- `hooks/session-start.sh`: 자동화 설정 초기화 로직 추가
- `hooks/on-agent-start.sh`: 단계 전환 승인 로직 추가

### Files
- Created: `docs/templates/automation-config.md` - 자동화 설정 가이드
- Created: `docs/specs/automation-levels/` - Plan, Design, Wrapup 문서

## [1.0.0] - 2025-01-15

### Added
- Initial release
- 6 specialized agents (strategist, architect, engineer, guardian, librarian, debugger)
- 9 execution skills (plan, design, implement, check, wrapup, harness, debug, fullrun, grill-me)
- Hook automation system (security, backup, logging, state tracking)
- PDCA 5-stage workflow with automatic iteration
- Feature registry and dependency management
- File conflict detection
