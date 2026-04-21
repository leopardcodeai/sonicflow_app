export const MODES = [
  {
    id: "focus",
    name: "Focus",
    beatHz: 40,
    description: "Sharpens attention for deep work.",
    color: "var(--mode-focus)",
    ambientMix: 45,
    pulseDepth: 95
  },
  {
    id: "flow",
    name: "Flow",
    beatHz: 10,
    description: "Balances calm and creative momentum.",
    color: "var(--mode-flow)",
    ambientMix: 55,
    pulseDepth: 78
  },
  {
    id: "meditation",
    name: "Meditation",
    beatHz: 6,
    description: "Soft theta pacing for inward focus.",
    color: "var(--mode-meditation)",
    ambientMix: 68,
    pulseDepth: 62
  },
  {
    id: "sleep",
    name: "Sleep",
    beatHz: 2,
    description: "Slow down gently toward rest.",
    color: "var(--mode-sleep)",
    ambientMix: 78,
    pulseDepth: 46
  }
];

export const EXAMPLES = [
  {
    id: "focus-primer",
    title: "Focus Primer",
    subtitle: "5 min gamma warmup",
    mode: "focus",
    durationMinutes: 5,
    ambientMix: 45,
    pulseDepth: 95
  },
  {
    id: "flow-reset",
    title: "Flow Reset",
    subtitle: "5 min alpha reset",
    mode: "flow",
    durationMinutes: 5,
    ambientMix: 55,
    pulseDepth: 78
  },
  {
    id: "night-drift",
    title: "Night Drift",
    subtitle: "5 min delta wind-down",
    mode: "sleep",
    durationMinutes: 5,
    ambientMix: 78,
    pulseDepth: 46
  }
];

export const DEFAULT_SETTINGS = {
  mode: "focus",
  volume: 15,
  active: false,
  durationMinutes: 25,
  ambientMix: 45,
  pulseDepth: 95
};
