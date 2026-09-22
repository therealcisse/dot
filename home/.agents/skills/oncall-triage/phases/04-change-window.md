# Phase 4: Change Window

Build the change timeline around symptom onset. Correlation only — this phase never asserts causation.

## Objective

- Query Spinnaker (via `spinnaker` MCP, read-only) for pipeline executions of the mapped `spinnaker_apps` in the window **T-60m → T+10m**, where T = `impact_started_at` from `incident.json`
- Record what changed, when, and who triggered it
- Write normalized `deployments/executions.json` and `deployments/changes.json`

## The Rule (verbatim, non-negotiable)

> A change occurring before an incident is evidence, not proof of causation.

Every summary sentence written by this phase uses "correlates with" wording. Never "caused", never "explains".

## Execution Steps

### Step 1: Query Executions

For each mapped app: pipeline executions with start time in the window. Record: app, pipeline name, status (succeeded/failed/canceled/running), started_at, ended_at, triggered_by, artifact/version if present in the execution context.

Failed or rolled-back executions in the window are **more** interesting than clean ones — flag them.

Write raw normalized results to `deployments/executions.json`.

### Step 2: Derive Changes for the Report

For each execution that changed running state in the window, produce a report-ready entry:

```json
{
  "type": "deployment",
  "summary": "checkout-api v2.14.3 deployed to prod",
  "at": "2026-09-21T14:31:00Z",
  "source": "spinnaker",
  "evidence_ref": "deployments/executions.json"
}
```

Config-type changes visible in execution context (e.g. a pipeline parameterizing a config push) get `type: "config"`.

Write `deployments/changes.json`.

### Step 3: Coverage Handling

| Situation | Handling |
|-----------|----------|
| No STACK.md mapping | `mcp_coverage.spinnaker = "unmapped"`; recent_changes will be empty — say so in the report |
| Spinnaker server unavailable | `mcp_coverage.spinnaker = "unavailable"`; continue |
| Window contains zero executions | Record `"changes": []` explicitly — absence of change is itself evidence |

## Output

- `deployments/executions.json`, `deployments/changes.json`
- Append timeline entries for the window query

## Quality Checks

- [ ] No pipeline was triggered, cancelled, or retried
- [ ] Window anchored on `impact_started_at`, not "now"
- [ ] Empty result recorded as evidence, not skipped

## Next Phase

Proceed to [Phase 5: Known-Incident Lookup](05-known-incidents.md).
