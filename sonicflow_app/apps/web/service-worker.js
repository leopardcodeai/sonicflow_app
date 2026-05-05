const CACHE_NAME = "sonicflow-web-v2";
const CACHE_URLS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./src/app.js",
  "./src/personalizationModel.js",
  "./src/sessionModel.js",
  "./src/styles.css",
  "../../extensions/safari/popup-model.js",
  "../../shared/core-js/beatEngine.js",
  "../../../brand/generated/tokens.css",
  "../../../brand/assets/wallpapers/leopard_pattern_2048x2048.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(CACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then((cached) => cached ?? fetch(event.request))
  );
});
