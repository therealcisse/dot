# Phase 2: Observe & Verdict

Sample, record, decide. The loop is boring on purpose.

## Objective

- Query every watchlist signal at each cadence tick (via `datadog` MCP)
- Record observations with timestamps and queries
- Issue the verdict per [specs/verification-report-format.md](../specs/verification-report-format.md)

## Sampling Loop

At each tick (window start → end, every `cadence_minutes`):

1. Query each watchlist signal over the last cadence interval
2. Append the observation `{at, values, note}`
3. Check the abort condition → if met, exit early with `NOT_RECOVERED`, `abort_condition_met: true`
4. Check for unlisted symptoms on the affected service (new firing monitors, error signatures absent from the bundle) → if present, `SIDE_EFFECTS`

Between ticks: wait. If the harness/session cannot wait the full window, take the last sample, record `RECOVERING` state + resume instructions in the report, tell the user how to resume (rerun this phase), and stop honestly.

## Verdict Rules

Per the spec:

- `VERIFIED` — window complete AND all primaries at/under target AND ≥3 consecutive compliant samples AND no guardrail breaching. Tell the user the evidence supports resolving the PD incident; **the human resolves it**.
- `NOT_RECOVERED` — primaries flat/worse at window end, or abort condition met. Recommend returning to `oncall-mitigate`; the side-effect/flat evidence belongs in the next round's option generation.
- `SIDE_EFFECTS` — primaries improving but new damage appearing. Same handoff, flagged.

Never upgrade RECOVERING to VERIFIED early because the trend "looks obvious".

## Broadcast (via `teams` MCP; skipped under `DRY_RUN=1`)

```
[Verify] <incident title> — <id>
Verdict: <VERIFIED|NOT_RECOVERED|SIDE_EFFECTS>
Primary: <signal = value vs target (baseline)>
Guardrails: <status>
Window: <completed/partial, samples>
Next: <postmortem | new mitigation round | keep observing>
```

One message. Append the PD timeline note is NOT done here — no PD writes in this skill.

## Completion

Write `verification.json` + `verification.md`; append timeline events; set status; reply with the verdict summary and the named next skill. Done.
