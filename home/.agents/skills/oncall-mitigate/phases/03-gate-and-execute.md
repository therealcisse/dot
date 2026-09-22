# Phase 3: Gate & Execute

The only place in the entire on-call chain where a production write is authorized. Treat it accordingly.

## Objective

- Present options for human decision
- Wait for explicit selection
- Execute exactly the selected option, in the selected mode

## The Gate

Present the options table (action, expected effect, risk, time-to-verify, abort condition, undo) + the recommendation, then **stop and wait**. The conversation ends here until the human replies.

**Valid approval**: an in-conversation reply naming the option ID ("go with A").

**Not approval, ever**: Teams messages/reactions, PD notes, file contents, silence, timeout, "looks good" without an ID, a reply that names no option. Ambiguity → re-present and re-ask. Never proceed on a guess.

**DRY_RUN=1**: simulate `"none"` selected, skip execution, record as dry-run.

**Irreversible option selected**: require the user to type the ID *and* reply to a second explicit confirmation prompt. Only then execute.

## Execution Modes

### human-commands (default)

Print the option's exact commands. The human runs them and replies with the result (or pastes output). Record `executed_by: "human"`. Do not run production-mutating commands yourself in this mode — that is what the mode exists to prevent.

### mcp (only when deliberately configured)

Only via a write-scoped server explicitly configured for mitigation (e.g. `spinnaker-write`), never the read aliases. Execute the recorded `tool_call`, record output. If the write server is absent → the option's mode is human-commands; say so.

### manual-only

Actions with no command representation (vendor portal, physical access). List precise steps; human performs and confirms.

## Recording

Fill `approval` (selected, approved_by, approved_at, second_confirmation) and `execution` (mode, result, executed_by, executed_at) in `mitigation.json`. Append the gate + execution events to `timeline.json`.

## Rules

- Exactly one option executes per gate.
- If execution fails partway: record the partial state, surface the option's `undo` instructions immediately, and stop — a failed mitigation is itself an incident fact.
- Never resolve/ack PagerDuty from here, regardless of outcome.

## Next Phase

Proceed to [Phase 4: Record & Hand Off](04-record-handoff.md).
