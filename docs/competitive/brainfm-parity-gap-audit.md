# Brain.fm Parity Gap Audit

Date: 2026-04-24

Linear source: SF-33, "Competitor analysis: Brain.fm"

## Source Notes

Brain.fm currently positions itself around functional music for Focus, Sleep,
Relaxation, and Meditation, with activity variants such as Deep Work,
Creativity, Learning, Light Work, Motivation, Unwind, Destress, Recharge, Chill,
Guided Sleep, Deep Sleep, Wind Down, Power Nap, Guided Meditation, and Unguided
Meditation.

Official Brain.fm pages also describe:

- patented neuromodulation / neural phase-locking rather than binaural beats
- direct acoustic modulation, temporal patterning, and frequency shaping
- no headphone requirement
- sleep 3D spatialization / rocking or cradling effect
- science-first positioning with NSF-funded and peer-reviewed research claims
- web, iOS, Android, and desktop availability
- current public pricing of $14.99/month and $99.99/year

Primary references:

- https://www.brain.fm/pricing
- https://www.brain.fm/home
- https://www.brain.fm/blog/how-neural-phase-locking-works
- https://brainfm.helpscoutdocs.com/article/43-what-is-brain-fm

## Current SonicFlow Coverage

| Capability | Current SonicFlow state | Parity assessment |
| --- | --- | --- |
| Four functional modes | Focus, Flow, Meditation, Sleep exist across core JS, core Swift, iOS, macOS, Chrome, and Android surfaces. | Partial. Brain.fm names Relax instead of Flow; Flow is currently alpha productivity, not explicitly relaxation. |
| Target frequency bands | Gamma 40 Hz, alpha 10 Hz, theta 6 Hz, delta 2 Hz are implemented in shared engines. | Partial. Bands exist, but there is no richer mode taxonomy or activity sub-mode mapping. |
| Direct amplitude modulation | JS and Swift engines apply amplitude modulation to generated stereo PCM. | Partial. Current left/right channels are identical and simple sinusoidal modulation; no independent channel design, temporal patterning, frequency shaping, or sub-perceptual calibration. |
| Session controls | Duration, ambient mix, pulse depth, beat volume, starter sessions, source/file controls, Pomodoro, infinite sleep, and web feedback/check events exist. | Partial. Session history and aggregate reporting remain future work. |
| External audio overlay | Chrome can layer over web-tab audio; macOS has partial system/source capture; iOS and Android do not yet expose a complete Spotify/YouTube overlay mode. | Partial. This should become a first-class "Overlay Mode" across platforms where OS rules allow it. |
| Web app / PWA | Browser extension exists; standalone web app is tracked in Linear SF-34 but not implemented in the repo. | Missing. Needed for Brain.fm-style web availability and standalone browser sessions. |
| Personalization | No onboarding quiz, neurotype, genre preference, or intensity defaults. | Missing. |
| Genre/activity selection | Starter sessions exist; genres do not. | Missing for Brain.fm-level parity. |
| Offline access | README explicitly says browser shells do not offer native offline render/export/cache flows. | Missing. Mobile offline should be prioritized before desktop offline. |
| Sleep spatialization | Shared JS, Swift, and Kotlin cores expose sleep-only slow stereo rocking with off/low/medium/high levels and bounded output tests. | Partial. Needs platform UI rollout beyond the web app and speaker/headphone QA. |
| Research validation | Web app exposes modulated/control sessions, subjective feedback, lightweight attention checks, and a public science-claim gate. | Partial. EEG/fMRI partnership tracking, aggregate reporting, and validated evidence are still missing. |
| Platform coverage | Browser, iOS, macOS, Android exist. | Mostly present. Product depth varies by platform. |
| Monetization | No subscription/paywall plan in app surfaces. | Missing, but not required before core functional parity. |

## Required Parity Tracks

### 1. Mode Taxonomy and Session UX

Align the product taxonomy to the competitive baseline:

- Focus: Deep Work, Creative Flow, Light Work, Learning, Motivation
- Relax: Unwind, Destress, Recharge, Chill
- Sleep: Deep Sleep, Wind Down, Power Nap, Guided Sleep, Infinite Sleep
- Meditate: Guided Meditation, Unguided Meditation

Implementation implication:

- introduce a shared activity/sub-mode model
- decide whether current Flow becomes a Focus sub-mode or remains a branded
  alpha productivity mode
- keep one-click default sessions to avoid decision fatigue
- add Pomodoro/interval timer and infinite sleep playback

### 2. Modulation Engine Upgrade

Move beyond simple sinusoidal beat generation:

- support low/medium/high neural intensity
- support direct amplitude modulation that works over speakers
- add independent stereo channel modulation while avoiding binaural-only logic
- add temporal patterning and frequency shaping per mode
- add seamless looping for long sessions
- add tests proving modulation depth, frequency bands, and fade/loop behavior

IP note: do not claim or copy patented Brain.fm technology. Treat this as an
independent modulation engine inspired by known auditory entrainment concepts,
with legal review before using "neural phase-locking" language commercially.

### 3. Personalization

Add onboarding and defaults:

- focus challenge quiz
- ADHD/self-reported attention support path
- genre preferences
- neurotype/intensity assignment
- per-session intensity override

Data model requirements:

- local-first profile model
- sync-ready shape for future Supabase/backend work
- privacy-safe analytics events

### 4. Offline Mobile

Mobile should support offline sessions first:

- render/cache generated session assets
- download/delete UI
- storage quota handling
- offline availability indicators
- no offline promise on browser shells

### 5. Sleep Spatialization

Add a sleep-specific spatial layer:

- slow stereo pan / 3D rocking profile: implemented in shared JS, Swift, and Kotlin cores
- low-distraction movement curve: implemented as slow 0.04 Hz rocking
- no abrupt dynamic shifts: covered by bounded synthesis tests
- speaker and headphone QA: still required
- disable/soften spatialization at low intensity: supported through off/low/medium/high levels

### 6. Scientific Validation and Claims Gate

Build the measurement layer before strong claims:

- placebo/unmodulated control sessions: implemented in shared engines/web model
- sustained-attention task integration: lightweight web attention check implemented
- subjective efficacy feedback: implemented in web model
- anonymous aggregate reporting
- formal research-partnership tracker
- marketing copy gate: implemented as a blocked/validated/wellness claim resolver

### 7. External Audio Overlay Mode

SonicFlow has a distinct product advantage that should be treated as a core
mode, not a hidden implementation detail: layering functional modulation over
audio the user already plays in Spotify, YouTube, Apple Music, podcasts, or
browser tabs.

Target behavior:

- Overlay Mode is explicit in the UI next to standalone sessions.
- The user can choose an external source where the platform permits it.
- The functional layer stays low-distraction and mixes under the primary media.
- Mode, activity, intensity, duration, and Pomodoro/infinite timers still apply.
- Source status is always honest: connected, unavailable, permission needed, or
  browser-tab only.

Platform rules:

- Web app / PWA: support standalone generated sessions first; expose Overlay Mode
  only where browser APIs or companion extension permissions make it reliable.
- Chrome/web extension: prioritize YouTube and supported browser tabs with the
  existing content-script/tab-audio path.
- macOS: use system capture where permitted and keep file fallback.
- iOS: system-wide Spotify/YouTube capture is not generally available; support
  local/media-library or app-owned playback first and avoid promising full
  Spotify overlay unless a compliant API path exists.
- Android: investigate media session / audio capture policy, then implement only
  sources that are legal and technically reliable.

Acceptance criteria:

- Overlay Mode has a shared product model and platform capability matrix.
- Unsupported sources fail gracefully with clear UI copy.
- Browser and macOS implementations can mix the SonicFlow layer with active
  external audio without hijacking playback.
- Verification covers source selection, permission states, and session-state
  continuity when source availability changes.

## Recommended Execution Order

1. Ship taxonomy/session controls: Brain.fm-like modes, activities, intensity,
   Pomodoro, and infinite sleep.
2. Upgrade the modulation engine with tests before changing marketing claims.
3. Add personalization profile and genre preferences.
4. Add offline mobile render/cache.
5. Add sleep spatialization.
6. Promote External Audio Overlay Mode across browser and macOS, then define
   compliant mobile fallbacks.
7. Add research validation tooling and keep science claims conservative until
   external validation exists.

## Immediate Product Decision

SonicFlow should not market itself as having Brain.fm-equivalent patented neural
phase-locking. The safe target is feature parity in user outcomes and independent
audio-engine capability: purpose-built functional audio, explicit activity modes,
speaker-compatible modulation, low-distraction sessions, and measurable efficacy.
