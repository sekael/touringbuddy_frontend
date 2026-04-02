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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/pwa/pwa_install_service.dart';

/// Displays a material banner prompting the user to install TouringBuddy as
/// a PWA. Only rendered on web when the browser signals install eligibility.
///
/// Wrap the app body with this widget to display the banner at the top of the
/// screen. The widget renders nothing on native platforms or when installation
/// is not available.
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({required this.child, super.key});

  /// The widget below the banner in the tree.
  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Consumer<PwaInstallService>(
      builder: (context, service, _) {
        return Column(
          children: [
            if (service.shouldShowBanner)
              MaterialBanner(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                content: const Text(
                  'Install TourenBuddy for quick access and a better experience.',
                ),
                leading: const Icon(Icons.download_rounded),
                actions: [
                  TextButton(
                    onPressed: service.install,
                    child: const Text('Install'),
                  ),
                  TextButton(
                    onPressed: service.dismiss,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
