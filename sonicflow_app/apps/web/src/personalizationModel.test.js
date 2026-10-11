import test from "node:test";
import assert from "node:assert/strict";

import { createInitialSessionState } from "./sessionModel.js";
import {
  createPersonalizationProfile,
  deriveSessionDefaults,
  updateProfilePreferences
} from "./personalizationModel.js";

test("quiz answers produce deterministic high-support focus defaults", () => {
  const profile = createPersonalizationProfile({
    focusPattern: "distractible",
    attentionSupport: "adhd-self-reported",
    sensitivity: "balanced",
    genre: "electronic"
  });

  assert.deepEqual(profile, {
    schemaVersion: 1,
    source: "local-onboarding",
    sync: { status: "local-only", updatedAt: null },
    neurotype: "high-support",
    defaultActivity: "deep-work",
    defaultIntensity: "high",
    genre: "electronic"
  });
});

test("quiz answers can produce recovery-led low-intensity defaults", () => {
  const profile = createPersonalizationProfile({
    focusPattern: "stress",
    attentionSupport: "standard",
    sensitivity: "gentle",
    genre: "nature"
  });

  assert.equal(profile.neurotype, "recovery-led");
  assert.equal(profile.defaultActivity, "unwind");
  assert.equal(profile.defaultIntensity, "low");
  assert.equal(profile.genre, "nature");
});

test("profile preferences remain editable after onboarding", () => {
  const profile = createPersonalizationProfile({
    focusPattern: "creative-block",
    attentionSupport: "standard",
    sensitivity: "strong",
    genre: "cinematic"
  });
  const updated = updateProfilePreferences(profile, {
    genre: "lo-fi",
    defaultIntensity: "medium"
  });

  assert.equal(updated.defaultActivity, "creative-flow");
  assert.equal(updated.genre, "lo-fi");
  assert.equal(updated.defaultIntensity, "medium");
});

test("session defaults derive activity and intensity from profile", () => {
  const profile = createPersonalizationProfile({
    focusPattern: "creative-block",
    attentionSupport: "standard",
    sensitivity: "balanced",
    genre: "acoustic"
  });
  const session = deriveSessionDefaults(createInitialSessionState(), profile);

  assert.equal(session.activityId, "creative-flow");
  assert.equal(session.engineMode, "flow");
  assert.equal(session.timerId, "pomodoro");
  assert.equal(session.intensity, "medium");
  assert.equal(session.genre, "acoustic");
});
