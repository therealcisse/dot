# Phase 5: Known-Incident Lookup

Has this service looked like this before? Two sources: PagerDuty history and graduated local lessons.

## Objective

- Search PD incident history for the same service, last 90 days, similar titles/alerts
- Grep this skill's `references/` directory by symptom keywords
- Write matches to `known-incidents/`
- Surface recurrence — the third checkout-latency page this month changes the hypotheses Phase 6 forms

## Execution Steps

### Step 1: PagerDuty History (via `pagerduty` MCP)

Query resolved + triggering incidents for the service, last 90 days, limit ~20. Score similarity on title keywords and alert dedup keys/monitor names:

- Strong match: same monitors alerting, similar title → record with `similarity: strong`
- Weak match: same service, different symptom → record with `similarity: weak`

Write `known-incidents/history.json` with id, title, created_at, resolved_at, duration, similarity, and one-line outcome if notes contain it.

### Step 2: Local References (Glob + Grep)

Grep **both** reference locations for symptom keywords (latency, error, 5xx, saturation, lag, timeout, connection, throttle — derived from the actual symptom names, not a fixed list):

1. `~/.config/oncall/references/*.md` — work-specific lessons (may name real services; stays out of the dot repo)
2. `references/*.md` in this skill — sanitized, non-work-specific lessons only

For each hit, record location, filename, and the matching section into `known-incidents/reference-hits.json`.

Both empty → empty result, recorded as `{"hits": []}`.

### Step 3: Recurrence Signal

If ≥2 strong history matches within 30 days, set a `recurrent: true` flag and carry it into Phase 6 — recurring incidents bias hypotheses toward previously confirmed causes *as candidates only*, still subject to falsification later.

## Output

- `known-incidents/history.json`
- `known-incidents/reference-hits.json`
- Recurrence flag for Phase 6

## Quality Checks

- [ ] History search anchored to the mapped PD service, not a keyword guess
- [ ] Reference hits cite file + section
- [ ] Recurrence only set on strong matches

## Next Phase

Proceed to [Phase 6: Emit Triage Report](06-emit-report.md).
