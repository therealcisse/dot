# Phase 2: Deep Collection

Gather the evidence classes triage deliberately skipped. All queries via MCP, all read-only, all into the bundle.

## Objective

- `metrics/`: the actual series behind each symptom, plus key health signals of the mapped service
- `logs/`: error/warning samples around onset
- `traces/`: APM slow/error traces for the affected service
- `cloudtrail/`: AWS API activity in the change window
- Record coverage honestly — unavailable classes are `unavailable`/`not-configured`, never silently skipped

## Execution Steps

### Step 1: Metrics (via `datadog` MCP)

For each symptom in `triage.json.symptoms`, query its underlying series over the collection window. Additionally query standard health signals for the mapped `datadog_service`: request rate, error rate, latency percentiles, saturation (CPU/memory/connections where tagged).

One file per signal: `metrics/<symptom-slug>.json` containing the query, the window, and the points (or a downsampled representation + note if the series is huge).

### Step 2: Logs (via `datadog` MCP)

Query logs for the mapped service, severity error/warn, focused on the window, ordered by time. Cap at a few hundred lines; extract the distinct error signatures rather than dumping volume. Redact tokens/PII. Write `logs/<service>-errors.json`.

### Step 3: Traces (via `datadog` MCP)

APM traces for the affected service filtered to slow/error spans in the window. If APM isn't configured for the service, record `traces` coverage as `not-configured` and move on — do not substitute logs for traces and call them traces.

Write `traces/<service>-spans.json` with span name, duration, status, and the slowest dependency breakdown available.

### Step 4: CloudTrail (via `aws` MCP)

`LookupEvents` over the change window (T-60m→T+10m as recorded in `deployments/`) for the mapped accounts, filtered to write-type events. Group by actor + event name. Write `cloudtrail/window-events.json`. No CloudTrail access → `not-configured`.

### Step 5: Note New Candidates

If evidence here contradicts or extends the dispatch set (e.g. logs show a config parse error nobody hypothesized), append the new hypothesis to the dispatch set with rationale, respecting the cap of 5.

## Rules

- Read-only. No comment, no mute, no dashboard writes.
- Every file records its query and window — future readers must be able to reproduce it.
- Volume discipline: evidence files are for reasoning, not archival. Downsample, summarize signatures, cite counts.

## Next Phase

Proceed to [Phase 3: Freeze Bundle](03-freeze-bundle.md).
