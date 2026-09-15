# Action: Complete

Complete the review and save the final state.

## Purpose

End the code review workflow:
- Save the final state
- Output the review summary
- Provide the report path

## Preconditions

- [ ] state.status === 'running'
- [ ] state.report_generated === true

## Execution

```javascript
async function execute(state, workDir) {
  // 1. Calculate review duration.
  const duration = Date.now() - new Date(state.started_at).getTime();
  const durationMinutes = Math.round(duration / 60000);
  
  // 2. Generate the final summary.
  const summary = {
    ...state.summary,
    review_duration_ms: duration,
    completed_at: new Date().toISOString()
  };
  
  // 3. Save the final state.
  const finalState = {
    ...state,
    status: 'completed',
    completed_at: summary.completed_at,
    summary: summary
  };
  
  Write(`${workDir}/state.json`, JSON.stringify(finalState, null, 2));
  
  // 4. Output summary information.
  console.log('========================================');
  console.log('        CODE REVIEW COMPLETED');
  console.log('========================================');
  console.log('');
  console.log(`📁 Review target: ${state.context.target_path}`);
  console.log(`📄 File count: ${state.context.file_count}`);
  console.log(`📝 Lines of code: ${state.context.total_lines}`);
  console.log('');
  console.log('--- Issue Statistics ---');
  console.log(`🔴 Critical: ${summary.critical}`);
  console.log(`🟠 High:     ${summary.high}`);
  console.log(`🟡 Medium:   ${summary.medium}`);
  console.log(`🔵 Low:      ${summary.low}`);
  console.log(`⚪ Info:     ${summary.info}`);
  console.log(`📊 Total:    ${summary.total_issues}`);
  console.log('');
  console.log(`⏱️  Review duration: ${durationMinutes} minutes`);
  console.log('');
  console.log(`📋 Report path: ${state.report_path}`);
  console.log('========================================');
  
  // 5. Return state updates.
  return {
    stateUpdates: {
      status: 'completed',
      completed_at: summary.completed_at,
      summary: summary
    }
  };
}
```

## State Updates

```javascript
return {
  stateUpdates: {
    status: 'completed',
    completed_at: new Date().toISOString(),
    summary: {
      total_issues: state.summary.total_issues,
      critical: state.summary.critical,
      high: state.summary.high,
      medium: state.summary.medium,
      low: state.summary.low,
      info: state.summary.info,
      review_duration_ms: duration
    }
  }
};
```

## Output

- **Console**: Review completion summary
- **State**: Final state saved to `state.json`

## Error Handling

| Error Type | Recovery |
|------------|----------|
| State save failure | Output to console |

## Next Actions

- None, terminal state

## Post-Completion

The user can:
1. View the full report: `cat ${workDir}/review-report.md`
2. View issue details: `cat ${workDir}/findings/*.json`
3. Export the report to another location
