import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/pages/auth_gate.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';
import 'package:touringbuddy_frontend/supabase.dart';

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
        ChangeNotifierProvider(create: (_) => ToursService()),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      scaffoldMessengerKey: rootMessengerKey,
      navigatorKey: rootNavigatorKey,
      home: AuthGate(),
    );
  }
}
