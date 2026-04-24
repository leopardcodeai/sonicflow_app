import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import { MODES, DEFAULT_SETTINGS, EXAMPLES, OVERLAY_SOURCES, resolveOverlayStatus } from "./popup-model.js";

const popupMarkup = readFileSync(new URL("./popup.html", import.meta.url), "utf8");

test("popup model exposes all four beat modes and defaults", () => {
  assert.deepEqual(
    MODES.map((mode) => mode.id),
    ["focus", "flow", "meditation", "sleep"]
  );
  assert.deepEqual(DEFAULT_SETTINGS, {
    mode: "focus",
    overlaySource: "browser-tab",
    volume: 15,
    active: false,
    durationMinutes: 25,
    ambientMix: 45,
    pulseDepth: 95
  });
  assert.deepEqual(
    EXAMPLES.map((example) => example.id),
    ["focus-primer", "flow-reset", "night-drift"]
  );
});

test("popup model exposes browser overlay source capability", () => {
  assert.deepEqual(
    OVERLAY_SOURCES.map((source) => source.id),
    ["browser-tab", "macos-system", "ios-local", "android-policy-review"]
  );
  assert.equal(
    resolveOverlayStatus({ pageHasAudioSource: true }).message,
    "Overlay ready for this browser tab."
  );
  assert.equal(
    resolveOverlayStatus({ pageHasAudioSource: false }).message,
    "Open YouTube, SoundCloud, or another supported media tab first."
  );
});

test("popup markup contains the expected control surface anchors", () => {
  assert.match(popupMarkup, /assets\/leopard_wallpaper\.png/);
  assert.match(popupMarkup, /id="hero-art"/);
  assert.match(popupMarkup, /assets\/bowl_hero\.png/);
  assert.match(popupMarkup, /id="mode-grid"/);
  assert.match(popupMarkup, /id="example-grid"/);
  assert.match(popupMarkup, /id="volume-slider"/);
  assert.match(popupMarkup, /id="duration-value"/);
  assert.match(popupMarkup, /id="duration-slider"/);
  assert.match(popupMarkup, /id="ambient-value"/);
  assert.match(popupMarkup, /id="ambient-slider"/);
  assert.match(popupMarkup, /id="pulse-value"/);
  assert.match(popupMarkup, /id="pulse-slider"/);
  assert.match(popupMarkup, /id="toggle-button"/);
  assert.match(popupMarkup, /id="page-message"/);
  assert.match(popupMarkup, /id="overlay-mode-panel"/);
  assert.match(popupMarkup, /id="overlay-source-list"/);
  assert.match(popupMarkup, /id="overlay-source-status"/);
});
