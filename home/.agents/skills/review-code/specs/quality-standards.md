# Quality Standards

Code review quality standards.

## When to Use

| Phase | Usage | Section |
|-------|-------|---------|
| action-generate-report | Quality assessment | Quality Dimensions |
| action-complete | Final scoring | Quality Gates |

---

## Quality Dimensions

### 1. Completeness - 25%

**Assess how complete the review coverage is.**

| Score | Criteria |
|-------|----------|
| 100% | All dimensions reviewed and all high-risk files checked |
| 80% | Core dimensions completed and main files checked |
| 60% | Some dimensions completed |
| < 60% | Review is incomplete |

**Checkpoints**:
- [ ] All 6 dimensions reviewed
- [ ] High-risk areas reviewed with extra focus
- [ ] Critical files covered

---

### 2. Accuracy - 25%

**Assess how accurate the findings are.**

| Score | Criteria |
|-------|----------|
| 100% | Issues are located accurately, classified correctly, and have no false positives |
| 80% | Occasional classification deviation, but locations are accurate |
| 60% | False positives or missed issues exist |
| < 60% | Poor accuracy |

**Checkpoints**:
- [ ] Issue line numbers are accurate
- [ ] Severity levels are reasonable
- [ ] Classification is correct

---

### 3. Actionability - 25%

**Assess how practical the recommendations are.**

| Score | Criteria |
|-------|----------|
| 100% | Every issue has a specific, executable fix recommendation |
| 80% | Most issues have clear recommendations |
| 60% | Recommendations are too general |
| < 60% | Lacks actionable recommendations |

**Checkpoints**:
- [ ] Specific fix recommendations are provided
- [ ] Code examples are included
- [ ] Fix priority is explained

---

### 4. Consistency - 25%

**Assess how consistent the review standards are.**

| Score | Criteria |
|-------|----------|
| 100% | Same issues are handled the same way and standards are unified |
| 80% | Mostly consistent, with occasional differences |
| 60% | Standards are not very consistent |
| < 60% | Standards are inconsistent |

**Checkpoints**:
- [ ] ID format is consistent
- [ ] Severity standards are consistent
- [ ] Description style is consistent

---

## Quality Gates

### Review Quality Gate

| Gate | Overall Score | Action |
|------|---------------|--------|
| **Excellent** | ≥ 90% | High-quality review |
| **Good** | ≥ 80% | Qualified review |
| **Acceptable** | ≥ 70% | Basically acceptable |
| **Needs Improvement** | < 70% | Needs improvement |

### Code Quality Gate (Based on Findings)

| Gate | Condition | Recommendation |
|------|-----------|----------------|
| **Block** | Critical > 0 | Block merge, must fix |
| **Warn** | High > 3 | Requires team discussion |
| **Caution** | Medium > 10 | Recommended improvements |
| **Pass** | Other | Can merge |

---

## Report Quality Checklist

### Structure

- [ ] Includes review overview
- [ ] Includes issue statistics
- [ ] Includes high-risk areas
- [ ] Includes issue details
- [ ] Includes fix recommendations

### Content

- [ ] Issue descriptions are clear
- [ ] File locations are accurate
- [ ] Code snippets are valid
- [ ] Fix recommendations are specific
- [ ] Priorities are clear

### Format

- [ ] Markdown format is correct
- [ ] Tables are aligned
- [ ] Code block syntax is correct
- [ ] Links are valid
- [ ] No spelling errors

---

## Validation Function

```javascript
function validateReviewQuality(state) {
  const scores = {
    completeness: 0,
    accuracy: 0,
    actionability: 0,
    consistency: 0
  };
  
  // 1. Completeness
  const dimensionsReviewed = state.reviewed_dimensions?.length || 0;
  scores.completeness = (dimensionsReviewed / 6) * 100;
  
  // 2. Accuracy (requires manual validation or later feedback)
  // Temporarily estimate based on whether errors exist.
  scores.accuracy = state.error_count === 0 ? 100 : Math.max(0, 100 - state.error_count * 20);
  
  // 3. Actionability
  const findings = Object.values(state.findings).flat();
  const withRecommendations = findings.filter(f => f.recommendation).length;
  scores.actionability = findings.length > 0 
    ? (withRecommendations / findings.length) * 100 
    : 100;
  
  // 4. Consistency (checks ID format, etc.)
  const validIds = findings.filter(f => /^(CORR|SEC|PERF|READ|TEST|ARCH)-\d{3}$/.test(f.id)).length;
  scores.consistency = findings.length > 0 
    ? (validIds / findings.length) * 100 
    : 100;
  
  // Overall
  const overall = (
    scores.completeness * 0.25 +
    scores.accuracy * 0.25 +
    scores.actionability * 0.25 +
    scores.consistency * 0.25
  );
  
  return {
    scores,
    overall,
    gate: overall >= 90 ? 'excellent' :
          overall >= 80 ? 'good' :
          overall >= 70 ? 'acceptable' : 'needs_improvement'
  };
}
```

---

## Improvement Recommendations

### If Completeness is Low

- Increase the scope of scanned files
- Ensure all dimensions are reviewed
- Focus on high-risk areas

### If Accuracy is Low

- Improve rule precision
- Reduce false positives
- Verify line number accuracy

### If Actionability is Low

- Add fix recommendations for every issue
- Provide code examples
- Explain the fix steps

### If Consistency is Low

- Standardize ID format
- Standardize severity decisions
- Use templated descriptions
