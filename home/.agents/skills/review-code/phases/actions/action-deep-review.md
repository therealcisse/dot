# Action: Deep Review

Perform a deep review of code quality for the specified dimension.

## Purpose

Perform a deep review for a single dimension:
- Check files one by one
- Record discovered issues
- Provide specific fix recommendations

## Preconditions

- [ ] state.status === 'running'
- [ ] state.scan_completed === true
- [ ] At least one dimension remains unreviewed

## Dimension Focus Areas

### Correctness

- Logic errors and boundary conditions
- Null and undefined handling
- Error handling completeness
- Type safety
- Resource leaks

### Readability

- Naming conventions
- Function length and complexity
- Code duplication
- Comment quality
- Code organization

### Performance

- Algorithmic complexity
- Unnecessary computation
- Memory usage
- I/O efficiency
- Caching strategy

### Security

- Injection risks, such as SQL, XSS, and command injection
- Authentication and authorization
- Sensitive data handling
- Encryption usage
- Dependency security

### Testing

- Test coverage
- Boundary condition tests
- Error path tests
- Test maintainability
- Mock usage

### Architecture

- Layered structure
- Dependency direction
- Single responsibility
- Interface design
- Extensibility

## Execution

```javascript
async function execute(state, workDir, currentDimension) {
  const context = state.context;
  const dimension = currentDimension;
  const findings = [];

  // Load rules from an external JSON file.
  const rulesConfig = loadRulesConfig(dimension, workDir);
  const rules = rulesConfig.rules || [];
  const prefix = rulesConfig.prefix || getDimensionPrefix(dimension);

  // Review high-risk areas first.
  const filesToReview = state.scan_summary?.risk_areas
    ?.map(r => r.file)
    ?.filter(f => context.files.includes(f)) || context.files;

  const filesToCheck = [...new Set([
    ...filesToReview.slice(0, 20),
    ...context.files.slice(0, 30)
  ])].slice(0, 50);  // At most 50 files.

  let findingCounter = 1;
  const fileCache = {};

  for (const file of filesToCheck) {
    try {
      if (!fileCache[file]) {
        fileCache[file] = Read(file);
      }
      const content = fileCache[file];
      const lines = content.split('\n');

      // Apply rules from the external rules file.
      for (const rule of rules) {
        const matches = detectByPattern(content, lines, file, rule);
        for (const match of matches) {
          findings.push({
            id: `${prefix}-${String(findingCounter++).padStart(3, '0')}`,
            severity: rule.severity || match.severity,
            dimension: dimension,
            category: rule.category,
            file: file,
            line: match.line,
            code_snippet: match.snippet,
            description: rule.description,
            recommendation: rule.recommendation,
            fix_example: rule.fixExample
          });
        }
      }
    } catch (e) {
      // Skip files that cannot be read.
    }
  }

  // Save findings for this dimension.
  Write(`${workDir}/findings/${dimension}.json`, JSON.stringify(findings, null, 2));

  return {
    stateUpdates: {
      reviewed_dimensions: [...(state.reviewed_dimensions || []), dimension],
      current_dimension: null,
      [`findings.${dimension}`]: findings
    }
  };
}

/**
 * Load rule configuration from an external JSON file.
 * Rule files are located at specs/rules/{dimension}-rules.json.
 * @param {string} dimension - Dimension name, such as correctness or security.
 * @param {string} workDir - Working directory, used for logging.
 * @returns {object} Rule configuration object containing the rules array and prefix.
 */
function loadRulesConfig(dimension, workDir) {
  // Rules file path, relative to the skill directory.
  const rulesPath = `specs/rules/${dimension}-rules.json`;

  try {
    const rulesFile = Read(rulesPath);
    const rulesConfig = JSON.parse(rulesFile);
    return rulesConfig;
  } catch (e) {
    console.warn(`Failed to load rules for ${dimension}: ${e.message}`);
    // Return an empty rule configuration for backward compatibility.
    return { rules: [], prefix: getDimensionPrefix(dimension) };
  }
}

/**
 * Detect code issues based on the rule patternType.
 * Supported patternType values: regex, includes.
 * @param {string} content - File content.
 * @param {string[]} lines - Content split by line.
 * @param {string} file - File path.
 * @param {object} rule - Rule configuration object.
 * @returns {Array} Array of match results.
 */
function detectByPattern(content, lines, file, rule) {
  const matches = [];
  const { pattern, patternType, negativePatterns, caseInsensitive } = rule;

  if (!pattern) return matches;

  switch (patternType) {
    case 'regex':
      return detectByRegex(content, lines, pattern, negativePatterns, caseInsensitive);

    case 'includes':
      return detectByIncludes(content, lines, pattern, negativePatterns);

    default:
      // Use includes mode by default.
      return detectByIncludes(content, lines, pattern, negativePatterns);
  }
}

/**
 * Detect code issues using a regular expression.
 * @param {string} content - Full file content.
 * @param {string[]} lines - Content split by line.
 * @param {string} pattern - Regular expression pattern.
 * @param {string[]} negativePatterns - List of exclusion patterns.
 * @param {boolean} caseInsensitive - Whether to ignore case.
 * @returns {Array} Array of match results.
 */
function detectByRegex(content, lines, pattern, negativePatterns, caseInsensitive) {
  const matches = [];

  // Reject overly complex patterns to prevent ReDoS
  if (pattern.length > 500) {
    console.warn(`Regex pattern too long (${pattern.length} chars), skipping`);
    return matches;
  }
  const nestedGroupDepth = (pattern.match(/\(/g) || []).length;
  if (nestedGroupDepth > 10) {
    console.warn(`Regex pattern has too many groups (${nestedGroupDepth}), skipping`);
    return matches;
  }

  const flags = caseInsensitive ? 'gi' : 'g';

  try {
    const regex = new RegExp(pattern, flags);
    let match;
    let matchCount = 0;

    while ((match = regex.exec(content)) !== null && matchCount < 1000) {
      matchCount++;
      const lineNum = content.substring(0, match.index).split('\n').length;
      const lineContent = lines[lineNum - 1] || '';

      // Check exclusion patterns. Skip if the line matches any exclusion pattern.
      if (negativePatterns && negativePatterns.length > 0) {
        const shouldExclude = negativePatterns.some(np => {
          try {
            return new RegExp(np).test(lineContent);
          } catch {
            return lineContent.includes(np);
          }
        });
        if (shouldExclude) continue;
      }

      matches.push({
        line: lineNum,
        snippet: lineContent.trim().substring(0, 100),
        matchedText: match[0]
      });
    }
  } catch (e) {
    console.warn(`Invalid regex pattern: ${pattern}`);
  }

  return matches;
}

/**
 * Detect code issues using string inclusion.
 * @param {string} content - Full file content, unused but kept for interface consistency.
 * @param {string[]} lines - Content split by line.
 * @param {string} pattern - String to search for.
 * @param {string[]} negativePatterns - List of exclusion patterns.
 * @returns {Array} Array of match results.
 */
function detectByIncludes(content, lines, pattern, negativePatterns) {
  const matches = [];

  lines.forEach((line, i) => {
    if (line.includes(pattern)) {
      // Check exclusion patterns. Skip if the line contains any exclusion string.
      if (negativePatterns && negativePatterns.length > 0) {
        const shouldExclude = negativePatterns.some(np => line.includes(np));
        if (shouldExclude) return;
      }

      matches.push({
        line: i + 1,
        snippet: line.trim().substring(0, 100),
        matchedText: pattern
      });
    }
  });

  return matches;
}

/**
 * Get the dimension prefix, used as a fallback when the rules file does not exist.
 * @param {string} dimension - Dimension name.
 * @returns {string} 4-character prefix.
 */
function getDimensionPrefix(dimension) {
  const prefixes = {
    correctness: 'CORR',
    readability: 'READ',
    performance: 'PERF',
    security: 'SEC',
    testing: 'TEST',
    architecture: 'ARCH'
  };
  return prefixes[dimension] || 'MISC';
}
```

## State Updates

```javascript
return {
  stateUpdates: {
    reviewed_dimensions: [...state.reviewed_dimensions, currentDimension],
    current_dimension: null,
    findings: {
      ...state.findings,
      [currentDimension]: newFindings
    }
  }
};
```

## Output

- **File**: `findings/{dimension}.json`
- **Location**: `${workDir}/findings/`
- **Format**: JSON array of Finding objects

## Error Handling

| Error Type | Recovery |
|------------|----------|
| File read failure | Skip the file and record a warning |
| Rule execution error | Skip the rule and continue with other rules |

## Next Actions

- Unreviewed dimensions remain: continue action-deep-review
- All dimensions completed: action-generate-report
