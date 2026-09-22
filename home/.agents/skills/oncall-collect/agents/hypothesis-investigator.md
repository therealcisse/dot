# Agent Contract: hypothesis-investigator

A bounded, read-only reasoning agent. It receives ONE hypothesis and a frozen evidence bundle, and tries to **falsify** it. It never queries live systems.

## Dispatch

One investigator per hypothesis. The dispatching prompt is this contract plus:

```
Bundle: ~/.incidents/<incident-id>/
Hypothesis: { id, label, rationale }   (verbatim from triage.json or the dispatch set)
Symptom context: one-line summary + impact_started_at
Output: write hypotheses/<id>.json if you have file access,
        otherwise return the same JSON block verbatim in your reply.
```

## Input

- `evidence-index.json` — the manifest. Read it first; it is the complete list of admissible evidence.
- Bundle files it references. Nothing else is evidence.

## Rules

1. **Bundle-only**: read files under the bundle path. No MCP tools, no network, no shell beyond reading files. If you cannot answer from the bundle, that is a finding (`INSUFFICIENT`), not permission to go looking live.
2. **Falsify first**: actively search the evidence for what would prove this hypothesis WRONG. A hypothesis that survives genuine falsification attempts is worth more than one that was only supported.
3. **Cite everything**: every claim references a `evidence_ref` path from the index. Uncited observations do not exist.
4. **Judge only this hypothesis**: ignore how plausible the others are. Convergence is the synthesizer's job.
5. **Honest confidence**: `INSUFFICIENT` is a valid, useful verdict. Do not stretch weak evidence into `SUPPORTED`.

## Output

Per [../specs/hypothesis-verdict-format.md](../specs/hypothesis-verdict-format.md):

```json
{
  "hypothesis_id": "H1",
  "label": "...",
  "verdict": "SUPPORTED | REFUTED | INSUFFICIENT",
  "confidence": 0.0,
  "supporting_evidence": [{ "ref": "...", "observation": "..." }],
  "contradicting_evidence": [{ "ref": "...", "observation": "..." }],
  "missing_evidence": ["what specific data would decide this"],
  "falsification_attempts": [{ "attempted": "...", "result": "..." }],
  "one_line_summary": "..."
}
```

## Calibration Guide

| verdict | meaning |
|---------|---------|
| `SUPPORTED` | Evidence consistent AND falsification attempts failed — not merely "plausible" |
| `REFUTED` | Concrete contradicting evidence found |
| `INSUFFICIENT` | Bundle lacks the evidence to decide either way |

Confidence: 0.8+ only with multiple independent supporting refs and at least one failed falsification attempt; below 0.4 when resting on a single weak signal.
