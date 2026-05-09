import { MODES as ENGINE_MODES } from "../../../shared/core-js/beatEngine.js";
import {
  PRODUCT_MODES,
  SESSION_ACTIVITIES,
  SESSION_TIMERS
} from "../../../extensions/safari/popup-model.js";
import {
  detectOverlayCapability,
  resolveScienceClaim
} from "./sessionModel.js";
import { GENRES, INTENSITIES } from "./personalizationModel.js";
import { createTranslator } from "./i18n.js";
import { DEFAULT_WEB_UI_STATE } from "./webSessionStore.js";

const VIEW_LABELS = {
  home: "Home",
  player: "Player",
  library: "Library",
  stats: "Stats",
  profile: "Profile"
};

export const LIBRARY_SESSIONS = [
  { id: "ember", title: "ember", mode: "focus", genre: "cinematic", duration: "60m", favorite: true },
  { id: "glacier", title: "glacier", mode: "relax", genre: "ambient", duration: "45m", favorite: false },
  { id: "forest", title: "forest", mode: "sleep", genre: "nature", duration: "90m", favorite: false },
  { id: "desert", title: "desert", mode: "focus", genre: "classical", duration: "60m", favorite: true },
  { id: "nimbus", title: "nimbus", mode: "focus", genre: "electronic", duration: "30m", favorite: false },
  { id: "monsoon", title: "monsoon", mode: "meditate", genre: "piano", duration: "60m", favorite: false },
  { id: "canyon", title: "canyon", mode: "focus", genre: "orchestral", duration: "90m", favorite: false },
  { id: "tide", title: "tide", mode: "sleep", genre: "ambient", duration: "45m", favorite: false }
];

export function createPlaybackSnapshot(state, elapsedSeconds = 0) {
  const progress = state.durationMinutes === null
    ? 100
    : Math.min(100, (elapsedSeconds / (state.durationMinutes * 60)) * 100);

  return {
    elapsedSeconds,
    progress: Number.isFinite(progress) ? progress : 0,
    statusLabel: state.isPlaying ? "Live" : "Ready"
  };
}

export function renderApp({
  state,
  profile,
  quizAnswers,
  playback,
  view = "home",
  uiState = DEFAULT_WEB_UI_STATE,
  environment = globalThis
}) {
  const model = createRenderModel({ state, profile, quizAnswers, playback, view, uiState, environment });

  return `
    <div class="webapp-frame" data-view="${escapeAttribute(model.view)}" data-language="${escapeAttribute(model.i18n.language)}">
      ${renderSidebar(model)}
      <section class="webapp-main" aria-label="${escapeAttribute(modelViewLabel(model))}">
        ${renderTopBar(model)}
        ${renderView(model)}
      </section>
      ${renderPlayerBar(model)}
      ${model.ui.commandPaletteOpen ? renderCommandPalette(model) : ""}
    </div>
  `;
}

function createRenderModel({ state, profile, quizAnswers, playback, view, uiState, environment }) {
  const i18n = createTranslator(environment);
  const activeActivity = SESSION_ACTIVITIES.find((activity) => activity.id === state.activityId) ?? SESSION_ACTIVITIES[0];
  const activeTimer = SESSION_TIMERS[state.timerId];
  const engineMode = ENGINE_MODES[state.engineMode];
  const capability = detectOverlayCapability(environment);
  const scienceClaim = resolveScienceClaim({ requestedClaim: i18n.t("efficacyRequest"), evidenceValidated: false });
  const activities = SESSION_ACTIVITIES.filter((activity) => activity.mode === state.productMode);
  const snapshot = playback ?? createPlaybackSnapshot(state, 0);
  const safeView = Object.hasOwn(VIEW_LABELS, view) ? view : "home";
  const modeLabel = PRODUCT_MODES.find((mode) => mode.id === state.productMode)?.label ?? state.productMode;
  const remainingSeconds = state.durationMinutes === null
    ? null
    : Math.max(0, state.durationMinutes * 60 - snapshot.elapsedSeconds);
  const ui = normalizeUiState(uiState);
  const sessions = decorateLibrarySessions(ui);
  const filteredLibrarySessions = sortLibrarySessions(
    sessions.filter((session) => ui.libraryGenre === "all" || session.genre === ui.libraryGenre),
    ui.librarySort
  );
  const searchResults = searchLibrarySessions(sessions, ui.searchQuery);
  const queueSessions = ui.queueSessionIds
    .map((id) => sessions.find((session) => session.id === id))
    .filter(Boolean);

  return {
    i18n,
    state,
    profile,
    quizAnswers,
    activeActivity,
    activeTimer,
    engineMode,
    capability,
    scienceClaim,
    activities,
    snapshot,
    view: safeView,
    modeLabel,
    remainingSeconds,
    ui,
    sessions,
    filteredLibrarySessions,
    searchResults,
    queueSessions
  };
}

function renderSidebar(model) {
  const primary = [
    ["home", "⌂", model.i18n.t("home")],
    ["focus", "◐", model.i18n.label("Focus")],
    ["relax", "○", model.i18n.label("Relax")],
    ["sleep", "☾", model.i18n.label("Sleep")],
    ["meditate", "✦", model.i18n.label("Meditate")]
  ];
  const library = [
    ["library", "☰", model.i18n.t("library")],
    ["stats", "◊", model.i18n.t("stats")],
    ["profile", "♡", model.i18n.t("profile")]
  ];

  return `
    <aside class="webapp-sidebar glass-surface" aria-label="${escapeAttribute(model.i18n.t("sonicFlowSections"))}">
      <button class="brand-lockup" type="button" data-view="home" aria-label="SonicFlow home">
        <span class="leopard-logo" aria-hidden="true"></span>
        <span>sonicflow</span>
      </button>
      <p class="nav-label">Modes</p>
      <nav class="nav-stack">
        ${primary.map(([id, icon, label]) => navButton({
          id,
          icon,
          label,
          selected: id === model.state.productMode && model.view !== "library"
        })).join("")}
      </nav>
      <p class="nav-label">${escapeHtml(model.i18n.t("yourLibrary"))}</p>
      <nav class="nav-stack">
        ${library.map(([id, icon, label]) => navButton({
          id,
          icon,
          label,
          selected: model.view === id
        })).join("")}
      </nav>
      <div class="user-pill">
        <span class="leopard-logo small" aria-hidden="true"></span>
        <span><strong>sam wilson</strong><small>pro · 12d streak</small></span>
      </div>
    </aside>
  `;
}

function navButton({ id, icon, label, selected }) {
  const isProductMode = PRODUCT_MODES.some((mode) => mode.id === id);
  const dataAttribute = isProductMode ? `data-product-mode="${escapeAttribute(id)}"` : `data-view="${escapeAttribute(id)}"`;

  return `
    <button class="nav-item ${selected ? "active" : ""}" type="button" ${dataAttribute} aria-current="${selected ? "page" : "false"}">
      <span aria-hidden="true">${escapeHtml(icon)}</span>
      <span>${escapeHtml(label)}</span>
    </button>
  `;
}

function renderTopBar(model) {
  return `
    <header class="webapp-topbar">
      <div>
        <p class="eyebrow">${model.view === "home" ? escapeHtml(model.i18n.t("goodAfternoon")) : "sonicflow.app"}</p>
        <h1>${model.view === "library" ? escapeHtml(model.i18n.t("library").toLowerCase()) : model.view === "player" ? modelSessionName(model) : escapeHtml(model.i18n.t("whatFocusToday"))}</h1>
      </div>
      <label class="search-pill glass-surface">
        <span aria-hidden="true">⌕</span>
        <input type="search" value="${escapeAttribute(model.ui.searchQuery)}" placeholder="${escapeAttribute(model.i18n.t("searchSessions"))}" aria-label="${escapeAttribute(model.i18n.t("searchSessionsLabel"))}" data-search>
        <button class="key-button" type="button" data-command-palette aria-label="Open command palette"><kbd>⌘K</kbd></button>
      </label>
    </header>
  `;
}

function renderView(model) {
  switch (model.view) {
    case "player":
      return renderPlayerView(model);
    case "library":
      return renderLibraryView(model);
    case "stats":
      return renderStatsView(model);
    case "profile":
      return renderProfileView(model);
    default:
      return renderDashboard(model);
  }
}

function renderDashboard(model) {
  return `
    <div class="dashboard-grid">
      <section class="continue-card glass-surface">
        <div class="session-art large" aria-hidden="true">${leopardSpots(12)}</div>
        <div>
          <p class="eyebrow">● ${escapeHtml(model.i18n.t("pickUpWhereLeftOff"))}</p>
          <h2>${modelSessionName(model)} · ${escapeHtml(model.i18n.label(model.activeActivity.label))}</h2>
          <p>${formatRemaining(model)} · ${Math.round(clampProgress(model.snapshot.progress))}% complete · ${escapeHtml(model.profile.genre)}</p>
        </div>
        <button class="glass-control resume-button" type="button" data-toggle-playback>
          ${escapeHtml(model.state.isPlaying ? model.i18n.t("pause") : model.i18n.t("resume"))}
        </button>
      </section>

      <section class="mode-tile-grid" aria-labelledby="start-fresh-heading">
        <p class="nav-label" id="start-fresh-heading">${escapeHtml(model.i18n.t("orStartFresh"))}</p>
        <div class="mode-tiles" role="tablist" aria-label="${escapeAttribute(model.i18n.t("productModes"))}">
          ${PRODUCT_MODES.map((mode) => ritualTile(mode, model)).join("")}
        </div>
      </section>

      <section class="recent-panel glass-surface">
        <div class="panel-header">
          <p class="nav-label">${escapeHtml(model.i18n.t("recentSessions"))}</p>
          <button class="text-button" type="button" data-view="library">${escapeHtml(model.i18n.t("viewAll"))}</button>
        </div>
        ${LIBRARY_SESSIONS.slice(0, 3).map((session) => recentRow(session)).join("")}
      </section>

      <section class="week-panel glass-surface">
        <p class="nav-label">${escapeHtml(model.i18n.t("thisWeek"))}</p>
        <strong>4h 32m</strong>
        <small>↑ 18% vs last wk</small>
        <div class="week-bars" aria-hidden="true">
          ${[40, 60, 30, 80, 55, 70, 45].map((height, index) => `<span style="--bar:${height}%" class="${index === 6 ? "today" : ""}"></span>`).join("")}
        </div>
      </section>

      <section class="shortcut-grid" aria-label="Quick start shortcuts">
        ${renderTimerShortcuts(model)}
        ${renderGenreShortcuts(model)}
      </section>
    </div>
    <section class="detail-grid">
      ${renderControlsPanel(model)}
      ${renderQueuePanel(model)}
      ${renderOverlayPanel(model)}
      ${renderResearchPanel(model)}
    </section>
  `;
}

function renderPlayerView(model) {
  return `
    <div class="now-playing-view">
      <section class="album-stage glass-surface">
        <div class="album-art" aria-hidden="true">${leopardSpots(18)}</div>
        <div class="visualizer" aria-hidden="true">
          ${Array.from({ length: 56 }, (_, index) => `<span style="--h:${Math.round(16 + Math.abs(Math.sin(index * 0.55 + 1)) * 70)}%"></span>`).join("")}
        </div>
      </section>
      <section class="player-detail glass-surface">
        <p class="eyebrow">Now playing</p>
        <h2>${modelSessionName(model)}</h2>
        <p>${escapeHtml(model.profile.genre)} · ${escapeHtml(model.engineMode?.beatHz ?? "")}Hz neural · ${formatDuration(model)} ${escapeHtml(model.i18n.t("session"))}</p>
        <div class="scrubber" style="--progress:${clampProgress(model.snapshot.progress)}%">
          <span></span>
        </div>
        <div class="time-row">
          <span>${formatElapsed(model.snapshot.elapsedSeconds)}</span>
          <span>${formatRemaining(model)}</span>
        </div>
        <div class="transport-row">
          <button class="icon-button glass-control ${isFavorite(model, modelSessionId(model)) ? "active" : ""}" type="button" aria-pressed="${isFavorite(model, modelSessionId(model))}" data-toggle-favorite="${escapeAttribute(modelSessionId(model))}" aria-label="Favorite">${isFavorite(model, modelSessionId(model)) ? "♥" : "♡"}</button>
          <button class="icon-button glass-control" type="button" data-player-action="previous" aria-label="Previous">⏮</button>
          <button class="play-button glass-control" type="button" data-toggle-playback aria-label="${model.state.isPlaying ? "Pause" : "Start"}">${model.state.isPlaying ? "▌▌" : "▶"}</button>
          <button class="icon-button glass-control" type="button" data-player-action="next" aria-label="Next">⏭</button>
          <button class="icon-button glass-control" type="button" aria-label="Download">⤓</button>
        </div>
        ${renderQueuePanel(model)}
        ${renderControlsPanel(model)}
      </section>
    </div>
  `;
}

function renderLibraryView(model) {
  const chips = ["all", ...GENRES];
  return `
    <section class="library-view" data-library-layout="${escapeAttribute(model.ui.libraryLayout)}" data-library-sort="${escapeAttribute(model.ui.librarySort)}" data-library-genre="${escapeAttribute(model.ui.libraryGenre)}">
      <div class="filter-row" aria-label="${escapeAttribute(model.i18n.t("libraryFilters"))}">
        ${chips.map((chip) => `<button class="glass-control ${chip === model.ui.libraryGenre ? "active" : ""}" type="button" data-library-genre="${escapeAttribute(chip)}" aria-pressed="${chip === model.ui.libraryGenre}">${escapeHtml(formatGenre(chip))}</button>`).join("")}
      </div>
      <div class="library-toolbar">
        <div class="segmented-control glass-surface" aria-label="Library layout">
          ${["grid", "list"].map((layout) => `<button type="button" class="${model.ui.libraryLayout === layout ? "active" : ""}" data-library-layout="${layout}" aria-pressed="${model.ui.libraryLayout === layout}">${escapeHtml(layout)}</button>`).join("")}
        </div>
        <label class="compact-select">
          <span>Sort</span>
          <select data-library-sort>
            ${option("recent", "Recent", model.ui.librarySort)}
            ${option("title", "Title", model.ui.librarySort)}
            ${option("duration", "Duration", model.ui.librarySort)}
          </select>
        </label>
      </div>
      <div class="${model.ui.libraryLayout === "list" ? "library-list" : "library-grid"}">
        ${model.filteredLibrarySessions.map((session, index) => libraryCard(session, index, model)).join("")}
      </div>
    </section>
  `;
}

function renderStatsView(model) {
  return `
    <section class="glass-surface placeholder-view">
      <p class="eyebrow">${escapeHtml(model.i18n.t("stats"))}</p>
      <h2>4h 32m this week</h2>
      <p>${escapeHtml(model.i18n.t("sessionHistoryCopy"))}</p>
    </section>
  `;
}

function renderProfileView(model) {
  return `
    <section class="profile-layout">
      <div class="glass-surface profile-hero">
        <span class="leopard-logo profile-logo" aria-hidden="true"></span>
        <div>
          <p class="eyebrow">${escapeHtml(model.i18n.t("profile"))}</p>
          <h2>${formatNeurotype(model.profile.neurotype)}</h2>
          <p>12 day streak · ${escapeHtml(model.profile.genre)} default · ${escapeHtml(model.i18n.t("localOnlySync"))}</p>
        </div>
      </div>
      ${renderProfilePanel(model)}
    </section>
  `;
}

function renderControlsPanel(model) {
  return `
    <div class="glass-surface controls-panel">
      <div class="panel-header">
        <p class="nav-label">${escapeHtml(model.i18n.t("neuralIntensity"))}</p>
        <strong>${escapeHtml(model.i18n.label(model.state.intensity))}</strong>
      </div>
      <div class="intensity-row" aria-label="${escapeAttribute(model.i18n.t("neuralIntensity"))}">
        ${["low", "medium", "high"].map((intensity) => toggleButton({
          label: model.i18n.label(intensity),
          value: intensity,
          selected: model.state.intensity === intensity,
          dataName: "intensity"
        })).join("")}
      </div>
      <label>
        <span>${escapeHtml(model.i18n.t("duration"))}</span>
        <input type="range" min="5" max="120" step="5" value="${escapeAttribute(model.state.durationMinutes ?? 25)}" data-duration ${model.state.durationMinutes === null ? "disabled" : ""}>
      </label>
      <label>
        <span>${escapeHtml(model.i18n.t("volume"))}</span>
        <input type="range" min="0" max="60" step="1" value="${escapeAttribute(model.state.volume)}" data-volume>
      </label>
      <div class="intensity-row spatialization-row" aria-label="Sleep spatialization">
        ${["off", "low", "medium", "high"].map((level) => toggleButton({
          label: model.i18n.label(level),
          value: level,
          selected: model.state.sleepSpatialization === level,
          dataName: "sleep-spatialization",
          disabled: model.state.productMode !== "sleep"
        })).join("")}
      </div>
    </div>
  `;
}

function renderProfilePanel(model) {
  return `
    <div class="glass-surface profile-panel">
      <div class="profile-grid">
        <label>
          <span>${escapeHtml(model.i18n.t("focusPattern"))}</span>
          <select data-quiz-answer="focusPattern">
            ${option("deep-work", "Deep work", model.quizAnswers.focusPattern)}
            ${option("distractible", model.i18n.label("Distractible"), model.quizAnswers.focusPattern)}
            ${option("creative-block", "Creative block", model.quizAnswers.focusPattern)}
            ${option("stress", "Stress", model.quizAnswers.focusPattern)}
            ${option("low-energy", "Low energy", model.quizAnswers.focusPattern)}
          </select>
        </label>
        <label>
          <span>${escapeHtml(model.i18n.t("attentionSupport"))}</span>
          <select data-quiz-answer="attentionSupport">
            ${option("standard", "Standard", model.quizAnswers.attentionSupport)}
            ${option("adhd-self-reported", model.i18n.label("ADHD self-reported"), model.quizAnswers.attentionSupport)}
          </select>
        </label>
        <label>
          <span>${escapeHtml(model.i18n.t("sensitivity"))}</span>
          <select data-quiz-answer="sensitivity">
            ${option("gentle", model.i18n.label("Gentle"), model.quizAnswers.sensitivity)}
            ${option("balanced", model.i18n.label("Balanced"), model.quizAnswers.sensitivity)}
            ${option("strong", model.i18n.label("Strong"), model.quizAnswers.sensitivity)}
          </select>
        </label>
        <label>
          <span>${escapeHtml(model.i18n.t("genre"))}</span>
          <select data-profile-genre>
            ${GENRES.map((genre) => option(genre, formatGenre(genre), model.profile.genre)).join("")}
          </select>
        </label>
        <label>
          <span>${escapeHtml(model.i18n.t("defaultIntensity"))}</span>
          <select data-profile-intensity>
            ${INTENSITIES.map((intensity) => option(intensity, model.i18n.label(intensity), model.profile.defaultIntensity)).join("")}
          </select>
        </label>
      </div>
    </div>
  `;
}

function renderOverlayPanel(model) {
  return `
    <div class="glass-surface overlay-panel">
      <div>
        <p class="nav-label">${escapeHtml(model.i18n.t("overlayMode"))}</p>
        <strong>${formatCapability(model.capability.browserTabOverlay, model)}</strong>
      </div>
      <p>${escapeHtml(model.capability.message)}</p>
      <div class="capability-grid">
        <span>Standalone <b>${escapeHtml(model.capability.standaloneSessions)}</b></span>
        <span>PWA <b>${escapeHtml(model.capability.installablePwa)}</b></span>
      </div>
    </div>
  `;
}

function renderResearchPanel(model) {
  return `
    <div class="glass-surface research-panel">
      <div>
        <p class="nav-label">${escapeHtml(model.i18n.t("researchGate"))}</p>
        <strong>${escapeHtml(model.scienceClaim.allowed ? model.i18n.t("claimAllowed") : model.i18n.t("claimBlocked"))}</strong>
      </div>
      <p>${escapeHtml(model.scienceClaim.copy)}</p>
      <div class="intensity-row" aria-label="${escapeAttribute(model.i18n.t("researchCondition"))}">
        ${["modulated", "control"].map((condition) => toggleButton({
          label: model.i18n.label(condition),
          value: condition,
          selected: model.state.researchCondition === condition,
          dataName: "research-condition"
        })).join("")}
      </div>
      <div class="feedback-row" aria-label="${escapeAttribute(model.i18n.t("subjectiveFeedback"))}">
        ${[1, 2, 3, 4, 5].map((rating) => `
          <button type="button" class="glass-control" data-feedback="${rating}">${rating}</button>
        `).join("")}
        <button type="button" class="glass-control" data-attention-check>${escapeHtml(model.i18n.t("focusCheck"))}</button>
      </div>
    </div>
  `;
}

function renderPlayerBar(model) {
  const currentSessionId = modelSessionId(model);
  const favorited = isFavorite(model, currentSessionId);
  return `
    <footer class="player-bar glass-surface" aria-label="Persistent player">
      <button class="track-info" type="button" data-view="player">
        <span class="session-art small" aria-hidden="true">${leopardSpots(4)}</span>
        <span>
          <strong>${modelSessionName(model)}</strong>
          <small>${escapeHtml(model.i18n.lowerLabel(model.modeLabel))} · ${escapeHtml(model.profile.genre)} · ${escapeHtml(model.engineMode?.beatHz ?? "")}Hz</small>
        </span>
      </button>
      <div class="bar-transport">
        <button class="icon-button glass-control ${favorited ? "active" : ""}" type="button" aria-pressed="${favorited}" data-toggle-favorite="${escapeAttribute(currentSessionId)}" aria-label="Favorite">${favorited ? "♥" : "♡"}</button>
        <button class="icon-button glass-control" type="button" data-player-action="previous" aria-label="Previous">⏮</button>
        <button class="icon-button glass-control" type="button" data-player-action="restart" aria-label="Restart">↺</button>
        <button class="play-button glass-control" type="button" data-toggle-playback aria-label="${model.state.isPlaying ? "Pause" : "Start"}">${model.state.isPlaying ? "▌▌" : "▶"}</button>
        <button class="icon-button glass-control" type="button" data-player-action="next" aria-label="Next">⏭</button>
        <button class="icon-button glass-control" type="button" aria-label="Open player" data-view="player">⤢</button>
      </div>
      <div class="bar-progress">
        <span>${formatElapsed(model.snapshot.elapsedSeconds)}</span>
        <div class="scrubber mini" style="--progress:${clampProgress(model.snapshot.progress)}%"><span></span></div>
        <span>${formatRemaining(model)}</span>
        <span class="playback-status" aria-live="polite" aria-atomic="true">${escapeHtml(model.state.isPlaying ? model.i18n.t("statusLive") : model.i18n.t("statusReady"))}</span>
      </div>
    </footer>
  `;
}

function renderTimerShortcuts(model) {
  const timerIds = ["pomodoro", "short", "standard", "power-nap"];
  return `
    <div class="glass-surface shortcut-panel">
      <p class="nav-label">Timers</p>
      <div class="shortcut-card-grid">
        ${timerIds.map((timerId) => {
          const timer = SESSION_TIMERS[timerId];
          const selected = model.state.timerId === timerId;
          return `
            <button class="shortcut-card ${selected ? "active" : ""}" type="button" data-timer-shortcut="${escapeAttribute(timerId)}" aria-pressed="${selected}">
              <strong>${escapeHtml(model.i18n.label(timer.label))}</strong>
              <small>${timer.durationMinutes === null ? escapeHtml(model.i18n.t("openEnded")) : `${escapeHtml(timer.durationMinutes)}m`}</small>
            </button>
          `;
        }).join("")}
      </div>
    </div>
  `;
}

function renderGenreShortcuts(model) {
  const genreIds = ["lo-fi", "cinematic", "ambient", "nature"];
  return `
    <div class="glass-surface shortcut-panel">
      <p class="nav-label">Genres</p>
      <div class="shortcut-card-grid">
        ${genreIds.map((genre) => `
          <button class="shortcut-card ${model.profile.genre === genre ? "active" : ""}" type="button" data-genre-shortcut="${escapeAttribute(genre)}" aria-pressed="${model.profile.genre === genre}">
            <strong>${escapeHtml(formatGenre(genre))}</strong>
            <small>${escapeHtml(model.sessions.filter((session) => session.genre === genre).length)} sessions</small>
          </button>
        `).join("")}
      </div>
    </div>
  `;
}

function renderQueuePanel(model) {
  return `
    <div class="queue-panel glass-surface">
      <div class="panel-header">
        <p class="nav-label">Up Next</p>
        <button class="text-button" type="button" data-view="library">Edit queue</button>
      </div>
      <div class="queue-list">
        ${(model.queueSessions.length > 0 ? model.queueSessions : model.sessions.slice(0, 3)).map((session, index) => `
          <div class="queue-row">
            <button type="button" class="queue-track" data-play-session="${escapeAttribute(session.id)}">
              <span>${index + 1}</span>
              <span><strong>${escapeHtml(session.title)}</strong><small>${escapeHtml(session.genre)} · ${escapeHtml(session.duration)}</small></span>
            </button>
            <button class="icon-button glass-control queue-remove" type="button" data-queue-remove="${escapeAttribute(session.id)}" aria-label="Remove ${escapeAttribute(session.title)}">×</button>
          </div>
        `).join("")}
      </div>
    </div>
  `;
}

function renderCommandPalette(model) {
  const results = model.searchResults.slice(0, 5);
  return `
    <div class="command-backdrop" data-command-close>
      <section class="command-palette glass-surface" role="dialog" aria-modal="true" aria-label="Command palette">
        <label class="command-search">
          <span aria-hidden="true">⌕</span>
          <input type="search" value="${escapeAttribute(model.ui.searchQuery)}" placeholder="${escapeAttribute(model.i18n.t("searchSessions"))}" data-search autofocus>
        </label>
        <div class="command-actions">
          <button type="button" data-command="view:library">Open Library</button>
          <button type="button" data-command="view:player">Open Player</button>
          ${PRODUCT_MODES.map((mode) => `<button type="button" data-command="mode:${escapeAttribute(mode.id)}">${escapeHtml(model.i18n.label(mode.label))}</button>`).join("")}
        </div>
        <div class="command-results">
          ${results.length === 0 ? `<p>No matches</p>` : results.map((session) => `
            <button type="button" data-play-session="${escapeAttribute(session.id)}">
              <span><strong>${escapeHtml(session.title)}</strong><small>${escapeHtml(model.i18n.label(titleCase(session.mode)))} · ${escapeHtml(session.genre)} · ${escapeHtml(session.duration)}</small></span>
              <span aria-hidden="true">▶</span>
            </button>
          `).join("")}
        </div>
      </section>
    </div>
  `;
}

function ritualTile(mode, model) {
  const selected = model.state.productMode === mode.id;
  const activity = SESSION_ACTIVITIES.find((entry) => entry.id === mode.defaultActivity);
  return `
    <button type="button" class="ritual-tile glass-surface ${selected ? "active" : ""}" role="tab" aria-selected="${selected}" data-product-mode="${escapeAttribute(mode.id)}">
      <span class="tile-orb" aria-hidden="true"></span>
      <span><strong>${escapeHtml(model.i18n.lowerLabel(mode.label))}</strong><small>${escapeHtml(activity ? model.i18n.lowerLabel(activity.label) : model.i18n.t("session"))}</small></span>
    </button>
  `;
}

function recentRow(session) {
  return `
    <button class="recent-row" type="button" data-play-session="${escapeAttribute(session.id)}">
      <span class="session-art tiny" aria-hidden="true">${leopardSpots(3)}</span>
      <span><strong>${escapeHtml(session.title)}</strong><small>${escapeHtml(session.mode)} · ${escapeHtml(session.duration)} · today</small></span>
      <span aria-hidden="true">▶</span>
    </button>
  `;
}

function libraryCard(session, index, model) {
  const favorited = isFavorite(model, session.id);
  return `
    <article class="library-card glass-surface ${index % 4 === 0 ? "accent" : ""}">
      <button class="library-card-main" type="button" data-play-session="${escapeAttribute(session.id)}">
        <span class="library-art" aria-hidden="true">${leopardSpots(7)}</span>
        <span class="nav-label">${escapeHtml(session.mode)}</span>
        <strong>${escapeHtml(session.title)}</strong>
        <small>${escapeHtml(session.genre)} · ${escapeHtml(session.duration)}</small>
      </button>
      <button class="favorite-button glass-control ${favorited ? "active" : ""}" type="button" aria-pressed="${favorited}" data-toggle-favorite="${escapeAttribute(session.id)}" aria-label="${favorited ? "Remove favorite" : "Add favorite"}">${favorited ? "♥" : "♡"}</button>
      <button class="queue-add glass-control" type="button" data-queue-add="${escapeAttribute(session.id)}">Queue</button>
    </article>
  `;
}

function toggleButton({ label, value, selected, dataName, disabled = false }) {
  return `
    <button type="button" class="glass-control ${selected ? "active" : ""}" data-${dataName}="${escapeAttribute(value)}" ${disabled ? "disabled" : ""}>
      ${escapeHtml(label)}
    </button>
  `;
}

function option(value, label, selectedValue) {
  return `<option value="${escapeAttribute(value)}" ${value === selectedValue ? "selected" : ""}>${escapeHtml(label)}</option>`;
}

function modelViewLabel(model) {
  return {
    home: model.i18n.t("home"),
    player: model.i18n.t("player"),
    library: model.i18n.t("library"),
    stats: model.i18n.t("stats"),
    profile: model.i18n.t("profile")
  }[model.view] ?? "SonicFlow";
}

function normalizeUiState(uiState) {
  const merged = { ...DEFAULT_WEB_UI_STATE, ...(uiState ?? {}) };
  return {
    ...merged,
    favoriteSessionIds: Array.isArray(merged.favoriteSessionIds) ? merged.favoriteSessionIds : DEFAULT_WEB_UI_STATE.favoriteSessionIds,
    queueSessionIds: Array.isArray(merged.queueSessionIds) ? merged.queueSessionIds : DEFAULT_WEB_UI_STATE.queueSessionIds,
    searchQuery: typeof merged.searchQuery === "string" ? merged.searchQuery : "",
    commandPaletteOpen: Boolean(merged.commandPaletteOpen),
    libraryLayout: ["grid", "list"].includes(merged.libraryLayout) ? merged.libraryLayout : "grid",
    librarySort: ["recent", "title", "duration"].includes(merged.librarySort) ? merged.librarySort : "recent",
    libraryGenre: typeof merged.libraryGenre === "string" ? merged.libraryGenre : "all"
  };
}

function decorateLibrarySessions(ui) {
  const favoriteIds = new Set(ui.favoriteSessionIds);
  return LIBRARY_SESSIONS.map((session) => ({
    ...session,
    favorite: favoriteIds.has(session.id)
  }));
}

function sortLibrarySessions(sessions, sort) {
  const ordered = [...sessions];
  if (sort === "title") {
    return ordered.sort((left, right) => left.title.localeCompare(right.title));
  }
  if (sort === "duration") {
    return ordered.sort((left, right) => durationMinutes(left.duration) - durationMinutes(right.duration));
  }
  return ordered;
}

function searchLibrarySessions(sessions, query) {
  const normalizedQuery = query.trim().toLowerCase();
  if (!normalizedQuery) {
    return sessions.slice(0, 5);
  }

  return sessions.filter((session) => [
    session.title,
    session.mode,
    session.genre,
    session.duration
  ].some((value) => value.toLowerCase().includes(normalizedQuery)));
}

function isFavorite(model, sessionId) {
  return model.ui.favoriteSessionIds.includes(sessionId);
}

function modelSessionId(model) {
  return model.sessions.find((session) => session.title === modelSessionName(model))?.id ?? "ember";
}

function leopardSpots(count) {
  return "";
}

function modelSessionName(model) {
  if (model.state.productMode === "sleep") return "forest";
  if (model.state.productMode === "relax") return "glacier";
  if (model.state.productMode === "meditate") return "monsoon";
  return "ember";
}

export function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function escapeAttribute(value) {
  return escapeHtml(value);
}

function clampProgress(progress) {
  const numericProgress = Number(progress);
  if (!Number.isFinite(numericProgress)) {
    return 0;
  }
  return Math.max(0, Math.min(100, numericProgress));
}

function formatCapability(capability, model) {
  if (capability === "browser-api-review") {
    return model.i18n.t("browserApiReview");
  }
  if (capability === "extension-required") {
    return model.i18n.t("extensionRequired");
  }
  return escapeHtml(capability);
}

function formatDuration(model) {
  return model.state.durationMinutes === null ? model.i18n.t("openEnded") : `${escapeHtml(model.state.durationMinutes)}m`;
}

function formatElapsed(seconds) {
  const wholeSeconds = Math.max(0, Math.floor(seconds));
  const minutes = Math.floor(wholeSeconds / 60);
  const rest = String(wholeSeconds % 60).padStart(2, "0");
  return `${minutes}:${rest}`;
}

function formatRemaining(model) {
  if (model.remainingSeconds === null) {
    return model.i18n.t("untilStopped");
  }
  const minutes = Math.max(0, Math.ceil(model.remainingSeconds / 60));
  return `${minutes}m left`;
}

function formatGenre(genre) {
  return String(genre)
    .split("-")
    .map((part) => `${part[0]?.toUpperCase() ?? ""}${part.slice(1)}`)
    .join("-");
}

function formatNeurotype(neurotype) {
  return escapeHtml(String(neurotype)
    .split("-")
    .map((part) => `${part[0]?.toUpperCase() ?? ""}${part.slice(1)}`)
    .join(" "));
}

function durationMinutes(duration) {
  const parsed = Number.parseInt(duration, 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

function titleCase(value) {
  return `${String(value)[0]?.toUpperCase() ?? ""}${String(value).slice(1)}`;
}
