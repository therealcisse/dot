# Phase 2: Draft RCA

The only sanctioned causal reasoning in the entire chain. Discipline: every claim cites evidence.

## Objective

- Build the incident timeline (detection → mitigation → recovery)
- State the root cause with an explicit evidence chain, or honestly record `undetermined`
- Separate contributing factors from causes

## Execution Steps

### Step 1: Timeline

Merge `timeline.json` + key moments from each artifact (first alert, triage emitted, freeze, verdicts, gate approval, execution, verdict VERIFIED). Each entry carries a `source` ref. One line each — the timeline is chronological, not narrative.

### Step 2: Root Cause

From the synthesis's leading hypothesis + the verification outcome, state the root cause:

- **Confirmed** (`root_cause_confidence: "confirmed"`): a SUPPORTED hypothesis whose mechanism the mitigation's success empirically validated (VERIFIED after targeting it).
- **Probable**: strong synthesis support but no verification loop confirming the mechanism (e.g. recovery was coincidental, incident faded).
- **Undetermined**: no supported hypothesis or inconclusive verification. `root_cause: null`, and the missing-evidence list carries forward.

Each causal sentence in the chain cites its ref: "payment-span p99 rose at 14:36 (`traces/payment-spans.json`); checkout p99 degraded 14:37 (`metrics/checkout-p99.json`); mitigation targeting H2 produced VERIFIED recovery (`verification.json`) → payment dependency latency caused the checkout degradation."

**Blameless rewrite pass**: rephrase any cause naming a person or their choice into the condition that allowed it. "No canary covered the latency path" not "X deployed without canarying".

### Step 3: Contributing Factors

Everything that made the incident more likely, longer, or harder to diagnose — detection gaps, alert noise, missing monitors (the `missing_evidence` lists are a ready source), mapping gaps. Factors are not causes; they don't need the full evidence chain, but each still cites where it's visible.

## Output

- Draft timeline, root cause (+ confidence), contributing factors

## Next Phase

Proceed to [Phase 3: Actions & Lessons](03-actions-lessons.md).
