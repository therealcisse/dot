# Phase 1: Resolve Input

Turn the user's input into a bound incident identity and an initialized evidence bundle.

## Objective

- Parse the input: PagerDuty incident ID, PD URL, or free-text symptom description
- Bind to an existing PD incident when confidently possible; otherwise open a synthetic ID
- Create the bundle skeleton at `~/.incidents/<incident-id>/`
- Record the raw input and the resolution decision in `input.json`

## Execution Steps

### Step 1: Classify the Input

| Input shape | Handling |
|-------------|----------|
| PD incident URL (`.../incidents/<ID>`) | Extract ID, bind directly |
| Bare PD incident ID (short uppercase alphanum) | Bind directly |
| Free text (symptom description) | Step 2 |

### Step 2: Free-Text Resolution

Search PagerDuty (via `pagerduty` MCP) for incidents in the last 24 hours matching service keywords in the text:

- Exactly one confident match → bind it, set `input_mode: free_text_bound`, note the match in `input.json`
- Multiple plausible matches or none → do **not** guess. Open a synthetic ID, set `input_mode: free_text_synthetic`, and flag `no_pd_incident: true`

Wrong binding is worse than no binding; a synthetic bundle is always safe.

### Step 3: Synthetic ID (when unbound)

Format: `adhoc-YYYYMMDD-HHMMSS-<slug>` where `<slug>` is 3–6 hyphenated keywords from the input (e.g. `checkout-latency-p99`).

### Step 4: Create Bundle Skeleton

```bash
mkdir -p ~/.incidents/<incident-id>/{monitors,deployments,known-incidents}
```

### Step 5: Write input.json

```json
{
  "raw_input": "<verbatim>",
  "input_mode": "pd_incident | free_text_bound | free_text_synthetic",
  "bound_incident_id": "<id or null>",
  "match_rationale": "<why bound, or why synthetic>",
  "resolved_at": "<ISO-8601 UTC>"
}
```

Initialize `timeline.json` as `{"events": []}` — every phase appends `{ "at", "phase", "event" }` entries.

## Output

- `~/.incidents/<incident-id>/` skeleton with `input.json` and `timeline.json`

## Gate

- If free text names no service and no symptom class → status **NEEDS_CONTEXT**, stop and ask the user.
- If input is a PD ID but fetch in Phase 2 shows no such incident → status **BLOCKED**.

## Next Phase

Proceed to [Phase 2: Incident Context](02-incident-context.md).
