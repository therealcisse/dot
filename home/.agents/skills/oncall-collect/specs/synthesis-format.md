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
      "description": "Hypothesis IDs ordered: SUPPORTED with assessment UPHELD or DOWNGRADE by effective_confidence, then INSUFFICIENT, then SUPPORTED with assessment OVERTURN, DISCARDED, or NOT_REVIEWED, then REFUTED"
    },
    "leading_hypothesis": {
      "type": ["string", "null"],
      "description": "ID of the top-ranked hypothesis whose verdict is SUPPORTED, whose review assessment is UPHELD or DOWNGRADE, and whose effective_confidence is >= 0.5; null when none qualifies, including when the only SUPPORTED verdicts carry a DISCARDED or NOT_REVIEWED review or the blind-spot check finds a material uncovered mechanism"
    },
    "conflicts": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Where verdicts tension: e.g. H1 and H2 both supported but imply different mechanisms"
    },
    "review_adjustments": {
      "type": "array",
      "description": "Optional in schema, always written by Phase 5. One entry per hypothesis in the dispatch set, derived from hypotheses/H*.review.json",
      "items": {
        "type": "object",
        "required": ["id", "assessment", "original_confidence", "effective_confidence", "key_defect"],
        "properties": {
          "id": { "type": "string" },
          "assessment": { "type": "string", "enum": ["UPHELD", "DOWNGRADE", "OVERTURN", "DISCARDED", "NOT_REVIEWED"] },
          "original_confidence": { "type": "number" },
          "effective_confidence": { "type": "number", "description": "adjusted_confidence when assessment is DOWNGRADE or OVERTURN; otherwise original_confidence" },
          "key_defect": { "type": ["string", "null"] }
        }
      }
    },
    "uncovered_mechanism": {
      "type": ["string", "null"],
      "description": "Blind-spot check result: one correlation-worded sentence when the aggregated evidence points to a mechanism no dispatched hypothesis covers; null otherwise"
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
2. `leading_hypothesis` is null unless at least one verdict is `SUPPORTED`, its review assessment is `UPHELD` or `DOWNGRADE`, and its `effective_confidence` ≥ 0.5.
3. Rank: `SUPPORTED` with assessment `UPHELD` or `DOWNGRADE` (by `effective_confidence` desc), `INSUFFICIENT` (by closeness to decidable), `SUPPORTED` with assessment `OVERTURN`, `DISCARDED`, or `NOT_REVIEWED`, `REFUTED` last.
4. Discard reviews citing refs absent from the evidence index (`defects[].ref`, `overlooked_evidence`); note the discard. The verdict itself stands and is recorded as `DISCARDED` in `review_adjustments`.
5. `effective_confidence` = `adjusted_confidence` when the review's `assessment` is `DOWNGRADE` or `OVERTURN`; otherwise the verdict's original confidence. `review_adjustments` carries one entry per hypothesis in the dispatch set; a hypothesis with no valid review is `NOT_REVIEWED` at its original confidence.
6. A `SUPPORTED` verdict whose review is `DISCARDED` or `NOT_REVIEWED` is not eligible to lead. Note it in `synthesis.md` and set `completion_status: DONE_WITH_CONCERNS`.
7. Blind-spot check, after ranking: do the reviews' `overlooked_evidence`, recurring `missing_evidence`, Phase 2 emergent candidates, and indexed files no verdict cited point to a mechanism no dispatched hypothesis covers? Yes → `uncovered_mechanism` is one correlation-worded sentence; if it is material to the leading hypothesis, set `leading_hypothesis` to null and say why in `synthesis.md`. No → `uncovered_mechanism: null`.
8. Surface conflicts explicitly — two supported hypotheses with incompatible mechanisms is a finding, not a problem to bury.
9. `recommended_focus` describes where evidence points, using correlation wording. It is input to mitigation planning, not a decision.
10. Do not propose mitigations, rollbacks, or commands. That is `oncall-mitigate`'s job.

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
  "review_adjustments": [
    { "id": "H2", "assessment": "UPHELD", "original_confidence": 0.82, "effective_confidence": 0.82, "key_defect": null },
    { "id": "H1", "assessment": "NOT_REVIEWED", "original_confidence": 0.7, "effective_confidence": 0.7, "key_defect": null }
  ],
  "uncovered_mechanism": null,
  "missing_evidence": ["payment provider status page"],
  "recommended_focus": "Evidence correlates symptom onset with payment-span latency; deployment timeline contradicts H1.",
  "coverage": { "metrics": "ok", "logs": "ok", "traces": "ok", "cloudtrail": "not-configured" },
  "next_action": "oncall-mitigate",
  "completion_status": "DONE"
}
```
