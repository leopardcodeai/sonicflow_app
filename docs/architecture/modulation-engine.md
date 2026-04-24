# Modulation Engine Guardrails

SonicFlow uses an independent speaker-compatible amplitude-modulation engine. It does not copy, describe, or claim Brain.fm patented neural phase-locking methods.

## Public Claim Boundary

- Product copy may describe generated sessions, target frequency bands, intensity levels, and conservative wellness-oriented use cases.
- Product copy must not claim clinical outcomes, patented entrainment methods, or validated cognitive efficacy without a separate research review.
- Any future efficacy language needs evidence from controlled studies, formal research partnership, or clearly labeled user feedback.

## Engine Model

The shared engines expose two layers:

- Legacy mode rendering for existing callers: Focus, Flow, Meditation, Sleep.
- Modulation profiles for Brain.fm-parity product taxonomy: Focus, Relax, Sleep, Meditate.

`Relax` maps to the current Flow alpha profile. `Meditate` maps to the current Meditation theta profile. This preserves existing UI names while allowing the engine API to support the broader product taxonomy.

## Intensity Model

The shared low/medium/high intensity model controls:

- modulation depth
- output gain
- stereo modulation phase offset

Default legacy rendering remains stereo-mirrored for backward compatibility. Profile-based rendering can use independent left/right amplitude modulation while staying bounded by the engine amplitude ceiling.

## Stability Guarantees

Unit tests cover:

- target beat/carrier frequencies
- intensity ordering and modulation depth
- fade-in/fade-out behavior
- bounded high-intensity stereo output
- long-session finite sample generation and silent loop endpoints

These tests prove deterministic synthesis behavior only. They do not prove health, sleep, productivity, or attention outcomes.
