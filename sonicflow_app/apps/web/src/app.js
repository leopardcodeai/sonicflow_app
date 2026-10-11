import {
  createFeedbackEvent,
  scoreAttentionTask,
  selectActivity,
  selectProductMode,
  setResearchCondition,
  setSleepSpatialization,
  setDurationMinutes
} from "./sessionModel.js";
import { SESSION_TIMERS } from "../../../extensions/safari/popup-model.js";
import {
  createPersonalizationProfile,
  deriveSessionDefaults,
  updateProfilePreferences
} from "./personalizationModel.js";
import { SonicFlowPlayer } from "./SonicFlowPlayer.js";
import {
  LIBRARY_SESSIONS,
  createPlaybackSnapshot,
  renderApp
} from "./renderApp.js";
import {
  loadWebSessionStore,
  persistWebSessionStore
} from "./webSessionStore.js";
import { resolveLanguage } from "./i18n.js";

const app = document.querySelector("#app");

let { state, profile, quizAnswers, uiState } = loadWebSessionStore();
let currentView = "home";

const player = new SonicFlowPlayer({
  onTick: renderPlaybackProgress,
  onStop: () => {
    state = { ...state, isPlaying: false };
    persist();
    render();
  }
});

app.addEventListener("click", async (event) => {
  const commandPaletteButton = event.target.closest("[data-command-palette]");
  if (commandPaletteButton) {
    uiState = { ...uiState, commandPaletteOpen: true };
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-command-close]")) {
    uiState = { ...uiState, commandPaletteOpen: false };
    persist();
    render();
    return;
  }

  const commandButton = event.target.closest("[data-command]");
  if (commandButton) {
    await runCommand(commandButton.dataset.command);
    return;
  }

  const favoriteButton = event.target.closest("[data-toggle-favorite]");
  if (favoriteButton) {
    uiState = {
      ...uiState,
      favoriteSessionIds: toggleListValue(uiState.favoriteSessionIds, favoriteButton.dataset.toggleFavorite)
    };
    persist();
    render();
    return;
  }

  const playSessionButton = event.target.closest("[data-play-session]");
  if (playSessionButton) {
    await playLibrarySession(playSessionButton.dataset.playSession);
    return;
  }

  const queueAddButton = event.target.closest("[data-queue-add]");
  if (queueAddButton) {
    uiState = {
      ...uiState,
      queueSessionIds: appendUnique(uiState.queueSessionIds, queueAddButton.dataset.queueAdd)
    };
    persist();
    render();
    return;
  }

  const queueRemoveButton = event.target.closest("[data-queue-remove]");
  if (queueRemoveButton) {
    uiState = {
      ...uiState,
      queueSessionIds: uiState.queueSessionIds.filter((id) => id !== queueRemoveButton.dataset.queueRemove)
    };
    persist();
    render();
    return;
  }

  const playerActionButton = event.target.closest("[data-player-action]");
  if (playerActionButton) {
    await runPlayerAction(playerActionButton.dataset.playerAction);
    return;
  }

  const timerShortcutButton = event.target.closest("[data-timer-shortcut]");
  if (timerShortcutButton) {
    state = applyTimerShortcut(state, timerShortcutButton.dataset.timerShortcut);
    await syncPlayback();
    persist();
    render();
    return;
  }

  const genreShortcutButton = event.target.closest("[data-genre-shortcut]");
  if (genreShortcutButton) {
    const genre = genreShortcutButton.dataset.genreShortcut;
    quizAnswers = { ...quizAnswers, genre };
    profile = updateProfilePreferences(profile, { genre });
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persist();
    render();
    return;
  }

  const libraryGenreButton = event.target.closest("[data-library-genre]");
  if (libraryGenreButton) {
    uiState = { ...uiState, libraryGenre: libraryGenreButton.dataset.libraryGenre };
    persist();
    render();
    return;
  }

  const libraryLayoutButton = event.target.closest("[data-library-layout]");
  if (libraryLayoutButton) {
    uiState = { ...uiState, libraryLayout: libraryLayoutButton.dataset.libraryLayout };
    persist();
    render();
    return;
  }

  const viewButton = event.target.closest("[data-view]");
  if (viewButton) {
    currentView = viewButton.dataset.view;
    uiState = { ...uiState, commandPaletteOpen: false };
    render();
    return;
  }

  const modeButton = event.target.closest("[data-product-mode]");
  if (modeButton) {
    state = selectProductMode(state, modeButton.dataset.productMode);
    if (!modeButton.closest(".filter-row")) {
      currentView = "home";
    }
    await syncPlayback();
    persist();
    render();
    return;
  }

  const activityButton = event.target.closest("[data-activity]");
  if (activityButton) {
    state = selectActivity(state, activityButton.dataset.activity);
    await syncPlayback();
    persist();
    render();
    return;
  }

  const intensityButton = event.target.closest("[data-intensity]");
  if (intensityButton) {
    state = { ...state, intensity: intensityButton.dataset.intensity };
    await syncPlayback();
    persist();
    render();
    return;
  }

  const spatializationButton = event.target.closest("[data-sleep-spatialization]");
  if (spatializationButton) {
    state = setSleepSpatialization(state, spatializationButton.dataset.sleepSpatialization);
    await syncPlayback();
    persist();
    render();
    return;
  }

  const researchButton = event.target.closest("[data-research-condition]");
  if (researchButton) {
    state = setResearchCondition(state, researchButton.dataset.researchCondition);
    await syncPlayback();
    persist();
    render();
    return;
  }

  const feedbackButton = event.target.closest("[data-feedback]");
  if (feedbackButton) {
    state = {
      ...state,
      lastFeedbackEvent: createFeedbackEvent(state, {
        effectiveness: Number(feedbackButton.dataset.feedback),
        calm: Number(feedbackButton.dataset.feedback)
      })
    };
    persist();
    render();
    return;
  }

  if (event.target.closest("[data-attention-check]")) {
    state = {
      ...state,
      lastAttentionEvent: scoreAttentionTask(state, [
        { correct: true, reactionMs: 410 },
        { correct: true, reactionMs: 390 },
        { correct: state.researchCondition !== "control", reactionMs: 520 }
      ])
    };
    persist();
    render();
    return;
  }

  if (event.target.closest("[data-toggle-playback]")) {
    state = { ...state, isPlaying: !state.isPlaying };
    await syncPlayback();
    persist();
    render();
  }
});

app.addEventListener("input", async (event) => {
  if (event.target.matches("[data-search]")) {
    uiState = {
      ...uiState,
      searchQuery: event.target.value,
      commandPaletteOpen: true
    };
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-duration]")) {
    state = setDurationMinutes(state, event.target.value);
    await syncPlayback();
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-volume]")) {
    state = { ...state, volume: Number(event.target.value) };
    player.updateVolume(state.volume);
    persist();
    render();
  }
});

app.addEventListener("change", async (event) => {
  if (event.target.matches("[data-library-sort]")) {
    uiState = { ...uiState, librarySort: event.target.value };
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-quiz-answer]")) {
    quizAnswers = {
      ...quizAnswers,
      [event.target.dataset.quizAnswer]: event.target.value
    };
    profile = createPersonalizationProfile(quizAnswers);
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-profile-genre]")) {
    quizAnswers = { ...quizAnswers, genre: event.target.value };
    profile = updateProfilePreferences(profile, { genre: event.target.value });
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persist();
    render();
    return;
  }

  if (event.target.matches("[data-profile-intensity]")) {
    profile = updateProfilePreferences(profile, { defaultIntensity: event.target.value });
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persist();
    render();
  }
});

async function syncPlayback() {
  if (state.isPlaying) {
    await player.start(state);
  } else {
    player.stop();
  }
}

function render() {
  document.documentElement.lang = resolveLanguage(globalThis);
  app.innerHTML = renderApp({
    state,
    profile,
    quizAnswers,
    playback: createPlaybackSnapshot(state, player.elapsedSeconds),
    view: currentView,
    uiState,
    environment: window
  });
}

function renderPlaybackProgress() {
  const snapshot = createPlaybackSnapshot(state, player.elapsedSeconds);
  app.querySelectorAll(".scrubber, .meter").forEach((progressElement) => {
    progressElement.style.setProperty("--progress", `${snapshot.progress}%`);
  });

  app.querySelectorAll(".playback-status").forEach((status) => {
    status.textContent = snapshot.statusLabel;
  });
}

function persist() {
  persistWebSessionStore({ state, profile, quizAnswers, uiState });
}

async function runCommand(command) {
  const [kind, value] = String(command).split(":");
  if (kind === "view") {
    currentView = value;
    uiState = { ...uiState, commandPaletteOpen: false };
    persist();
    render();
    return;
  }
  if (kind === "mode") {
    state = selectProductMode(state, value);
    currentView = "home";
    uiState = { ...uiState, commandPaletteOpen: false };
    await syncPlayback();
    persist();
    render();
  }
}

async function playLibrarySession(sessionId) {
  const session = LIBRARY_SESSIONS.find((entry) => entry.id === sessionId);
  if (!session) {
    return;
  }

  state = selectProductMode(state, session.mode);
  state = setDurationMinutes(state, parseDurationMinutes(session.duration));
  currentView = "player";
  uiState = {
    ...uiState,
    commandPaletteOpen: false,
    queueSessionIds: appendUnique(uiState.queueSessionIds, session.id)
  };
  await syncPlayback();
  persist();
  render();
}

async function runPlayerAction(action) {
  if (action === "restart") {
    await syncPlayback();
    render();
    return;
  }

  const currentSessionId = sessionIdForMode(state.productMode);
  const currentIndex = uiState.queueSessionIds.indexOf(currentSessionId);
  const nextIndex = action === "previous"
    ? Math.max(0, currentIndex - 1)
    : Math.min(uiState.queueSessionIds.length - 1, currentIndex + 1);
  const nextSessionId = uiState.queueSessionIds[nextIndex] ?? uiState.queueSessionIds[0];
  if (nextSessionId) {
    await playLibrarySession(nextSessionId);
  }
}

function applyTimerShortcut(currentState, timerId) {
  const timer = SESSION_TIMERS[timerId];
  if (!timer) {
    return currentState;
  }

  return {
    ...currentState,
    timerId,
    durationMinutes: timer.durationMinutes,
    isInfinite: timer.durationMinutes === null
  };
}

function parseDurationMinutes(duration) {
  const parsed = Number.parseInt(duration, 10);
  return Number.isFinite(parsed) ? parsed : 25;
}

function toggleListValue(list, value) {
  return list.includes(value)
    ? list.filter((entry) => entry !== value)
    : [...list, value];
}

function appendUnique(list, value) {
  return list.includes(value) ? list : [...list, value];
}

function sessionIdForMode(productMode) {
  if (productMode === "sleep") return "forest";
  if (productMode === "relax") return "glacier";
  if (productMode === "meditate") return "monsoon";
  return "ember";
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("./service-worker.js").catch(() => null);
  }
}

render();
registerServiceWorker();
