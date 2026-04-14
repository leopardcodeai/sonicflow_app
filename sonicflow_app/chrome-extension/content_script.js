import { BeatEngine } from "../core-js/beatEngine.js";
import { createChunkPlan, DEFAULT_ENGINE_SETTINGS } from "./content-script-runtime.js";

const state = {
  pageHasAudioSource: false,
  active: false,
  mode: "focus",
  volume: 15
};

class FlowTonesScheduler {
  constructor() {
    this.engine = new BeatEngine();
    this.audioContext = null;
    this.gainNode = null;
    this.timeoutId = null;
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
  }
}

const scheduler = new FlowTonesScheduler();

function findPrimaryMediaElement() {
  return document.querySelector("video, audio");
}

function refreshAvailability() {
  state.pageHasAudioSource = Boolean(findPrimaryMediaElement());
}

refreshAvailability();

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message?.type === "FLOWTONES_GET_STATE") {
    refreshAvailability();
    sendResponse({ ...state });
    return false;
  }

  if (message?.type === "FLOWTONES_SET_STATE") {
    refreshAvailability();
    state.active = Boolean(message.active);
    state.mode = message.mode ?? state.mode;
    state.volume = Number.isFinite(message.volume) ? message.volume : state.volume;
    scheduler.updateVolume();

    if (state.active && state.pageHasAudioSource) {
      scheduler.start().catch(() => {
        state.active = false;
      });
    } else {
      scheduler.stop();
    }
    sendResponse({ ...state });
    return false;
  }

  return false;
});
