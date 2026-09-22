---
name: oncall-triage
description: Bounded, read-only incident triage for PagerDuty + Datadog + Spinnaker + AWS + Teams via MCP. Produces a structured triage report and initializes the incident evidence bundle. No RCA, no mitigation, no ack/resolve. Triggers on "oncall", "triage", "incident", "page", "pagerduty incident", "I got paged".
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Oncall Triage

The front door of the on-call skill set. Turns a PagerDuty incident (or free-text symptom) into a structured triage report and an initialized evidence bundle, then stops. Root-cause investigation, mitigation, and verification belong to later skills (`oncall-collect`, hypothesis investigation, mitigation, verification) and are never performed here.

## Design Principles

1. **Triage, not RCA**: output severity, symptoms, affected surfaces, recent changes, and *candidate* hypotheses only. The report always states "No RCA yet."
2. **Read-only**: every remote call is a read. The only writes are the local bundle, one Teams message, and one optional PagerDuty incident note.
3. **Correlation is evidence, not causation**: a change preceding an incident is recorded as a correlated change, never asserted as the cause.
4. **Bounded**: single context, no subagents, minutes not hours. Depth belongs to `oncall-collect`.
5. **Snapshot now, reason later**: everything gathered is normalized into the bundle so downstream skills and hypothesis agents work from identical, frozen evidence.

## MCP Requirements

This skill requires five MCP servers, wired in the harness MCP config with read-scoped credentials. Server aliases are contracted in [STACK.md](STACK.md).

| Alias | Used for | Write tools used |
|-------|----------|------------------|
| `pagerduty` | Incident, alerts, service, history | note append only (optional) |
| `datadog` | Monitors, metrics query, service catalog | none |
| `spinnaker` | Pipeline execution history | none |
| `aws` | AWS Health events | none |
| `teams` | Triage broadcast (phase 7 only) | send-message only |

If a server is unavailable, mark it `unavailable` in `mcp_coverage` and continue; degraded coverage is reported, not fatal. Never ack, resolve, or trigger anything.

## Execution Flow

```
Phase 1: Resolve Input
  Parse PD incident ID/URL or free-text symptom; bind or open synthetic ID
  Create bundle skeleton at ~/.incidents/<incident-id>/
      |
      v
Phase 2: Incident Context            [pagerduty]
  Alert payload, service, urgency, escalation state, timeline
  Output: incident.json, timeline.json initialized
      |
      v
Phase 3: Monitor Sweep               [datadog, aws]
  Firing/related monitors, service-catalog dependencies, AWS Health
  Output: monitors/, blast-radius hint
      |
      v
Phase 4: Change Window               [spinnaker]
  Pipeline executions T-60m..T+10m for mapped apps
  Output: deployments/. Correlation, never causation.
      |
      v
Phase 5: Known-Incident Lookup       [pagerduty + local references/]
  PD history for the service + graduated lessons in references/
  Output: known-incidents/
      |
      v
Phase 6: Emit Triage Report
  triage.json + triage.md per spec. Severity suspected, hypotheses as
  candidate labels, explicit "No RCA yet".
      |
      v
Phase 7: Broadcast & Hand Off        [teams, pagerduty note]
  One Teams message, optional PD note, then STOP.
  Name next skill (oncall-collect); do not auto-run it.
```

## Evidence Bundle

```
~/.incidents/<incident-id>/
  input.json          # raw input and how it was resolved
  incident.json       # normalized PD incident + alerts
  timeline.json       # append-only triage timeline
  monitors/           # firing + related monitors, dependencies, AWS Health
  deployments/        # Spinnaker executions in the change window
  known-incidents/    # PD history matches + reference hits
  triage.json         # machine-readable report (spec: specs/triage-report-format.md)
  triage.md           # human-readable report
```

## Guardrails (strictly enforced)

- No `ack`, `resolve`, or any state-changing PagerDuty call.
- No Spinnaker pipeline triggers. Read execution history only.
- No mutations to AWS. Health/describe reads only.
- Teams is broadcast-only: send the triage summary; never treat replies, reactions, or card actions as approval for anything.
- STACK.md and bundle files never contain credentials; auth lives in the harness MCP config.
- Real service names, channels, and work identifiers never go in the dot repo: bindings live in `~/.config/oncall/stack.md`, work lessons in `~/.config/oncall/references/`, and evidence bundles in `~/.incidents/` — all outside the repo.
- `DRY_RUN=1` (env) skips both remote writes (Teams message, PD note) — use for replays and testing against production data.
- Hypotheses are labels with evidence pointers. Wording like "the deploy caused the incident" is prohibited; write "deploy of X at 14:31 correlates with symptom onset at 14:37".

## Completion Status Protocol

| Status | When |
|--------|------|
| **DONE** | Report written, broadcast sent (or DRY_RUN logged) |
| **DONE_WITH_CONCERNS** | Report written but one or more MCP servers degraded/unavailable or STACK.md mappings missing |
| **BLOCKED** | Cannot resolve input to any incident and free-text is unactionable |
| **NEEDS_CONTEXT** | Free-text input too ambiguous to begin (no service, no symptom class) |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [STACK.md](STACK.md) | Bindings template + overlay contract; real mappings live at `~/.config/oncall/stack.md` (work-safe, out of repo) |
| [phases/01-resolve-input.md](phases/01-resolve-input.md) | Input parsing and bundle skeleton |
| [phases/02-incident-context.md](phases/02-incident-context.md) | PagerDuty incident normalization |
| [phases/03-monitor-sweep.md](phases/03-monitor-sweep.md) | Datadog monitors, dependencies, AWS Health |
| [phases/04-change-window.md](phases/04-change-window.md) | Spinnaker change correlation |
| [phases/05-known-incidents.md](phases/05-known-incidents.md) | History and lessons lookup |
| [phases/06-emit-report.md](phases/06-emit-report.md) | Report assembly and hypothesis rules |
| [phases/07-broadcast-handoff.md](phases/07-broadcast-handoff.md) | Teams broadcast, PD note, handoff |
| [specs/triage-report-format.md](specs/triage-report-format.md) | triage.json JSON schema |
| [references/](references/) | Graduated incident lessons (populated by postmortem skill) |

## Sub-Agent Integration

None by design. Triage runs in a single context to stay fast and inspectable. Parallel investigation is the job of downstream skills.
