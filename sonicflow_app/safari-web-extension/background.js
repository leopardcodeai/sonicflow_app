import { extensionApi } from "./browser-polyfill.js";

function once(fn) {
  let didRun = false;
  return (value) => {
    if (didRun) {
      return;
    }
    didRun = true;
    fn(value);
  };
}

function isThenable(value) {
  return Boolean(value) && typeof value.then === "function";
}

export function createBackgroundMessageHandler(api) {
  return (message, _sender, sendResponse) => {
    const respond = once(sendResponse);

    if (message?.type === "FLOWTONES_QUERY_ACTIVE_TAB") {
      try {
        const maybePromise = api.tabs.query({ active: true, currentWindow: true }, ([tab]) => {
          respond({ tabId: tab?.id ?? null });
        });

        if (isThenable(maybePromise)) {
          maybePromise
            .then((tabs) => {
              respond({ tabId: tabs?.[0]?.id ?? null });
            })
            .catch(() => {
              respond({ tabId: null });
            });
        }
      } catch {
        respond({ tabId: null });
      }
      return true;
    }

    if (message?.type === "FLOWTONES_FORWARD_TO_TAB") {
      try {
        const maybePromise = api.tabs.sendMessage(message.tabId, message.payload, (response) => {
          respond(response ?? null);
        });

        if (isThenable(maybePromise)) {
          maybePromise
            .then((response) => {
              respond(response ?? null);
            })
            .catch(() => {
              respond(null);
            });
        }
      } catch {
        respond(null);
      }
      return true;
    }

    return false;
  };
}

if (extensionApi?.runtime?.onMessage?.addListener) {
  extensionApi.runtime.onMessage.addListener(createBackgroundMessageHandler(extensionApi));
}
