export const DEFAULT_ENGINE_SETTINGS = {
  chunkDurationSeconds: 10,
  overlapSeconds: 1,
  sampleRate: 44100
};

const MEDIA_CONTEXTS = [
  {
    hostPattern: /(^|\.)youtube\.com$/,
    id: "youtube-media",
    label: "YouTube",
    mediaService: "youtube",
    suggestedActivityId: "creative-flow",
    suggestedMode: "flow"
  },
  {
    hostPattern: /(^|\.)soundcloud\.com$/,
    id: "soundcloud-media",
    label: "SoundCloud",
    mediaService: "soundcloud",
    suggestedActivityId: "creative-flow",
    suggestedMode: "flow"
  },
  {
    hostPattern: /(^|\.)music\.apple\.com$/,
    id: "apple-music",
    label: "Apple Music",
    mediaService: "apple-music",
    suggestedActivityId: "creative-flow",
    suggestedMode: "flow"
  }
];

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

function getHostname(url) {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return "";
  }
}

export function detectPageContext({
  url = "",
  title = "",
  hasEditableText = false,
  pageHasAudioSource = false
} = {}) {
  const host = getHostname(url);
  const titleText = String(title).toLowerCase();
  const mediaContext = MEDIA_CONTEXTS.find((context) => context.hostPattern.test(host));

  if (mediaContext) {
    return {
      id: mediaContext.id,
      label: mediaContext.label,
      host,
      suggestedActivityId: mediaContext.suggestedActivityId,
      suggestedMode: mediaContext.suggestedMode,
      pageHasAudioSource,
      mediaService: mediaContext.mediaService
    };
  }

  if (
    hasEditableText ||
    /docs\.google\.com$/.test(host) ||
    /notion\.site$|notion\.so$/.test(host) ||
    titleText.includes("document") ||
    titleText.includes("doc")
  ) {
    return {
      id: "writing-doc",
      label: "Writing Doc",
      host,
      suggestedActivityId: "deep-work",
      suggestedMode: "focus",
      pageHasAudioSource,
      mediaService: null
    };
  }

  if (/meet\.google\.com$|zoom\.us$|teams\.microsoft\.com$/.test(host)) {
    return {
      id: "meeting",
      label: "Meeting",
      host,
      suggestedActivityId: "light-work",
      suggestedMode: "flow",
      pageHasAudioSource,
      mediaService: "meeting"
    };
  }

  return {
    id: pageHasAudioSource ? "browser-media" : "browser-page",
    label: pageHasAudioSource ? "Media Tab" : "Browser Page",
    host,
    suggestedActivityId: pageHasAudioSource ? "creative-flow" : "deep-work",
    suggestedMode: pageHasAudioSource ? "flow" : "focus",
    pageHasAudioSource,
    mediaService: pageHasAudioSource ? "browser" : null
  };
}
