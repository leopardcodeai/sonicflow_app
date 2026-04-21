import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import { MODES, DEFAULT_SETTINGS, EXAMPLES } from "./popup-model.js";

const popupMarkup = readFileSync(new URL("./popup.html", import.meta.url), "utf8");

test("popup model exposes all four beat modes and defaults", () => {
  assert.deepEqual(
    MODES.map((mode) => mode.id),
    ["focus", "flow", "meditation", "sleep"]
  );
  assert.deepEqual(DEFAULT_SETTINGS, {
    mode: "focus",
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
});
