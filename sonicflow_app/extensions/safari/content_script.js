import { BeatEngine } from "../../shared/core-js/beatEngine.js";
import { extensionApi } from "./browser-polyfill.js";
import { createChunkPlan, DEFAULT_ENGINE_SETTINGS, detectPageContext } from "./content-script-runtime.js";

const state = {
  pageHasAudioSource: false,
  pageContext: detectPageContext(),
  active: false,
  mode: "focus",
  volume: 15,
  preferences: {
    floatingPlayer: true
  }
};

class SonicFlowScheduler {
  constructor() {
    this.engine = new BeatEngine();
    this.audioContext = null;
    this.gainNode = null;
    this.timeoutId = null;
    this.sources = new Set();
    this.startedAt = 0;
    this.lastScheduledAt = 0;
  }

  async ensureContext() {
    if (!this.audioContext) {
      this.audioContext = new AudioContext({
        sampleRate: DEFAULT_ENGINE_SETTINGS.sampleRate
      });
      this.gainNode = this.audioContext.createGain();
      this.gainNode.gain.value = state.volume / 100;
      this.gainNode.connect(this.audioContext.destination);
    }

    if (this.audioContext.state === "suspended") {
      await this.audioContext.resume();
    }
  }

  updateVolume() {
    if (this.gainNode) {
      this.gainNode.gain.value = state.volume / 100;
    }
  }

  createBufferSource(startTime) {
    const pcm = this.engine.generate(
      state.mode,
      DEFAULT_ENGINE_SETTINGS.chunkDurationSeconds,
      DEFAULT_ENGINE_SETTINGS.sampleRate
    );
    const frameCount = pcm.length / 2;
    const buffer = this.audioContext.createBuffer(
      2,
      frameCount,
      DEFAULT_ENGINE_SETTINGS.sampleRate
    );
    const left = buffer.getChannelData(0);
    const right = buffer.getChannelData(1);

    for (let frame = 0; frame < frameCount; frame += 1) {
      left[frame] = pcm[frame * 2];
      right[frame] = pcm[frame * 2 + 1];
    }

    const source = this.audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(this.gainNode);
    source.onended = () => {
      this.sources.delete(source);
      source.disconnect();
    };
    this.sources.add(source);
    source.start(startTime);
  }

  scheduleChunk(startedAt) {
    const plan = createChunkPlan({ startedAt });
    this.createBufferSource(plan.current.startsAt);
    this.lastScheduledAt = plan.current.startsAt;
    this.timeoutId = window.setTimeout(() => {
      if (!state.active) {
        return;
      }
      this.scheduleChunk(plan.next.startsAt);
    }, (DEFAULT_ENGINE_SETTINGS.chunkDurationSeconds - DEFAULT_ENGINE_SETTINGS.overlapSeconds) * 1000);
  }

  async start() {
    await this.ensureContext();
    this.stop();
    this.startedAt = this.audioContext.currentTime;
    this.scheduleChunk(this.startedAt);
  }

  stop() {
    if (this.timeoutId) {
      window.clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
    for (const source of this.sources) {
      source.onended = null;
      try {
        source.stop();
      } catch {
        // A source can already be ended when a stop races with onended.
      }
      source.disconnect();
    }
    this.sources.clear();
  }
}

const scheduler = new SonicFlowScheduler();

function findPrimaryMediaElement() {
  return document.querySelector("video, audio");
}

function hasEditableText() {
  return Boolean(document.querySelector("textarea, input[type='text'], [contenteditable='true'], [role='textbox']"));
}

function refreshAvailability() {
  state.pageHasAudioSource = Boolean(findPrimaryMediaElement());
  state.pageContext = detectPageContext({
    url: location.href,
    title: document.title,
    hasEditableText: hasEditableText(),
    pageHasAudioSource: state.pageHasAudioSource
  });
}

function ensureMiniPlayer() {
  if (!state.preferences.floatingPlayer) {
    document.querySelector("#sonicflow-mini-player")?.remove();
    return;
  }

  let miniPlayer = document.querySelector("#sonicflow-mini-player");
  if (!miniPlayer) {
    miniPlayer = document.createElement("aside");
    miniPlayer.id = "sonicflow-mini-player";
    miniPlayer.attachShadow({ mode: "open" });
    document.documentElement.append(miniPlayer);
  }

  miniPlayer.shadowRoot.innerHTML = `
    <style>
      :host {
        all: initial;
        position: fixed;
        right: 18px;
        bottom: 18px;
        z-index: 2147483647;
        --sf-fg: #F5F7FB;
        --sf-muted: #8E97A8;
        --sf-panel-strong: rgba(18, 18, 22, 0.86);
        --sf-border: rgba(245, 247, 251, 0.16);
        --accent-gold: #D4A24C;
        --accent-danger: #E0484D;
        --neutral-ink: #0A0A0B;
        font: 12px/1.35 -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
      }

      .panel {
        display: grid;
        grid-template-columns: 28px minmax(0, 1fr);
        gap: 8px;
        align-items: center;
        width: 168px;
        padding: 9px 10px;
        border: 1px solid var(--sf-border);
        border-radius: 12px;
        color: var(--sf-fg);
        background: var(--sf-panel-strong);
        box-shadow: 0 14px 28px var(--sf-border);
        backdrop-filter: blur(18px) saturate(140%);
        -webkit-backdrop-filter: blur(18px) saturate(140%);
      }

      .mark {
        display: grid;
        place-items: center;
        width: 28px;
        height: 28px;
        border-radius: 8px;
        background: ${state.active ? "var(--accent-danger)" : "var(--accent-gold)"};
        color: ${state.active ? "var(--sf-fg)" : "var(--neutral-ink)"};
        font-weight: 900;
      }

      strong, span {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      span {
        color: var(--sf-muted);
        font-size: 11px;
      }
    </style>
    <div class="panel" role="status" aria-live="polite">
      <div class="mark">${state.active ? "||" : ">"}</div>
      <div>
        <strong>${state.active ? "SonicFlow on" : "SonicFlow ready"}</strong>
        <span>${state.pageContext.label} · ${state.mode}</span>
      </div>
    </div>
  `;
}

refreshAvailability();

extensionApi.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message?.type === "FLOWTONES_GET_STATE") {
    refreshAvailability();
    ensureMiniPlayer();
    sendResponse({ ...state });
    return false;
  }

  if (message?.type === "FLOWTONES_SET_STATE") {
    refreshAvailability();
    state.active = Boolean(message.active);
    state.mode = message.mode ?? state.mode;
    state.volume = Number.isFinite(message.volume) ? message.volume : state.volume;
    state.preferences = {
      ...state.preferences,
      ...(message.preferences ?? {})
    };
    scheduler.updateVolume();

    if (state.active && state.pageHasAudioSource) {
      scheduler.start().catch(() => {
        state.active = false;
      });
    } else {
      scheduler.stop();
    }
    ensureMiniPlayer();
    sendResponse({ ...state });
    return false;
  }

  return false;
});
