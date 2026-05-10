# Action: Generate Report

Summarize all findings and generate a structured review report.

## Purpose

Generate the final code review report:
- Summarize findings from all dimensions
- Sort by severity
- Provide a statistical summary
- Output the report in Markdown format

## Preconditions

- [ ] state.status === 'running'
- [ ] All dimensions have been reviewed (reviewed_dimensions.length === 6)

## Execution

```javascript
async function execute(state, workDir) {
  const context = state.context;
  const findings = state.findings;
  
  // 1. Summarize all findings.
  const allFindings = [
    ...findings.correctness,
    ...findings.readability,
    ...findings.performance,
    ...findings.security,
    ...findings.testing,
    ...findings.architecture
  ];
  
  // 2. Sort by severity.
  const severityOrder = { critical: 0, high: 1, medium: 2, low: 3, info: 4 };
  allFindings.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);
  
  // 3. Calculate statistics.
  const stats = {
    total_issues: allFindings.length,
    critical: allFindings.filter(f => f.severity === 'critical').length,
    high: allFindings.filter(f => f.severity === 'high').length,
    medium: allFindings.filter(f => f.severity === 'medium').length,
    low: allFindings.filter(f => f.severity === 'low').length,
    info: allFindings.filter(f => f.severity === 'info').length,
    by_dimension: {
      correctness: findings.correctness.length,
      readability: findings.readability.length,
      performance: findings.performance.length,
      security: findings.security.length,
      testing: findings.testing.length,
      architecture: findings.architecture.length
    }
  };
  
  // 4. Generate the report.
  const report = generateMarkdownReport(context, stats, allFindings, state.scan_summary);
  
  // 5. Save the report.
  const reportPath = `${workDir}/review-report.md`;
  Write(reportPath, report);
  
  return {
    stateUpdates: {
      report_generated: true,
      report_path: reportPath,
      summary: {
        ...stats,
        review_duration_ms: Date.now() - new Date(state.started_at).getTime()
      }
    }
  };
}

function generateMarkdownReport(context, stats, findings, scanSummary) {
  const severityEmoji = {
    critical: '🔴',
    high: '🟠',
    medium: '🟡',
    low: '🔵',
    info: '⚪'
  };
  
  let report = `# Code Review Report

## Review Overview

| Item | Value |
|------|------|
| Target Path | \`${context.target_path}\` |
| File Count | ${context.file_count} |
| Lines of Code | ${context.total_lines} |
| Primary Language | ${context.language} |
| Framework | ${context.framework || 'N/A'} |

## Issue Statistics

| Severity | Count |
|----------|------|
| 🔴 Critical | ${stats.critical} |
| 🟠 High | ${stats.high} |
| 🟡 Medium | ${stats.medium} |
| 🔵 Low | ${stats.low} |
| ⚪ Info | ${stats.info} |
| **Total** | **${stats.total_issues}** |

### Statistics by Dimension

| Dimension | Issue Count |
|------|--------|
| Correctness | ${stats.by_dimension.correctness} |
| Security | ${stats.by_dimension.security} |
| Performance | ${stats.by_dimension.performance} |
| Readability | ${stats.by_dimension.readability} |
| Testing | ${stats.by_dimension.testing} |
| Architecture | ${stats.by_dimension.architecture} |

---

## High-Risk Areas

`;

  if (scanSummary?.risk_areas?.length > 0) {
    report += `| File | Reason | Priority |
|------|------|--------|
`;
    for (const area of scanSummary.risk_areas.slice(0, 10)) {
      report += `| \`${area.file}\` | ${area.reason} | ${area.priority} |\n`;
    }
  } else {
    report += `No obvious high-risk areas were found.\n`;
  }

  report += `
---

## Issue Details

`;

  // Output grouped by dimension.
  const dimensions = ['correctness', 'security', 'performance', 'readability', 'testing', 'architecture'];
  const dimensionNames = {
    correctness: 'Correctness',
    security: 'Security',
    performance: 'Performance',
    readability: 'Readability',
    testing: 'Testing',
    architecture: 'Architecture'
  };

  for (const dim of dimensions) {
    const dimFindings = findings.filter(f => f.dimension === dim);
    if (dimFindings.length === 0) continue;
    
    report += `### ${dimensionNames[dim]}

`;
    
    for (const finding of dimFindings) {
      report += `#### ${severityEmoji[finding.severity]} [${finding.id}] ${finding.category}

- **Severity**: ${finding.severity.toUpperCase()}
- **File**: \`${finding.file}\`${finding.line ? `:${finding.line}` : ''}
- **Description**: ${finding.description}
`;
      
      if (finding.code_snippet) {
        report += `
\`\`\`
${finding.code_snippet}
\`\`\`
`;
      }
      
      report += `
**Recommendation**: ${finding.recommendation}
`;
      
      if (finding.fix_example) {
        report += `
**Fix Example**:
\`\`\`
${finding.fix_example}
\`\`\`
`;
      }
      
      report += `
---

`;
    }
  }

  report += `
## Review Recommendations

### Must Fix

${stats.critical + stats.high > 0 
  ? `Found ${stats.critical} critical issues and ${stats.high} high-priority issues. These should be fixed before merging.`
  : 'No issues requiring immediate fixes were found.'}

### Should Fix

${stats.medium > 0 
  ? `Found ${stats.medium} medium-priority issues. These should be improved in a later iteration.`
  : 'Code quality is good, with no obvious areas requiring improvement.'}

### Nice to Have

${stats.low + stats.info > 0 
  ? `Found ${stats.low + stats.info} low-priority suggestions. Handle them according to team standards.`
  : 'No additional suggestions.'}

---

*Report generated at: ${new Date().toISOString()}*
`;

  return report;
}
```

## State Updates

```javascript
return {
  stateUpdates: {
    report_generated: true,
    report_path: reportPath,
    summary: {
      total_issues: totalCount,
      critical: criticalCount,
      high: highCount,
      medium: mediumCount,
      low: lowCount,
      info: infoCount,
      review_duration_ms: duration
    }
  }
};
```

## Output

- **File**: `review-report.md`
- **Location**: `${workDir}/review-report.md`
- **Format**: Markdown

## Error Handling

| Error Type | Recovery |
|------------|----------|
| Write failure | Try a fallback location |
| Template error | Use a simplified format |

## Next Actions

- Success: action-complete
