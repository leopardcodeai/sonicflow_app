import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import { MODES, DEFAULT_SETTINGS } from "./popup-model.js";

const popupMarkup = readFileSync(new URL("./popup.html", import.meta.url), "utf8");

test("popup model exposes all four beat modes and defaults", () => {
  assert.deepEqual(
    MODES.map((mode) => mode.id),
    ["focus", "flow", "meditation", "sleep"]
  );
  assert.equal(DEFAULT_SETTINGS.mode, "focus");
  assert.equal(DEFAULT_SETTINGS.volume, 15);
});

test("popup markup contains the expected control surface anchors", () => {
  assert.match(popupMarkup, /id="mode-grid"/);
  assert.match(popupMarkup, /id="volume-slider"/);
  assert.match(popupMarkup, /id="toggle-button"/);
  assert.match(popupMarkup, /id="page-message"/);
});
