import test from "node:test";
import assert from "node:assert/strict";

import {
  createFeedbackEvent,
  createInitialSessionState,
  createResearchSessionEvent,
  detectOverlayCapability,
  resolveScienceClaim,
  scoreAttentionTask,
  selectActivity,
  selectProductMode,
  setResearchCondition,
  setSleepSpatialization,
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
    sleepSpatialization: "off",
    researchCondition: "modulated",
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
  assert.equal(sleep.sleepSpatialization, "medium");
});

test("manual duration exits infinite sleep without changing activity context", () => {
  const sleep = selectActivity(createInitialSessionState(), "wind-down");
  const fixed = setDurationMinutes(sleep, 45);

  assert.equal(fixed.activityId, "wind-down");
  assert.equal(fixed.timerId, "standard");
  assert.equal(fixed.durationMinutes, 45);
  assert.equal(fixed.isInfinite, false);
});

test("sleep spatialization can be toggled and resets outside sleep", () => {
  const sleep = selectProductMode(createInitialSessionState(), "sleep");
  const high = setSleepSpatialization(sleep, "high");
  const focus = selectProductMode(high, "focus");

  assert.equal(high.sleepSpatialization, "high");
  assert.equal(setSleepSpatialization(sleep, "off").sleepSpatialization, "off");
  assert.equal(focus.sleepSpatialization, "off");
});

test("research session events distinguish modulated and control sessions", () => {
  const modulated = selectProductMode(createInitialSessionState(), "sleep");
  const control = setResearchCondition(modulated, "control");

  assert.deepEqual(createResearchSessionEvent(modulated, "session_start"), {
    type: "session_start",
    productMode: "sleep",
    activityId: "wind-down",
    engineMode: "sleep",
    researchCondition: "modulated",
    modulation: "active",
    intensity: "medium",
    sleepSpatialization: "medium"
  });
  assert.equal(createResearchSessionEvent(control, "session_start").modulation, "unmodulated");
});

test("subjective feedback and attention checks are captured as research events", () => {
  const session = selectProductMode(createInitialSessionState(), "focus");
  const feedback = createFeedbackEvent(session, { effectiveness: 4, calm: 5 });
  const attention = scoreAttentionTask(session, [
    { correct: true, reactionMs: 420 },
    { correct: false, reactionMs: 900 },
    { correct: true, reactionMs: 380 }
  ]);

  assert.equal(feedback.type, "subjective_feedback");
  assert.equal(feedback.effectiveness, 4);
  assert.equal(attention.type, "attention_check");
  assert.equal(attention.accuracy, 2 / 3);
  assert.equal(attention.meanReactionMs, 400);
});

test("science claims are gated until evidence has been validated", () => {
  assert.deepEqual(resolveScienceClaim({ requestedClaim: "wellness" }), {
    allowed: true,
    claimLevel: "wellness",
    copy: "Generated audio sessions for focus, relaxation, meditation, and sleep routines."
  });
  assert.deepEqual(resolveScienceClaim({ requestedClaim: "efficacy", evidenceValidated: false }), {
    allowed: false,
    claimLevel: "blocked",
    copy: "Efficacy claims require validated evidence or a formal research partnership before publication."
  });
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
