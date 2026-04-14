const DEFAULT_AMPLITUDE = 0.12;
const DEFAULT_SAMPLE_RATE = 44100;
const FADE_SECONDS = 5;

export const MODES = {
  focus: {
    name: "Focus",
    beatHz: 40,
    carrierHz: 200,
    description: "Fast gamma modulation for alert concentration.",
    color: "#378ADD"
  },
  flow: {
    name: "Flow",
    beatHz: 10,
    carrierHz: 200,
    description: "Balanced alpha pulse for calm productivity.",
    color: "#7F77DD"
  },
  meditation: {
    name: "Meditation",
    beatHz: 6,
    carrierHz: 180,
    description: "Gentle theta movement for inward attention.",
    color: "#1D9E75"
  },
  sleep: {
    name: "Sleep",
    beatHz: 2,
    carrierHz: 150,
    description: "Slow delta pulse for downshifting and rest.",
    color: "#534AB7"
  }
};

function resolveMode(mode) {
  if (typeof mode === "string" && MODES[mode]) {
    return MODES[mode];
  }

  throw new Error(`Unknown mode: ${mode}`);
}

function envelopeAt(index, totalFrames, fadeFrames) {
  if (totalFrames <= 1) {
    return 0;
  }

  if (fadeFrames <= 0) {
    return 1;
  }

  if (index < fadeFrames) {
    return index / fadeFrames;
  }

  const fadeOutStart = totalFrames - fadeFrames;
  if (index >= fadeOutStart) {
    return Math.max((totalFrames - 1 - index) / fadeFrames, 0);
  }

  return 1;
}

export class BeatEngine {
  generate(mode, durationSeconds, sampleRate = DEFAULT_SAMPLE_RATE) {
    const definition = resolveMode(mode);
    const totalFrames = Math.max(0, Math.floor(durationSeconds * sampleRate));
    const interleaved = new Float32Array(totalFrames * 2);
    const fadeFrames = Math.min(Math.floor(FADE_SECONDS * sampleRate), Math.floor(totalFrames / 2));

    for (let frame = 0; frame < totalFrames; frame += 1) {
      const time = frame / sampleRate;
      const carrier = Math.sin(2 * Math.PI * definition.carrierHz * time);
      const modulation = 0.5 + 0.5 * Math.sin(2 * Math.PI * definition.beatHz * time);
      const envelope = envelopeAt(frame, totalFrames, fadeFrames);
      const sample = carrier * modulation * DEFAULT_AMPLITUDE * envelope;
      const offset = frame * 2;

      interleaved[offset] = sample;
      interleaved[offset + 1] = sample;
    }

    return interleaved;
  }
}
