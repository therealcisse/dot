---
name: oncall-collect
description: Deep incident evidence collection and parallel hypothesis investigation. Freezes the evidence bundle, dispatches one read-only falsification agent per triage hypothesis, independently reviews each leading verdict, and synthesizes verdicts. Requires a prior oncall-triage run. Triggers on "collect evidence", "investigate the incident", "run hypotheses", "dig into the incident", "oncall collect".
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Oncall Collect

The investigation engine. Takes the bundle initialized by `oncall-triage`, deepens the evidence (metrics, logs, traces, CloudTrail), freezes it, fans the hypotheses out to independent falsification agents that read **only the frozen bundle**, subjects each leading verdict to an independent bundle-only review, and merges verdicts and reviews into a synthesis. Stops before mitigation.

## Design Principles

1. **Collect once, reason many times**: collection happens in this skill's context via MCP; hypothesis agents get the frozen bundle and no live tools. Every agent investigates the same reality.
2. **Falsify, don't confirm**: each hypothesis agent's job is to *disprove* its hypothesis. Confirmation bias is the failure mode; the verdict schema forces contradicting evidence and falsification attempts to be recorded.
3. **Freeze before fan-out**: the bundle is checksummed and indexed; investigators cite `evidence_ref` paths that provably exist.
4. **Bounded writes**: local bundle only. No Teams, no PD notes, no remote writes at all in this skill.
5. **Synthesis ranks, humans decide**: output is a ranked verdict set with a leading hypothesis — never a mitigation.
6. **Independent review, one round**: a second bundle-only adversary attacks each leading verdict (faithfulness, rigor, overlooked contradictions, calibration); the synthesizer decides, and no verdict becomes the leading hypothesis without a valid review.

## Prerequisites

- A bundle at `~/.incidents/<id>/` containing `triage.json` from a completed `oncall-triage` run. If missing: stop and tell the user to run `oncall-triage` first. Do not silently re-run triage.

## MCP Requirements

Collection phases use `datadog` (metrics/logs/traces queries) and `aws` (CloudTrail) — read-only, same aliases and overlay as `oncall-triage` (`~/.config/oncall/stack.md`). Hypothesis and review agents use **no MCP servers**.

## Execution Flow

```
Phase 1: Prepare
  Verify triage.json; read STACK.md overlay mappings; load hypotheses
      |
      v
Phase 2: Deep Collection                [datadog, aws]
  metrics/ logs/ traces/ cloudtrail/ around impact_started_at
      |
      v
Phase 3: Freeze Bundle
  evidence-index.json (files + sha256); bundle now immutable for agents
      |
      v
Phase 4: Dispatch Hypotheses            [agents/, no MCP]
  One investigator per hypothesis, parallel when the harness supports it
  Each returns a verdict per specs/hypothesis-verdict-format.md
      |
      v
Phase 4b: Review Verdicts               [agents/, no MCP]
  One reviewer per verdict in the review set (every SUPPORTED + one INSUFFICIENT)
  Each returns a review per specs/verdict-review-format.md
      |
      v
Phase 5: Synthesize
  Merge verdicts and reviews, rank, detect conflicts, list missing evidence
  Blind-spot check: does the evidence point to a mechanism no hypothesis covers?
  Output: synthesis.json + synthesis.md. Next: oncall-mitigate.
```

## Bundle Additions

```
~/.incidents/<id>/
  metrics/           # per-symptom query results (from triage monitors)
  logs/              # error/warning samples around onset
  traces/            # APM slow/error traces for affected service
  cloudtrail/        # AWS API activity in the change window
  evidence-index.json    # frozen manifest: file, sha256, collected_at
  hypotheses/H*.json     # one verdict per hypothesis
  hypotheses/H*.review.json  # one independent review per reviewed verdict
  synthesis.json / synthesis.md
```

## Sub-Agent Integration

| Phase | Agent | Contract |
|-------|-------|----------|
| Phase 4 | hypothesis-investigator × N (one per hypothesis) | [agents/hypothesis-investigator.md](agents/hypothesis-investigator.md) |
| Phase 4b | verdict-reviewer × M (one per verdict in the review set) | [agents/verdict-reviewer.md](agents/verdict-reviewer.md) |

Dispatch with your harness's child-agent/subagent mechanism (in Warp/Oz: `run_agents`, one child per hypothesis). Sequential dispatch is acceptable when the harness has no agent mechanism — the contract is unchanged. Investigators are read-only and bundle-only by instruction; never attach MCP tools to them. Reviewers use the same dispatch mechanism and, like investigators, never receive MCP tools.

## Guardrails (strictly enforced)

- Zero remote writes. This skill writes only inside `~/.incidents/<id>/`.
- Hypothesis agents receive no live tools — bundle files only.
- Verdicts cite `evidence_ref` paths that exist in `evidence-index.json`.
- Maximum 5 concurrent investigators (matches the triage schema's hypothesis cap).
- If new candidate hypotheses emerge during collection, add them to the dispatch set with recorded rationale — cap total at 5.
- Correlation wording only until synthesis; causal claims appear solely in the postmortem skill.
- Reviewers are bundle-only and receive no MCP tools — same freeze contract as investigators.
- One verdict per reviewer. A reviewer never sees sibling verdicts or other reviews.
- One review round. Reviewers flag, the synthesizer decides; never re-dispatch investigators or let reviewers converse with them.
- `leading_hypothesis` requires a valid review (UPHELD or DOWNGRADE). A SUPPORTED verdict whose review was discarded or failed is not eligible.

## Completion Status Protocol

| Status | When |
|--------|------|
| **DONE** | Bundle frozen, all hypotheses dispatched and verdicted, review set reviewed, synthesis written |
| **DONE_WITH_CONCERNS** | Synthesis written but some evidence classes unavailable (e.g. traces not configured) — recorded in `synthesis.json.coverage` — or a review was discarded/failed so the leading hypothesis was withheld |
| **BLOCKED** | Prerequisite triage missing, or bundle unfreezable (no evidence gathered at all) |
| **NEEDS_CONTEXT** | Overly broad free-text entry point with no triage to anchor (redirect to oncall-triage) |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [agents/hypothesis-investigator.md](agents/hypothesis-investigator.md) | Investigator prompt contract (bundle-only falsification) |
| [agents/verdict-reviewer.md](agents/verdict-reviewer.md) | Reviewer prompt contract (bundle-only verdict adversary) |
| [phases/01-prepare.md](phases/01-prepare.md) | Prerequisite check and hypothesis loading |
| [phases/02-collect-deep.md](phases/02-collect-deep.md) | Metrics, logs, traces, CloudTrail collection |
| [phases/03-freeze-bundle.md](phases/03-freeze-bundle.md) | Evidence index and freeze |
| [phases/04-dispatch-hypotheses.md](phases/04-dispatch-hypotheses.md) | Investigator fan-out |
| [phases/04b-review-verdicts.md](phases/04b-review-verdicts.md) | Verdict review fan-out |
| [phases/05-synthesize.md](phases/05-synthesize.md) | Verdict merge and ranking |
| [specs/evidence-bundle-format.md](specs/evidence-bundle-format.md) | Full bundle layout contract |
| [specs/hypothesis-verdict-format.md](specs/hypothesis-verdict-format.md) | Verdict JSON schema |
| [specs/verdict-review-format.md](specs/verdict-review-format.md) | Review JSON schema |
| [specs/confidence-calibration.md](specs/confidence-calibration.md) | Shared confidence bands |
| [specs/synthesis-format.md](specs/synthesis-format.md) | Synthesis JSON schema |
