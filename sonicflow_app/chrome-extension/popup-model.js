export const MODES = [
  {
    id: "focus",
    name: "Focus",
    beatHz: 40,
    description: "Sharpens attention for deep work.",
    color: "var(--mode-focus)"
  },
  {
    id: "flow",
    name: "Flow",
    beatHz: 10,
    description: "Balances calm and creative momentum.",
    color: "var(--mode-flow)"
  },
  {
    id: "meditation",
    name: "Meditation",
    beatHz: 6,
    description: "Soft theta pacing for inward focus.",
    color: "var(--mode-meditation)"
  },
  {
    id: "sleep",
    name: "Sleep",
    beatHz: 2,
    description: "Slow down gently toward rest.",
    color: "var(--mode-sleep)"
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
