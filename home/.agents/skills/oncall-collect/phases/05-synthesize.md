# Phase 5: Synthesize

Merge independent verdicts into one ranked synthesis. Reasoning happens here — but conclusions stay correlation-worded and mitigation-free.

## Objective

- Read all `hypotheses/H*.json` verdicts + the evidence they cite
- Produce `synthesis.json` + `synthesis.md` per [specs/synthesis-format.md](../specs/synthesis-format.md)
- Hand off to `oncall-mitigate` by naming it

## Execution Steps

### Step 1: Validate Inputs

Discard verdicts citing refs not in `evidence-index.json`; note every discard with its reason in the synthesis.

### Step 2: Cross-Examine

Read the cited evidence yourself — the synthesizer is accountable for what the synthesis claims. Check for:

- **Corroboration**: independent verdicts citing the same evidence for compatible reasons
- **Conflicts**: two SUPPORTED hypotheses implying different mechanisms; a SUPPORTED hypothesis whose key evidence another verdict contradicts
- **Gaps**: recurring `missing_evidence` items across verdicts

### Step 3: Rank

`SUPPORTED` by confidence desc → `INSUFFICIENT` (closest-to-decidable first) → `REFUTED`. Set `leading_hypothesis` only if a SUPPORTed verdict clears confidence 0.5; otherwise null.

### Step 4: Write Outputs

`synthesis.json` per schema; `synthesis.md` structured:

```
# Synthesis: <incident title>
Leading hypothesis: <label (confidence) | none>
## Verdicts (H1..Hn: verdict, confidence, key evidence)
## Conflicts
## Missing evidence
## Recommended focus (correlation wording)
Next step: oncall-mitigate
```

Append the synthesis event to `timeline.json`.

## Rules

- No mitigations, no commands, no rollback suggestions — those belong to `oncall-mitigate`, and suggesting them here contaminates the human gate.
- `leading_hypothesis: null` is a valid, common outcome. Say so plainly in `synthesis.md`.
- Causal language remains prohibited. The first sanctioned causal claim in the entire chain is the postmortem's RCA.

## Completion

Set status per the protocol in SKILL.md, reply to the user with `synthesis.md` contents, and stop after naming `oncall-mitigate` as the next step.
