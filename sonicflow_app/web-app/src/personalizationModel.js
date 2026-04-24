import { selectActivity } from "./sessionModel.js";

export const GENRES = [
  "lo-fi",
  "cinematic",
  "electronic",
  "acoustic",
  "nature",
  "classical"
];

export const INTENSITIES = ["low", "medium", "high"];

const FOCUS_PATTERN_DEFAULTS = {
  "deep-work": {
    neurotype: "steady-focus",
    defaultActivity: "deep-work"
  },
  distractible: {
    neurotype: "high-support",
    defaultActivity: "deep-work"
  },
  "creative-block": {
    neurotype: "creative-flow",
    defaultActivity: "creative-flow"
  },
  stress: {
    neurotype: "recovery-led",
    defaultActivity: "unwind"
  },
  "low-energy": {
    neurotype: "activation-led",
    defaultActivity: "motivation"
  }
};

export function createPersonalizationProfile(answers) {
  const pattern = FOCUS_PATTERN_DEFAULTS[answers.focusPattern] ?? FOCUS_PATTERN_DEFAULTS["deep-work"];
  const genre = GENRES.includes(answers.genre) ? answers.genre : "lo-fi";
  return {
    schemaVersion: 1,
    source: "local-onboarding",
    sync: { status: "local-only", updatedAt: null },
    neurotype: answers.attentionSupport === "adhd-self-reported"
      ? "high-support"
      : pattern.neurotype,
    defaultActivity: pattern.defaultActivity,
    defaultIntensity: resolveIntensity(answers),
    genre
  };
}

export function updateProfilePreferences(profile, preferences) {
  return {
    ...profile,
    genre: GENRES.includes(preferences.genre) ? preferences.genre : profile.genre,
    defaultIntensity: INTENSITIES.includes(preferences.defaultIntensity)
      ? preferences.defaultIntensity
      : profile.defaultIntensity
  };
}

export function deriveSessionDefaults(currentSession, profile) {
  return {
    ...selectActivity(currentSession, profile.defaultActivity),
    intensity: profile.defaultIntensity,
    genre: profile.genre
  };
}

function resolveIntensity(answers) {
  if (answers.sensitivity === "gentle") {
    return "low";
  }
  if (answers.sensitivity === "strong" || answers.attentionSupport === "adhd-self-reported") {
    return "high";
  }
  return "medium";
}
