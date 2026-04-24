import {
  PRODUCT_MODES,
  resolveSessionPlan
} from "../../chrome-extension/popup-model.js";

export const DEFAULT_WEB_SESSION = {
  intensity: "medium",
  volume: 18,
  isPlaying: false
};

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
  return {
    ...currentState,
    productMode: sessionPlan.productMode,
    activityId: sessionPlan.activityId,
    engineMode: sessionPlan.engineMode,
    timerId: sessionPlan.timerId,
    durationMinutes: sessionPlan.durationMinutes,
    isInfinite: sessionPlan.isInfinite
  };
}
