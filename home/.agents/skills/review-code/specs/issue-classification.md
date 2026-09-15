# Issue Classification

Issue classification and severity standards.

## When to Use

| Phase | Usage | Section |
|-------|-------|---------|
| action-deep-review | Determine issue severity | Severity Levels |
| action-generate-report | Display issue categories | Category Mapping |

---

## Severity Levels

### Critical 🔴

**Definition**: Blocking issues that must be fixed before merge.

**Criteria**:
- Security vulnerabilities that can be exploited
- Risk of data corruption or data loss
- Risk of system crash
- Major production failure

**Examples**:
- SQL, XSS, or command injection
- Hardcoded secret exposure
- Uncaught exception causing a crash
- Database transaction not handled correctly

**Response**: Must be fixed immediately and blocks merge.

---

### High 🟠

**Definition**: Important issues that should be fixed before merge.

**Criteria**:
- Functional defects
- Important boundary conditions not handled
- Severe performance degradation
- Resource leaks

**Examples**:
- Core business logic error
- Memory leak
- N+1 query issue
- Missing required error handling

**Response**: Strongly recommended to fix.

---

### Medium 🟡

**Definition**: Code quality issues that are recommended to fix.

**Criteria**:
- Code maintainability issues
- Minor performance issues
- Insufficient test coverage
- Does not follow team standards

**Examples**:
- Function is too long
- Naming is unclear
- Missing comments
- Code duplication

**Response**: Recommended to fix in a later iteration.

---

### Low 🔵

**Definition**: Optional optimization issues.

**Criteria**:
- Style issues
- Small optimizations
- Readability improvements

**Examples**:
- Variable declaration order
- Extra blank lines
- Code that could be written more concisely

**Response**: Handle according to team preference.

---

### Info ⚪

**Definition**: Informational suggestions, not issues.

**Criteria**:
- Learning opportunities
- Alternative solution suggestions
- Documentation improvement suggestions

**Examples**:
- "Consider using the newer API here."
- "Consider adding JSDoc comments."
- "You can refer to the xxx pattern."

**Response**: For reference only.

---

## Category Mapping

### By Dimension

| Dimension | Common Categories |
|-----------|-------------------|
| Correctness | `null-check`, `boundary`, `error-handling`, `type-safety`, `logic-error` |
| Security | `injection`, `xss`, `hardcoded-secret`, `auth`, `sensitive-data` |
| Performance | `complexity`, `n+1-query`, `memory-leak`, `blocking-io`, `inefficient-algorithm` |
| Readability | `naming`, `function-length`, `complexity`, `comments`, `duplication` |
| Testing | `coverage`, `boundary-test`, `mock-abuse`, `test-isolation` |
| Architecture | `layer-violation`, `circular-dependency`, `coupling`, `srp-violation` |

### Category Details

#### Correctness Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `null-check` | Missing null check | High |
| `boundary` | Boundary condition not handled | High |
| `error-handling` | Improper error handling | High |
| `type-safety` | Type safety issue | Medium |
| `logic-error` | Logic error | Critical/High |
| `resource-leak` | Resource leak | High |

#### Security Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `injection` | Injection risk, such as SQL or command injection | Critical |
| `xss` | Cross-site scripting risk | Critical |
| `hardcoded-secret` | Hardcoded secret | Critical |
| `auth` | Authentication or authorization issue | High |
| `sensitive-data` | Sensitive data exposure | High |
| `insecure-dependency` | Insecure dependency | Medium |

#### Performance Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `complexity` | High algorithmic complexity | Medium |
| `n+1-query` | N+1 query issue | High |
| `memory-leak` | Memory leak | High |
| `blocking-io` | Blocking I/O | Medium |
| `inefficient-algorithm` | Inefficient algorithm | Medium |
| `missing-cache` | Missing cache | Low |

#### Readability Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `naming` | Naming issue | Medium |
| `function-length` | Function is too long | Medium |
| `nesting-depth` | Excessive nesting depth | Medium |
| `comments` | Comment issue | Low |
| `duplication` | Code duplication | Medium |
| `magic-number` | Magic number | Low |

#### Testing Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `coverage` | Insufficient test coverage | Medium |
| `boundary-test` | Missing boundary test | Medium |
| `mock-abuse` | Excessive mock usage | Low |
| `test-isolation` | Test is not isolated | Medium |
| `flaky-test` | Flaky test | High |

#### Architecture Categories

| Category | Description | Default Severity |
|----------|-------------|------------------|
| `layer-violation` | Layer violation | Medium |
| `circular-dependency` | Circular dependency | High |
| `coupling` | Excessive coupling | Medium |
| `srp-violation` | Single responsibility principle violation | Medium |
| `god-class` | God class | High |

---

## Finding ID Format

```text
{PREFIX}-{NNN}

Prefixes by Dimension:
- CORR: Correctness
- SEC:  Security
- PERF: Performance
- READ: Readability
- TEST: Testing
- ARCH: Architecture

Examples:
- SEC-001: First security finding
- CORR-015: 15th correctness finding
```

---

## Quality Gates

| Gate | Condition | Action |
|------|-----------|--------|
| **Block** | Critical > 0 | Block merge |
| **Warn** | High > 0 | Requires approval |
| **Pass** | Critical = 0, High = 0 | Allow merge |

### Recommended Thresholds

| Metric | Ideal | Acceptable | Needs Work |
|--------|-------|------------|------------|
| Critical | 0 | 0 | Any > 0 |
| High | 0 | ≤ 2 | > 2 |
| Medium | ≤ 5 | ≤ 10 | > 10 |
| Total | ≤ 10 | ≤ 20 | > 20 |
