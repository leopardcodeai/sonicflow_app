import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import {
  createTranslator,
  resolveLanguage
} from "./i18n.js";

import {
  MODES,
  DEFAULT_SETTINGS,
  EXAMPLES,
  OVERLAY_SOURCES,
  PRODUCT_MODES,
  SESSION_ACTIVITIES,
  SESSION_TIMERS,
  deleteSiteRule,
  resolveRuleForUrl,
  resolveOverlayStatus,
  resolveSessionActivity,
  resolveSessionPlan,
  resolveSessionTimer,
  upsertSiteRule
} from "./popup-model.js";

const popupMarkup = readFileSync(new URL("./popup.html", import.meta.url), "utf8");

test("popup model exposes all four beat modes and defaults", () => {
  assert.deepEqual(
    MODES.map((mode) => mode.id),
    ["focus", "flow", "meditation", "sleep"]
  );
  assert.deepEqual(DEFAULT_SETTINGS, {
    mode: "focus",
    activityId: "deep-work",
    timerId: "pomodoro",
    overlaySource: "browser-tab",
    siteRules: [],
    preferences: {
      floatingPlayer: true,
      autoApplySiteRules: true,
      compactPopup: false
    },
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
    ["browser-tab", "macos-system", "ios-local"]
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

test("popup model exposes Brain.fm parity session taxonomy", () => {
  assert.deepEqual(
    PRODUCT_MODES.map((mode) => mode.id),
    ["focus", "relax", "sleep", "meditate"]
  );
  assert.deepEqual(
    SESSION_ACTIVITIES.map((activity) => activity.id),
    [
      "deep-work",
      "creative-flow",
      "light-work",
      "learning",
      "motivation",
      "unwind",
      "destress",
      "recharge",
      "chill",
      "deep-sleep",
      "wind-down",
      "power-nap",
      "guided-sleep",
      "guided-meditation",
      "unguided-meditation"
    ]
  );
  assert.deepEqual(resolveSessionActivity("creative-flow"), {
    id: "creative-flow",
    mode: "focus",
    engineMode: "flow",
    defaultTimer: "pomodoro"
  });
  assert.equal(resolveSessionActivity("wind-down").defaultTimer, "infinite-sleep");
  assert.equal(SESSION_TIMERS.pomodoro.durationMinutes, 25);
  assert.equal(SESSION_TIMERS["infinite-sleep"].durationMinutes, null);
  assert.equal(resolveSessionTimer("pomodoro").durationMinutes, 25);
  assert.deepEqual(resolveSessionPlan("deep-work"), {
    activityId: "deep-work",
    productMode: "focus",
    engineMode: "focus",
    timerId: "pomodoro",
    durationMinutes: 25,
    isInfinite: false
  });
  assert.deepEqual(resolveSessionPlan("wind-down"), {
    activityId: "wind-down",
    productMode: "sleep",
    engineMode: "sleep",
    timerId: "infinite-sleep",
    durationMinutes: null,
    isInfinite: true
  });
});

test("popup markup contains the expected control surface anchors", () => {
  assert.match(popupMarkup, /assets\/leopard_pattern_2048x2048\.png/);
  assert.match(popupMarkup, /id="hero-art"/);
  assert.match(popupMarkup, /icons\/icon-128\.svg/);
  assert.match(popupMarkup, /id="mode-grid"/);
  assert.match(popupMarkup, /id="activity-panel"/);
  assert.match(popupMarkup, /id="activity-select"/);
  assert.match(popupMarkup, /id="activity-timer"/);
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
  assert.match(popupMarkup, /id="site-rule-panel"/);
  assert.match(popupMarkup, /id="site-rule-host"/);
  assert.match(popupMarkup, /id="site-rule-list"/);
  assert.match(popupMarkup, /id="preferences-panel"/);
  assert.match(popupMarkup, /id="floating-player-toggle"/);
});

test("popup language follows German system locale", () => {
  const translator = createTranslator({ navigator: { language: "de-DE" } });

  assert.equal(resolveLanguage({ navigator: { languages: ["de-DE", "en-US"] } }), "de");
  assert.equal(translator.language, "de");
  assert.equal(translator.t("start"), "SonicFlow starten");
  assert.equal(translator.label("Focus"), "Fokus");
  assert.equal(translator.label("Overlay ready for this browser tab."), "Overlay ist fur diesen Browser-Tab bereit.");
});

test("site rules can be added, edited, resolved, and deleted by host", () => {
  const first = upsertSiteRule([], {
    host: "https://www.youtube.com/watch?v=abc",
    mode: "flow",
    activityId: "creative-flow",
    autoStart: true
  });

  assert.deepEqual(first, [
    {
      host: "youtube.com",
      mode: "flow",
      activityId: "creative-flow",
      autoStart: true
    }
  ]);
  assert.deepEqual(resolveRuleForUrl(first, "https://music.youtube.com/watch?v=abc"), first[0]);

  const edited = upsertSiteRule(first, {
    host: "youtube.com",
    mode: "sleep",
    activityId: "wind-down",
    autoStart: false
  });
  assert.equal(edited.length, 1);
  assert.equal(edited[0].mode, "sleep");
  assert.equal(edited[0].autoStart, false);

  assert.deepEqual(deleteSiteRule(edited, "www.youtube.com"), []);
});
