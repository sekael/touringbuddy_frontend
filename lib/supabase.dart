import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/core/exceptions/unauthenticated_user_exception.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';

Future<void> initializeSupabase() async {
  await dotenv.load(fileName: 'config/supabase.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null) {
    throw Exception('Missing value for SUPABASE_URL');
  } else if (supabaseAnonKey == null) {
    throw Exception('Missing value for SUPABASE_ANON_KEY');
  }

  logger.i('Initializing Supabase client with URL = $supabaseUrl');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

User getCurrentUser() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw UnauthenticatedUserException();
  }
  return user;
}

Future<void> signOut() async {
  await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
}
