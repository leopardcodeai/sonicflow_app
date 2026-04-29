const CACHE_NAME = "sonicflow-web-v1";
const CACHE_URLS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./src/app.js",
  "./src/personalizationModel.js",
  "./src/sessionModel.js",
  "./src/styles.css",
  "../safari-web-extension/popup-model.js",
  "../core-js/beatEngine.js",
  "../../brand/generated/tokens.css",
  "../../brand/assets/wallpapers/leopard_wallpaper.png",
  "../safari-web-extension/assets/bowl_hero.png"
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
