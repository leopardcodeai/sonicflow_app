import { extensionApi } from "./browser-polyfill.js";
import { DEFAULT_SETTINGS, MODES } from "./popup-model.js";

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
  await extensionApi.storage.local.set({ flowtonesSettings: settings });
}

async function loadStoredSettings() {
  const stored = await extensionApi.storage.local.get("flowtonesSettings");
  return {
    ...DEFAULT_SETTINGS,
    ...(stored.flowtonesSettings ?? {})
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

function updateHero(settings) {
  const heroTitle = document.querySelector("#hero-title");
  const heroDescription = document.querySelector("#hero-description");
  const activeMode = MODES.find((mode) => mode.id === settings.mode) ?? MODES[0];

  heroTitle.textContent = `${activeMode.name} Session`;
  heroDescription.textContent = `${activeMode.description} ${settings.durationMinutes} minute browser-safe layer with ${settings.ambientMix}% ambience and ${settings.pulseDepth}% pulse depth.`;
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
  updateHero(settings);
  volumeSlider.value = String(settings.volume);
  volumeValue.textContent = String(settings.volume);
  durationSlider.value = String(settings.durationMinutes);
  durationValue.textContent = `${settings.durationMinutes} min`;
  ambientSlider.value = String(settings.ambientMix);
  ambientValue.textContent = `${settings.ambientMix}%`;
  pulseSlider.value = String(settings.pulseDepth);
  pulseValue.textContent = `${settings.pulseDepth}%`;

  if (!tabState) {
    statusText.textContent = "Unavailable";
    pageMessage.textContent = "Open a supported YouTube or SoundCloud tab first.";
    toggleButton.disabled = true;
    return;
  }

  dot.classList.toggle("active", settings.active);
  statusText.textContent = settings.active ? "Active" : "Off";
  toggleButton.disabled = !tabState.pageHasAudioSource;
  toggleButton.classList.toggle("stop", settings.active);
  toggleButton.textContent = settings.active ? "Stop SonicFlow" : "Start SonicFlow";
  pageMessage.textContent = tabState.pageHasAudioSource
    ? "Media element detected. Ready to layer the selected mode."
    : "Open YouTube or SoundCloud first.";
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

  document.querySelector("#volume-slider").addEventListener("input", async (event) => {
    settings.volume = Number(event.target.value);
    await persistSettings(settings);
    await pushStateToTab(settings).catch(() => null);
    renderState(settings, tabState);
  });

  document.querySelector("#duration-slider").addEventListener("input", async (event) => {
    settings.durationMinutes = Number(event.target.value);
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
