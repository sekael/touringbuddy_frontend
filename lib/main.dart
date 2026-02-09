import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/features/user/user_profile_repository.dart';
import 'package:touringbuddy_frontend/features/user/user_service.dart';
import 'package:touringbuddy_frontend/pages/map.dart';
import 'package:touringbuddy_frontend/supabase.dart';

// Require user to sign in to add tours

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeSupabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              UserService(userProfileRepository: UserProfileRepository())
                ..init(),
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: MapPage(),
    );
  }
}
