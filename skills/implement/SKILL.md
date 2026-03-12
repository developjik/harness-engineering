---
name: implement
description: 설계 문서를 기반으로 TDD 방식으로 코드를 구현합니다. 테스트 작성, 구현, 리팩토링을 반복합니다.
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Write, Edit, Bash
---

# Implement Skill

설계 문서를 받아 RED-GREEN-REFACTOR 사이클을 따르며 고품질의 코드를 구현합니다.

## RED-GREEN-REFACTOR 사이클

각 기능마다 다음 단계를 반복합니다:

### 1단계: RED - 실패하는 테스트 작성

```javascript
// test/calculator.test.js
describe('Calculator', () => {
  it('should add two numbers', () => {
    const result = add(2, 3);
    expect(result).toBe(5);
  });
});
```

### 2단계: GREEN - 최소한의 코드로 테스트 통과

```javascript
// src/calculator.js
function add(a, b) {
  return a + b;
}
```

### 3단계: REFACTOR - 코드 개선

```javascript
// 더 나은 구조로 리팩토링
class Calculator {
  add(a, b) {
    return a + b;
  }
}
```

## 구현 순서

1. 설계 문서에서 구현 단계 확인
2. 각 단계별로:
   - 테스트 작성 (RED)
   - 구현 (GREEN)
   - 리팩토링 (REFACTOR)
   - 커밋
3. 다음 단계로 진행

## 코드 품질 기준

### SOLID 원칙 준수

**S**ingle Responsibility: 한 클래스는 한 가지 책임만 가져야 합니다.

**O**pen/Closed: 확장에는 열려있고 수정에는 닫혀있어야 합니다.

**L**iskov Substitution: 상속 관계가 올바르게 설계되어야 합니다.

**I**nterface Segregation: 인터페이스가 작고 구체적이어야 합니다.

**D**ependency Inversion: 추상화에 의존해야 합니다.

### 기타 원칙

**DRY** (Don't Repeat Yourself): 중복 코드를 제거합니다.

**YAGNI** (You Aren't Gonna Need It): 불필요한 기능을 추가하지 않습니다.

**KISS** (Keep It Simple, Stupid): 단순함을 유지합니다.

## 진행 상황 보고

각 단계마다 다음 형식으로 진행 상황을 보고합니다:

```
📊 구현 진행률: [3/10 tasks completed] (30%)

✅ 완료된 작업:
- [작업 1]
- [작업 2]
- [작업 3]

🔄 현재 작업:
- [작업 4]

⏭️ 다음 작업:
- [작업 5]
- [작업 6]

🐛 발견된 문제:
- [문제 1]: [해결 방안]

💡 개선 사항:
- [개선 1]
```

## 테스트 작성 가이드

### 테스트 이름 규칙

```javascript
// ❌ 나쁜 예
it('works', () => { ... });

// ✅ 좋은 예
it('should return sum when adding two positive numbers', () => { ... });
```

### AAA 패턴

```javascript
it('should calculate total price with tax', () => {
  // Arrange: 테스트 데이터 준비
  const price = 100;
  const taxRate = 0.1;
  
  // Act: 함수 실행
  const total = calculateTotal(price, taxRate);
  
  // Assert: 결과 검증
  expect(total).toBe(110);
});
```

### 테스트 커버리지

목표는 80% 이상의 코드 커버리지입니다. 다음 명령어로 확인할 수 있습니다:

```bash
npm run test:coverage
```

테스트에는 정상 경로, 엣지 케이스, 에러 경로가 모두 포함되어야 합니다.

## 커밋 메시지 규칙

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type:**
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `test`: 테스트 추가
- `refactor`: 코드 리팩토링
- `docs`: 문서 수정

**예:**
```
feat(calculator): add multiplication operation

- Implement multiply function
- Add unit tests
- Update documentation

Closes #123
```

## 문제 해결 가이드

### 테스트 실패

1. 에러 메시지 읽기
2. 예상 값과 실제 값 비교
3. 테스트 코드 검토
4. 구현 코드 수정
5. 테스트 재실행

### 코드 복잡도 증가

1. 함수 크기 확인 (20줄 이상이면 분할 고려)
2. 순환 복잡도 확인 (10 이상이면 리팩토링)
3. 책임 분리 검토
4. 헬퍼 함수 추출

## 체크리스트

구현 완료 후 다음을 확인합니다:

- [ ] 모든 테스트 통과
- [ ] 테스트 커버리지 80% 이상
- [ ] 코드 리뷰 기준 충족
- [ ] 커밋 메시지 명확
- [ ] 문서 업데이트
- [ ] 성능 최적화 검토
- [ ] 보안 검토

## 주의사항

- 설계 문서를 벗어나지 않습니다
- 테스트 없이 코드를 작성하지 않습니다
- 과도한 최적화는 피합니다
- 구현 완료 후 Guardian 에이전트에게 코드 리뷰를 요청합니다
