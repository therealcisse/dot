# Phase 1: Basis Gate

The Iron Law of this skill: no mitigation options without a synthesis to stand on.

## Objective

- Verify `synthesis.json` exists in the bundle and parses
- Load verdicts, ranking, leading hypothesis, recommended focus, coverage
- Classify the basis quality

## Execution Steps

### Step 1: Verify

| Check | On failure |
|-------|-----------|
| `~/.incidents/<id>/synthesis.json` exists | Redirect to `oncall-collect`. Do not generate options from `triage.json` alone |
| Parses and carries `hypothesis_verdicts` | Same — corrupted synthesis is no basis |

### Step 2: Classify Basis

- `leading-hypothesis` — synthesis carries a leading hypothesis. Full option mode.
- `no-leading-hypothesis` — everything INSUFFICIENT/REFUTED or leading is null. **Safest-option mode only** (Phase 2): reversible, low-blast-radius options; no speculative fixes targeting refuted hypotheses.

### Step 3: Load Supporting Context

`deployments/changes.json` and `deployments/executions.json` (rollback targets), `triage.json` symptoms (what recovery means), STACK.md overlay recovery hints (what the verifier will watch).

## Output

- Basis quality classification
- Loaded synthesis + change context

## Next Phase

Proceed to [Phase 2: Generate Options](02-generate-options.md).
