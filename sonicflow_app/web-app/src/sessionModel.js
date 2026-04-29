import {
  PRODUCT_MODES,
  resolveSessionPlan
} from "../../safari-web-extension/popup-model.js";

export const DEFAULT_WEB_SESSION = {
  intensity: "medium",
  volume: 18,
  sleepSpatialization: "off",
  researchCondition: "modulated",
  isPlaying: false
};

export const SLEEP_SPATIALIZATION_LEVELS = ["off", "low", "medium", "high"];
export const RESEARCH_CONDITIONS = ["modulated", "control"];

export function createInitialSessionState() {
  const focusMode = PRODUCT_MODES.find((mode) => mode.id === "focus") ?? PRODUCT_MODES[0];
  return applySessionPlan(
    {
      productMode: focusMode.id,
      ...DEFAULT_WEB_SESSION
    },
    resolveSessionPlan(focusMode.defaultActivity)
  );
}

export function selectProductMode(currentState, productModeId) {
  const productMode = PRODUCT_MODES.find((mode) => mode.id === productModeId);
  if (!productMode) {
    throw new Error(`Unknown product mode: ${productModeId}`);
  }

  return applySessionPlan(currentState, resolveSessionPlan(productMode.defaultActivity));
}

export function selectActivity(currentState, activityId) {
  return applySessionPlan(currentState, resolveSessionPlan(activityId));
}

export function setDurationMinutes(currentState, durationMinutes) {
  const normalizedDuration = Math.max(5, Math.min(120, Number(durationMinutes)));
  return {
    ...currentState,
    timerId: "standard",
    durationMinutes: normalizedDuration,
    isInfinite: false
  };
}

export function setSleepSpatialization(currentState, level) {
  const normalizedLevel = SLEEP_SPATIALIZATION_LEVELS.includes(level) ? level : "off";
  return {
    ...currentState,
    sleepSpatialization: currentState.productMode === "sleep" ? normalizedLevel : "off"
  };
}

export function setResearchCondition(currentState, condition) {
  const normalizedCondition = RESEARCH_CONDITIONS.includes(condition) ? condition : "modulated";
  return {
    ...currentState,
    researchCondition: normalizedCondition
  };
}

export function createResearchSessionEvent(currentState, type) {
  const researchCondition = currentState.researchCondition ?? "modulated";
  return {
    type,
    productMode: currentState.productMode,
    activityId: currentState.activityId,
    engineMode: currentState.engineMode,
    researchCondition,
    modulation: researchCondition === "control" ? "unmodulated" : "active",
    intensity: currentState.intensity,
    sleepSpatialization: currentState.sleepSpatialization ?? "off"
  };
}

export function createFeedbackEvent(currentState, feedback) {
  return {
    ...createResearchSessionEvent(currentState, "subjective_feedback"),
    effectiveness: clampRating(feedback.effectiveness),
    calm: clampRating(feedback.calm)
  };
}

export function scoreAttentionTask(currentState, trials) {
  const safeTrials = Array.isArray(trials) ? trials : [];
  const correctTrials = safeTrials.filter((trial) => trial.correct);
  const reactionTimes = correctTrials
    .map((trial) => Number(trial.reactionMs))
    .filter((reactionMs) => Number.isFinite(reactionMs) && reactionMs >= 0);
  const meanReactionMs = reactionTimes.length === 0
    ? null
    : Math.round(reactionTimes.reduce((total, reactionMs) => total + reactionMs, 0) / reactionTimes.length);

  return {
    ...createResearchSessionEvent(currentState, "attention_check"),
    trialCount: safeTrials.length,
    accuracy: safeTrials.length === 0 ? 0 : correctTrials.length / safeTrials.length,
    meanReactionMs
  };
}

export function resolveScienceClaim({ requestedClaim = "wellness", evidenceValidated = false } = {}) {
  if (requestedClaim === "efficacy" && !evidenceValidated) {
    return {
      allowed: false,
      claimLevel: "blocked",
      copy: "Efficacy claims require validated evidence or a formal research partnership before publication."
    };
  }

  if (requestedClaim === "efficacy") {
    return {
      allowed: true,
      claimLevel: "validated-efficacy",
      copy: "Validated research-backed efficacy language may be used with cited evidence."
    };
  }

  return {
    allowed: true,
    claimLevel: "wellness",
    copy: "Generated audio sessions for focus, relaxation, meditation, and sleep routines."
  };
}

export function detectOverlayCapability(environment = globalThis) {
  const navigatorRef = environment.navigator ?? {};
  const canRequestDisplayAudio = Boolean(navigatorRef.mediaDevices?.getDisplayMedia);
  const canInstallPwa = Boolean(environment.isSecureContext && navigatorRef.serviceWorker);

  return {
    standaloneSessions: "supported",
    browserTabOverlay: canRequestDisplayAudio ? "browser-api-review" : "extension-required",
    installablePwa: canInstallPwa ? "supported" : "limited",
    message: canRequestDisplayAudio
      ? "Standalone sessions are available. Browser capture may be browser-specific and permission-gated."
      : "Standalone sessions are available. Browser-tab overlay needs the SonicFlow extension."
  };
}

function applySessionPlan(currentState, sessionPlan) {
  const sleepSpatialization = sessionPlan.productMode === "sleep"
    ? (currentState.productMode === "sleep" ? currentState.sleepSpatialization ?? "medium" : "medium")
    : "off";

  return {
    ...currentState,
    productMode: sessionPlan.productMode,
    activityId: sessionPlan.activityId,
    engineMode: sessionPlan.engineMode,
    timerId: sessionPlan.timerId,
    durationMinutes: sessionPlan.durationMinutes,
    sleepSpatialization,
    isInfinite: sessionPlan.isInfinite
  };
}

function clampRating(value) {
  const numericValue = Number(value);
  if (!Number.isFinite(numericValue)) {
    return null;
  }
  return Math.max(1, Math.min(5, Math.round(numericValue)));
}
