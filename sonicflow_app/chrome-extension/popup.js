import { extensionApi } from "./browser-polyfill.js";
import {
  DEFAULT_SETTINGS,
  EXAMPLES,
  MODES,
  OVERLAY_SOURCES,
  SESSION_ACTIVITIES,
  resolveOverlayStatus,
  resolveSessionActivity,
  resolveSessionPlan,
  resolveSessionTimer
} from "./popup-model.js";

async function queryActiveTabState() {
  const { tabId } = await extensionApi.runtime.sendMessage({
    type: "FLOWTONES_QUERY_ACTIVE_TAB"
  });

  if (!tabId) {
    return null;
  }

  return extensionApi.runtime.sendMessage({
    type: "FLOWTONES_FORWARD_TO_TAB",
    tabId,
    payload: { type: "FLOWTONES_GET_STATE" }
  });
}

async function persistSettings(settings) {
  await extensionApi.storage.local.set({ sonicflowSettings: settings });
}

async function loadStoredSettings() {
  const stored = await extensionApi.storage.local.get("sonicflowSettings");
  return {
    ...DEFAULT_SETTINGS,
    ...(stored.sonicflowSettings ?? {})
  };
}

async function pushStateToTab(nextState) {
  const { tabId } = await extensionApi.runtime.sendMessage({
    type: "FLOWTONES_QUERY_ACTIVE_TAB"
  });

  if (!tabId) {
    return null;
  }

  return extensionApi.runtime.sendMessage({
    type: "FLOWTONES_FORWARD_TO_TAB",
    tabId,
    payload: {
      type: "FLOWTONES_SET_STATE",
      ...nextState
    }
  });
}

function renderModeGrid(settings) {
  const modeGrid = document.querySelector("#mode-grid");
  modeGrid.replaceChildren();

  for (const mode of MODES) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `mode-card${settings.mode === mode.id ? " active" : ""}`;
    button.style.setProperty("--mode-color", mode.color);
    button.dataset.mode = mode.id;
    button.innerHTML = `
      <strong>${mode.name}</strong>
      <small>${mode.beatHz} Hz</small>
      <span>${mode.description}</span>
    `;
    modeGrid.append(button);
  }
}

function renderExamples(settings) {
  const exampleGrid = document.querySelector("#example-grid");
  exampleGrid.replaceChildren();

  for (const example of EXAMPLES) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `mode-card${settings.durationMinutes === example.durationMinutes && settings.mode === example.mode ? " active" : ""}`;
    button.dataset.example = example.id;
    const mode = MODES.find((entry) => entry.id === example.mode) ?? MODES[0];
    button.style.setProperty("--mode-color", mode.color);
    button.innerHTML = `
      <strong>${example.title}</strong>
      <small>${example.subtitle}</small>
      <span>${example.durationMinutes} min</span>
    `;
    exampleGrid.append(button);
  }
}

function renderActivitySelector(settings) {
  const activitySelect = document.querySelector("#activity-select");
  const activityTimer = document.querySelector("#activity-timer");
  activitySelect.replaceChildren();

  for (const activity of SESSION_ACTIVITIES) {
    const option = document.createElement("option");
    option.value = activity.id;
    option.textContent = activity.label;
    activitySelect.append(option);
  }

  const activity = resolveSessionActivity(settings.activityId ?? DEFAULT_SETTINGS.activityId);
  const timer = resolveSessionTimer(settings.timerId ?? activity.defaultTimer);
  activitySelect.value = activity.id;
  activityTimer.textContent = timer.durationMinutes === null
    ? `${timer.label} · plays until stopped`
    : `${timer.label} · ${timer.durationMinutes} min`;
}

function updateHero(settings) {
  const heroTitle = document.querySelector("#hero-title");
  const heroDescription = document.querySelector("#hero-description");
  const activeMode = MODES.find((mode) => mode.id === settings.mode) ?? MODES[0];
  const durationLabel = settings.durationMinutes === null
    ? "open-ended"
    : `${settings.durationMinutes} minute`;

  heroTitle.textContent = `${activeMode.name} Session`;
  heroDescription.textContent = `${activeMode.description} ${durationLabel} browser-safe layer with ${settings.ambientMix}% ambience and ${settings.pulseDepth}% pulse depth.`;
}

function renderOverlaySources(settings, tabState) {
  const sourceList = document.querySelector("#overlay-source-list");
  const sourceStatus = document.querySelector("#overlay-source-status");
  const overlayStatus = resolveOverlayStatus(tabState);

  sourceList.replaceChildren();
  for (const source of OVERLAY_SOURCES) {
    const item = document.createElement("button");
    item.type = "button";
    item.className = `source-pill${settings.overlaySource === source.id ? " active" : ""}`;
    item.dataset.overlaySource = source.id;
    item.innerHTML = `
      <span>${source.label}</span>
      <small>${source.status}</small>
    `;
    item.title = source.description;
    sourceList.append(item);
  }

  sourceStatus.textContent = overlayStatus.message;
}

function renderState(settings, tabState) {
  const dot = document.querySelector("#status-dot");
  const statusText = document.querySelector("#status-text");
  const pageMessage = document.querySelector("#page-message");
  const volumeValue = document.querySelector("#volume-value");
  const volumeSlider = document.querySelector("#volume-slider");
  const durationValue = document.querySelector("#duration-value");
  const durationSlider = document.querySelector("#duration-slider");
  const ambientValue = document.querySelector("#ambient-value");
  const ambientSlider = document.querySelector("#ambient-slider");
  const pulseValue = document.querySelector("#pulse-value");
  const pulseSlider = document.querySelector("#pulse-slider");
  const toggleButton = document.querySelector("#toggle-button");

  renderModeGrid(settings);
  renderExamples(settings);
  renderActivitySelector(settings);
  renderOverlaySources(settings, tabState);
  updateHero(settings);
  volumeSlider.value = String(settings.volume);
  volumeValue.textContent = String(settings.volume);
  durationSlider.disabled = settings.durationMinutes === null;
  durationSlider.value = String(settings.durationMinutes ?? DEFAULT_SETTINGS.durationMinutes);
  durationValue.textContent = settings.durationMinutes === null
    ? "Until stopped"
    : `${settings.durationMinutes} min`;
  ambientSlider.value = String(settings.ambientMix);
  ambientValue.textContent = `${settings.ambientMix}%`;
  pulseSlider.value = String(settings.pulseDepth);
  pulseValue.textContent = `${settings.pulseDepth}%`;

  if (!tabState) {
    statusText.textContent = "Unavailable";
    pageMessage.textContent = resolveOverlayStatus(null).message;
    toggleButton.disabled = true;
    return;
  }

  const overlayStatus = resolveOverlayStatus(tabState);
  dot.classList.toggle("active", settings.active);
  statusText.textContent = settings.active ? "Active" : "Off";
  toggleButton.disabled = !overlayStatus.ready;
  toggleButton.classList.toggle("stop", settings.active);
  toggleButton.textContent = settings.active ? "Stop SonicFlow" : "Start SonicFlow";
  pageMessage.textContent = overlayStatus.message;
}

async function bootstrap() {
  const settings = await loadStoredSettings();
  const tabState = await queryActiveTabState().catch(() => null);

  renderState(settings, tabState);

  document.querySelector("#mode-grid").addEventListener("click", async (event) => {
    const button = event.target.closest("[data-mode]");
    if (!button) {
      return;
    }

    settings.mode = button.dataset.mode;
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#example-grid").addEventListener("click", async (event) => {
    const button = event.target.closest("[data-example]");
    if (!button) {
      return;
    }

    const example = EXAMPLES.find((entry) => entry.id === button.dataset.example);
    if (!example) {
      return;
    }

    settings.mode = example.mode;
    settings.durationMinutes = example.durationMinutes;
    settings.ambientMix = example.ambientMix;
    settings.pulseDepth = example.pulseDepth;
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#activity-select").addEventListener("change", async (event) => {
    const sessionPlan = resolveSessionPlan(event.target.value);
    settings.activityId = sessionPlan.activityId;
    settings.timerId = sessionPlan.timerId;
    settings.mode = sessionPlan.engineMode;
    settings.durationMinutes = sessionPlan.durationMinutes;
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#overlay-source-list").addEventListener("click", async (event) => {
    const button = event.target.closest("[data-overlay-source]");
    if (!button) {
      return;
    }

    settings.overlaySource = button.dataset.overlaySource;
    await persistSettings(settings);
    renderState(settings, tabState);
  });

  document.querySelector("#volume-slider").addEventListener("input", async (event) => {
    settings.volume = Number(event.target.value);
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#duration-slider").addEventListener("input", async (event) => {
    settings.durationMinutes = Number(event.target.value);
    settings.timerId = "standard";
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#ambient-slider").addEventListener("input", async (event) => {
    settings.ambientMix = Number(event.target.value);
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#pulse-slider").addEventListener("input", async (event) => {
    settings.pulseDepth = Number(event.target.value);
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#toggle-button").addEventListener("click", async () => {
    settings.active = !settings.active;
    const response = await pushStateToTab(settings).catch(() => null);
    await persistSettings(settings);
    renderState(settings, response ?? tabState);
  });
}

bootstrap().catch(() => {
  renderState({ ...DEFAULT_SETTINGS }, null);
});
