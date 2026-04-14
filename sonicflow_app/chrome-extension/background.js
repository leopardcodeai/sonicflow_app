import { extensionApi } from "./browser-polyfill.js";

extensionApi.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type === "FLOWTONES_QUERY_ACTIVE_TAB") {
    extensionApi.tabs.query({ active: true, currentWindow: true }, ([tab]) => {
      sendResponse({ tabId: tab?.id ?? null });
    });
    return true;
  }

  if (message?.type === "FLOWTONES_FORWARD_TO_TAB") {
    extensionApi.tabs.sendMessage(message.tabId, message.payload, sendResponse);
    return true;
  }

  return false;
});
