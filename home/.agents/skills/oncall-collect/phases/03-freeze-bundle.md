# Phase 3: Freeze Bundle

Build `evidence-index.json` and declare the bundle frozen for investigators.

## Objective

- Enumerate every evidence file with its sha256
- Record coverage per evidence class
- Make the freeze explicit in the timeline

## Execution Steps

### Step 1: Build the Index

For every file under the bundle (excluding `evidence-index.json` itself and `hypotheses/`, `synthesis.*` which come after):

```bash
find ~/.incidents/<id> -type f -not -path '*/hypotheses/*' -not -name 'evidence-index.json' -not -name 'synthesis.*'
```

For each: relative path, `sha256` (`shasum -a 256`), `collected_at`, one-line note.

### Step 2: Record Coverage

Per [specs/evidence-bundle-format.md](../specs/evidence-bundle-format.md): `metrics`, `logs`, `traces`, `cloudtrail` each `ok | degraded | unavailable | not-configured`. An empty `metrics/` with a working Datadog server is `unavailable` (query failure), not `not-configured`.

### Step 3: Write and Declare

Write `evidence-index.json`; append the freeze event to `timeline.json`.

## Freeze Contract

From this point:

- Investigators (Phase 4) read only files in this index.
- The synthesizer discards verdicts citing anything else.
- Need fresh evidence? Re-run collection — new `frozen_at`, new index version. Never edit frozen files in place.

## Next Phase

Proceed to [Phase 4: Dispatch Hypotheses](04-dispatch-hypotheses.md).
