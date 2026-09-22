# Phase 3: Actions & Lessons

Fix the system, then feed the memory that makes the next triage smarter.

## Objective

- Draft corrective actions (at least one tracking the root cause)
- Append lessons to `~/.config/oncall/lessons.md`
- Graduate recurring patterns into reference files

## Execution Steps

### Step 1: Corrective Actions

- At least one P1/P2 action `tracks_root_cause` when a root cause exists — fixing the cause, not just the symptom
- Sources: contributing factors, `missing_evidence` lists (each gap is a monitoring/tooling action), detection delay, gate friction
- Owners are proposed, not assigned — humans accept them. Priority: P1 = prevents recurrence of this exact cause, P2 = reduces blast radius/detection time, P3 = hygiene
- Actions are specific and testable ("add p99 canary gate on the checkout deploy pipeline"), never "improve monitoring"

### Step 2: Append Lessons

Append to `~/.config/oncall/lessons.md` (create if absent):

```
## <date> — <incident-id> — <one-line symptom>
- Fact: <what was true, with ref>
- Lesson: <what to check first next time this signature appears>
```

1–3 lines max. Facts, not feelings. This file is read by future triage Phase 5 — write for that reader. This file lives outside the repo precisely because it will name real services.

### Step 3: Graduation Check

Graduate when a pattern has now appeared ≥2 times (this incident + a strong match in `known-incidents/history.json`, or an existing reference file matches):

- Create/update `~/.config/oncall/references/<symptom-class>.md` (work-specific) or the sanitized in-repo `references/` when content contains no work identifiers
- File shape per the references README: symptom signature, known causes with incident IDs, distinguishing evidence, what recovered it
- The next triage's Phase 5 grep will find it

No recurrence → no graduation. One incident is a data point, not a pattern.

## Output

- `corrective_actions`, `lessons_appended`, `references_graduated` for the report

## Next Phase

Proceed to [Phase 4: Publish](04-publish.md).
