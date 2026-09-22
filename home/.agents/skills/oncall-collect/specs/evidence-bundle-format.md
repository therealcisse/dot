# Evidence Bundle Format

The full layout of `~/.incidents/<incident-id>/` across the on-call skill chain. `oncall-triage` creates the skeleton; `oncall-collect` deepens and freezes it; `oncall-mitigate`, `oncall-verify`, and `oncall-postmortem` append their artifacts.

## Layout

```
~/.incidents/<incident-id>/
  input.json              # triage: raw input + resolution
  incident.json           # triage: normalized PD incident + alerts
  timeline.json           # append-only across all skills
  monitors/               # triage: firing.json, dependencies.json, aws-health.json
  deployments/            # triage: executions.json, changes.json
  known-incidents/        # triage: history.json, reference-hits.json
  metrics/                # collect: <symptom-slug>.json per queried signal
  logs/                   # collect: error/warning samples around onset
  traces/                 # collect: APM slow/error traces
  cloudtrail/             # collect: AWS API activity in window
  evidence-index.json     # collect: frozen manifest
  hypotheses/H*.json      # collect: verdicts, one per hypothesis
  synthesis.json/.md      # collect: merged verdicts + ranking
  mitigation.json/.md     # mitigate: options, approval record, execution record
  verification.json/.md   # verify: watchlist, observations, verdict
  postmortem.json/.md     # postmortem: RCA artifact
```

## File Naming

- Evidence files: kebab-case slugs derived from content (`metrics/checkout-p99.json`, `logs/checkout-errors.json`).
- Timestamps inside files: ISO-8601 UTC.
- No credentials ever. Redact tokens/PII when writing log samples.

## evidence-index.json

```json
{
  "incident_id": "...",
  "frozen_at": "...",
  "window": { "from": "impact_started_at - 60m", "to": "freeze time" },
  "coverage": {
    "metrics": "ok | degraded | unavailable",
    "logs": "ok | degraded | unavailable",
    "traces": "ok | degraded | unavailable | not-configured",
    "cloudtrail": "ok | degraded | unavailable | not-configured"
  },
  "files": [
    { "path": "metrics/checkout-p99.json", "sha256": "...", "collected_at": "...", "note": "optional" }
  ]
}
```

Rules:

- Every file present at freeze time is listed. Files listed must exist; files existing must be listed.
- After freeze, investigators treat the index as the complete admissible evidence set. The orchestrator may still append *new* post-freeze evidence only by re-running collection (new index version, noted in `frozen_at`).
- `sha256` computed at freeze (`shasum -a 256` or equivalent).

## Freeze Semantics

"Frozen" is a contract, not a filesystem flag: after `evidence-index.json` exists, hypothesis agents read only indexed files. Mitigation and verification skills read the bundle but do not modify frozen files; they append their own artifacts.
