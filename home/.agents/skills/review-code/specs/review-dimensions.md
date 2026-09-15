# Review Dimensions

Code review dimension definitions and checkpoint specifications.

## When to Use

| Phase | Usage | Section |
|-------|-------|---------|
| action-deep-review | Get dimension check rules | All |
| action-generate-report | Map dimension names | Dimension Names |

---

## Dimension Overview

| Dimension | Weight | Focus | Key Indicators |
|-----------|--------|-------|----------------|
| **Correctness** | 25% | Functional correctness | Boundary conditions, error handling, type safety |
| **Security** | 25% | Security risks | Injection attacks, sensitive data, permissions |
| **Performance** | 15% | Execution efficiency | Algorithmic complexity, resource usage |
| **Readability** | 15% | Maintainability | Naming, structure, comments |
| **Testing** | 10% | Test quality | Coverage, boundary tests |
| **Architecture** | 10% | Architectural consistency | Layering, dependencies, patterns |

---

## 1. Correctness

### Checklist

- [ ] **Boundary condition handling**
  - Empty arrays and empty strings
  - Null and undefined
  - Numeric boundaries, such as 0, negative numbers, and MAX_INT
  - Collection boundaries, such as first element and last element

- [ ] **Error handling**
  - Try-catch coverage
  - Errors are not silently swallowed
  - Error messages are meaningful
  - Resources are released correctly

- [ ] **Type safety**
  - Type conversions are correct
  - Avoid implicit conversions
  - TypeScript strict mode

- [ ] **Logic completeness**
  - If-else branches are complete
  - Switch statements have a default case
  - Loop termination conditions are correct

### Common Issue Patterns

```javascript
// Problem: null is not checked.
function getName(user) {
  return user.name.toUpperCase();  // user may be null
}

// Fix
function getName(user) {
  return user?.name?.toUpperCase() ?? 'Unknown';
}

// Problem: empty catch block.
try {
  await fetchData();
} catch (e) {}  // Error is silently swallowed.

// Fix
try {
  await fetchData();
} catch (e) {
  console.error('Failed to fetch data:', e);
  throw e;
}
```

---

## 2. Security

### Checklist

- [ ] **Injection protection**
  - SQL injection, use parameterized queries
  - XSS, avoid innerHTML
  - Command injection, avoid exec
  - Path traversal

- [ ] **Authentication and authorization**
  - Permission checks are complete
  - Token validation
  - Session management

- [ ] **Sensitive data**
  - No hardcoded secrets
  - Logs do not contain sensitive information
  - Encrypted transmission

- [ ] **Dependency security**
  - No dependencies with known vulnerabilities
  - Version locking

### Common Issue Patterns

```javascript
// Problem: SQL injection risk.
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Fix: parameterized query.
const query = `SELECT * FROM users WHERE id = ?`;
db.query(query, [userId]);

// Problem: XSS risk.
element.innerHTML = userInput;

// Fix
element.textContent = userInput;

// Problem: hardcoded secret.
const apiKey = 'sk-xxxxxxxxxxxx';

// Fix
const apiKey = process.env.API_KEY;
```

---

## 3. Performance

### Checklist

- [ ] **Algorithmic complexity**
  - Avoid O(n²) on large datasets
  - Use appropriate data structures
  - Avoid unnecessary loops

- [ ] **I/O efficiency**
  - Batch operations instead of looping over individual operations
  - Avoid N+1 queries
  - Use caching appropriately

- [ ] **Resource usage**
  - Memory leaks
  - Connection pool usage
  - Stream processing for large files

- [ ] **Asynchronous processing**
  - Parallel vs. serial execution
  - Use Promise.all
  - Avoid blocking

### Common Issue Patterns

```javascript
// Problem: N+1 query.
for (const user of users) {
  const posts = await db.query('SELECT * FROM posts WHERE user_id = ?', [user.id]);
}

// Fix: batch query.
const userIds = users.map(u => u.id);
const posts = await db.query('SELECT * FROM posts WHERE user_id IN (?)', [userIds]);

// Problem: serial execution of operations that can run in parallel.
const a = await fetchA();
const b = await fetchB();
const c = await fetchC();

// Fix: parallel execution.
const [a, b, c] = await Promise.all([fetchA(), fetchB(), fetchC()]);
```

---

## 4. Readability

### Checklist

- [ ] **Naming conventions**
  - Variable names clearly express their meaning
  - Function names express actions
  - Constants use UPPER_CASE
  - Avoid abbreviations and single-letter names

- [ ] **Function design**
  - Single responsibility
  - Length < 50 lines
  - Parameters < 5
  - Nesting < 4 levels

- [ ] **Code organization**
  - Logical grouping
  - Blank line separation
  - Import order

- [ ] **Comment quality**
  - Explain why, not what
  - Keep comments up to date
  - No redundant comments

### Common Issue Patterns

```javascript
// Problem: unclear naming.
const d = new Date();
const a = users.filter(x => x.s === 'active');

// Fix
const currentDate = new Date();
const activeUsers = users.filter(user => user.status === 'active');

// Problem: function is too long and has too many responsibilities.
function processOrder(order) {
  // ... 200 lines of code, including validation, calculation, saving, and notification
}

// Fix: split responsibilities.
function validateOrder(order) { /* ... */ }
function calculateTotal(order) { /* ... */ }
function saveOrder(order) { /* ... */ }
function notifyCustomer(order) { /* ... */ }
```

---

## 5. Testing

### Checklist

- [ ] **Test coverage**
  - Core logic has tests
  - Boundary conditions have tests
  - Error paths have tests

- [ ] **Test quality**
  - Tests are independent
  - Assertions are explicit
  - Mock usage is moderate

- [ ] **Test maintainability**
  - Naming is clear
  - Structure is consistent
  - Avoid duplication

### Common Issue Patterns

```javascript
// Problem: test is not independent.
let counter = 0;
test('increment', () => {
  counter++;  // Depends on external state.
  expect(counter).toBe(1);
});

// Fix: each test is independent.
test('increment', () => {
  const counter = new Counter();
  counter.increment();
  expect(counter.value).toBe(1);
});

// Problem: missing boundary test.
test('divide', () => {
  expect(divide(10, 2)).toBe(5);
});

// Fix: include boundary case.
test('divide by zero throws', () => {
  expect(() => divide(10, 0)).toThrow();
});
```

---

## 6. Architecture

### Checklist

- [ ] **Layered structure**
  - Layers are clear
  - Dependency direction is correct
  - No circular dependencies

- [ ] **Modularity**
  - High cohesion and low coupling
  - Interfaces are clearly defined
  - Single responsibility

- [ ] **Design patterns**
  - Appropriate patterns are used
  - Avoid over-engineering
  - Follow existing project patterns

### Common Issue Patterns

```javascript
// Problem: layer confusion, controller directly accesses the database.
class UserController {
  async getUser(req, res) {
    const user = await db.query('SELECT * FROM users WHERE id = ?', [req.params.id]);
    res.json(user);
  }
}

// Fix: clear layering.
class UserController {
  constructor(private userService: UserService) {}
  
  async getUser(req, res) {
    const user = await this.userService.findById(req.params.id);
    res.json(user);
  }
}

// Problem: circular dependency.
// moduleA.ts
import { funcB } from './moduleB';
// moduleB.ts
import { funcA } from './moduleA';

// Fix: extract a shared module or use dependency injection.
```

---

## Severity Mapping

| Severity | Criteria |
|----------|----------|
| **Critical** | Security vulnerability, data corruption risk, crash risk |
| **High** | Functional defect, severe performance issue, important boundary not handled |
| **Medium** | Code quality issue, maintainability issue |
| **Low** | Style issue, optimization suggestion |
| **Info** | Informational suggestion, learning opportunity |
