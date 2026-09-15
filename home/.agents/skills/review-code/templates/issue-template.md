# Issue Template

Issue record template.

## Single Issue Template

```markdown
#### {{severity_emoji}} [{{id}}] {{category}}

- **Severity**: {{severity}}
- **Dimension**: {{dimension}}
- **File**: `{{file}}`{{#if line}}:{{line}}{{/if}}
- **Description**: {{description}}

{{#if code_snippet}}
**Problematic Code**:
```{{language}}
{{code_snippet}}
```
{{/if}}

**Recommendation**: {{recommendation}}

{{#if fix_example}}
**Fix Example**:
```{{language}}
{{fix_example}}
```
{{/if}}

{{#if references}}
**References**:
{{#each references}}
- {{this}}
{{/each}}
{{/if}}
```

## Issue Object Schema

```typescript
interface Issue {
  id: string;           // e.g., "SEC-001"
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info';
  dimension: string;    // e.g., "security"
  category: string;     // e.g., "xss-risk"
  file: string;         // e.g., "src/utils/render.ts"
  line?: number;        // e.g., 42
  column?: number;      // e.g., 15
  code_snippet?: string;
  description: string;
  recommendation: string;
  fix_example?: string;
  references?: string[];
}
```

## ID Generation

```javascript
function generateIssueId(dimension, counter) {
  const prefixes = {
    correctness: 'CORR',
    readability: 'READ',
    performance: 'PERF',
    security: 'SEC',
    testing: 'TEST',
    architecture: 'ARCH'
  };
  
  const prefix = prefixes[dimension] || 'MISC';
  const number = String(counter).padStart(3, '0');
  
  return `${prefix}-${number}`;
}
```

## Severity Emojis

```javascript
const SEVERITY_EMOJI = {
  critical: '🔴',
  high: '🟠',
  medium: '🟡',
  low: '🔵',
  info: '⚪'
};
```

## Issue Categories by Dimension

### Correctness

- `null-check` - Missing null check
- `boundary` - Boundary condition not handled
- `error-handling` - Improper error handling
- `type-safety` - Type safety issue
- `logic-error` - Logic error
- `resource-leak` - Resource leak

### Security

- `injection` - Injection risk
- `xss` - Cross-site scripting
- `hardcoded-secret` - Hardcoded secret
- `auth` - Authentication and authorization
- `sensitive-data` - Sensitive data

### Performance

- `complexity` - Complexity issue
- `n+1-query` - N+1 query
- `memory-leak` - Memory leak
- `blocking-io` - Blocking I/O
- `inefficient-algorithm` - Inefficient algorithm

### Readability

- `naming` - Naming issue
- `function-length` - Function is too long
- `nesting-depth` - Excessive nesting depth
- `comments` - Comment issue
- `duplication` - Code duplication

### Testing

- `coverage` - Insufficient coverage
- `boundary-test` - Missing boundary test
- `test-isolation` - Test is not isolated
- `flaky-test` - Flaky test

### Architecture

- `layer-violation` - Layer violation
- `circular-dependency` - Circular dependency
- `coupling` - Excessive coupling
- `srp-violation` - Single responsibility principle violation

## Example Issues

### Critical Security Issue

```json
{
  "id": "SEC-001",
  "severity": "critical",
  "dimension": "security",
  "category": "xss",
  "file": "src/components/Comment.tsx",
  "line": 25,
  "code_snippet": "element.innerHTML = userComment;",
  "description": "User input is inserted directly with innerHTML, creating an XSS attack risk.",
  "recommendation": "Use textContent or HTML-escape user input before insertion.",
  "fix_example": "element.textContent = userComment;\n// Or\nelement.innerHTML = DOMPurify.sanitize(userComment);",
  "references": [
    "https://owasp.org/www-community/xss-filter-evasion-cheatsheet"
  ]
}
```

### High Correctness Issue

```json
{
  "id": "CORR-003",
  "severity": "high",
  "dimension": "correctness",
  "category": "error-handling",
  "file": "src/services/api.ts",
  "line": 42,
  "code_snippet": "try {\n  await fetchData();\n} catch (e) {}",
  "description": "The empty catch block silently swallows errors, making issues difficult to detect and debug.",
  "recommendation": "Log the error or rethrow the exception.",
  "fix_example": "try {\n  await fetchData();\n} catch (e) {\n  console.error('Failed to fetch data:', e);\n  throw e;\n}"
}
```

### Medium Readability Issue

```json
{
  "id": "READ-007",
  "severity": "medium",
  "dimension": "readability",
  "category": "function-length",
  "file": "src/utils/processor.ts",
  "line": 15,
  "description": "The processData function has 150 lines, exceeding the recommended 50-line limit and making it difficult to understand and maintain.",
  "recommendation": "Split the function into smaller functions, with each function responsible for a single concern.",
  "fix_example": "// Split into:\nfunction validateInput(data) { ... }\nfunction transformData(data) { ... }\nfunction saveData(data) { ... }"
}
```
