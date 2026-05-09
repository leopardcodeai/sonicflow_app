import test from "node:test";
import assert from "node:assert/strict";

import { createInitialSessionState } from "./sessionModel.js";
import { createPersonalizationProfile } from "./personalizationModel.js";
import {
  createPlaybackSnapshot,
  renderApp
} from "./renderApp.js";
import {
  DEFAULT_WEB_UI_STATE,
  loadWebSessionStore,
  persistWebSessionStore
} from "./webSessionStore.js";

const defaultQuizAnswers = {
  focusPattern: "deep-work",
  attentionSupport: "standard",
  sensitivity: "balanced",
  genre: "lo-fi"
};

test("renders selected product modes as tabs with aria-selected state", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 0),
    environment: {}
  });

  assert.match(html, /role="tablist" aria-label="Product modes"/);
  assert.match(html, /role="tab" aria-selected="true"[^>]+data-product-mode="focus"/);
  assert.match(html, /role="tab" aria-selected="false"[^>]+data-product-mode="sleep"/);
});

test("renders the redesign dashboard frame with sidebar and persistent player", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 0),
    environment: {}
  });

  assert.match(html, /class="webapp-sidebar/);
  assert.match(html, /Pick up where you left off/);
  assert.match(html, /class="player-bar/);
  assert.match(html, /data-view="library"/);
});

test("renders player and library views from the redesign flow", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const playerHtml = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 12),
    view: "player",
    environment: {}
  });
  const libraryHtml = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 12),
    view: "library",
    environment: {}
  });

  assert.match(playerHtml, /class="now-playing-view"/);
  assert.match(playerHtml, /Now playing/);
  assert.match(libraryHtml, /class="library-grid"/);
  assert.match(libraryHtml, /cinematic/);
});

test("renders only playback status as live text", () => {
  const state = { ...createInitialSessionState(), isPlaying: true };
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 12),
    environment: {}
  });

  assert.match(html, /class="playback-status"[^>]+aria-live="polite"/);
  assert.match(html, />Live</);
  assert.doesNotMatch(html, /<section[^>]+aria-live=/);
});

test("escapes dynamic text before rendering HTML", () => {
  const state = createInitialSessionState();
  const profile = {
    ...createPersonalizationProfile(defaultQuizAnswers),
    neurotype: "steady-focus<script>alert(1)</script>"
  };
  const html = renderApp({
    state,
    profile,
    quizAnswers: {
      ...defaultQuizAnswers,
      focusPattern: "deep-work\"><img src=x onerror=alert(1)>"
    },
    playback: createPlaybackSnapshot(state, 0),
    view: "profile",
    environment: {}
  });

  assert.doesNotMatch(html, /<script>/);
  assert.doesNotMatch(html, /<img/);
  assert.match(html, /Steady Focus&lt;script&gt;alert\(1\)&lt;\/script&gt;/);
});

test("detects German system language for visible UI labels", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 0),
    environment: { navigator: { language: "de-DE", languages: ["de-DE", "en-US"] } }
  });

  assert.match(html, /data-language="de"/);
  assert.match(html, /Da weitermachen, wo du aufgehort hast/);
  assert.match(html, /Neurale Intensitat/);
  assert.match(html, /Bibliothek/);
});

test("renders favorites workflow, filtered library, and list sorting controls", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 0),
    view: "library",
    uiState: {
      ...DEFAULT_WEB_UI_STATE,
      favoriteSessionIds: ["glacier"],
      libraryLayout: "list",
      librarySort: "duration",
      libraryGenre: "ambient"
    },
    environment: {}
  });

  assert.match(html, /data-library-layout="list"/);
  assert.match(html, /data-library-sort="duration"/);
  assert.match(html, /data-library-genre="ambient"/);
  assert.match(html, /aria-pressed="true"[^>]+data-toggle-favorite="glacier"/);
  assert.match(html, /class="library-list"/);
  assert.match(html, /glacier/);
  assert.match(html, /tide/);
  assert.doesNotMatch(html, /data-play-session="ember"/);
});

test("renders command palette search results and actions", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 0),
    uiState: {
      ...DEFAULT_WEB_UI_STATE,
      searchQuery: "sleep",
      commandPaletteOpen: true
    },
    environment: {}
  });

  assert.match(html, /class="command-palette glass-surface"/);
  assert.match(html, /value="sleep"/);
  assert.match(html, /data-command="view:library"/);
  assert.match(html, /data-play-session="forest"/);
  assert.match(html, /Sleep/);
});

test("renders queue, shortcut cards, and complete bottom player controls", () => {
  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const html = renderApp({
    state,
    profile,
    quizAnswers: defaultQuizAnswers,
    playback: createPlaybackSnapshot(state, 34),
    uiState: {
      ...DEFAULT_WEB_UI_STATE,
      queueSessionIds: ["ember", "glacier", "forest"],
      favoriteSessionIds: ["ember"]
    },
    environment: {}
  });

  assert.match(html, /class="shortcut-grid"/);
  assert.match(html, /data-timer-shortcut="pomodoro"/);
  assert.match(html, /data-genre-shortcut="cinematic"/);
  assert.match(html, /class="queue-panel glass-surface"/);
  assert.match(html, /Up Next/);
  assert.match(html, /data-queue-remove="glacier"/);
  assert.match(html, /data-player-action="previous"/);
  assert.match(html, /data-player-action="restart"/);
  assert.match(html, /data-player-action="next"/);
  assert.match(html, /data-toggle-favorite="ember"/);
});

test("persists web-only library and queue preferences", () => {
  const writes = new Map();
  const storage = {
    getItem(key) {
      return writes.get(key) ?? null;
    },
    setItem(key, value) {
      writes.set(key, value);
    }
  };

  const state = createInitialSessionState();
  const profile = createPersonalizationProfile(defaultQuizAnswers);
  const uiState = {
    ...DEFAULT_WEB_UI_STATE,
    favoriteSessionIds: ["ember", "glacier"],
    queueSessionIds: ["forest"],
    libraryLayout: "list",
    librarySort: "duration",
    libraryGenre: "ambient"
  };

  persistWebSessionStore({ state, profile, quizAnswers: defaultQuizAnswers, uiState }, storage);
  const loaded = loadWebSessionStore(storage);

  assert.deepEqual(loaded.uiState.favoriteSessionIds, ["ember", "glacier"]);
  assert.deepEqual(loaded.uiState.queueSessionIds, ["forest"]);
  assert.equal(loaded.uiState.libraryLayout, "list");
  assert.equal(loaded.uiState.librarySort, "duration");
  assert.equal(loaded.uiState.libraryGenre, "ambient");
});
