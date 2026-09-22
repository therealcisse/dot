# Phase 1: Gather

Assemble the incident's full recorded history. The postmortem writes nothing new about what happened — it reads what the chain already recorded.

## Objective

- Read the complete bundle: `timeline.json`, `triage.json`, `synthesis.json`, `mitigation.json`, `verification.json` (as available), plus the key evidence files the synthesis cited
- Note which chain stages ran and which are absent

## Execution Steps

### Step 1: Inventory

List bundle contents; map against the expected chain (triage → collect/synthesis → mitigate → verify). Absent stages are recorded in `source_artifacts` as null — an interim postmortem with no mitigation/verification is legitimate, not an error.

### Step 2: Read the Story in Order

`timeline.json` events → `triage.json` → hypothesis verdicts → `synthesis.json` → `mitigation.json` (options, gate, execution) → `verification.json` (watchlist, samples, verdict).

### Step 3: Pull Cited Evidence

Open the evidence files named in the synthesis's `key_evidence` and the verification's primary signals — these anchor the RCA's causal claims in Phase 2.

### Step 4: Known-Incident Context

Read `known-incidents/` — recurrence signal from triage feeds Phase 3's graduation decision.

## Output

- Assembled record + stage inventory

## Next Phase

Proceed to [Phase 2: Draft RCA](02-draft-rca.md).
