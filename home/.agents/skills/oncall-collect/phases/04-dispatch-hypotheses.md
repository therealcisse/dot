# Phase 4: Dispatch Hypotheses

Fan the dispatch set out to independent investigator agents. One hypothesis per agent, bundle-only, no live tools.

## Objective

- Dispatch one [hypothesis-investigator](../agents/hypothesis-investigator.md) per hypothesis in the dispatch set
- Parallel when the harness supports it; sequential otherwise
- Collect verdicts into `hypotheses/H*.json`

## Execution Steps

### Step 1: Build Per-Hypothesis Prompts

Each dispatch prompt = the full text of `agents/hypothesis-investigator.md` +:

```
Bundle: ~/.incidents/<incident-id>/
Hypothesis: { "id": "H1", "label": "...", "rationale": "..." }
Symptom context: <one line> + impact_started_at <ts>
```

Nothing else. No other hypotheses, no orchestrator opinions, no hint of which answer is expected — leading questions contaminate independent verdicts.

### Step 2: Dispatch

- Harness with child agents (Warp/Oz `run_agents`, Claude Code `Task`, opencode agents): one child per hypothesis, same batch, parallel.
- No agent mechanism: run each contract sequentially in-context. Slower, same contract.

### Step 3: Collect Verdicts

- Agent wrote `hypotheses/<id>.json` → verify it parses.
- Agent returned JSON in its reply → validate against [specs/hypothesis-verdict-format.md](../specs/hypothesis-verdict-format.md), write the file yourself.

Validation failures (missing fields, zero falsification attempts on a SUPPORTED, refs outside the index): return the verdict to the agent once for correction; if still invalid, record it as discarded with the reason. Do not silently repair verdicts — the synthesizer must see what actually came back.

### Step 4: Handle the Worst Case

Every verdict `INSUFFICIENT` → do not force a synthesis conclusion. Proceed to Phase 5; the synthesis will carry `leading_hypothesis: null` and a `missing_evidence` list — that is an honest outcome, and the mitigation skill's gate will handle it (safest-option mode).

## Rules

- Never attach MCP tools or write access to investigators.
- Max 5 concurrent.
- Do not read verdicts mid-flight and "help" agents converge. Independence is the point.

## Next Phase

Proceed to [Phase 5: Synthesize](05-synthesize.md).
