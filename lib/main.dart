import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/pages/auth_gate.dart';
import 'package:touringbuddy_frontend/providers/contacts_service.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';
import 'package:touringbuddy_frontend/supabase.dart';

// TODO: make it all look nice and consistent
// TODO: add different colors for different types of tours
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  runApp(
    MultiProvider(
      providers: [
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
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touring Buddy',
      theme: touringBuddyTheme,
      scaffoldMessengerKey: rootMessengerKey,
      navigatorKey: rootNavigatorKey,
      home: const AuthGate(),
    );
  }
}
