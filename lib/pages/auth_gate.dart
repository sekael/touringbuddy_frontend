import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/pages/home.dart';
import 'package:touringbuddy_frontend/pages/map.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (_, _) {
        final session = Supabase.instance.client.auth.currentSession;
        return session != null ? const MapPage() : const HomePage();
      },
    );
  }
}
