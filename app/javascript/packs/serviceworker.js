const CACHE_NAME = "v1-cached-assets"

function onInstall(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function prefill(cache) {
      return cache.addAll([
        '/offline.html'
      ]);
    })
  );
}

function onActivate(event) {
  event.waitUntil(
    caches.keys().then(function (cacheNames) {
      return Promise.all(
        cacheNames.filter(function (cacheName) {
          // Return true if you want to remove this cache,
          // but remember that caches are shared across
          // the whole origin
          return cacheName.indexOf('v1') !== 0;
        }).map(function (cacheName) {
          return caches.delete(cacheName);
        })
      );
    })
  );
}

self.addEventListener('install', onInstall)
self.addEventListener('activate', onActivate)

function onFetch(event) {
  // Fetch from network, fallback to cached content, then offline.html for same-origin GET requests
  const request = event.request;

  if (!request.url.match(/localhost|herokuapp/)) {
    return;
  }
  if (request.method !== 'GET') {
    return;
  }

  event.respondWith(
    fetch(request).catch(function fallback() {
      return caches.match('/offline.html')
    })
  );

  // See https://jakearchibald.com/2014/offline-cookbook/#on-network-response for more examples
}

self.addEventListener('fetch', onFetch);
