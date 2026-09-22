# STACK.md — Bindings Template for oncall-triage

The semantic layer between the skill and the MCP transport. MCP servers own *how* to talk to each system; the bindings own *what things are called* in your environment. Never edit SKILL.md or phase files for mapping changes.

This file is the **template and contract only**. Real service names never go in this repo.

## Local Bindings Overlay (work-safe)

Phases resolve bindings in this order:

1. `~/.config/oncall/stack.md` — your real mappings (this machine only, never in the dot repo)
2. This file — template with EXAMPLE rows; any lookup that falls through to it yields `unmapped`

To set up: copy this file to `~/.config/oncall/stack.md` and replace the EXAMPLE rows. The local file may add or remove sections, but keep the table shapes — phases parse by header.

Graduated incident lessons follow the same split: work-specific references live in `~/.config/oncall/references/`; only sanitized, non-work-specific lessons belong in this skill's `references/` directory.

Neither file contains credentials. Auth lives in each harness's MCP config.

## MCP Server Aliases

The skill refers to servers by these aliases. Each harness must wire an MCP server under the matching name.

| Alias | Scope required | Notes |
|-------|----------------|-------|
| `pagerduty` | read + add-note | Never grant ack/resolve for triage |
| `datadog` | read-only keys | Monitors, metrics query, service catalog |
| `spinnaker` | read-only | Execution history only; no trigger scope |
| `aws` | read-only role | Health + describe only |
| `teams` | send-message | Webhook held by the MCP server, not here |

## Service Map

One row per PagerDuty service. This is the core mapping: given the paged service, the skill knows which Datadog monitors and Spinnaker apps belong to it.

| pd_service | datadog_service | monitor_tags | spinnaker_apps | owner | notes |
|------------|-----------------|--------------|----------------|-------|-------|
| EXAMPLE-checkout-api | checkout-api | `service:checkout-api` | checkout-api, checkout-worker | payments | EXAMPLE ROW — replace |
| EXAMPLE-edge-gateway | edge-gateway | `service:edge-gateway` | edge-gateway | platform | EXAMPLE ROW — replace |

Rows marked EXAMPLE are the shape contract. Replace them in `~/.config/oncall/stack.md`, not here. A paged service with no row in the local overlay yields `DONE_WITH_CONCERNS` with `mcp_coverage.spinnaker = "unmapped"`.

## Environments

| Env | Datadog site | Spinnaker account | Notes |
|-----|--------------|-------------------|-------|
| prod | EXAMPLE: datadoghq.com | EXAMPLE: prod-aws | EXAMPLE ROW — replace |

## Recovery Hints

Per alert class, the metric that means "recovered" — used by the future verification skill, recorded at triage so the contract exists from incident start.

| Alert class | Recovery signal |
|-------------|-----------------|
| high-latency | EXAMPLE: p99 latency below monitor threshold for 15m |
| error-rate | EXAMPLE: 5xx rate back within 2σ of 7-day baseline |
| saturation | EXAMPLE: utilization below 70% for 15m |

## Teams

| Purpose | Channel (name, not webhook) |
|---------|------------------------------|
| Incident broadcasts | EXAMPLE: "Incident Response" |

## Maintenance Rules

All of these apply to `~/.config/oncall/stack.md`:

- Keep mappings alphabetical by `pd_service` once there are more than ten rows.
- When a service is renamed in any system, update the row in the local overlay immediately.
- If a triage run reports an unmapped service, add the row before the next run.
- Never copy real rows back into this template or anywhere in the dot repo.
