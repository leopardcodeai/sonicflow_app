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

## Sleep Spatialization

Sleep profiles can add a slow stereo rocking layer that gently shifts gain between
left and right channels without raising peak amplitude beyond the engine ceiling.
The layer is sleep-only and has four explicit states:

- off: no spatial movement
- low: light movement for sensitive sessions
- medium: default sleep movement
- high: stronger rocking for headphone/speaker QA

Non-sleep modes always resolve this layer to `off`, even if a caller asks for a
sleep spatialization level.

## Research Controls

The engine and web app now expose a `modulated` vs `control` research condition.
`control` sessions keep the same mode routing and carrier frequencies while
setting modulation depth and stereo phase offset to zero. That gives analytics
and future studies an unmodulated comparison path without changing the user flow.

The web app can emit research-shaped events for:

- session start/end metadata
- subjective efficacy/calm feedback
- lightweight attention checks with accuracy and mean correct reaction time

Public-facing efficacy language remains blocked unless the claim is backed by
validated evidence or a formal research partnership.

## Stability Guarantees

Unit tests cover:

- target beat/carrier frequencies
- intensity ordering and modulation depth
- sleep-only spatialization levels and bounded stereo rocking
- control-session modulation disablement
- subjective feedback, attention checks, and science-claim gating
- fade-in/fade-out behavior
- bounded high-intensity stereo output
- long-session finite sample generation and silent loop endpoints

These tests prove deterministic synthesis behavior only. They do not prove health, sleep, productivity, or attention outcomes.
