# Phase 1: Baseline & Watchlist

Define what "recovered" means, numerically, before looking at anything live.

## Objective

- Load the mitigation contract (selected option, expected_effect, time_to_verify, abort_condition)
- Extract pre-mitigation baselines from the frozen bundle
- Build the watchlist (primary + guardrail signals) with targets
- Define the observation window

## Execution Steps

### Step 1: Load the Contract

From `mitigation.json`: the selected option's fields are the verification requirements. `abort_condition` is copied verbatim — it was written for this moment.

### Step 2: Baselines from the Bundle

Pre-mitigation values come from the frozen evidence (`metrics/*.json` around onset), not from memory or current live values. If the bundle lacks a signal, mark it unqueryable rather than inventing a baseline.

### Step 3: Build the Watchlist

- **Primary** signals: the triage symptoms the mitigation targeted (one per symptom, plus the leading-hypothesis signal when distinct).
- **Guardrail** signals: things that should NOT move — error rates, other services' monitors that were healthy at freeze, the abort_condition's referenced signals.
- **Targets**: STACK.md overlay recovery hints per alert class; where the overlay lacks a hint, derive from the pre-incident baseline in the bundle (e.g. symptom threshold inverted) and mark the derivation.

### Step 4: Window

- `started_at` = mitigation `executed_at` + the option's `time_to_verify` offset
- `duration_minutes` = at least 2× `time_to_verify`, minimum 15 (default 30)
- `cadence_minutes` = window/6, clamped to 2–10 (default 5)

### Step 5: Prerequisites Check

No watchlist signal queryable → status BLOCKED with the list of dead signals.

## Output

- Watchlist + window recorded (draft `verification.json` without observations)

## Next Phase

Proceed to [Phase 2: Observe & Verdict](02-observe-verdict.md).
