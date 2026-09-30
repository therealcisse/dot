# Phase 4b: Review Verdicts

Put a second, independent adversary on each leading verdict. One round, bundle-only, no live tools — the reviewer attacks the verdict, not the hypothesis.

## Objective

- Select the review set from the Phase 4 verdicts
- Dispatch one [verdict-reviewer](../agents/verdict-reviewer.md) per verdict in the review set
- Collect reviews into `hypotheses/H*.review.json` as advisory input to Phase 5

## Execution Steps

### Step 1: Select the Review Set

- Every verdict with `verdict: SUPPORTED`
- Plus exactly one `INSUFFICIENT` verdict: the one with the fewest `missing_evidence` items (ties → highest confidence)

`REFUTED` verdicts and verdicts discarded in Phase 4 are not reviewed. Log the selection and what was skipped (with the reason) in `timeline.json`. An empty review set (every verdict `REFUTED` or discarded) is logged the same way; proceed to Phase 5.

### Step 2: Build Per-Verdict Prompts

Each dispatch prompt = the full text of `agents/verdict-reviewer.md` +:

```
Bundle: ~/.incidents/<incident-id>/
Verdict: <the ONE hypotheses/<id>.json, verbatim>
Output: write hypotheses/<id>.review.json if you have file access,
        otherwise return the same JSON block verbatim in your reply.
```

Nothing else. No other verdicts, no other reviews, no triage ranking, no orchestrator opinion, no hint of the expected outcome — a reviewer who knows what you want to hear is not independent.

### Step 3: Dispatch

Same mechanics as Phase 4:

- Harness with child agents (Warp/Oz `run_agents`, Claude Code `Task`, opencode agents): one child per verdict in the review set, same batch, parallel.
- No agent mechanism: run each contract sequentially in-context. Slower, same contract.
- Max 5 concurrent.

### Step 4: Collect Reviews

- Agent wrote `hypotheses/<id>.review.json` → verify it parses.
- Agent returned JSON in its reply → validate against [specs/verdict-review-format.md](../specs/verdict-review-format.md), write the file yourself.

Validation failures (missing fields, `adjusted_confidence` on an `UPHELD`, `adjusted_confidence` above the original confidence, `DOWNGRADE` with zero defects, `OVERTURN` without a qualifying faithfulness defect or contradicting overlooked entry, refs outside the index): return the review to the agent once for correction; if still invalid, record it as discarded with the reason. Do not silently repair reviews — the synthesizer must see what actually came back.

### Step 5: No Second Round

Reviews are advisory input to Phase 5. The reviewer flags; the synthesizer decides.

- Never re-dispatch an investigator to answer a review.
- Never let a reviewer and an investigator converse.
- Never read reviews mid-flight to steer the reviewers still running.

## Rules

- Never attach MCP tools or live access to reviewers. Bundle-only, read-only; the only permitted write is `hypotheses/<id>.review.json`.
- One verdict per reviewer. Never sibling verdicts, never other reviews.
- Max 5 concurrent.
- One round. No re-dispatch, no rebuttal, no reconciliation between agents.
- A `SUPPORTED` verdict whose review is discarded or never arrives is still ranked in Phase 5 but cannot become `leading_hypothesis`.

## Next Phase

Proceed to [Phase 5: Synthesize](05-synthesize.md).
