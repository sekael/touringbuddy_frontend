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

import 'package:flutter/foundation.dart';
import 'package:touringbuddy_frontend/core/pwa/pwa_install_interop.dart'
    if (dart.library.io) 'package:touringbuddy_frontend/core/pwa/pwa_install_interop_stub.dart';

/// Manages PWA install prompt state.
///
/// On construction, polls `window._pwaInstallPrompt` (set by `index.html` when
/// the browser fires `beforeinstallprompt`) and exposes the current install
/// availability to the widget tree via [ChangeNotifier].
class PwaInstallService extends ChangeNotifier {
  PwaInstallService() {
    if (kIsWeb && canInstallPwa) {
      _canInstall = true;
    }
  }

  bool _canInstall = false;
  bool _isDismissed = false;

  /// Whether the install banner should be shown.
  bool get shouldShowBanner => _canInstall && !_isDismissed;

  /// Triggers the browser install dialog and hides the banner.
  void install() {
    if (!_canInstall) return;
    triggerPwaInstallPrompt();
    _canInstall = false;
    notifyListeners();
  }

  /// Hides the install banner for the remainder of the session.
  void dismiss() {
    _isDismissed = true;
    notifyListeners();
  }
}
