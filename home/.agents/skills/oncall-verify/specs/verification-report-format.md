# Verification Report Format

The observation record and verdict. Written to `verification.json` + `verification.md`.

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Recovery Verification",
  "type": "object",
  "required": [
    "incident_id",
    "bundle_path",
    "generated_at",
    "mitigation_ref",
    "watchlist",
    "window",
    "observations",
    "verdict",
    "verdict_reasoning",
    "next_action",
    "completion_status"
  ],
  "properties": {
    "incident_id": { "type": "string" },
    "bundle_path": { "type": "string" },
    "generated_at": { "type": "string", "format": "date-time" },
    "mitigation_ref": { "type": "string", "description": "mitigation.json + selected option id" },
    "watchlist": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["signal", "source", "baseline", "target", "role"],
        "properties": {
          "signal": { "type": "string", "description": "e.g. checkout-api p99 latency" },
          "source": { "type": "string", "description": "Datadog query or monitor name" },
          "baseline": { "type": "string", "description": "Pre-mitigation value from the frozen bundle" },
          "target": { "type": "string", "description": "Threshold that means recovered" },
          "role": { "type": "string", "enum": ["primary", "guardrail"] }
        }
      }
    },
    "window": {
      "type": "object",
      "required": ["started_at", "duration_minutes", "cadence_minutes"],
      "properties": {
        "started_at": { "type": "string", "format": "date-time", "description": "Mitigation execution time + time_to_verify offset" },
        "duration_minutes": { "type": "integer", "minimum": 10 },
        "cadence_minutes": { "type": "integer", "minimum": 1 }
      }
    },
    "observations": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["at", "values", "note"],
        "properties": {
          "at": { "type": "string", "format": "date-time" },
          "values": { "type": "object", "description": "signal → sampled value" },
          "note": { "type": "string" }
        }
      }
    },
    "verdict": {
      "type": "string",
      "enum": ["RECOVERING", "VERIFIED", "NOT_RECOVERED", "SIDE_EFFECTS"]
    },
    "verdict_reasoning": { "type": "string", "description": "Cites observations against baselines/targets" },
    "abort_condition_met": { "type": ["boolean", "null"] },
    "next_action": {
      "type": "string",
      "enum": ["oncall-postmortem", "oncall-mitigate", "continue-observing"]
    },
    "completion_status": { "type": "string", "enum": ["DONE", "DONE_WITH_CONCERNS", "BLOCKED", "NEEDS_CONTEXT"] }
  }
}
```

## Verdict Rules

- `VERIFIED` requires: window complete AND every `primary` signal at/under target at the final sample AND no `guardrail` signal newly breaching. One good sample mid-window is never sufficient.
- `NOT_RECOVERED` when: window complete with primaries flat/worse, or `abort_condition_met` is true (early exit allowed — abort conditions exist to be honored fast).
- `SIDE_EFFECTS` when primaries recover but guardrails (or unlisted signals on the affected service) degrade — the mitigation traded one symptom for another.
- `RECOVERING` only as an in-flight status; final reports carry one of the other three.

## Example (abridged)

```json
{
  "incident_id": "P8XYZ12",
  "bundle_path": "/Users/therealcisse/.incidents/P8XYZ12",
  "generated_at": "2026-09-21T18:20:00Z",
  "mitigation_ref": "mitigation.json option A",
  "watchlist": [
    { "signal": "checkout-api p99 latency", "source": "avg:checkout.api.latency.p99{env:prod}", "baseline": "4.7s", "target": "< 1.5s for 15m", "role": "primary" },
    { "signal": "checkout-api 5xx rate", "source": "avg:checkout.api.errors.5xx{env:prod}", "baseline": "0.1%", "target": "< 0.5%", "role": "guardrail" }
  ],
  "window": { "started_at": "2026-09-21T17:52:00Z", "duration_minutes": 30, "cadence_minutes": 5 },
  "observations": [
    { "at": "2026-09-21T17:57:00Z", "values": { "checkout-api p99 latency": "3.9s", "checkout-api 5xx rate": "0.1%" }, "note": "early sample" },
    { "at": "2026-09-21T18:20:00Z", "values": { "checkout-api p99 latency": "1.1s", "checkout-api 5xx rate": "0.1%" }, "note": "final sample, stable 3 consecutive" }
  ],
  "verdict": "VERIFIED",
  "verdict_reasoning": "Primary at 1.1s vs 1.5s target, stable across final 3 samples; guardrail unchanged from baseline.",
  "abort_condition_met": false,
  "next_action": "oncall-postmortem",
  "completion_status": "DONE"
}
```
