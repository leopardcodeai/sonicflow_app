const state = {
  pageHasAudioSource: false,
  active: false,
  mode: "focus",
  volume: 15
};

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
    sendResponse({ ...state });
    return false;
  }

  return false;
});
