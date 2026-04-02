## 1. Manifest & Meta Tags

- [x] 1.1 Update `web/manifest.json` with complete app identity: name, short_name, description, start_url, scope, display, theme_color (orange), background_color, orientation, categories, and full icon references for all sizes
- [x] 1.2 Update `web/index.html` meta tags: add `<meta name="description">`, `<meta name="theme-color">`, update apple-mobile-web-app meta tags (status-bar-style to black-translucent, title to TouringBuddy), and add Open Graph tags (og:title, og:description, og:type, og:image)

## 2. Icons & Assets

- [x] 2.1 Update `flutter_launcher_icons` configuration in `pubspec.yaml` to generate all required PWA icon sizes (72, 96, 128, 144, 152, 192, 384, 512) with maskable variants
- [x] 2.2 Run `flutter_launcher_icons` to generate the full icon set and verify all sizes exist in `web/icons/`
- [x] 2.3 Update `manifest.json` icons array to reference all generated icon sizes with correct src, sizes, type, and purpose fields

## 3. Service Worker

- [x] 3.1 Create `web/offline.html` — a lightweight static page with inline CSS showing an offline message and retry button
- [x] 3.2 Create custom service worker at `web/sw.js` implementing: cache-first for app shell, network-first for Supabase API requests, stale-while-revalidate for CDN resources (MapLibre), offline fallback for failed navigation requests, and lifecycle management (skipWaiting, cache cleanup)
- [x] 3.3 Create `web/flutter_bootstrap.js` to register the custom service worker instead of relying solely on Flutter's default, ensuring it wraps/extends Flutter's generated service worker logic

## 4. Install Prompt

- [x] 4.1 Create a JS interop utility in `lib/core/` that captures the `beforeinstallprompt` event via `dart:js_interop` and exposes `canInstall` / `promptInstall()` to Dart
- [x] 4.2 Create PwaInstallService (ChangeNotifier) for PWA install state (canInstall, isDismissed) in `lib/features/pwa/presentation/providers/`
- [x] 4.3 Create an install banner widget (`PwaInstallBanner`) using `MaterialBanner` that shows when install is available, with "Install" and "Dismiss" actions, guarded by `kIsWeb`
- [x] 4.4 Integrate the install banner into the app shell (e.g., below the app bar or as a persistent banner on the home screen)

## 5. Verification

- [x] 5.1 Run `flutter analyze` and `dart format .` — fix any issues
- [x] 5.2 Run `flutter test` — ensure no regressions
- [x] 5.3 Build with `flutter build web` and verify the built output includes the custom service worker, offline.html, all icon sizes, and updated manifest
