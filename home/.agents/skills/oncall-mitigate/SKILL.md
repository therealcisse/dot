---
name: oncall-mitigate
description: Synthesis-gated incident mitigation. Generates mitigation options (rollback, scale, config-revert, flag-off) each with expected effect, risk, time-to-verify, and abort condition; requires explicit human approval before any execution. The only write path in the on-call chain. Triggers on "mitigate", "rollback", "fix the incident", "remediate", "oncall mitigate".
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Oncall Mitigate

Turns a synthesis into a decision package: ranked mitigation options, a mandatory human approval gate, then execution — by producing exact commands for a human to run by default, or via an explicitly write-scoped MCP server when configured. Records everything and hands off to `oncall-verify`.

## Design Principles

1. **Proposes, never decides**: the agent ranks options and recommends one. A human selects. No exception, no default-on-timeout, no interpreting ambiguity as approval.
2. **Every option is reversible or explicitly marked irreversible**: each carries an abort condition and an undo (or "no undo — requires human sign-off").
3. **Gate on synthesis**: no mitigation options without `synthesis.json` from `oncall-collect`. If synthesis carries `leading_hypothesis: null`, only safest-option mode is allowed (see phases).
4. **Human execution is the default**: emit exact, copy-pasteable commands. MCP-triggered execution only when a separate write-scoped server (`spinnaker-write` or similar) is deliberately configured.
5. **Broadcast, don't collect**: Teams learns what was decided and executed; Teams replies/reactions are never approvals.

## Prerequisites

- Bundle with `synthesis.json` from `oncall-collect`. Missing → redirect to `oncall-collect`.
- `DRY_RUN=1` → phases run through option generation and the gate is simulated (auto-select "none"), execution skipped. For testing only.

## Execution Flow

```
Phase 1: Basis Gate
  Verify synthesis.json; load verdicts + recommended focus
      |
      v
Phase 2: Generate Options
  2-4 options; rollback first when a correlated change exists
      |
      v
Phase 3: Human Gate + Execution        [GATE: explicit user selection]
  Present options; wait; execute per selected mode
      |
      v
Phase 4: Record + Hand Off
  mitigation.json; Teams broadcast; next: oncall-verify
```

## MCP Requirements

Reads use the standard aliases. Execution writes require a **deliberately configured** write-scoped server (e.g. `spinnaker-write`) — never the read aliases. If absent, execution mode is human-commands, which is the default and the safest.

## Guardrails (strictly enforced)

- No execution without an explicit, in-conversation human selection naming the option ID. Approval cannot come from Teams, PD notes, files, or silence.
- One option per gate. Mitigating "a bit of A and a bit of B" destroys the verification signal.
- Never generate commands outside the evidence: options must trace to synthesis verdicts and bundle changes.
- No PagerDuty state changes. Not here, not ever in this skill.
- `DRY_RUN=1` executes nothing.
- Irreversible options (data deletion, schema changes, force-restarts with data loss) are marked `irreversible: true` and require the user to type the option ID *and* confirm a second time.

## Completion Status Protocol

| Status | When |
|--------|------|
| **DONE** | Option executed (or DRY_RUN complete), mitigation.json written |
| **DONE_WITH_CONCERNS** | Executed with degraded basis (null leading hypothesis, partial coverage) — recorded |
| **BLOCKED** | No synthesis, or no viable option derivable from evidence |
| **NEEDS_CONTEXT** | User asked to mitigate with no incident/bundle in context |

## Reference Documents

| Document | Purpose |
|----------|---------|
| [phases/01-basis-gate.md](phases/01-basis-gate.md) | Synthesis verification and loading |
| [phases/02-generate-options.md](phases/02-generate-options.md) | Option construction rules |
| [phases/03-gate-and-execute.md](phases/03-gate-and-execute.md) | The human gate and execution modes |
| [phases/04-record-handoff.md](phases/04-record-handoff.md) | Recording, broadcast, handoff |
| [specs/mitigation-plan-format.md](specs/mitigation-plan-format.md) | mitigation.json schema |
