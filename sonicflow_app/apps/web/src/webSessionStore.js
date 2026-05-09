import {
  createPersonalizationProfile,
  deriveSessionDefaults
} from "./personalizationModel.js";
import { createInitialSessionState } from "./sessionModel.js";

export const DEFAULT_QUIZ_ANSWERS = {
  focusPattern: "deep-work",
  attentionSupport: "standard",
  sensitivity: "balanced",
  genre: "lo-fi"
};

const STORAGE_KEY = "sonicflowWebSession";
const PROFILE_STORAGE_KEY = "sonicflowPersonalizationProfile";
const QUIZ_STORAGE_KEY = "sonicflowPersonalizationAnswers";
const UI_STORAGE_KEY = "sonicflowWebUiState";

export const DEFAULT_WEB_UI_STATE = {
  favoriteSessionIds: ["ember", "desert"],
  queueSessionIds: ["ember", "glacier", "forest"],
  searchQuery: "",
  commandPaletteOpen: false,
  libraryLayout: "grid",
  librarySort: "recent",
  libraryGenre: "all"
};

export function loadWebSessionStore(storage = globalThis.localStorage) {
  const quizAnswers = normalizeQuizAnswers(readJson(storage, QUIZ_STORAGE_KEY));
  const profile = normalizeProfile(readJson(storage, PROFILE_STORAGE_KEY), quizAnswers);
  const state = normalizeSessionState(readJson(storage, STORAGE_KEY), profile);
  const uiState = normalizeWebUiState(readJson(storage, UI_STORAGE_KEY));

  return { state, profile, quizAnswers, uiState };
}

export function persistWebSessionStore({ state, profile, quizAnswers, uiState }, storage = globalThis.localStorage) {
  if (!isStorageLike(storage)) {
    return;
  }

  storage.setItem(STORAGE_KEY, JSON.stringify({ ...state, isPlaying: false }));
  storage.setItem(PROFILE_STORAGE_KEY, JSON.stringify(profile));
  storage.setItem(QUIZ_STORAGE_KEY, JSON.stringify(quizAnswers));
  storage.setItem(UI_STORAGE_KEY, JSON.stringify(normalizeWebUiState(uiState)));
}

function normalizeSessionState(stored, profile) {
  const defaults = deriveSessionDefaults(createInitialSessionState(), profile);
  if (!isPlainObject(stored)) {
    return defaults;
  }

  return {
    ...defaults,
    ...stored,
    isPlaying: false
  };
}

function normalizeQuizAnswers(stored) {
  if (!isPlainObject(stored)) {
    return { ...DEFAULT_QUIZ_ANSWERS };
  }

  return {
    ...DEFAULT_QUIZ_ANSWERS,
    ...stored
  };
}

function normalizeProfile(stored, quizAnswers) {
  if (!isPlainObject(stored)) {
    return createPersonalizationProfile(quizAnswers);
  }

  return {
    ...createPersonalizationProfile(quizAnswers),
    ...stored
  };
}

function normalizeWebUiState(stored) {
  if (!isPlainObject(stored)) {
    return { ...DEFAULT_WEB_UI_STATE };
  }

  return {
    ...DEFAULT_WEB_UI_STATE,
    ...stored,
    favoriteSessionIds: normalizeStringList(stored.favoriteSessionIds, DEFAULT_WEB_UI_STATE.favoriteSessionIds),
    queueSessionIds: normalizeStringList(stored.queueSessionIds, DEFAULT_WEB_UI_STATE.queueSessionIds),
    searchQuery: typeof stored.searchQuery === "string" ? stored.searchQuery : DEFAULT_WEB_UI_STATE.searchQuery,
    commandPaletteOpen: Boolean(stored.commandPaletteOpen),
    libraryLayout: ["grid", "list"].includes(stored.libraryLayout) ? stored.libraryLayout : DEFAULT_WEB_UI_STATE.libraryLayout,
    librarySort: ["recent", "title", "duration"].includes(stored.librarySort) ? stored.librarySort : DEFAULT_WEB_UI_STATE.librarySort,
    libraryGenre: typeof stored.libraryGenre === "string" ? stored.libraryGenre : DEFAULT_WEB_UI_STATE.libraryGenre
  };
}

function normalizeStringList(value, fallback) {
  if (!Array.isArray(value)) {
    return [...fallback];
  }

  return Array.from(new Set(value.filter((item) => typeof item === "string")));
}

function readJson(storage, key) {
  if (!isStorageLike(storage)) {
    return null;
  }

  try {
    return JSON.parse(storage.getItem(key) ?? "null");
  } catch {
    return null;
  }
}

function isStorageLike(storage) {
  return Boolean(storage && typeof storage.getItem === "function" && typeof storage.setItem === "function");
}

function isPlainObject(value) {
  return Boolean(value && typeof value === "object" && !Array.isArray(value));
}
