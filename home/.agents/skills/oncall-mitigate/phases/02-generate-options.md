# Phase 2: Generate Options

Build 2–4 evidence-traced options. Every field is written for two readers: the human deciding, and `oncall-verify` watching.

## Objective

- Generate options per [specs/mitigation-plan-format.md](../specs/mitigation-plan-format.md)
- Rank and recommend one
- Write the draft plan (approval still null)

## Option Construction Rules

1. **Trace to evidence.** Each option cites what justifies it:
   - rollback ← a correlated change in `deployments/changes.json` + the version history in `executions.json`
   - scale ← saturation evidence in `metrics/`
   - config-revert ← a config change in `cloudtrail/` or deployments context
   - feature-flag ← flag evidence anywhere in the bundle
   An option with no evidentiary trace is not generated, however obvious it seems.
2. **Rollback first** when a correlated change exists — cheapest to reason about, easiest to undo, fastest to verify. Target the last-known-good version explicitly.
3. **Do-nothing is not an option here.** If the honest answer is "no safe action", that is status BLOCKED with reasoning, not a padded option list.
4. **Safest-option mode** (basis `no-leading-hypothesis`): only reversible, bounded-blast-radius actions — rollback of the most-recent correlated change, scaling. No speculative fixes.
5. **Irreversible options**: mark `irreversible: true`, set `undo: "irreversible"`. These should be rare; if one appears, double-confirmation applies at the gate.

## Field Guidance

- `expected_effect`: which watchlist signals should move, in which direction, by roughly how much
- `time_to_verify`: honest propagation delay ("rollout ~5m, metrics react within ~10m")
- `abort_condition`: the observation that means "this made it worse or did nothing — stop"
- `execution.commands`: exact, copy-pasteable, derived from the mapped `spinnaker_apps`/accounts in the overlay — with placeholders where only the human knows the value, and a note saying so

## Ranking

Recommend by: evidence strength behind the target → reversibility → speed to verify. State the one-line why in `recommended`.

## Output

- Draft `mitigation.json` (approval null), presented in Phase 3

## Next Phase

Proceed to [Phase 3: Gate & Execute](03-gate-and-execute.md).
