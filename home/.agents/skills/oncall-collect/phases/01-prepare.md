# Phase 1: Prepare

Verify the prerequisite chain and load what Phase 4 will dispatch.

## Objective

- Confirm the bundle exists and contains a completed `triage.json`
- Load the STACK.md overlay mapping for the incident's service
- Assemble the hypothesis dispatch set
- Decide the collection window

## Execution Steps

### Step 1: Verify Prerequisites

| Check | On failure |
|-------|-----------|
| `~/.incidents/<id>/` exists | Ask user for the incident ID or redirect to `oncall-triage` |
| `triage.json` exists and parses | Redirect to `oncall-triage`; do not fabricate one |
| `incident.json` exists (for `impact_started_at`) | Redirect to `oncall-triage` |
| `evidence-index.json` absent (not yet frozen) | Fine — this run will freeze |
| `evidence-index.json` present (already collected) | Ask user: re-collect fresh evidence, or jump to Phase 4 with the existing freeze |

### Step 2: Load Mappings

Read `~/.config/oncall/stack.md` (overlay first; the in-repo STACK.md is template only). Extract `datadog_service`, `monitor_tags`, and the change-window relevant `spinnaker_apps` for the paged service.

### Step 3: Assemble the Dispatch Set

Start from `triage.json.initial_hypotheses` (all of them, regardless of triage's informal ranking). During Phase 2, if collection surfaces a strong new candidate, append it with a recorded rationale in this phase's timeline entry. Hard cap: 5 total.

### Step 4: Collection Window

- `from` = `impact_started_at` − 60m
- `to` = now

All Phase 2 queries use this same window. Consistent windows make evidence comparable across files.

## Output

- Dispatch set (in-memory / timeline entry)
- Collection window

## Next Phase

Proceed to [Phase 2: Deep Collection](02-collect-deep.md).
