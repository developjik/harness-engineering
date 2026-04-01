# Verification

`colo-fe-flow`의 verification은 `check` 단계가 최신 검증 결과를 artifact와 state에 반영하는 구조입니다.

## 현재 구현 기준

- 사람용 최신 보고서는 `docs/specs/<JIRA-KEY>/check.md`
- 기계가 읽는 최신 상태는 `.colo-fe-flow/.state/tickets/<JIRA-KEY>.json.verification`
- 라우터는 주로 `last_check_status`, `open_gaps`, `check.md` 존재 여부를 읽습니다.

## `verification.*` 필드

현재 ticket state는 아래 필드를 가집니다.

- `verification.last_check_status`
  `not_run | passed | failed`
- `verification.last_check_at`
  마지막 check 기록 시각
- `verification.open_gaps`
  열린 gap 수
- `verification.plan_compliance_score`
  계획/설계 준수 점수
- `verification.classes.A`
- `verification.classes.B`
- `verification.classes.C`
- `verification.classes.D`
  class별 최신 상태

## Helper 기준 상태 기록

현재 shell helper는 `hooks/lib/verification.sh`와 `hooks/lib/execution.sh`를 통해 verification을 기록합니다.

- `cff_execution_write_check`
  `check.md`를 생성하고 `verification.*`를 갱신합니다.
- `cff_verification_record_check`
  `last_check_status`, `open_gaps`, `plan_compliance_score`, `classes`를 state에 씁니다.
- `cff_verification_is_passing`
  `last_check_status=passed`, `open_gaps=0`, `classes.A=passed`, `classes.B=passed`, `classes.D=passed`를 확인합니다.

## Class A/B/C/D 해석

문서 계약상 verification은 Class A/B/C/D 구분을 유지합니다.

- Class A
  핵심 기능/회귀 확인
- Class B
  계획/설계 준수와 주요 acceptance 확인
- Class C
  확장 검증 또는 E2E 계열을 수용할 수 있는 슬롯
- Class D
  최종 ship gate 성격의 판정

## 현재 스캐폴드의 한계

- 현재 helper 기본 구현은 class 값을 저장하지만 richer evidence는 담지 않습니다.
- `cff_execution_write_check`의 기본값은 `A=passed`, `B=passed`, `C=not_run`, `D=passed|failed` 형태입니다.
- 즉 Class C/E2E는 문서상의 목표 슬롯은 존재하지만, 현재 shell helper 기준 completion gate로 강하게 연결되지는 않았습니다.

## 목표 방향

- `check` runner가 class별 증거와 세부 결과를 더 풍부하게 기록
- E2E와 regression evidence를 Class C 또는 별도 세부 구조로 확장
- 라우터가 필요하면 단순 `last_check_status` 이상으로 class별 gate를 읽도록 강화
