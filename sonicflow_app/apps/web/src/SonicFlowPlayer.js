import { BeatEngine } from "../../../shared/core-js/beatEngine.js";

const CHUNK_SECONDS = 10;
const SAMPLE_RATE = 44100;

export class SonicFlowPlayer {
  constructor({ onTick, onStop, AudioContextRef = globalThis.AudioContext } = {}) {
    this.engine = new BeatEngine();
    this.AudioContextRef = AudioContextRef;
    this.audioContext = null;
    this.gainNode = null;
    this.timeoutId = null;
    this.tickId = null;
    this.sources = new Set();
    this.startedAt = 0;
    this.elapsedSeconds = 0;
    this.onTick = onTick ?? (() => {});
    this.onStop = onStop ?? (() => {});
  }

  async start(sessionState) {
    await this.ensureContext();
    this.stopScheduledAudio();
    this.sessionState = sessionState;
    this.startedAt = this.audioContext.currentTime;
    this.elapsedSeconds = 0;
    this.updateVolume(sessionState.volume);
    this.scheduleChunk(this.startedAt);
    this.tickId = window.setInterval(() => this.tick(), 500);
  }

  stop() {
    this.stopScheduledAudio();
    this.elapsedSeconds = 0;
  }

  updateVolume(volume) {
    if (this.gainNode) {
      this.gainNode.gain.value = volume / 100;
    }
  }

  async ensureContext() {
    if (!this.audioContext) {
      this.audioContext = new this.AudioContextRef({ sampleRate: SAMPLE_RATE });
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
    source.onended = () => {
      this.sources.delete(source);
      source.disconnect();
    };
    this.sources.add(source);
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

  stopScheduledAudio() {
    if (this.timeoutId) {
      window.clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
    if (this.tickId) {
      window.clearInterval(this.tickId);
      this.tickId = null;
    }
    for (const source of this.sources) {
      source.onended = null;
      try {
        source.stop();
      } catch {
        // Already-ended buffer sources throw when stopped twice.
      }
      source.disconnect();
    }
    this.sources.clear();
  }
}
