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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/core/pwa/pwa_install_banner.dart';
import 'package:touringbuddy_frontend/core/pwa/pwa_install_service.dart';
import 'package:touringbuddy_frontend/features/map/data/swisstopo_styles.dart';
import 'package:touringbuddy_frontend/pages/auth_gate.dart';
import 'package:touringbuddy_frontend/providers/contacts_service.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';
import 'package:touringbuddy_frontend/supabase.dart';

// TODO: make it all look nice and consistent
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  await SwisstopoStyles.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PwaInstallService()),
        ChangeNotifierProvider(create: (_) => UserService()..init()),
        ChangeNotifierProxyProvider<UserService, ContactsService>(
          create: (_) => ContactsService(),
          update: (context, userService, contactsService) {
            if (userService.isLoggedIn) {
              contactsService!.loadContacts();
            } else {
              contactsService!.clear();
            }
            return contactsService;
          },
        ),
        ChangeNotifierProxyProvider<UserService, ToursService>(
          create: (_) => ToursService(),
          update: (context, userService, toursService) {
            if (userService.isLoggedIn) {
              toursService!.getToursForCurrentUser();
            } else {
              toursService!.clear();
            }
            return toursService;
          },
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TourenBuddy',
      theme: tourenBuddyTheme,
      scaffoldMessengerKey: rootMessengerKey,
      navigatorKey: rootNavigatorKey,
      home: const PwaInstallBanner(child: AuthGate()),
    );
  }
}
