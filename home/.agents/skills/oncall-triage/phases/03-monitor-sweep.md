# Phase 3: Monitor Sweep

Cheap, broad snapshot of what is firing and what depends on what. Blast radius only — no RCA reasoning.

## Objective

- List monitors in alert/warn states relevant to the mapped service (via `datadog` MCP)
- Pull service-catalog dependencies for a blast-radius hint
- Quick AWS Health check: is this an AWS-side event?
- Write everything to `monitors/`

## Execution Steps

### Step 1: Firing Monitors

Query monitors by status (alert, warn) filtered to `monitor_tags` from STACK.md (fallback: PD service name). Record for each: name, status, query summary, threshold, triggered-at, last-triggered duration if cheap to get.

Also capture the specific monitors named in the PD alerts — these are the incident's own monitors.

Write `monitors/firing.json`.

### Step 2: Service Catalog Dependencies

For the mapped `datadog_service`, fetch its service-catalog entry: upstream (dependencies it calls) and downstream (dependents). Firing monitors belonging to dependencies get listed in the blast-radius hint, not merged into symptoms.

Write `monitors/dependencies.json`.

### Step 3: Blast-Radius Hint

Derive, without RCA reasoning:

- `downstream`: dependents whose monitors are also alerting, or that own the firing monitors
- `expanding`: true if a dependent's monitor triggered *after* the primary; false if all triggers cluster at onset; null if undetermined

This is a hint for the report's `blast_radius_hint` field — the full blast-radius analysis belongs to a later skill.

### Step 4: AWS Health Check (via `aws` MCP)

Active AWS Health events (issue/scheduled-change) in the mapped accounts, within ±24h. Any hit is recorded in `monitors/aws-health.json` and flagged prominently in the report — platform-side events often explain multi-service symptoms.

## Output

- `monitors/firing.json`, `monitors/dependencies.json`, `monitors/aws-health.json` (when queried)
- Blast-radius hint for Phase 6

## Rules

- Read-only. No monitor muting, no dashboard writes.
- If the Datadog server is down: mark `mcp_coverage.datadog = "unavailable"`, continue with PD evidence only. Severity confidence drops accordingly.

## Next Phase

Proceed to [Phase 4: Change Window](04-change-window.md).
