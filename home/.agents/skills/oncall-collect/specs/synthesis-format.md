# Synthesis Format

Merged output of all hypothesis verdicts. Written to `synthesis.json` + `synthesis.md`. This is the gate input for `oncall-mitigate`.

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Incident Synthesis",
  "type": "object",
  "required": [
    "incident_id",
    "bundle_path",
    "generated_at",
    "based_on",
    "hypothesis_verdicts",
    "ranking",
    "leading_hypothesis",
    "conflicts",
    "missing_evidence",
    "recommended_focus",
    "coverage",
    "next_action",
    "completion_status"
  ],
  "properties": {
    "incident_id": { "type": "string" },
    "bundle_path": { "type": "string" },
    "generated_at": { "type": "string", "format": "date-time" },
    "based_on": {
      "type": "object",
      "properties": {
        "triage": { "type": "string", "description": "triage.json" },
        "evidence_index": { "type": "string", "description": "evidence-index.json with frozen_at" },
        "verdicts": { "type": "array", "items": { "type": "string" } }
      }
    },
    "hypothesis_verdicts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "label", "verdict", "confidence", "key_evidence"],
        "properties": {
          "id": { "type": "string" },
          "label": { "type": "string" },
          "verdict": { "type": "string", "enum": ["SUPPORTED", "REFUTED", "INSUFFICIENT"] },
          "confidence": { "type": "number" },
          "key_evidence": { "type": "array", "items": { "type": "string" } }
        }
      }
    },
    "ranking": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Hypothesis IDs ordered: SUPPORTED by confidence, then INSUFFICIENT, then REFUTED"
    },
    "leading_hypothesis": {
      "type": ["string", "null"],
      "description": "ID of the top SUPPORTED hypothesis; null when none is supported"
    },
    "conflicts": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Where verdicts tension: e.g. H1 and H2 both supported but imply different mechanisms"
    },
    "missing_evidence": { "type": "array", "items": { "type": "string" } },
    "recommended_focus": {
      "type": "string",
      "description": "What mitigation planning should anchor on; correlation wording still applies"
    },
    "coverage": { "type": "object", "description": "Copied from evidence-index.json" },
    "next_action": { "type": "string", "const": "oncall-mitigate" },
    "completion_status": { "type": "string", "enum": ["DONE", "DONE_WITH_CONCERNS"] }
  }
}
```

## Synthesizer Rules

1. Discard verdicts citing refs absent from the evidence index; note the discard.
2. `leading_hypothesis` is null unless at least one verdict is `SUPPORTED` with confidence ≥ 0.5.
3. Rank: `SUPPORTED` (by confidence desc), `INSUFFICIENT` (by closeness to decidable), `REFUTED` last.
4. Surface conflicts explicitly — two supported hypotheses with incompatible mechanisms is a finding, not a problem to bury.
5. `recommended_focus` describes where evidence points, using correlation wording. It is input to mitigation planning, not a decision.
6. Do not propose mitigations, rollbacks, or commands. That is `oncall-mitigate`'s job.

## Example (abridged)

```json
{
  "incident_id": "P8XYZ12",
  "bundle_path": "/Users/therealcisse/.incidents/P8XYZ12",
  "generated_at": "2026-09-21T16:10:00Z",
  "based_on": { "triage": "triage.json", "evidence_index": "evidence-index.json", "verdicts": ["hypotheses/H1.json", "hypotheses/H2.json"] },
  "hypothesis_verdicts": [
    { "id": "H1", "label": "v2.14.3 regression", "verdict": "REFUTED", "confidence": 0.7, "key_evidence": ["metrics/checkout-p99.json: latency degraded before deploy completed"] },
    { "id": "H2", "label": "downstream payment latency", "verdict": "SUPPORTED", "confidence": 0.82, "key_evidence": ["traces/payment-span.json", "metrics/checkout-p99.json"] }
  ],
  "ranking": ["H2", "H1"],
  "leading_hypothesis": "H2",
  "conflicts": [],
  "missing_evidence": ["payment provider status page"],
  "recommended_focus": "Evidence correlates symptom onset with payment-span latency; deployment timeline contradicts H1.",
  "coverage": { "metrics": "ok", "logs": "ok", "traces": "ok", "cloudtrail": "not-configured" },
  "next_action": "oncall-mitigate",
  "completion_status": "DONE"
}
```
