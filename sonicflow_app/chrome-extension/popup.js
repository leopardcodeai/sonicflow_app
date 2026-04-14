async function queryActiveTabState() {
  const { tabId } = await chrome.runtime.sendMessage({
    type: "FLOWTONES_QUERY_ACTIVE_TAB"
  });

  if (!tabId) {
    return null;
  }

  return chrome.runtime.sendMessage({
    type: "FLOWTONES_FORWARD_TO_TAB",
    tabId,
    payload: { type: "FLOWTONES_GET_STATE" }
  });
}

function renderState(tabState) {
  const dot = document.querySelector("#status-dot");
  const statusText = document.querySelector("#status-text");
  const pageMessage = document.querySelector("#page-message");

  if (!tabState) {
    statusText.textContent = "Unavailable";
    pageMessage.textContent = "Open a supported YouTube or SoundCloud tab first.";
    return;
  }

  dot.classList.toggle("active", tabState.active);
  statusText.textContent = tabState.active ? "Active" : "Off";
  pageMessage.textContent = tabState.pageHasAudioSource
    ? "Media element detected. SF-5 will add the full control surface."
    : "This page is open, but no media element is available yet.";
}

queryActiveTabState()
  .then(renderState)
  .catch(() => {
    renderState(null);
  });
