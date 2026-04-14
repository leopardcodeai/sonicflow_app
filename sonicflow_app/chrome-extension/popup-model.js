export const MODES = [
  {
    id: "focus",
    name: "Focus",
    beatHz: 40,
    description: "Sharpens attention for deep work.",
    color: "#378ADD"
  },
  {
    id: "flow",
    name: "Flow",
    beatHz: 10,
    description: "Balances calm and creative momentum.",
    color: "#7F77DD"
  },
  {
    id: "meditation",
    name: "Meditation",
    beatHz: 6,
    description: "Soft theta pacing for inward focus.",
    color: "#1D9E75"
  },
  {
    id: "sleep",
    name: "Sleep",
    beatHz: 2,
    description: "Slow down gently toward rest.",
    color: "#534AB7"
  }
];

export const DEFAULT_SETTINGS = {
  mode: "focus",
  volume: 15,
  active: false
};
