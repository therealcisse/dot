---
name: oncall-verify
description: Observation-window recovery verification after a mitigation. Builds a watchlist from the mitigation plan and STACK.md recovery hints, samples signals over time, and issues an explicit verdict (RECOVERING / VERIFIED / NOT_RECOVERED / SIDE_EFFECTS). Humans resolve PagerDuty, never this skill. Triggers on "verify recovery", "is it fixed", "watch the metrics", "oncall verify".
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Oncall Verify

Watches what the mitigation was supposed to change, for as long as it needed to change it, and says so with evidence. `kubectl rollout undo` followed by a shrug is not verification; an observation window with recorded samples and a verdict is.

## Design Principles

1. **Verdicts, not vibes**: every verdict cites sampled values against baselines and thresholds.
2. **The mitigation defines the watchlist**: `expected_effect`, `time_to_verify`, and `abort_condition` from `mitigation.json` are the contract; STACK.md recovery hints refine thresholds.
3. **Time is part of the evidence**: recovery claims require the observation window to complete, not one good sample.
4. **Humans resolve PD**: even on VERIFIED, this skill never acks or resolves PagerDuty. It tells the human the evidence supports resolution.

## Prerequisites

- Bundle containing `mitigation.json` with a recorded execution. Missing execution record → redirect to `oncall-mitigate` (a plan with no executed option has nothing to verify).

## Execution Flow

```
Phase 1: Baseline & Watchlist
  Load mitigation contract + recovery hints; capture pre-mitigation baselines
  from the frozen bundle; define thresholds and window
      |
      v
Phase 2: Observe & Verdict
  Sample watchlist at cadence over the window; record observations;
  issue verdict; broadcast; hand off (postmortem | back to mitigate)
```

## Verdicts

| Verdict | Meaning | Next |
|---------|---------|------|
| `RECOVERING` | Window incomplete but signals trending to target | Keep observing (rerun Phase 2) |
| `VERIFIED` | Window complete, all primary signals at/under target, no new symptoms | `oncall-postmortem` |
| `NOT_RECOVERED` | Window complete, signals flat or worse, or abort_condition met | Back to `oncall-mitigate` (new options, new gate) |
| `SIDE_EFFECTS` | Primary signals recovering but new symptoms appeared | Back to `oncall-mitigate` with the side-effect evidence |

## MCP Requirements

`datadog` (metric queries at each sample) and `teams` (verdict broadcast) — read + one message, same aliases and overlay as the rest of the chain.

## Guardrails (strictly enforced)

- Read-only against all systems; the only write is the verdict broadcast to Teams (skipped under `DRY_RUN=1`).
- Never ack/resolve PagerDuty, even on VERIFIED.
- Never declare VERIFIED on a partial window because things "look fine".
- Samples are recorded with timestamps and query text — the verdict must be auditable from the bundle alone.
- If the session cannot span the window (user leaves, context ends), record state and verdict `RECOVERING`-at-last-sample with a note on how to resume; do not guess the rest.

## Completion Status Protocol

| Status | When |
|--------|------|
| **DONE** | Verdict issued (VERIFIED / NOT_RECOVERED / SIDE_EFFECTS), verification.json written |
| **DONE_WITH_CONCERNS** | Verdict issued but some watchlist signals unqueryable (recorded) |
| **BLOCKED** | No executed mitigation to verify, or no watchlist signal is queryable |
| **NEEDS_CONTEXT** | No incident/bundle in context |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [phases/01-baseline-watchlist.md](phases/01-baseline-watchlist.md) | Baselines, thresholds, window definition |
| [phases/02-observe-verdict.md](phases/02-observe-verdict.md) | Sampling loop and verdict rules |
| [specs/verification-report-format.md](specs/verification-report-format.md) | verification.json schema |
