import { extensionApi } from "./browser-polyfill.js";
import {
  DEFAULT_SETTINGS,
  EXAMPLES,
  MODES,
  OVERLAY_SOURCES,
  SESSION_ACTIVITIES,
  deleteSiteRule,
  normalizeRuleHost,
  resolveRuleForUrl,
  resolveOverlayStatus,
  resolveSessionActivity,
  resolveSessionPlan,
  resolveSessionTimer,
  upsertSiteRule
} from "./popup-model.js";
import { createTranslator } from "./i18n.js";

const i18n = createTranslator(globalThis);

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
    ...(stored.sonicflowSettings ?? {}),
    preferences: {
      ...DEFAULT_SETTINGS.preferences,
      ...(stored.sonicflowSettings?.preferences ?? {})
    },
    siteRules: stored.sonicflowSettings?.siteRules ?? DEFAULT_SETTINGS.siteRules
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
      <strong>${i18n.label(mode.name)}</strong>
      <small>${mode.beatHz} Hz</small>
      <span>${i18n.label(mode.description)}</span>
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
      <strong>${i18n.label(example.title)}</strong>
      <small>${i18n.label(example.subtitle)}</small>
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
    option.textContent = i18n.label(activity.label);
    activitySelect.append(option);
  }

  const activity = resolveSessionActivity(settings.activityId ?? DEFAULT_SETTINGS.activityId);
  const timer = resolveSessionTimer(settings.timerId ?? activity.defaultTimer);
  activitySelect.value = activity.id;
  activityTimer.textContent = timer.durationMinutes === null
    ? `${i18n.label(timer.label)} · ${i18n.t("untilStopped").toLowerCase()}`
    : `${i18n.label(timer.label)} · ${timer.durationMinutes} min`;
}

function applyContextSuggestion(settings, tabState) {
  if (!settings.preferences.autoApplySiteRules) {
    return;
  }

  const matchedRule = resolveRuleForUrl(settings.siteRules, tabState?.pageContext?.host);
  if (matchedRule) {
    settings.mode = matchedRule.mode;
    settings.activityId = matchedRule.activityId;
    if (matchedRule.autoStart && tabState?.pageHasAudioSource) {
      settings.active = true;
    }
    return;
  }

  if (!settings.active && tabState?.pageContext?.suggestedMode) {
    settings.mode = tabState.pageContext.suggestedMode;
    settings.activityId = tabState.pageContext.suggestedActivityId ?? settings.activityId;
  }
}

function updateHero(settings, tabState) {
  const heroTitle = document.querySelector("#hero-title");
  const heroDescription = document.querySelector("#hero-description");
  const detected = document.querySelector("[data-i18n='detected-doc']");
  const activeMode = MODES.find((mode) => mode.id === settings.mode) ?? MODES[0];
  const activity = resolveSessionActivity(settings.activityId ?? DEFAULT_SETTINGS.activityId);
  const durationLabel = settings.durationMinutes === null
    ? i18n.t("open")
    : `${settings.durationMinutes}m`;
  const ambienceLabel = settings.ambientMix >= 75 ? i18n.t("warmAmbience") : i18n.t("cleanAmbience");
  const pulseLabel = settings.pulseDepth >= 80 ? i18n.t("highPulse") : i18n.t("softPulse");

  detected.textContent = `Detected · ${tabState?.pageContext?.label ?? "Browser Page"}`;
  heroTitle.textContent = `${i18n.t("suggested")}: ${i18n.label(activeMode.name)}`;
  heroDescription.textContent = `${i18n.label(activity.label)} · ${durationLabel} · ${ambienceLabel} · ${pulseLabel}.`;
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
      <span>${i18n.label(source.label)}</span>
      <small>${i18n.label(source.status)}</small>
    `;
    item.title = source.description;
    sourceList.append(item);
  }

  sourceStatus.textContent = i18n.label(overlayStatus.message);
}

function localizeStaticShell() {
  document.documentElement.lang = i18n.language;
  document.querySelector("[data-i18n='detected-doc']").textContent = i18n.t("detectedDoc");
  document.querySelector("[data-i18n='starter-sessions']").textContent = i18n.t("starterSessions");
  document.querySelector("[data-i18n='activity']").textContent = i18n.t("activity");
  document.querySelector("[data-i18n='activity-copy']").textContent = i18n.t("activityCopy");
  document.querySelector("[data-i18n='overlay-mode']").textContent = i18n.t("overlayMode");
  document.querySelector("[data-i18n='overlay-copy']").textContent = i18n.t("layerCopy");
  document.querySelector("[data-i18n='beat-volume']").textContent = i18n.t("beatVolume");
  document.querySelector("[data-i18n='duration']").textContent = i18n.t("duration");
  document.querySelector("[data-i18n='ambient-mix']").textContent = i18n.t("ambientMix");
  document.querySelector("[data-i18n='pulse-depth']").textContent = i18n.t("pulseDepth");
}

function renderSiteRules(settings, tabState) {
  const hostInput = document.querySelector("#site-rule-host");
  const modeSelect = document.querySelector("#site-rule-mode");
  const activitySelect = document.querySelector("#site-rule-activity");
  const autoStart = document.querySelector("#site-rule-autostart");
  const currentLabel = document.querySelector("#current-site-rule-label");
  const list = document.querySelector("#site-rule-list");
  const host = tabState?.pageContext?.host ?? "";
  const matchedRule = resolveRuleForUrl(settings.siteRules, host);

  hostInput.value = hostInput.value || host;
  modeSelect.value = matchedRule?.mode ?? settings.mode;
  autoStart.checked = matchedRule?.autoStart ?? false;
  activitySelect.replaceChildren();
  for (const activity of SESSION_ACTIVITIES) {
    const option = document.createElement("option");
    option.value = activity.id;
    option.textContent = i18n.label(activity.label);
    activitySelect.append(option);
  }
  activitySelect.value = matchedRule?.activityId ?? settings.activityId;
  currentLabel.innerHTML = matchedRule
    ? `auto-play <b>${matchedRule.mode}</b> on ${matchedRule.host}`
    : `suggest <b>${settings.mode}</b> for ${host || "this site"}`;

  list.replaceChildren();
  for (const rule of settings.siteRules) {
    const row = document.createElement("div");
    row.className = "site-rule-row";
    row.innerHTML = `
      <span><b>${rule.host}</b> · ${rule.mode}${rule.autoStart ? " · auto" : ""}</span>
      <button class="rule-delete" type="button" data-rule-delete="${rule.host}">Delete</button>
    `;
    list.append(row);
  }
}

function renderPreferences(settings) {
  document.querySelector("#floating-player-toggle").checked = Boolean(settings.preferences.floatingPlayer);
  document.querySelector("#site-rules-toggle").checked = Boolean(settings.preferences.autoApplySiteRules);
  document.querySelector("#compact-popup-toggle").checked = Boolean(settings.preferences.compactPopup);
  document.body.classList.toggle("compact", Boolean(settings.preferences.compactPopup));
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
  renderSiteRules(settings, tabState);
  renderPreferences(settings);
  updateHero(settings, tabState);
  volumeSlider.value = String(settings.volume);
  volumeValue.textContent = String(settings.volume);
  durationSlider.disabled = settings.durationMinutes === null;
  durationSlider.value = String(settings.durationMinutes ?? DEFAULT_SETTINGS.durationMinutes);
  durationValue.textContent = settings.durationMinutes === null
    ? i18n.t("untilStopped")
    : `${settings.durationMinutes} min`;
  ambientSlider.value = String(settings.ambientMix);
  ambientValue.textContent = `${settings.ambientMix}%`;
  pulseSlider.value = String(settings.pulseDepth);
  pulseValue.textContent = `${settings.pulseDepth}%`;

  if (!tabState) {
    statusText.textContent = i18n.t("unavailable");
    pageMessage.textContent = i18n.label(resolveOverlayStatus(null).message);
    toggleButton.disabled = true;
    return;
  }

  const overlayStatus = resolveOverlayStatus(tabState);
  dot.classList.toggle("active", settings.active);
  statusText.textContent = settings.active ? i18n.t("active") : i18n.t("off");
  toggleButton.disabled = !overlayStatus.ready;
  toggleButton.classList.toggle("stop", settings.active);
  toggleButton.textContent = settings.active ? i18n.t("stop") : i18n.t("start");
  pageMessage.textContent = i18n.label(overlayStatus.message);
}

async function bootstrap() {
  localizeStaticShell();
  const settings = await loadStoredSettings();
  const tabState = await queryActiveTabState().catch(() => null);
  applyContextSuggestion(settings, tabState);
  await persistSettings(settings);

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

  document.querySelector("#site-rule-save").addEventListener("click", async () => {
    settings.siteRules = upsertSiteRule(settings.siteRules, {
      host: document.querySelector("#site-rule-host").value,
      mode: document.querySelector("#site-rule-mode").value,
      activityId: document.querySelector("#site-rule-activity").value,
      autoStart: document.querySelector("#site-rule-autostart").checked
    });
    await persistSettings(settings);
    renderState(settings, tabState);
  });

  document.querySelector("#site-rule-list").addEventListener("click", async (event) => {
    const button = event.target.closest("[data-rule-delete]");
    if (!button) {
      return;
    }

    settings.siteRules = deleteSiteRule(settings.siteRules, button.dataset.ruleDelete);
    await persistSettings(settings);
    renderState(settings, tabState);
  });

  document.querySelector("#site-rule-host").addEventListener("change", (event) => {
    event.target.value = normalizeRuleHost(event.target.value);
  });

  for (const [selector, key] of [
    ["#floating-player-toggle", "floatingPlayer"],
    ["#site-rules-toggle", "autoApplySiteRules"],
    ["#compact-popup-toggle", "compactPopup"]
  ]) {
    document.querySelector(selector).addEventListener("change", async (event) => {
      settings.preferences[key] = event.target.checked;
      await persistSettings(settings);
      await pushStateToTab(settings).catch(() => null);
      renderState(settings, tabState);
    });
  }

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
