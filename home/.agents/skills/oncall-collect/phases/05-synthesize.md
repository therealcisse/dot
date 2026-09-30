# Phase 5: Synthesize

Merge independent verdicts into one ranked synthesis. Reasoning happens here — but conclusions stay correlation-worded and mitigation-free.

## Objective

- Read all `hypotheses/H*.json` verdicts, all `hypotheses/H*.review.json` reviews, + the evidence they cite
- Produce `synthesis.json` + `synthesis.md` per [specs/synthesis-format.md](../specs/synthesis-format.md)
- Hand off to `oncall-mitigate` by naming it

## Execution Steps

### Step 1: Validate Inputs

Discard verdicts citing refs not in `evidence-index.json`. Discard reviews whose `defects[].ref` or `overlooked_evidence` entries do not resolve against it — the verdict itself stands. Note every discard with its reason in the synthesis.

### Step 2: Cross-Examine

Read the cited evidence yourself — the synthesizer is accountable for what the synthesis claims. Check for:

- **Corroboration**: independent verdicts citing the same evidence for compatible reasons
- **Conflicts**: two SUPPORTED hypotheses implying different mechanisms; a SUPPORTED hypothesis whose key evidence another verdict contradicts
- **Gaps**: recurring `missing_evidence` items across verdicts
- **Reviews**: apply each valid review — `effective_confidence` = `adjusted_confidence` when `assessment` is `DOWNGRADE` or `OVERTURN`, else the verdict's original confidence; treat `overlooked_evidence` as candidate conflicts / missing evidence and read those files yourself. Every hypothesis in the dispatch set gets a `review_adjustments` entry: no valid review (not in the review set, or the reviewer returned nothing usable) → `NOT_REVIEWED`; review discarded → `DISCARDED`

### Step 3: Rank

`SUPPORTED` with assessment `UPHELD` or `DOWNGRADE` by `effective_confidence` desc → `INSUFFICIENT` (closest-to-decidable first) → `SUPPORTED` with assessment `OVERTURN`, `DISCARDED`, or `NOT_REVIEWED` → `REFUTED`.

`leading_hypothesis` eligibility: verdict `SUPPORTED` AND assessment in {`UPHELD`, `DOWNGRADE`} AND `effective_confidence` ≥ 0.5. Set it to the top eligible verdict; otherwise null. A `SUPPORTED` verdict whose review is `DISCARDED` or `NOT_REVIEWED` is not eligible regardless of confidence: note it in `synthesis.md` and set `completion_status: DONE_WITH_CONCERNS`.

### Step 4: Blind-Spot Check

Inputs:

- `overlooked_evidence` across valid reviews
- `missing_evidence` items recurring across verdicts
- Phase 2 emergent candidates (Step 5 of Phase 2), including any left out at the cap of 5
- Indexed evidence files no verdict cited

Question: does the aggregated evidence point to a mechanism no dispatched hypothesis covers?

- Yes → `uncovered_mechanism` = one correlation-worded sentence. If it is material to the leading hypothesis (it accounts for the same evidence the leading verdict rests on), set `leading_hypothesis` to null and say why in `synthesis.md`.
- No → `uncovered_mechanism: null`.

### Step 5: Write Outputs

`synthesis.json` per schema; `synthesis.md` structured:

```
# Synthesis: <incident title>
Leading hypothesis: <label (effective_confidence) | none>
## Verdicts (H1..Hn: verdict, confidence, key evidence)
## Conflicts
## Review adjustments (H1..Hn: assessment, original → effective confidence, key defect)
## Uncovered mechanism (one correlation-worded sentence | none)
## Missing evidence
## Recommended focus (correlation wording)
Next step: oncall-mitigate
```

Append the synthesis event to `timeline.json`.

## Rules

- No mitigations, no commands, no rollback suggestions — those belong to `oncall-mitigate`, and suggesting them here contaminates the human gate.
- `leading_hypothesis: null` is a valid, common outcome. Say so plainly in `synthesis.md`.
- Reviews are advisory. The synthesizer remains accountable for every claim; a review never overrides evidence you have read yourself — it directs where you look.
- Causal language remains prohibited. The first sanctioned causal claim in the entire chain is the postmortem's RCA.

## Completion

Set status per the protocol in SKILL.md, reply to the user with `synthesis.md` contents, and stop after naming `oncall-mitigate` as the next step.
