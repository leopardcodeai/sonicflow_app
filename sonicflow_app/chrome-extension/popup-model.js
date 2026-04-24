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

export const PRODUCT_MODES = [
  { id: "focus", label: "Focus", defaultActivity: "deep-work" },
  { id: "relax", label: "Relax", defaultActivity: "unwind" },
  { id: "sleep", label: "Sleep", defaultActivity: "wind-down" },
  { id: "meditate", label: "Meditate", defaultActivity: "unguided-meditation" }
];

export const SESSION_TIMERS = {
  pomodoro: {
    id: "pomodoro",
    label: "Pomodoro",
    durationMinutes: 25,
    intervalMinutes: 5,
    repeats: 1
  },
  short: {
    id: "short",
    label: "Short",
    durationMinutes: 5,
    intervalMinutes: null,
    repeats: 1
  },
  standard: {
    id: "standard",
    label: "Standard",
    durationMinutes: 25,
    intervalMinutes: null,
    repeats: 1
  },
  "power-nap": {
    id: "power-nap",
    label: "Power nap",
    durationMinutes: 20,
    intervalMinutes: null,
    repeats: 1
  },
  "infinite-sleep": {
    id: "infinite-sleep",
    label: "Infinite sleep",
    durationMinutes: null,
    intervalMinutes: null,
    repeats: null
  }
};

export const SESSION_ACTIVITIES = [
  { id: "deep-work", label: "Deep Work", mode: "focus", engineMode: "focus", defaultTimer: "pomodoro" },
  { id: "creative-flow", label: "Creative Flow", mode: "focus", engineMode: "flow", defaultTimer: "pomodoro" },
  { id: "light-work", label: "Light Work", mode: "focus", engineMode: "flow", defaultTimer: "standard" },
  { id: "learning", label: "Learning", mode: "focus", engineMode: "focus", defaultTimer: "pomodoro" },
  { id: "motivation", label: "Motivation", mode: "focus", engineMode: "focus", defaultTimer: "short" },
  { id: "unwind", label: "Unwind", mode: "relax", engineMode: "flow", defaultTimer: "standard" },
  { id: "destress", label: "Destress", mode: "relax", engineMode: "meditation", defaultTimer: "standard" },
  { id: "recharge", label: "Recharge", mode: "relax", engineMode: "flow", defaultTimer: "short" },
  { id: "chill", label: "Chill", mode: "relax", engineMode: "flow", defaultTimer: "standard" },
  { id: "deep-sleep", label: "Deep Sleep", mode: "sleep", engineMode: "sleep", defaultTimer: "infinite-sleep" },
  { id: "wind-down", label: "Wind Down", mode: "sleep", engineMode: "sleep", defaultTimer: "infinite-sleep" },
  { id: "power-nap", label: "Power Nap", mode: "sleep", engineMode: "sleep", defaultTimer: "power-nap" },
  { id: "guided-sleep", label: "Guided Sleep", mode: "sleep", engineMode: "sleep", defaultTimer: "infinite-sleep" },
  { id: "guided-meditation", label: "Guided Meditation", mode: "meditate", engineMode: "meditation", defaultTimer: "standard" },
  { id: "unguided-meditation", label: "Unguided Meditation", mode: "meditate", engineMode: "meditation", defaultTimer: "standard" }
];

export function resolveSessionActivity(activityId) {
  const activity = SESSION_ACTIVITIES.find((entry) => entry.id === activityId);
  if (!activity) {
    throw new Error(`Unknown session activity: ${activityId}`);
  }
  return {
    id: activity.id,
    mode: activity.mode,
    engineMode: activity.engineMode,
    defaultTimer: activity.defaultTimer
  };
}

export function resolveSessionTimer(timerId) {
  const timer = SESSION_TIMERS[timerId];
  if (!timer) {
    throw new Error(`Unknown session timer: ${timerId}`);
  }
  return timer;
}

export function resolveSessionPlan(activityId) {
  const activity = resolveSessionActivity(activityId);
  const timer = resolveSessionTimer(activity.defaultTimer);
  return {
    activityId: activity.id,
    productMode: activity.mode,
    engineMode: activity.engineMode,
    timerId: timer.id,
    durationMinutes: timer.durationMinutes,
    isInfinite: timer.durationMinutes === null
  };
}

export const OVERLAY_SOURCES = [
  {
    id: "browser-tab",
    label: "Browser tab",
    status: "Available",
    description: "Layer SonicFlow under YouTube, SoundCloud, and pages with audio or video."
  },
  {
    id: "macos-system",
    label: "macOS system",
    status: "Native app",
    description: "Use the macOS app for permitted system audio capture."
  },
  {
    id: "ios-local",
    label: "iOS local",
    status: "Local only",
    description: "Picked files can layer with SonicFlow. Spotify and YouTube capture are unavailable."
  },
  {
    id: "android-policy-review",
    label: "Android",
    status: "Policy review",
    description: "External app capture needs platform and store policy review."
  }
];

export function resolveOverlayStatus(tabState) {
  if (tabState?.pageHasAudioSource) {
    return {
      ready: true,
      message: "Overlay ready for this browser tab."
    };
  }

  return {
    ready: false,
    message: "Open YouTube, SoundCloud, or another supported media tab first."
  };
}

export const DEFAULT_SETTINGS = {
  mode: "focus",
  activityId: "deep-work",
  timerId: "pomodoro",
  overlaySource: "browser-tab",
  volume: 15,
  active: false,
  durationMinutes: 25,
  ambientMix: 45,
  pulseDepth: 95
};
