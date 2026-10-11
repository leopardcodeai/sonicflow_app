const DEFAULT_AMPLITUDE = 0.12;
const DEFAULT_SAMPLE_RATE = 44100;
const FADE_SECONDS = 5;
const TWO_PI = 2 * Math.PI;

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

export const NEURAL_INTENSITIES = {
  low: {
    modulationDepth: 0.35,
    outputGain: 0.55,
    stereoPhaseOffset: 0
  },
  medium: {
    modulationDepth: 0.65,
    outputGain: 0.8,
    stereoPhaseOffset: Math.PI / 9
  },
  high: {
    modulationDepth: 0.95,
    outputGain: 1,
    stereoPhaseOffset: Math.PI / 4
  }
};

export const SLEEP_SPATIALIZATION = {
  off: {
    enabled: false,
    rockingHz: 0,
    panDepth: 0
  },
  low: {
    enabled: true,
    rockingHz: 0.04,
    panDepth: 0.12
  },
  medium: {
    enabled: true,
    rockingHz: 0.04,
    panDepth: 0.28
  },
  high: {
    enabled: true,
    rockingHz: 0.04,
    panDepth: 0.48
  }
};

export const MODULATION_PROFILES = {
  focus: {
    mode: "focus",
    targetBeatHz: MODES.focus.beatHz,
    carrierHz: MODES.focus.carrierHz
  },
  relax: {
    mode: "flow",
    targetBeatHz: MODES.flow.beatHz,
    carrierHz: MODES.flow.carrierHz
  },
  sleep: {
    mode: "sleep",
    targetBeatHz: MODES.sleep.beatHz,
    carrierHz: MODES.sleep.carrierHz
  },
  meditate: {
    mode: "meditation",
    targetBeatHz: MODES.meditation.beatHz,
    carrierHz: MODES.meditation.carrierHz
  }
};

function resolveMode(mode) {
  if (typeof mode === "string" && MODES[mode]) {
    return MODES[mode];
  }

  throw new Error(`Unknown mode: ${mode}`);
}

export function resolveModulationProfile(programOrMode, intensity = "medium") {
  const options = normalizeProfileOptions(intensity);
  const profile = MODULATION_PROFILES[programOrMode] ?? profileForMode(programOrMode);
  const intensityProfile = NEURAL_INTENSITIES[options.intensity];

  if (!profile) {
    throw new Error(`Unknown modulation profile: ${programOrMode}`);
  }

  if (!intensityProfile) {
    throw new Error(`Unknown neural intensity: ${options.intensity}`);
  }

  const researchCondition = options.researchCondition === "control" ? "control" : "modulated";
  const modulationDepth = researchCondition === "control" ? 0 : intensityProfile.modulationDepth;
  const stereoPhaseOffset = researchCondition === "control" ? 0 : intensityProfile.stereoPhaseOffset;

  return {
    ...profile,
    intensity: options.intensity,
    researchCondition,
    modulationDepth,
    outputGain: intensityProfile.outputGain,
    stereoPhaseOffset,
    sleepSpatialization: resolveSleepSpatialization(profile.mode, options.sleepSpatialization)
  };
}

function normalizeProfileOptions(intensityOrOptions) {
  if (typeof intensityOrOptions === "string") {
    return {
      intensity: intensityOrOptions,
      researchCondition: "modulated",
      sleepSpatialization: "off"
    };
  }

  return {
    intensity: intensityOrOptions?.intensity ?? "medium",
    researchCondition: intensityOrOptions?.researchCondition ?? "modulated",
    sleepSpatialization: intensityOrOptions?.sleepSpatialization ?? "off"
  };
}

function resolveSleepSpatialization(mode, requestedLevel) {
  if (mode !== "sleep") {
    return SLEEP_SPATIALIZATION.off;
  }

  return SLEEP_SPATIALIZATION[requestedLevel] ?? SLEEP_SPATIALIZATION.off;
}

function profileForMode(mode) {
  const definition = MODES[mode];
  if (!definition) {
    return null;
  }

  return {
    mode,
    targetBeatHz: definition.beatHz,
    carrierHz: definition.carrierHz
  };
}

function legacyProfile(mode) {
  const definition = resolveMode(mode);
  return {
    mode,
    targetBeatHz: definition.beatHz,
    carrierHz: definition.carrierHz,
    modulationDepth: 1,
    outputGain: 1,
    stereoPhaseOffset: 0
  };
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
  generate(mode, durationSeconds, sampleRate = DEFAULT_SAMPLE_RATE, options = null) {
    const profile = options
      ? resolveModulationProfile(mode, options)
      : legacyProfile(mode);
    const totalFrames = Math.max(0, Math.floor(durationSeconds * sampleRate));
    const interleaved = new Float32Array(totalFrames * 2);
    const fadeFrames = Math.min(Math.floor(FADE_SECONDS * sampleRate), Math.floor(totalFrames / 2));
    const carrierAngularStep = TWO_PI * profile.carrierHz / sampleRate;
    const beatAngularStep = TWO_PI * profile.targetBeatHz / sampleRate;
    const spatial = profile.sleepSpatialization ?? SLEEP_SPATIALIZATION.off;
    const spatialAngularStep = spatial.enabled ? TWO_PI * spatial.rockingHz / sampleRate : 0;
    const spatialNormalizer = spatial.enabled ? 1 + spatial.panDepth : 1;
    const amplitudeGain = DEFAULT_AMPLITUDE * profile.outputGain;

    for (let frame = 0; frame < totalFrames; frame += 1) {
      const carrier = Math.sin(carrierAngularStep * frame);
      const beatPhase = beatAngularStep * frame;
      const leftModulation = amplitudeModulation(profile, beatPhase, 0);
      const rightModulation = amplitudeModulation(profile, beatPhase, profile.stereoPhaseOffset);
      let leftSpatialGain = 1;
      let rightSpatialGain = 1;
      if (spatial.enabled) {
        const pan = spatial.panDepth * Math.sin(spatialAngularStep * frame);
        leftSpatialGain = (1 - pan) / spatialNormalizer;
        rightSpatialGain = (1 + pan) / spatialNormalizer;
      }
      const envelope = envelopeAt(frame, totalFrames, fadeFrames);
      const offset = frame * 2;

      interleaved[offset] = carrier * leftModulation * amplitudeGain * envelope * leftSpatialGain;
      interleaved[offset + 1] = carrier * rightModulation * amplitudeGain * envelope * rightSpatialGain;
    }

    return interleaved;
  }
}

function amplitudeModulation(profile, beatPhase, phaseOffset) {
  const lfo = 0.5 + 0.5 * Math.sin(beatPhase + phaseOffset);
  return (1 - profile.modulationDepth) + (profile.modulationDepth * lfo);
}
