# Phase 4: Record & Hand Off

Persist the decision, tell humans, and hand the watch to `oncall-verify`.

## Objective

- Finalize `mitigation.json` + `mitigation.md`
- Broadcast the decision to Teams (what was done — never that Teams approved anything)
- Name the next skill and stop

## Execution Steps

### Step 1: Finalize Artifacts

`mitigation.md` renders the decision story: basis (synthesis leading hypothesis or safest-option mode), options considered, what was selected and by whom, execution result, and what the verifier will watch. Write both files; append timeline events.

### Step 2: Teams Broadcast (via `teams` MCP; skipped in DRY_RUN)

```
[Mitigation] <incident title> — <id>
Basis: <leading hypothesis | safest-option mode>
Selected: <option action> (approved by <human>)
Executed: <mode, result>
Watching next: <primary watchlist signals> for <time_to_verify>
Abort if: <abort_condition>
```

One message. Broadcast-only.

### Step 3: Hand Off

Reply to the user with the decision summary plus:

> Next step: run `oncall-verify` to watch recovery over the observation window.

Then stop. Verification is a separate skill with its own timing; do not start watching here.

## Completion

Set status per SKILL.md protocol (`DONE_WITH_CONCERNS` when executed on a `no-leading-hypothesis` basis or with degraded coverage).

## Chain State

After this phase the bundle contains everything `oncall-verify` needs: watchlist inputs (`expected_effect`, `time_to_verify`, `abort_condition`), the executed action, and the symptoms that define recovery.
