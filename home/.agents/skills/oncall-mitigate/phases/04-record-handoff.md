# Phase 4: Record & Hand Off

Persist the decision, tell humans, and hand the watch to `oncall-verify`.

## Objective

- Finalize `mitigation.json` + `mitigation.md`
- Offer a Teams broadcast of the decision; post only on explicit approval (what was done — never that Teams approved anything)
- Name the next skill and stop

## Execution Steps

### Step 1: Finalize Artifacts

`mitigation.md` renders the decision story: basis (synthesis leading hypothesis or safest-option mode), options considered, what was selected and by whom, execution result, and what the verifier will watch. Write both files; append timeline events.

### Step 2: Teams Broadcast (opt-in; via `teams` MCP; skipped in DRY_RUN)

Draft the message below and present it to the user. Post it ONLY if the user, in this conversation, explicitly approves sending the Teams broadcast; absent that approval, do not send — record "Teams broadcast held (not approved)" in the timeline. `DRY_RUN=1` sends nothing regardless.

```
[Mitigation] <incident title> — <id>
Basis: <leading hypothesis | safest-option mode>
Selected: <option action> (approved by <human>)
Executed: <mode, result>
Watching next: <primary watchlist signals> for <time_to_verify>
Abort if: <abort_condition>
```

If and only if approved, send one message. Broadcast-only.

### Step 3: Hand Off

Reply to the user with the decision summary plus:

> Next step: run `oncall-verify` to watch recovery over the observation window.

Then stop. Verification is a separate skill with its own timing; do not start watching here.

## Completion

Set status per SKILL.md protocol (`DONE_WITH_CONCERNS` when executed on a `no-leading-hypothesis` basis or with degraded coverage).

## Chain State

After this phase the bundle contains everything `oncall-verify` needs: watchlist inputs (`expected_effect`, `time_to_verify`, `abort_condition`), the executed action, and the symptoms that define recovery.
