# Postmortem Format

The RCA artifact. Written to `postmortem.json` + `postmortem.md` in the bundle.

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Incident Postmortem",
  "type": "object",
  "required": [
    "incident_id",
    "bundle_path",
    "generated_at",
    "status",
    "summary",
    "severity_final",
    "impact",
    "timeline",
    "root_cause",
    "root_cause_confidence",
    "evidence_chain",
    "contributing_factors",
    "what_went_well",
    "what_went_poorly",
    "corrective_actions",
    "lessons_appended",
    "references_graduated",
    "source_artifacts",
    "completion_status"
  ],
  "properties": {
    "incident_id": { "type": "string" },
    "bundle_path": { "type": "string" },
    "generated_at": { "type": "string", "format": "date-time" },
    "status": { "type": "string", "enum": ["final", "interim"] },
    "summary": { "type": "string", "minLength": 20 },
    "severity_final": { "type": "string" },
    "impact": {
      "type": "object",
      "required": ["started_at", "affected"],
      "properties": {
        "started_at": { "type": "string", "format": "date-time" },
        "ended_at": { "type": ["string", "null"], "format": "date-time" },
        "duration_minutes": { "type": ["integer", "null"] },
        "affected": { "type": "array", "items": { "type": "string" } },
        "user_impact": { "type": "string" }
      }
    },
    "timeline": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["at", "event"],
        "properties": {
          "at": { "type": "string", "format": "date-time" },
          "event": { "type": "string" },
          "source": { "type": "string", "description": "bundle ref or timeline.json" }
        }
      }
    },
    "root_cause": {
      "type": ["string", "null"],
      "description": "Causal, blameless, evidence-chained; null when undetermined"
    },
    "root_cause_confidence": {
      "type": ["string", "null"],
      "enum": ["confirmed", "probable", "undetermined", null]
    },
    "evidence_chain": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Ordered claims, each citing bundle refs, leading to the root cause"
    },
    "contributing_factors": { "type": "array", "items": { "type": "string" } },
    "what_went_well": { "type": "array", "items": { "type": "string" } },
    "what_went_poorly": { "type": "array", "items": { "type": "string" } },
    "corrective_actions": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["action", "priority"],
        "properties": {
          "action": { "type": "string" },
          "priority": { "type": "string", "enum": ["P1", "P2", "P3"] },
          "owner": { "type": ["string", "null"] },
          "tracks_root_cause": { "type": "boolean" }
        }
      }
    },
    "lessons_appended": { "type": "array", "items": { "type": "string" } },
    "references_graduated": { "type": "array", "items": { "type": "string" } },
    "source_artifacts": {
      "type": "object",
      "description": "Which chain artifacts fed this postmortem",
      "properties": {
        "triage": { "type": "boolean" },
        "synthesis": { "type": "boolean" },
        "mitigation": { "type": ["boolean", "null"] },
        "verification": { "type": ["boolean", "null"] }
      }
    },
    "completion_status": { "type": "string", "enum": ["DONE", "DONE_WITH_CONCERNS", "BLOCKED", "NEEDS_CONTEXT"] }
  }
}
```

## Field Rules

- `root_cause` may be null with `root_cause_confidence: "undetermined"` — then `evidence_chain` lists what was established and `contributing_factors`/`corrective_actions` address the gaps.
- Blameless test: no root cause or factor names a person or implies individual fault; conditions and systems carry the causes.
- At least one `P1`/`P2` corrective action must `track_root_cause` when a root cause exists — actions that only treat symptoms are insufficient alone.
- `lessons_appended` records the exact lines added to `~/.config/oncall/lessons.md`.
- `references_graduated` lists files created in `~/.config/oncall/references/` (or the sanitized in-repo `references/`), empty when no graduation threshold was met.
