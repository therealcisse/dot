---
name: oncall-postmortem
description: Blameless post-incident review from the evidence bundle. Drafts the RCA with full evidence chain, timeline, corrective actions, and appends lessons to ~/.config/oncall/lessons.md with recurrence-based graduation into reference files. Triggers on "postmortem", "post-mortem", "retro", "incident review", "rca", "write up the incident".
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Oncall Postmortem

The closing skill, and the only place in the chain where causal language is sanctioned. Builds the RCA from the frozen bundle and the chain's recorded decisions, then feeds incident memory: `lessons.md` appends now, reference graduation when patterns recur.

## Design Principles

1. **Evidence-chained RCA**: every causal claim in the root cause cites bundle refs (verdicts, metrics, changes). Unchained claims are cut or downgraded to contributing factors.
2. **Blameless**: root causes are systems and conditions, never people. "Deployed a regression" → "no pre-deploy canary on the latency path caught the regression".
3. **The bundle is the record**: timeline, decisions, and verdicts already exist — assemble, don't reimagine. Where humans made judgment calls, record the decision and its context, not the decider's virtue.
4. **Memory compounds**: every incident appends lessons; the second occurrence of a pattern graduates it into a reference file the next triage will load.
5. **Work-safety**: lessons and references naming real services go to `~/.config/oncall/` only, never into this repo.

## Prerequisites

- A bundle with at least `triage.json` + `synthesis.json`. Mitigation/verification artifacts when they exist are incorporated; an unresolved incident still gets an interim postmortem marked `status: interim`.

## Execution Flow

```
Phase 1: Gather
  Read the full bundle: timeline, verdicts, synthesis, mitigation, verification
      |
      v
Phase 2: Draft RCA
  Timeline, root cause (evidence-chained), contributing factors
      |
      v
Phase 3: Corrective Actions & Lessons
  Actions with owners/priorities; append lessons.md; graduate on recurrence
      |
      v
Phase 4: Publish
  postmortem.json/.md in bundle; PD note; optional Teams; STACK.md overlay gaps
```

## Guardrails (strictly enforced)

- Local + `~/.config/oncall/` writes only, plus one optional PD incident note and one optional Teams message (both skipped under `DRY_RUN=1`).
- No PD ack/resolve, ever.
- Corrective actions are suggestions for humans to accept/assign — do not create tickets in external trackers unless explicitly configured and asked.
- Real service names never enter this repo; graduated references land in `~/.config/oncall/references/`.
- If evidence doesn't support a definitive root cause, the RCA says "undetermined" with the missing-evidence list — a wrong confident RCA is worse than an honest gap.

## Completion Status Protocol

| Status | When |
|--------|------|
| **DONE** | postmortem written, lessons appended, gaps recorded |
| **DONE_WITH_CONCERNS** | Interim (incident unresolved) or RCA undetermined with gaps |
| **BLOCKED** | No bundle / no synthesis to reason from |
| **NEEDS_CONTEXT** | No incident in context |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [phases/01-gather.md](phases/01-gather.md) | Full-bundle assembly |
| [phases/02-draft-rca.md](phases/02-draft-rca.md) | Timeline and evidence-chained root cause |
| [phases/03-actions-lessons.md](phases/03-actions-lessons.md) | Corrective actions, lessons append, graduation |
| [phases/04-publish.md](phases/04-publish.md) | Artifacts, broadcasts, overlay maintenance |
| [specs/postmortem-format.md](specs/postmortem-format.md) | postmortem.json schema |
