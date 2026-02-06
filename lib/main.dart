import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/map.dart';
import 'package:touringbuddy_frontend/supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeSupabase();
  runApp(const MainApp());
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
