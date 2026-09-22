# Hypothesis Verdict Format

Structured output of one hypothesis-investigator agent. Written to `hypotheses/<id>.json` (or returned verbatim when the agent lacks file access).

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Hypothesis Verdict",
  "type": "object",
  "required": [
    "hypothesis_id",
    "label",
    "verdict",
    "confidence",
    "supporting_evidence",
    "contradicting_evidence",
    "missing_evidence",
    "falsification_attempts",
    "one_line_summary"
  ],
  "properties": {
    "hypothesis_id": { "type": "string", "pattern": "^H[0-9]+$" },
    "label": { "type": "string", "description": "Verbatim from the dispatch set" },
    "verdict": { "type": "string", "enum": ["SUPPORTED", "REFUTED", "INSUFFICIENT"] },
    "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
    "supporting_evidence": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["ref", "observation"],
        "properties": {
          "ref": { "type": "string", "description": "Path listed in evidence-index.json" },
          "observation": { "type": "string" }
        }
      }
    },
    "contradicting_evidence": { "type": "array", "items": { "$ref": "#/properties/supporting_evidence/items" } },
    "missing_evidence": {
      "type": "array",
      "items": { "type": "string", "description": "Specific data that would decide the verdict" }
    },
    "falsification_attempts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["attempted", "result"],
        "properties": {
          "attempted": { "type": "string" },
          "result": { "type": "string", "enum": ["failed-to-falsify", "falsified", "inconclusive"] }
        }
      }
    },
    "one_line_summary": { "type": "string" }
  }
}
```

## Rules

- `verdict: SUPPORTED` requires ≥1 supporting ref and ≥1 `failed-to-falsify` attempt. A verdict with zero falsification attempts is invalid regardless of evidence.
- `verdict: REFUTED` requires ≥1 contradicting ref.
- Every `ref` must resolve against `evidence-index.json`. Verdicts citing unindexed files are discarded by the synthesizer.
- Confidence ≥ 0.8 needs ≥2 independent supporting refs.
