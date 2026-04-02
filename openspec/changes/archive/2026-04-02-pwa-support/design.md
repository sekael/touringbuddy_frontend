## Context

TouringBuddy is a Flutter web app deployed to Cloudflare Pages. It currently ships with Flutter's default PWA scaffolding: a generic `manifest.json`, placeholder icons, and an auto-generated service worker that uses a basic cache-first strategy for the app shell. There is no custom offline logic, no branded install experience, and no offline fallback page. The app uses MapLibre GL JS (loaded via CDN) and Supabase for backend services.

## Goals / Non-Goals

**Goals:**
- Make the app fully installable with branded identity (name, icons, splash) on all major platforms
- Provide a custom service worker with appropriate caching strategies for different resource types
- Show a meaningful offline fallback when no cached content is available
- Surface a discoverable in-app install prompt
- Ensure all changes pass Lighthouse PWA audit

**Non-Goals:**
- Full offline-first data layer (e.g., syncing Supabase data to local storage for offline use) — this is a future initiative
- Background sync for mutations made while offline
- Push notifications
- Caching map tiles for offline use (MapLibre tile caching is a separate concern)

## Decisions

### 1. Custom service worker via Flutter's `--pwa-strategy` + custom `flutter_service_worker.js` override

**Choice**: Use Flutter's built-in service worker generation but customize caching strategies by providing a post-build custom service worker that wraps Flutter's generated one.

**Alternatives considered**:
- **Workbox**: Powerful but adds a build-time dependency and complexity not warranted for our scope.
- **Fully custom service worker**: Maximum control but would need to replicate Flutter's app shell caching logic.

**Rationale**: Flutter generates a service worker that knows about all app shell assets. We extend it by adding a network-first strategy for API calls and an offline fallback for navigation requests. This keeps the Flutter build pipeline intact while adding the customizations we need.

### 2. Offline fallback as static HTML page

**Choice**: Ship a standalone `web/offline.html` that is pre-cached by the service worker and served when a navigation request fails.

**Rationale**: A lightweight HTML page with inline CSS loads instantly without any framework dependencies. It tells the user they're offline and suggests retrying. This avoids bootstrapping the full Flutter engine just to show an error.

### 3. Install prompt via JS interop (no external package)

**Choice**: Capture the `beforeinstallprompt` event in JavaScript, expose it to Dart via `dart:js_interop`, and show a Material banner in the app.

**Alternatives considered**:
- **`pwa_install` package**: Wraps this logic but adds a dependency for ~30 lines of code we can write ourselves.

**Rationale**: The interop is minimal and well-documented. Keeping it in-house avoids a dependency on a package with uncertain maintenance.

### 4. Icon generation with `flutter_launcher_icons`

**Choice**: Use the already-configured `flutter_launcher_icons` package to generate all required PWA icon sizes from a single source image.

**Rationale**: The package is already a dev dependency. We just need to update its configuration to output additional sizes (72, 96, 128, 144, 152, 384) and ensure maskable variants are included.

### 5. Theme colors aligned with Material 3 orange seed

**Choice**: Set manifest `theme_color` and `background_color` to match the app's Material 3 `ColorScheme.fromSeed()` orange-based palette.

**Rationale**: Consistent branding between the installed app chrome and the in-app theme.

## Risks / Trade-offs

- **[Risk] Custom service worker may conflict with Flutter upgrades** → Mitigation: Keep customizations minimal and isolated. The custom logic only handles fetch events for non-app-shell resources; Flutter's generated code handles its own assets.
- **[Risk] CDN-loaded MapLibre JS may not be cached correctly** → Mitigation: Add MapLibre CDN URL to the service worker's runtime cache with a stale-while-revalidate strategy.
- **[Risk] Offline fallback may confuse users who expect full app** → Mitigation: The fallback page clearly explains the situation and provides a retry button. It does not attempt to render the app.
- **[Trade-off] No offline data access** → Accepted for this iteration. The offline fallback is honest about requiring connectivity for data. Full offline support is a separate future initiative.
