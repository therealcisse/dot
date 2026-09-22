# Phase 4: Publish

Write the artifacts, close the loops the incident exposed.

## Objective

- Write `postmortem.json` + `postmortem.md` per [specs/postmortem-format.md](../specs/postmortem-format.md)
- One optional PD incident note linking the artifact (keeps PD the system of record)
- Optional Teams message for significant incidents
- Record STACK.md overlay maintenance gaps

## Execution Steps

### Step 1: Write Artifacts

`postmortem.md` renders the human story: summary, impact, timeline, root cause (+ confidence), contributing factors, what went well/poorly, corrective actions, lessons. `postmortem.json` carries the machine contract. Append the final timeline events.

### Step 2: PD Note (via `pagerduty` MCP; skipped under `DRY_RUN=1`; bound incidents only)

One note: "Postmortem: <root cause one-liner or undetermined> — details: <bundle_path>". Never resolve, never ack.

### Step 3: Teams (optional, via `teams` MCP; skipped under `DRY_RUN=1`)

For SEV-1/2 or cross-team incidents:

```
[Postmortem] <incident title> — <id>
Root cause: <one line | undetermined>
Duration: <impact window>
Corrective actions: <count, top P1>
Postmortem: <bundle_path>
```

### Step 4: Overlay Maintenance

If the incident exposed STACK.md gaps (unmapped service, missing recovery hint, wrong Spinnaker app mapping), list them explicitly in the final reply as concrete edits for `~/.config/oncall/stack.md`. Do not edit the overlay silently — the user owns that file's contents.

## Completion

Set status: `DONE_WITH_CONCERNS` for interim postmortems or undetermined RCAs with open gaps; otherwise `DONE`. Reply with the postmortem summary, the lessons appended, any overlay edits proposed — and stop. The chain is closed until the next page.
