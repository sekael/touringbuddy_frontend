{{flutter_js}}
{{flutter_build_config}}

// Register our custom service worker (sw.js) which wraps Flutter's generated
// service worker and adds PWA-specific caching strategies.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker
      .register('sw.js')
      .catch(function (err) {
        console.warn('TouringBuddy: Service worker registration failed:', err);
      });
  });
}

// Load Flutter without its own service worker registration.
// Our sw.js handles app shell caching via importScripts('flutter_service_worker.js').
_flutter.loader.load();
