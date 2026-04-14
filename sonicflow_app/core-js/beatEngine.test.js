import test from "node:test";
import assert from "node:assert/strict";

import { BeatEngine, MODES } from "./beatEngine.js";

test("exports the four expected modes", () => {
  assert.deepEqual(Object.keys(MODES), ["focus", "flow", "meditation", "sleep"]);
  assert.equal(MODES.focus.beatHz, 40);
  assert.equal(MODES.sleep.carrierHz, 150);
});

test("generates stereo interleaved float32 PCM for a known duration", () => {
  const engine = new BeatEngine();
  const sampleRate = 100;
  const durationSeconds = 10;

  const pcm = engine.generate("focus", durationSeconds, sampleRate);

  assert.ok(pcm instanceof Float32Array);
  assert.equal(pcm.length, durationSeconds * sampleRate * 2);
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
