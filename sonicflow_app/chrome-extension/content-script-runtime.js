export const DEFAULT_ENGINE_SETTINGS = {
  chunkDurationSeconds: 10,
  overlapSeconds: 1,
  sampleRate: 44100
};

export function createChunkPlan({
  startedAt,
  chunkDurationSeconds = DEFAULT_ENGINE_SETTINGS.chunkDurationSeconds,
  overlapSeconds = DEFAULT_ENGINE_SETTINGS.overlapSeconds
}) {
  return {
    current: {
      startsAt: startedAt,
      endsAt: startedAt + chunkDurationSeconds
    },
    next: {
      startsAt: startedAt + chunkDurationSeconds - overlapSeconds,
      endsAt: startedAt + (2 * chunkDurationSeconds) - overlapSeconds
    }
  };
}
