'use strict';

const CACHE_VERSION = 'tb-v1';
const OFFLINE_URL = 'offline.html';

// URL patterns for routing strategy decisions
const SUPABASE_API_PATTERN = /supabase\.co/;
const MAPLIBRE_CDN_PATTERN = /unpkg\.com\/maplibre-gl/;

// --- Install: pre-cache offline fallback ---
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE_VERSION)
      .then((cache) => cache.add(OFFLINE_URL))
      .then(() => self.skipWaiting()),
  );
});

// --- Activate: clean up old caches ---
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key !== CACHE_VERSION)
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

// --- Fetch: route requests through appropriate strategy ---
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Only handle GET requests
  if (request.method !== 'GET') return;

  // Strategy: network-first for Supabase API calls
  if (SUPABASE_API_PATTERN.test(url.href)) {
    event.respondWith(networkFirst(request));
    return;
  }

  // Strategy: stale-while-revalidate for MapLibre CDN
  if (MAPLIBRE_CDN_PATTERN.test(url.href)) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  // Strategy: offline fallback for same-origin navigation requests
  if (request.mode === 'navigate' && url.origin === self.location.origin) {
    event.respondWith(navigationWithOfflineFallback(request));
    return;
  }

  // All other requests: let Flutter's generated service worker handle them
  // (Flutter registers its own fetch handlers via importScripts below)
});

// Import Flutter's generated service worker for app shell caching.
// This file is created at build time; wrapped in try/catch for dev mode.
try {
  importScripts('flutter_service_worker.js');
} catch (_) {
  // flutter_service_worker.js not available (e.g., during flutter run dev server)
}

// --- Strategy implementations ---

async function networkFirst(request) {
  const cache = await caches.open(CACHE_VERSION);
  try {
    const response = await fetch(request);
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch (_) {
    const cached = await cache.match(request);
    return cached || Response.error();
  }
}

async function staleWhileRevalidate(request) {
  const cache = await caches.open(CACHE_VERSION);
  const cached = await cache.match(request);

  const networkFetch = fetch(request).then((response) => {
    if (response.ok) cache.put(request, response.clone());
    return response;
  });

  return cached || networkFetch;
}

async function navigationWithOfflineFallback(request) {
  try {
    return await fetch(request);
  } catch (_) {
    const cache = await caches.open(CACHE_VERSION);
    return (await cache.match(OFFLINE_URL)) || Response.error();
  }
}
