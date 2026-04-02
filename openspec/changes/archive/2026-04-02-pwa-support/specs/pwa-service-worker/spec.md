## ADDED Requirements

### Requirement: App shell assets use cache-first strategy
The service worker SHALL cache all Flutter app shell assets (HTML, JS, CSS, fonts, images) using a cache-first strategy. On first load, these assets SHALL be fetched from the network and stored in the cache. On subsequent loads, they SHALL be served from cache with a background update check.

#### Scenario: App loads from cache on repeat visit
- **WHEN** a user revisits the app after an initial load
- **THEN** the app shell SHALL load from the service worker cache without a network request for cached assets

#### Scenario: Cache is updated when new version is deployed
- **WHEN** a new version of the app is deployed
- **THEN** the service worker SHALL detect the new version, fetch updated assets, and activate the new cache on the next navigation

### Requirement: API requests use network-first strategy
The service worker SHALL intercept requests to the Supabase API and use a network-first strategy. If the network request fails (e.g., offline), the service worker SHALL return a cached response if one exists.

#### Scenario: API data is fresh when online
- **WHEN** the user is online and the app makes an API request
- **THEN** the response SHALL come from the network and the cache SHALL be updated

#### Scenario: Cached API response returned when offline
- **WHEN** the user is offline and the app makes an API request that was previously cached
- **THEN** the service worker SHALL return the cached response

### Requirement: CDN resources use stale-while-revalidate strategy
The service worker SHALL cache third-party CDN resources (e.g., MapLibre GL JS) using a stale-while-revalidate strategy. Cached versions SHALL be served immediately while a background fetch updates the cache.

#### Scenario: MapLibre JS loads from cache
- **WHEN** the app loads and MapLibre JS was previously cached
- **THEN** the cached version SHALL be served immediately and a background fetch SHALL update the cache

### Requirement: Offline fallback page for navigation requests
The service worker SHALL pre-cache a static `web/offline.html` page. When a navigation request fails and no cached response is available, the service worker SHALL serve this offline fallback page.

#### Scenario: Offline fallback shown when fully offline
- **WHEN** the user navigates to the app with no network and no cached app shell
- **THEN** the offline fallback page SHALL be displayed with a message explaining the user is offline and a retry button

#### Scenario: Offline fallback is pre-cached on install
- **WHEN** the service worker is installed for the first time
- **THEN** `offline.html` SHALL be added to the pre-cache so it is available immediately

### Requirement: Service worker lifecycle management
The service worker SHALL handle its lifecycle correctly:
- On install: pre-cache app shell and offline fallback, then skip waiting
- On activate: clean up old caches from previous versions
- On fetch: route requests through the appropriate caching strategy

#### Scenario: Old caches are cleaned up
- **WHEN** a new service worker version activates
- **THEN** caches from the previous version SHALL be deleted

#### Scenario: New service worker activates immediately
- **WHEN** a new service worker is installed
- **THEN** it SHALL call `skipWaiting()` and `clients.claim()` to take control immediately
