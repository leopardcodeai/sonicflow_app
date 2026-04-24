import { BeatEngine, MODES as ENGINE_MODES } from "../../core-js/beatEngine.js";
import {
  PRODUCT_MODES,
  SESSION_ACTIVITIES,
  SESSION_TIMERS
} from "../../chrome-extension/popup-model.js";
import {
  createFeedbackEvent,
  createInitialSessionState,
  resolveScienceClaim,
  scoreAttentionTask,
  detectOverlayCapability,
  selectActivity,
  selectProductMode,
  setResearchCondition,
  setSleepSpatialization,
  setDurationMinutes
} from "./sessionModel.js";
import {
  GENRES,
  INTENSITIES,
  createPersonalizationProfile,
  deriveSessionDefaults,
  updateProfilePreferences
} from "./personalizationModel.js";

const STORAGE_KEY = "sonicflowWebSession";
const PROFILE_STORAGE_KEY = "sonicflowPersonalizationProfile";
const QUIZ_STORAGE_KEY = "sonicflowPersonalizationAnswers";
const CHUNK_SECONDS = 10;
const SAMPLE_RATE = 44100;
const DEFAULT_QUIZ_ANSWERS = {
  focusPattern: "deep-work",
  attentionSupport: "standard",
  sensitivity: "balanced",
  genre: "lo-fi"
};

const app = document.querySelector("#app");
let player;
let profile;
let quizAnswers;
let state;

app.addEventListener("click", async (event) => {
  const modeButton = event.target.closest("[data-product-mode]");
  if (modeButton) {
    state = selectProductMode(state, modeButton.dataset.productMode);
    await syncPlayback();
    persistState();
    render();
    return;
  }

  const activityButton = event.target.closest("[data-activity]");
  if (activityButton) {
    state = selectActivity(state, activityButton.dataset.activity);
    await syncPlayback();
    persistState();
    render();
    return;
  }

  const intensityButton = event.target.closest("[data-intensity]");
  if (intensityButton) {
    state = { ...state, intensity: intensityButton.dataset.intensity };
    await syncPlayback();
    persistState();
    render();
    return;
  }

  const spatializationButton = event.target.closest("[data-sleep-spatialization]");
  if (spatializationButton) {
    state = setSleepSpatialization(state, spatializationButton.dataset.sleepSpatialization);
    await syncPlayback();
    persistState();
    render();
    return;
  }

  const researchButton = event.target.closest("[data-research-condition]");
  if (researchButton) {
    state = setResearchCondition(state, researchButton.dataset.researchCondition);
    await syncPlayback();
    persistState();
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
    persistState();
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
    persistState();
    render();
    return;
  }

  if (event.target.closest("[data-toggle-playback]")) {
    state = { ...state, isPlaying: !state.isPlaying };
    await syncPlayback();
    persistState();
    render();
  }
});

app.addEventListener("input", async (event) => {
  if (event.target.matches("[data-duration]")) {
    state = setDurationMinutes(state, event.target.value);
    await syncPlayback();
    persistState();
    render();
    return;
  }

  if (event.target.matches("[data-volume]")) {
    state = { ...state, volume: Number(event.target.value) };
    player.updateVolume(state.volume);
    persistState();
    render();
  }
});

app.addEventListener("change", async (event) => {
  if (event.target.matches("[data-quiz-answer]")) {
    quizAnswers = {
      ...quizAnswers,
      [event.target.dataset.quizAnswer]: event.target.value
    };
    profile = createPersonalizationProfile(quizAnswers);
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persistAll();
    render();
    return;
  }

  if (event.target.matches("[data-profile-genre]")) {
    quizAnswers = { ...quizAnswers, genre: event.target.value };
    profile = updateProfilePreferences(profile, { genre: event.target.value });
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persistAll();
    render();
    return;
  }

  if (event.target.matches("[data-profile-intensity]")) {
    profile = updateProfilePreferences(profile, { defaultIntensity: event.target.value });
    state = deriveSessionDefaults(state, profile);
    await syncPlayback();
    persistAll();
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
  const activeActivity = SESSION_ACTIVITIES.find((activity) => activity.id === state.activityId);
  const activeTimer = SESSION_TIMERS[state.timerId];
  const engineMode = ENGINE_MODES[state.engineMode];
  const capability = detectOverlayCapability(window);
  const scienceClaim = resolveScienceClaim({ requestedClaim: "efficacy", evidenceValidated: false });
  const elapsedSeconds = player.elapsedSeconds;
  const progress = state.durationMinutes === null
    ? 100
    : Math.min(100, (elapsedSeconds / (state.durationMinutes * 60)) * 100);
  const activities = SESSION_ACTIVITIES.filter((activity) => activity.mode === state.productMode);

  app.innerHTML = `
    <section class="hero" aria-labelledby="session-title">
      <div class="hero-copy">
        <p class="eyebrow">SonicFlow Web</p>
        <h1 id="session-title">${activeActivity.label}</h1>
        <p class="session-line">${engineMode.name} · ${engineMode.beatHz} Hz · ${activeTimer.label}</p>
      </div>
      <div class="hero-orb" aria-hidden="true">
        <img src="../chrome-extension/assets/bowl_hero.png" alt="">
      </div>
    </section>

    <section class="session-grid" aria-label="Session controls">
      <div class="glass-panel player-panel">
        <div class="meter" style="--progress: ${progress}%">
          <span>${state.isPlaying ? "Live" : "Ready"}</span>
        </div>
        <button class="transport" type="button" data-toggle-playback>
          ${state.isPlaying ? "Pause" : "Start"}
        </button>
        <div class="status-row">
          <span>${state.durationMinutes === null ? "Until stopped" : `${state.durationMinutes} min`}</span>
          <span>${state.intensity}</span>
          <span>${state.volume}%</span>
        </div>
      </div>

      <div class="glass-panel taxonomy-panel">
        <div class="segmented" role="tablist" aria-label="Product modes">
          ${PRODUCT_MODES.map((mode) => `
            <button type="button" class="${state.productMode === mode.id ? "active" : ""}" data-product-mode="${mode.id}">
              ${mode.label}
            </button>
          `).join("")}
        </div>
        <div class="activity-list">
          ${activities.map((activity) => `
            <button type="button" class="activity ${state.activityId === activity.id ? "active" : ""}" data-activity="${activity.id}">
              <strong>${activity.label}</strong>
              <span>${SESSION_TIMERS[activity.defaultTimer].label}</span>
            </button>
          `).join("")}
        </div>
      </div>

      <div class="glass-panel controls-panel">
        <label>
          <span>Duration</span>
          <input type="range" min="5" max="120" step="5" value="${state.durationMinutes ?? 25}" data-duration ${state.durationMinutes === null ? "disabled" : ""}>
        </label>
        <label>
          <span>Volume</span>
          <input type="range" min="0" max="60" step="1" value="${state.volume}" data-volume>
        </label>
        <div class="intensity-row" aria-label="Neural intensity">
          ${["low", "medium", "high"].map((intensity) => `
            <button type="button" class="${state.intensity === intensity ? "active" : ""}" data-intensity="${intensity}">
              ${intensity}
            </button>
          `).join("")}
        </div>
        <div class="intensity-row spatialization-row" aria-label="Sleep spatialization">
          ${["off", "low", "medium", "high"].map((level) => `
            <button type="button" class="${state.sleepSpatialization === level ? "active" : ""}" data-sleep-spatialization="${level}" ${state.productMode !== "sleep" ? "disabled" : ""}>
              ${level}
            </button>
          `).join("")}
        </div>
      </div>

      <div class="glass-panel profile-panel">
        <div>
          <p class="eyebrow">Personalization</p>
          <strong>${formatNeurotype(profile.neurotype)}</strong>
        </div>
        <div class="profile-grid">
          <label>
            <span>Focus pattern</span>
            <select data-quiz-answer="focusPattern">
              ${option("deep-work", "Deep work", quizAnswers.focusPattern)}
              ${option("distractible", "Distractible", quizAnswers.focusPattern)}
              ${option("creative-block", "Creative block", quizAnswers.focusPattern)}
              ${option("stress", "Stress", quizAnswers.focusPattern)}
              ${option("low-energy", "Low energy", quizAnswers.focusPattern)}
            </select>
          </label>
          <label>
            <span>Attention support</span>
            <select data-quiz-answer="attentionSupport">
              ${option("standard", "Standard", quizAnswers.attentionSupport)}
              ${option("adhd-self-reported", "ADHD self-reported", quizAnswers.attentionSupport)}
            </select>
          </label>
          <label>
            <span>Sensitivity</span>
            <select data-quiz-answer="sensitivity">
              ${option("gentle", "Gentle", quizAnswers.sensitivity)}
              ${option("balanced", "Balanced", quizAnswers.sensitivity)}
              ${option("strong", "Strong", quizAnswers.sensitivity)}
            </select>
          </label>
          <label>
            <span>Genre</span>
            <select data-profile-genre>
              ${GENRES.map((genre) => option(genre, formatGenre(genre), profile.genre)).join("")}
            </select>
          </label>
          <label>
            <span>Default intensity</span>
            <select data-profile-intensity>
              ${INTENSITIES.map((intensity) => option(intensity, intensity, profile.defaultIntensity)).join("")}
            </select>
          </label>
        </div>
      </div>

      <div class="glass-panel overlay-panel">
        <div>
          <p class="eyebrow">Overlay Mode</p>
          <strong>${formatCapability(capability.browserTabOverlay)}</strong>
        </div>
        <p>${capability.message}</p>
        <div class="capability-grid">
          <span>Standalone <b>${capability.standaloneSessions}</b></span>
          <span>PWA <b>${capability.installablePwa}</b></span>
        </div>
      </div>

      <div class="glass-panel research-panel">
        <div>
          <p class="eyebrow">Research gate</p>
          <strong>${scienceClaim.allowed ? "Claim allowed" : "Claim blocked"}</strong>
        </div>
        <p>${scienceClaim.copy}</p>
        <div class="intensity-row" aria-label="Research condition">
          ${["modulated", "control"].map((condition) => `
            <button type="button" class="${state.researchCondition === condition ? "active" : ""}" data-research-condition="${condition}">
              ${condition}
            </button>
          `).join("")}
        </div>
        <div class="feedback-row" aria-label="Subjective efficacy feedback">
          ${[1, 2, 3, 4, 5].map((rating) => `
            <button type="button" data-feedback="${rating}">${rating}</button>
          `).join("")}
          <button type="button" data-attention-check>Focus check</button>
        </div>
      </div>
    </section>
  `;
}

function loadState() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? "null");
    return stored
      ? { ...deriveSessionDefaults(createInitialSessionState(), profile), ...stored, isPlaying: false }
      : deriveSessionDefaults(createInitialSessionState(), profile);
  } catch {
    return deriveSessionDefaults(createInitialSessionState(), profile);
  }
}

function loadQuizAnswers() {
  try {
    const stored = JSON.parse(localStorage.getItem(QUIZ_STORAGE_KEY) ?? "null");
    return stored ? { ...DEFAULT_QUIZ_ANSWERS, ...stored } : DEFAULT_QUIZ_ANSWERS;
  } catch {
    return DEFAULT_QUIZ_ANSWERS;
  }
}

function loadProfile(answers) {
  try {
    const stored = JSON.parse(localStorage.getItem(PROFILE_STORAGE_KEY) ?? "null");
    return stored ?? createPersonalizationProfile(answers);
  } catch {
    return createPersonalizationProfile(answers);
  }
}

function persistAll() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...state, isPlaying: false }));
  localStorage.setItem(PROFILE_STORAGE_KEY, JSON.stringify(profile));
  localStorage.setItem(QUIZ_STORAGE_KEY, JSON.stringify(quizAnswers));
}

function persistState() {
  persistAll();
}

function formatCapability(capability) {
  if (capability === "browser-api-review") {
    return "Browser API review";
  }
  if (capability === "extension-required") {
    return "Extension required";
  }
  return capability;
}

function formatGenre(genre) {
  return genre
    .split("-")
    .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
    .join("-");
}

function formatNeurotype(neurotype) {
  return neurotype
    .split("-")
    .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
    .join(" ");
}

function option(value, label, selectedValue) {
  return `<option value="${value}" ${value === selectedValue ? "selected" : ""}>${label}</option>`;
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("./service-worker.js").catch(() => null);
  }
}

class SonicFlowPlayer {
  constructor({ onTick, onStop }) {
    this.engine = new BeatEngine();
    this.audioContext = null;
    this.gainNode = null;
    this.timeoutId = null;
    this.tickId = null;
    this.startedAt = 0;
    this.elapsedSeconds = 0;
    this.onTick = onTick;
    this.onStop = onStop;
  }

  async start(sessionState) {
    await this.ensureContext();
    this.stopTimers();
    this.sessionState = sessionState;
    this.startedAt = this.audioContext.currentTime;
    this.elapsedSeconds = 0;
    this.updateVolume(sessionState.volume);
    this.scheduleChunk(this.startedAt);
    this.tickId = window.setInterval(() => this.tick(), 500);
  }

  stop() {
    this.stopTimers();
    this.elapsedSeconds = 0;
  }

  updateVolume(volume) {
    if (this.gainNode) {
      this.gainNode.gain.value = volume / 100;
    }
  }

  async ensureContext() {
    if (!this.audioContext) {
      this.audioContext = new AudioContext({ sampleRate: SAMPLE_RATE });
      this.gainNode = this.audioContext.createGain();
      this.gainNode.connect(this.audioContext.destination);
    }

    if (this.audioContext.state === "suspended") {
      await this.audioContext.resume();
    }
  }

  scheduleChunk(startTime) {
    const pcm = this.engine.generate(
      this.sessionState.engineMode,
      CHUNK_SECONDS,
      SAMPLE_RATE,
      {
        intensity: this.sessionState.intensity,
        researchCondition: this.sessionState.researchCondition,
        sleepSpatialization: this.sessionState.sleepSpatialization
      }
    );
    const frameCount = pcm.length / 2;
    const buffer = this.audioContext.createBuffer(2, frameCount, SAMPLE_RATE);
    const left = buffer.getChannelData(0);
    const right = buffer.getChannelData(1);

    for (let frame = 0; frame < frameCount; frame += 1) {
      left[frame] = pcm[frame * 2];
      right[frame] = pcm[(frame * 2) + 1];
    }

    const source = this.audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(this.gainNode);
    source.start(startTime);
    this.timeoutId = window.setTimeout(() => {
      this.scheduleChunk(startTime + CHUNK_SECONDS - 1);
    }, (CHUNK_SECONDS - 1) * 1000);
  }

  tick() {
    this.elapsedSeconds = Math.max(0, this.audioContext.currentTime - this.startedAt);
    if (this.sessionState.durationMinutes !== null && this.elapsedSeconds >= this.sessionState.durationMinutes * 60) {
      this.stop();
      this.onStop();
      return;
    }
    this.onTick();
  }

  stopTimers() {
    if (this.timeoutId) {
      window.clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
    if (this.tickId) {
      window.clearInterval(this.tickId);
      this.tickId = null;
    }
  }
}

player = new SonicFlowPlayer({
  onTick: render,
  onStop: () => {
    state = { ...state, isPlaying: false };
    persistState();
    render();
  }
});

quizAnswers = loadQuizAnswers();
profile = loadProfile(quizAnswers);
state = loadState();
render();
registerServiceWorker();
