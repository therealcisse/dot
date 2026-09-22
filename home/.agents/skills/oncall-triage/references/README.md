# References — Graduated Incident Lessons

Starts empty. The future postmortem skill appends lessons to `~/.config/oncall/lessons.md` and graduates recurring patterns into reference files. **Work-specific lessons (anything naming real services) live in `~/.config/oncall/references/`, never in this directory** — this repo must stay free of work identifiers. Only sanitized, generic lessons belong here.

## File Naming

One file per symptom class or recurring failure mode, kebab-case:

- `high-latency.md`
- `error-rate-spike.md`
- `consumer-lag.md`
- `connection-pool-exhaustion.md`
- `dependency-timeout.md`

## File Shape

Each file: the symptom signature as seen in Datadog/PagerDuty, known causes observed in *this* environment with incident IDs, what evidence distinguished them, and what recovered them. Written for the triage and hypothesis phases to load as context.

Phase 5 greps this directory by symptom keywords. Until files exist, that lookup simply returns empty.
