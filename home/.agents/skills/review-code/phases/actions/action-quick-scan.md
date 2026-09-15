# Action: Quick Scan

Quickly scan the code and identify high-risk areas.

## Purpose

Perform the first quick scan:
- Identify files with high complexity
- Mark potential high-risk areas
- Detect obvious issue patterns

## Preconditions

- [ ] state.status === 'running'
- [ ] state.context !== null

## Execution

```javascript
async function execute(state, workDir) {
  const context = state.context;
  const riskAreas = [];
  const quickIssues = [];
  
  // 1. Scan each file.
  for (const file of context.files) {
    try {
      const content = Read(file);
      const lines = content.split('\n');
      
      // --- Complexity checks ---
      const functionMatches = content.match(/function\s+\w+|=>\s*{|async\s+\w+/g) || [];
      const nestingDepth = Math.max(...lines.map(l => (l.match(/^\s*/)?.[0].length || 0) / 2));
      
      if (lines.length > 500 || functionMatches.length > 20 || nestingDepth > 8) {
        riskAreas.push({
          file: file,
          reason: `High complexity: ${lines.length} lines, ${functionMatches.length} functions, depth ${nestingDepth}`,
          priority: 'high'
        });
      }
      
      // --- Quick issue detection ---
      
      // Quick security issue detection.
      if (content.includes('eval(') || content.includes('innerHTML')) {
        quickIssues.push({
          type: 'security',
          file: file,
          message: 'Potential XSS/injection risk: eval() or innerHTML usage'
        });
      }
      
      // Hardcoded secret detection.
      if (/(?:password|secret|api_key|token)\s*[=:]\s*['"][^'"]{8,}/i.test(content)) {
        quickIssues.push({
          type: 'security',
          file: file,
          message: 'Potential hardcoded credential detected'
        });
      }
      
      // TODO/FIXME detection.
      const todoCount = (content.match(/TODO|FIXME|HACK|XXX/gi) || []).length;
      if (todoCount > 5) {
        quickIssues.push({
          type: 'maintenance',
          file: file,
          message: `${todoCount} TODO/FIXME comments found`
        });
      }
      
      // console.log detection in production code.
      if (!file.includes('test') && !file.includes('spec')) {
        const consoleCount = (content.match(/console\.(log|debug|info)/g) || []).length;
        if (consoleCount > 3) {
          quickIssues.push({
            type: 'readability',
            file: file,
            message: `${consoleCount} console statements (should be removed in production)`
          });
        }
      }
      
      // Error handling detection.
      if (content.includes('catch') && content.includes('catch (') && content.match(/catch\s*\([^)]*\)\s*{\s*}/)) {
        quickIssues.push({
          type: 'correctness',
          file: file,
          message: 'Empty catch block detected'
        });
      }
      
    } catch (e) {
      // Skip files that cannot be read.
    }
  }
  
  // 2. Calculate complexity score.
  const complexityScore = Math.min(100, Math.round(
    (riskAreas.length * 10 + quickIssues.length * 5) / context.file_count * 100
  ));
  
  // 3. Build scan summary.
  const scanSummary = {
    risk_areas: riskAreas,
    complexity_score: complexityScore,
    quick_issues: quickIssues
  };
  
  // 4. Save scan results.
  Write(`${workDir}/scan-summary.json`, JSON.stringify(scanSummary, null, 2));
  
  return {
    stateUpdates: {
      scan_completed: true,
      scan_summary: scanSummary
    }
  };
}
```

## State Updates

```javascript
return {
  stateUpdates: {
    scan_completed: true,
    scan_summary: {
      risk_areas: riskAreas,
      complexity_score: score,
      quick_issues: quickIssues
    }
  }
};
```

## Output

- **File**: `scan-summary.json`
- **Location**: `${workDir}/scan-summary.json`
- **Format**: JSON

## Error Handling

| Error Type | Recovery |
|------------|----------|
| File read failure | Skip the file and continue scanning |
| Encoding issue | Skip as binary |

## Next Actions

- Success: action-deep-review, start reviewing dimension by dimension
- Too many risk areas (>20): May ask the user whether to narrow the scope
