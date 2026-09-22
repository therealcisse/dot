# Mitigation Plan Format

The decision + execution record for one incident. Written to `mitigation.json` + `mitigation.md`. Gate input for `oncall-verify`.

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Mitigation Plan",
  "type": "object",
  "required": [
    "incident_id",
    "bundle_path",
    "generated_at",
    "based_on_synthesis",
    "basis_quality",
    "options",
    "recommended",
    "approval",
    "execution",
    "next_action",
    "completion_status"
  ],
  "properties": {
    "incident_id": { "type": "string" },
    "bundle_path": { "type": "string" },
    "generated_at": { "type": "string", "format": "date-time" },
    "based_on_synthesis": { "type": "string", "description": "synthesis.json this plan derives from" },
    "basis_quality": {
      "type": "string",
      "enum": ["leading-hypothesis", "no-leading-hypothesis"],
      "description": "Whether synthesis carried a leading hypothesis"
    },
    "options": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "action", "type", "expected_effect", "risk", "time_to_verify", "abort_condition", "undo", "irreversible", "execution"],
        "properties": {
          "id": { "type": "string", "pattern": "^[A-D]$" },
          "action": { "type": "string", "description": "Imperative one-liner, e.g. 'rollback checkout-api to v2.14.2'" },
          "type": { "type": "string", "enum": ["rollback", "scale", "config-revert", "feature-flag", "other"] },
          "expected_effect": { "type": "string" },
          "risk": { "type": "string" },
          "time_to_verify": { "type": "string", "description": "How long until the watchlist should react" },
          "abort_condition": { "type": "string", "description": "What the human/verifier should see to abandon this path" },
          "undo": { "type": "string", "description": "How to reverse it, or 'irreversible'" },
          "irreversible": { "type": "boolean" },
          "execution": {
            "type": "object",
            "required": ["mode"],
            "properties": {
              "mode": { "type": "string", "enum": ["human-commands", "mcp", "manual-only"] },
              "commands": { "type": "array", "items": { "type": "string" }, "description": "Exact commands for human execution" },
              "tool_call": { "type": "string", "description": "MCP server alias + tool + args, when mode is mcp" }
            }
          }
        }
      }
    },
    "recommended": { "type": "string", "description": "Option ID + one-line why" },
    "approval": {
      "type": "object",
      "required": ["required"],
      "properties": {
        "required": { "type": "boolean" },
        "selected": { "type": ["string", "null"] },
        "approved_by": { "type": ["string", "null"] },
        "approved_at": { "type": ["string", "null"], "format": "date-time" },
        "second_confirmation": { "type": "boolean", "description": "True when irreversible option was double-confirmed" }
      }
    },
    "execution": {
      "type": "object",
      "properties": {
        "executed_at": { "type": "string", "format": "date-time" },
        "mode": { "type": "string" },
        "result": { "type": "string" },
        "executed_by": { "type": "string", "description": "human | agent | dry-run" }
      }
    },
    "next_action": { "type": "string", "const": "oncall-verify" },
    "completion_status": { "type": "string", "enum": ["DONE", "DONE_WITH_CONCERNS", "BLOCKED", "NEEDS_CONTEXT"] }
  }
}
```

## Field Rules

- Options must trace to synthesis verdicts and bundle evidence (`deployments/changes.json` for rollbacks). An option with no evidentiary basis is invalid.
- `approval.selected` stays null until a human names the option ID in-conversation; DRY_RUN writes `"dry-run"` and `executed_by: "dry-run"`.
- `time_to_verify` and `abort_condition` feed `oncall-verify`'s watchlist directly — write them for the verifier, not for prose.
- Rollback targets: prefer the last-known-good artifact recorded in `deployments/executions.json`; state the version explicitly in `action`.
