import test from "node:test";
import assert from "node:assert/strict";

import { createBackgroundMessageHandler } from "./background.js";

function captureResponse(run) {
  return new Promise((resolve) => {
    run((value) => resolve(value));
  });
}

test("background handles callback-based tabs API", async () => {
  const api = {
    tabs: {
      query(_query, callback) {
        callback([{ id: 42 }]);
      },
      sendMessage(_tabId, _payload, callback) {
        callback({ ok: true });
      }
    }
  };

  const handler = createBackgroundMessageHandler(api);

  const keepOpenQuery = handler(
    { type: "FLOWTONES_QUERY_ACTIVE_TAB" },
    null,
    () => {}
  );
  assert.equal(keepOpenQuery, true);

  const queryResponse = await captureResponse((sendResponse) => {
    handler({ type: "FLOWTONES_QUERY_ACTIVE_TAB" }, null, sendResponse);
  });
  assert.deepEqual(queryResponse, { tabId: 42 });

  const forwardResponse = await captureResponse((sendResponse) => {
    handler(
      {
        type: "FLOWTONES_FORWARD_TO_TAB",
        tabId: 42,
        payload: { type: "FLOWTONES_GET_STATE" }
      },
      null,
      sendResponse
    );
  });
  assert.deepEqual(forwardResponse, { ok: true });
});

test("background handles promise-based tabs API (Safari browser.* style)", async () => {
  const api = {
    tabs: {
      query() {
        return Promise.resolve([{ id: 7 }]);
      },
      sendMessage() {
        return Promise.resolve({ pageHasAudioSource: true });
      }
    }
  };

  const handler = createBackgroundMessageHandler(api);

  const queryResponse = await captureResponse((sendResponse) => {
    handler({ type: "FLOWTONES_QUERY_ACTIVE_TAB" }, null, sendResponse);
  });
  assert.deepEqual(queryResponse, { tabId: 7 });

  const forwardResponse = await captureResponse((sendResponse) => {
    handler(
      {
        type: "FLOWTONES_FORWARD_TO_TAB",
        tabId: 7,
        payload: { type: "FLOWTONES_GET_STATE" }
      },
      null,
      sendResponse
    );
  });
  assert.deepEqual(forwardResponse, { pageHasAudioSource: true });
});

test("background ignores unknown message types", () => {
  const api = {
    tabs: {
      query() {
        return Promise.resolve([]);
      },
      sendMessage() {
        return Promise.resolve(null);
      }
    }
  };

  const handler = createBackgroundMessageHandler(api);
  const keepOpen = handler({ type: "FLOWTONES_UNKNOWN" }, null, () => {});
  assert.equal(keepOpen, false);
});
