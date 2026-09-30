# Verdict Review Format

Structured output of one verdict-reviewer agent. Written to `hypotheses/<id>.review.json` (or returned verbatim when the agent lacks file access). Advisory input to synthesis: the reviewer flags, the synthesizer decides.

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Verdict Review",
  "type": "object",
  "required": [
    "hypothesis_id",
    "assessment",
    "defects",
    "overlooked_evidence",
    "one_line_summary"
  ],
  "properties": {
    "hypothesis_id": { "type": "string", "pattern": "^H[0-9]+$" },
    "assessment": { "type": "string", "enum": ["UPHELD", "DOWNGRADE", "OVERTURN"] },
    "adjusted_confidence": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "description": "Present iff assessment is DOWNGRADE or OVERTURN; must be <= the verdict's original confidence"
    },
    "defects": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["type", "detail"],
        "properties": {
          "type": { "type": "string", "enum": ["faithfulness", "rigor", "overlooked", "calibration"] },
          "ref": { "type": "string", "description": "Path listed in evidence-index.json. Optional; a calibration defect may have none" },
          "detail": { "type": "string" }
        }
      }
    },
    "overlooked_evidence": {
      "type": "array",
      "items": { "type": "string", "description": "evidence-index.json path the verdict did not cite but should have" }
    },
    "one_line_summary": { "type": "string" }
  }
}
```

## Rules

- `assessment: OVERTURN` requires either a `faithfulness` defect that removes the verdict's only supporting ref, or ≥1 entry in `overlooked_evidence` that contradicts the verdict.
- `assessment: DOWNGRADE` requires ≥1 defect and `adjusted_confidence` < the verdict's original `confidence`.
- `assessment: UPHELD` has no `adjusted_confidence`.
- `adjusted_confidence` is present iff `assessment` is `DOWNGRADE` or `OVERTURN`, and is ≤ the verdict's original `confidence`. For a `calibration` defect it is the top of the band the cited evidence supports per [confidence-calibration.md](confidence-calibration.md).
- Every `ref` and every `overlooked_evidence` entry must resolve against `evidence-index.json`. Reviews citing unindexed files are discarded by the synthesizer.
- One round only. The reviewer flags, the synthesizer decides; reviewers never re-dispatch or converse with investigators.
