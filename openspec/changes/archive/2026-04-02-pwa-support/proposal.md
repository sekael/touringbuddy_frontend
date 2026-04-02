## Why

TouringBuddy targets outdoor enthusiasts who often plan tours in areas with poor connectivity. The app currently has only Flutter's default PWA scaffolding — generic manifest metadata, placeholder icons, and no offline-aware logic. Users cannot install the app with a proper branded experience, and the app shell provides no meaningful offline fallback. Enhancing PWA support makes the app installable with a polished identity and lays the groundwork for offline resilience.

## What Changes

- **Manifest overhaul**: Update `web/manifest.json` with proper app name, description, theme colors matching the orange Material 3 seed, correct scope, and additional icon sizes for broader device coverage.
- **Custom service worker strategy**: Replace Flutter's default service worker with a custom configuration that uses a cache-first strategy for app shell assets and a network-first strategy for API calls, with an offline fallback page.
- **Branded icons & splash**: Generate a full set of PWA icons (including iOS splash screens and all recommended sizes) from the app's branding, replacing the default Flutter placeholder icons.
- **Offline fallback page**: Add a lightweight offline fallback HTML page shown when the user has no connectivity and no cached content is available.
- **Install prompt UX**: Add an in-app install banner/prompt that surfaces the browser's `beforeinstallprompt` event, giving users a discoverable way to install the app.
- **Meta tags & SEO**: Enhance `web/index.html` with complete PWA meta tags (theme-color, description, Open Graph basics) for better discoverability and install experience.

## Capabilities

### New Capabilities
- `pwa-manifest-and-assets`: Covers the web manifest configuration, icon generation, splash screens, and all static PWA assets needed for installability and branding.
- `pwa-service-worker`: Covers the custom service worker caching strategies, offline fallback page, and cache lifecycle management.
- `pwa-install-prompt`: Covers the in-app install prompt UX that intercepts the browser's beforeinstallprompt event and presents a branded install banner.

### Modified Capabilities
_(none — no existing specs to modify)_

## Impact

- **Files modified**: `web/index.html`, `web/manifest.json`
- **Files added**: Offline fallback HTML, install prompt widget/JS interop, new icon assets
- **Dependencies**: Potentially `pwa_install` or custom JS interop for install prompt; no heavy new packages
- **CI/CD**: No pipeline changes needed — Flutter web build picks up `web/` assets automatically
- **Deployment**: Cloudflare Pages serves static assets with proper caching headers by default
- **Breaking changes**: None — purely additive
