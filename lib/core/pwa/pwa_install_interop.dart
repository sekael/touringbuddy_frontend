// Copyright (C) 2026 Selim Kaelin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:js_interop';

/// Returns `true` if a deferred PWA install prompt is currently available.
///
/// The prompt is captured in `index.html` via the `beforeinstallprompt` event
/// and stored at `window._pwaInstallPrompt`.
bool get canInstallPwa => _deferredPrompt.isDefinedAndNotNull;

/// Triggers the browser's native PWA install dialog.
///
/// Calls `prompt()` on the captured `BeforeInstallPromptEvent`. Does nothing
/// if no prompt is available. Clears the stored reference after calling.
void triggerPwaInstallPrompt() {
  if (!canInstallPwa) return;
  (_deferredPrompt! as _BeforeInstallPromptEvent).prompt();
  _deferredPrompt = null;
}

// ---------------------------------------------------------------------------
// JS interop
// ---------------------------------------------------------------------------

@JS('window._pwaInstallPrompt')
external JSAny? get _deferredPrompt;

@JS('window._pwaInstallPrompt')
external set _deferredPrompt(JSAny? value);

/// Minimal JS interop type for `BeforeInstallPromptEvent`.
extension type _BeforeInstallPromptEvent(JSObject _) implements JSObject {
  external void prompt();
}
