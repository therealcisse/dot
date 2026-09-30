# Confidence Calibration

The one confidence scale shared by investigators, reviewers, and the synthesizer. The 0.5 leading-hypothesis threshold only means something if every agent scores the same way.

## Bands

| band | evidence required |
|------|-------------------|
| 0.0–0.2 | No ref carries the verdict on its own; signals absent or ambiguous. No `failed-to-falsify` attempt. Not available to `SUPPORTED` |
| 0.2–0.4 | One ref carrying a single weak signal, plus ≥1 `failed-to-falsify` attempt. The ceiling for any verdict resting on one weak signal |
| 0.4–0.6 | One ref carrying a clear signal, or ≥2 refs from the same file or evidence class, plus ≥1 `failed-to-falsify` attempt |
| 0.6–0.8 | ≥2 independent refs, ≥1 `failed-to-falsify` attempt, and the obvious disproofs for the hypothesis class attempted |
| 0.8–1.0 | Everything in 0.6–0.8, every obvious disproof `failed-to-falsify` (none `inconclusive`), and every contradicting ref in the cited files addressed in the verdict |

The bands apply to all three verdict kinds. Confidence is always confidence in the verdict as written — for `REFUTED`, confidence in the refutation, counting `contradicting_evidence` refs in place of supporting refs and `falsified` attempts in place of `failed-to-falsify`.

## Definitions

- **Independent refs** — refs to different files, preferably from different evidence classes (metrics, logs, traces, cloudtrail, deployments). Two refs into one file are one signal.
- **Failed-to-falsify** — a `falsification_attempts` entry with `result: failed-to-falsify`: a genuine attempt to disprove the verdict that the bundle did not bear out. A strawman attempt, one that could not have disproved anything, does not count.
- **Obvious disproofs** — the disproof a competent responder would try first for that hypothesis class. Recent-change regression: symptom onset preceding the deploy. Dependency latency: the dependency's own latency flat across onset. Saturation/resource: the resource metric flat at onset. Config change: no change event in the window.
- **Supported band** — the highest band whose requirements the cited evidence meets. Stated confidence may sit anywhere in or below it, never above it.
- **Band boundaries** — a boundary value belongs to the band above it (0.4 is in 0.4–0.6; 0.8 is in 0.8–1.0). The top of a band is therefore just below its boundary: a downgrade to the top of 0.2–0.4 is written as 0.39, not 0.4.

## Who Uses It

| user | how |
|------|-----|
| hypothesis-investigator | Self-scores `confidence` against the bands before writing the verdict |
| verdict-reviewer | Flags a `calibration` defect when stated `confidence` exceeds the top of the supported band; `DOWNGRADE` with `adjusted_confidence` at that band's top |
| synthesizer (Phase 5) | Applies the 0.5 leading-hypothesis threshold to `effective_confidence` — the reviewer's `adjusted_confidence` when present, else the verdict's `confidence` |
