# Phase 2: Incident Context

Pull and normalize the PagerDuty incident. This anchors every later time window.

## Objective

- Fetch incident, alerts, service, urgency, escalation state, and recent notes via `pagerduty` MCP
- Normalize into `incident.json`
- Establish `impact_started_at` anchor (earliest alert creation time)
- Read-only: never ack, resolve, or update the incident here

## Execution Steps

### Step 1: Fetch Incident

Via `pagerduty` MCP read tools: incident detail, all linked alerts, service, escalation policy, assignees, first/recent notes.

### Step 2: Normalize into incident.json

```json
{
  "id": "<PD id or synthetic>",
  "title": "...",
  "status": "triggered|acknowledged|resolved",
  "urgency": "high|low",
  "service": { "name": "...", "pd_service_id": "..." },
  "created_at": "...",
  "impact_started_at": "<earliest alert creation, else incident created_at>",
  "alerts": [
    { "id": "...", "summary": "...", "created_at": "...", "status": "...", "dedup_key": "...", "tags": ["..."] }
  ],
  "assignees": ["..."],
  "recent_notes": ["..."],
  "fetched_at": "..."
}
```

### Step 3: Look Up Service Mapping

Resolve bindings from the **local overlay first**: `~/.config/oncall/stack.md` (real mappings, work-safe, never in the dot repo). The in-repo [STACK.md](../STACK.md) is template only — rows there count as unmapped. Find the row whose `pd_service` matches (case-insensitive).

- Local overlay missing entirely → note it and treat as unmapped; the first run should start by creating the overlay from the template
- Found → carry `datadog_service`, `monitor_tags`, `spinnaker_apps` forward
- Not found → set `mcp_coverage.spinnaker = "unmapped"` and continue; Datadog queries fall back to the PD service name as a tag guess, flagged low confidence

### Step 4: Append Timeline

Append to `timeline.json`: incident fetched, mapping resolution result.

## Output

- `incident.json` in the bundle
- `impact_started_at` anchor for Phase 3 and 4 windows

## Quality Checks

- [ ] No state-changing PD call was made
- [ ] All alert timestamps normalized to ISO-8601 UTC
- [ ] Mapping outcome recorded either way

## Next Phase

Proceed to [Phase 3: Monitor Sweep](03-monitor-sweep.md).
