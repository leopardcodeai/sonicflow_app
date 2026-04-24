import test from "node:test";
import assert from "node:assert/strict";

import { BeatEngine, MODES, MODULATION_PROFILES, NEURAL_INTENSITIES, resolveModulationProfile } from "./beatEngine.js";

test("exports the four expected modes", () => {
  assert.deepEqual(Object.keys(MODES), ["focus", "flow", "meditation", "sleep"]);
  assert.equal(MODES.focus.beatHz, 40);
  assert.equal(MODES.sleep.carrierHz, 150);
});

test("exports independent modulation profiles and intensity depths", () => {
  assert.deepEqual(Object.keys(MODULATION_PROFILES), ["focus", "relax", "sleep", "meditate"]);
  assert.ok(NEURAL_INTENSITIES.low.modulationDepth < NEURAL_INTENSITIES.medium.modulationDepth);
  assert.ok(NEURAL_INTENSITIES.medium.modulationDepth < NEURAL_INTENSITIES.high.modulationDepth);

  assert.equal(resolveModulationProfile("relax", "medium").targetBeatHz, 10);
  assert.equal(resolveModulationProfile("meditate", "high").targetBeatHz, 6);
});

test("sleep spatialization profiles scale rocking depth by intensity", () => {
  const off = resolveModulationProfile("sleep", { intensity: "high", sleepSpatialization: "off" });
  const low = resolveModulationProfile("sleep", { intensity: "low", sleepSpatialization: "low" });
  const medium = resolveModulationProfile("sleep", { intensity: "medium", sleepSpatialization: "medium" });
  const high = resolveModulationProfile("sleep", { intensity: "high", sleepSpatialization: "high" });
  const focus = resolveModulationProfile("focus", { intensity: "high", sleepSpatialization: "high" });

  assert.equal(off.sleepSpatialization.enabled, false);
  assert.equal(focus.sleepSpatialization.enabled, false);
  assert.ok(low.sleepSpatialization.panDepth < medium.sleepSpatialization.panDepth);
  assert.ok(medium.sleepSpatialization.panDepth < high.sleepSpatialization.panDepth);
  assert.equal(high.sleepSpatialization.rockingHz, 0.04);
});

test("control research condition disables modulation without changing mode routing", () => {
  const control = resolveModulationProfile("focus", { intensity: "high", researchCondition: "control" });

  assert.equal(control.researchCondition, "control");
  assert.equal(control.mode, "focus");
  assert.equal(control.modulationDepth, 0);
  assert.equal(control.stereoPhaseOffset, 0);
});

test("generates stereo interleaved float32 PCM for a known duration", () => {
  const engine = new BeatEngine();
  const sampleRate = 100;
  const durationSeconds = 10;

  const pcm = engine.generate("focus", durationSeconds, sampleRate);

  assert.ok(pcm instanceof Float32Array);
  assert.equal(pcm.length, durationSeconds * sampleRate * 2);
});

test("intensity controls modulation depth", () => {
  const engine = new BeatEngine();
  const sampleRate = 1000;
  const low = engine.generate("focus", 12, sampleRate, { intensity: "low" });
  const high = engine.generate("focus", 12, sampleRate, { intensity: "high" });
  const middleStart = 6 * sampleRate;

  assert.ok(peakChannel(high, middleStart, sampleRate) > peakChannel(low, middleStart, sampleRate) * 1.25);
});

test("high intensity uses independent stereo modulation while staying bounded", () => {
  const engine = new BeatEngine();
  const sampleRate = 1000;
  const pcm = engine.generate("meditate", 12, sampleRate, { intensity: "high" });
  let accumulatedDifference = 0;
  let peak = 0;

  for (let frame = 6 * sampleRate; frame < 7 * sampleRate; frame += 1) {
    const left = pcm[frame * 2];
    const right = pcm[(frame * 2) + 1];
    accumulatedDifference += Math.abs(left - right);
    peak = Math.max(peak, Math.abs(left), Math.abs(right));
  }

  assert.ok(accumulatedDifference > 0.01);
  assert.ok(peak <= 0.120001);
});

test("sleep spatialization adds slow stereo rocking while staying bounded", () => {
  const engine = new BeatEngine();
  const sampleRate = 1000;
  const plain = engine.generate("sleep", 30, sampleRate, {
    intensity: "high",
    sleepSpatialization: "off"
  });
  const spatial = engine.generate("sleep", 30, sampleRate, {
    intensity: "high",
    sleepSpatialization: "high"
  });

  const earlySpatialBalance = channelBalance(spatial, 5 * sampleRate, 3 * sampleRate);
  const lateSpatialBalance = channelBalance(spatial, 15 * sampleRate, 3 * sampleRate);
  const earlyPlainBalance = channelBalance(plain, 5 * sampleRate, 3 * sampleRate);
  const latePlainBalance = channelBalance(plain, 15 * sampleRate, 3 * sampleRate);

  assert.ok(Math.abs(earlySpatialBalance - lateSpatialBalance) > Math.abs(earlyPlainBalance - latePlainBalance) + 0.005);
  assert.ok(maxAbs(spatial) <= 0.120001);
});

test("long rendered loops remain finite and fade to silence", () => {
  const engine = new BeatEngine();
  const pcm = engine.generate("sleep", 60, 200, { intensity: "medium" });
  const peak = pcm.reduce((current, sample) => {
    assert.ok(Number.isFinite(sample));
    return Math.max(current, Math.abs(sample));
  }, 0);

  assert.equal(pcm[0], 0);
  assert.equal(pcm[pcm.length - 1], 0);
  assert.ok(peak <= 0.120001);
});

test("mirrors left and right channels", () => {
  const engine = new BeatEngine();
  const pcm = engine.generate("flow", 6, 120);

  for (let i = 0; i < 20; i += 1) {
    assert.equal(pcm[i * 2], pcm[i * 2 + 1]);
  }
});

test("applies fade in and fade out", () => {
  const engine = new BeatEngine();
  const sampleRate = 100;
  const pcm = engine.generate("meditation", 12, sampleRate);
  const start = Math.abs(pcm[0]);
  const middleFrame = Math.floor((pcm.length / 2) / 2);
  const middleWindow = [];
  for (let offset = 0; offset < 10; offset += 1) {
    middleWindow.push(Math.abs(pcm[(middleFrame + offset) * 2]));
  }
  const middle = Math.max(...middleWindow);
  const end = Math.abs(pcm[pcm.length - 2]);

  assert.equal(start, 0);
  assert.ok(middle > 0.001);
  assert.ok(end < middle);
});

test("rejects unknown modes", () => {
  const engine = new BeatEngine();
  assert.throws(() => engine.generate("unknown", 5, 44100), /Unknown mode/);
});

function peakChannel(pcm, startFrame, frameCount) {
  let peak = 0;
  for (let frame = startFrame; frame < startFrame + frameCount; frame += 1) {
    peak = Math.max(peak, Math.abs(pcm[frame * 2]));
  }
  return peak;
}

function channelBalance(pcm, startFrame, frameCount) {
  let total = 0;
  for (let frame = startFrame; frame < startFrame + frameCount; frame += 1) {
    total += Math.abs(pcm[(frame * 2) + 1]) - Math.abs(pcm[frame * 2]);
  }
  return total / frameCount;
}

function maxAbs(pcm) {
  return pcm.reduce((peak, sample) => Math.max(peak, Math.abs(sample)), 0);
}
