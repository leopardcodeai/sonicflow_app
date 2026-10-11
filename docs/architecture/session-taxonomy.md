# Session Taxonomy

SonicFlow now separates product-facing session taxonomy from low-level engine modes.

## Product Modes

- Focus
- Relax
- Sleep
- Meditate

The older `Flow` engine mode remains available as SonicFlow's alpha profile. Product-facing `Creative Flow` and some Relax activities route to that engine mode without renaming the underlying audio primitive.

## Activities

Focus activities:

- Deep Work
- Creative Flow
- Light Work
- Learning
- Motivation

Relax activities:

- Unwind
- Destress
- Recharge
- Chill

Sleep activities:

- Deep Sleep
- Wind Down
- Power Nap
- Guided Sleep

Meditate activities:

- Guided Meditation
- Unguided Meditation

## Timers

- Pomodoro: 25 minutes with interval semantics for Focus activities.
- Short: 5 minutes for quick motivation or recharge sessions.
- Standard: 25 minutes for general sessions.
- Power nap: 20 minutes.
- Infinite sleep: no fixed duration; playback continues until stopped.

## Guardrails

This taxonomy is a product/navigation model. It does not imply clinical efficacy or patented neural phase-locking. Engine behavior and science claims remain governed by `docs/architecture/modulation-engine.md`.
