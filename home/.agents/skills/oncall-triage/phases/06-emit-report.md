# Phase 6: Emit Triage Report

Assemble everything gathered into the report. This phase reasons over evidence but produces **no conclusions**.

## Objective

- Build `triage.json` exactly per [specs/triage-report-format.md](../specs/triage-report-format.md)
- Render `triage.md` for humans
- Form 1–5 candidate hypotheses with correlation wording only

## Gate

Phases 1–5 must have written their bundle outputs (`input.json`, `incident.json`, `monitors/*`, `deployments/*`, `known-incidents/*` — empty results count, missing files do not). If a file is missing, go back and run that phase before reporting.

## Execution Steps

### Step 1: Assemble Evidence Fields

- `symptoms`: from the incident's own monitors + PD alert summaries; each carries an `evidence_ref` into the bundle
- `affected_surfaces`: PD service + any dependents flagged in the blast-radius hint
- `impact_started_at`: the anchor from `incident.json`
- `recent_changes`: from `deployments/changes.json`; AWS Health hits are recorded as `type: "infra"` changes
- `mcp_coverage`: as recorded by phases 2–5

### Step 2: Form Hypotheses

Rules:

1. 1–5 hypotheses, labeled `H1..H5`, ranked by evidence weight
2. Each cites ≥1 `evidence_refs` pointer into the bundle
3. `label` is a short noun phrase ("v2.14.3 regression", "downstream payment latency", "consumer lag backpressure") — never a sentence, never a conclusion
4. `rationale` uses correlation wording only. "Deploy at 14:31 correlates with onset at 14:37" — not "deploy caused the incident"
5. Standard candidate classes to consider (skip ones with no evidence): recent-change regression, dependency latency, saturation/resource, config change, platform event (AWS Health), recurring known issue
6. If Phase 5 set `recurrent: true`, previously confirmed causes may be listed as candidates — clearly rationaled on history, not on current evidence

Fewer well-evidenced hypotheses beat many speculative ones. It is fine to emit one.

### Step 3: Severity and Confidence

`severity_suspected` — from symptom evidence: user-facing impact signals (error rate, latency vs. threshold, revenue-path involvement, blast radius expanding). PD urgency is an input, not the answer; disagreement is allowed and noted in `triage.md`.

`evidence_confidence` — high when PD + Datadog + Spinnaker all covered and timestamps agree; low when any server was degraded/unmapped or onset time is uncertain.

### Step 4: Render triage.md

Structure:

```
# Triage: <title>
Severity: <suspected-sev-N> | Started: <impact_started_at> | Incident: <id>

## Affected
## Symptoms
## Recent changes (correlated, not causal)
## Blast radius hint
## Known incidents (recurrence if flagged)
## Initial hypotheses (candidates only)
## Evidence confidence + coverage
No RCA yet. Next step: oncall-collect.
```

The literal line `No RCA yet.` is required. `root_cause` in `triage.json` is schema-enforced `null`.

### Step 5: Write and Append

Write both files into the bundle; append the report event to `timeline.json`.

## Quality Checks

- [ ] Every hypothesis has ≥1 evidence_ref that exists in the bundle
- [ ] No causal wording anywhere in either file
- [ ] `triage.json` validates against the spec schema
- [ ] Coverage honestly reflects degraded/unmapped servers

## Next Phase

Proceed to [Phase 7: Broadcast & Hand Off](07-broadcast-handoff.md).
