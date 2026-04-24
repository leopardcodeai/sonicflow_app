import test from "node:test";
import assert from "node:assert/strict";

import {
  createInitialSessionState,
  detectOverlayCapability,
  selectActivity,
  selectProductMode,
  setDurationMinutes
} from "./sessionModel.js";

test("creates one-click focus defaults from the shared taxonomy", () => {
  assert.deepEqual(createInitialSessionState(), {
    productMode: "focus",
    activityId: "deep-work",
    engineMode: "focus",
    timerId: "pomodoro",
    durationMinutes: 25,
    intensity: "medium",
    volume: 18,
    isPlaying: false,
    isInfinite: false
  });
});

test("maps product modes and activities to engine-ready session state", () => {
  const creative = selectActivity(createInitialSessionState(), "creative-flow");
  assert.equal(creative.productMode, "focus");
  assert.equal(creative.engineMode, "flow");
  assert.equal(creative.timerId, "pomodoro");
  assert.equal(creative.durationMinutes, 25);

  const sleep = selectProductMode(creative, "sleep");
  assert.equal(sleep.activityId, "wind-down");
  assert.equal(sleep.engineMode, "sleep");
  assert.equal(sleep.timerId, "infinite-sleep");
  assert.equal(sleep.durationMinutes, null);
  assert.equal(sleep.isInfinite, true);
});

test("manual duration exits infinite sleep without changing activity context", () => {
  const sleep = selectActivity(createInitialSessionState(), "wind-down");
  const fixed = setDurationMinutes(sleep, 45);

  assert.equal(fixed.activityId, "wind-down");
  assert.equal(fixed.timerId, "standard");
  assert.equal(fixed.durationMinutes, 45);
  assert.equal(fixed.isInfinite, false);
});

test("detects honest web overlay capability states", () => {
  assert.deepEqual(detectOverlayCapability({}), {
    standaloneSessions: "supported",
    browserTabOverlay: "extension-required",
    installablePwa: "limited",
    message: "Standalone sessions are available. Browser-tab overlay needs the SonicFlow extension."
  });

  assert.deepEqual(
    detectOverlayCapability({
      navigator: {
        mediaDevices: { getDisplayMedia() {} },
        serviceWorker: {}
      },
      isSecureContext: true
    }),
    {
      standaloneSessions: "supported",
      browserTabOverlay: "browser-api-review",
      installablePwa: "supported",
      message: "Standalone sessions are available. Browser capture may be browser-specific and permission-gated."
    }
  );
});
