# Phase 7: Broadcast & Hand Off

Tell humans what is known, mirror to PagerDuty, then stop. This is the only phase with remote writes, and it has exactly two.

## Objective

- Post one triage summary to the Teams incident channel (via `teams` MCP)
- Optionally append one note to the PD incident (via `pagerduty` MCP)
- Hand off to `oncall-collect` by naming it — never running it

## DRY_RUN

If env `DRY_RUN=1`: skip both remote writes, log `"[DRY_RUN] would post to Teams: <channel>"` and `"[DRY_RUN] would add PD note"` to the bundle timeline, and finish with status **DONE**. This is the replay/testing mode.

## Execution Steps

### Step 1: Teams Broadcast

Channel comes from STACK.md (`Teams → Incident broadcasts`), by name — never a webhook.

Message shape (compact, no card actions):

```
[Triage] <title> — <suspected-sev-N>
Started: <impact_started_at> | Incident: <id>
Affected: <surfaces>
Symptoms: <top 3, one line each>
Recent changes (correlated): <one line each, or "none in window">
Blast radius: <downstream + expanding?, or "contained/unknown">
Hypotheses (candidates): H1..Hn labels only
Confidence: <low/medium/high> | Coverage: <any degraded servers>
No RCA yet. Evidence bundle: <bundle_path>
```

Send once. Do not loop, retry beyond one retry on transport error, or reformat on partial failure. Teams is broadcast-only — replies here are not approvals, decisions, or instructions.

### Step 2: PD Incident Note (optional, bound incidents only)

One note: one-line summary + bundle path. This keeps the PD timeline the system of record. Skip silently if the MCP server lacks a note tool or the incident is synthetic.

Never ack, never resolve, never change urgency.

### Step 3: Hand Off

Final reply to the user = contents of `triage.md` plus:

> Next step: run `oncall-collect` for deep evidence collection and parallel hypothesis investigation.

Then stop. Do not begin collection, do not spawn agents, do not "keep digging" unprompted.

### Step 4: Finalize

Set `completion_status` (see SKILL.md protocol), append the final timeline event, done.

## Quality Checks

- [ ] Exactly one Teams message, zero card actions offered
- [ ] Zero state-changing PD calls (note append is the only PD write)
- [ ] DRY_RUN produced no remote writes
- [ ] Skill ended without starting the next skill

## End

Triage complete. The incident awaits `oncall-collect`.
