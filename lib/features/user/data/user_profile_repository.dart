import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/domain/user_profile.dart';
import 'package:touringbuddy_frontend/supabase.dart';

const _table = 'user_profile';

class UserProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfileData?> getUserById(String userId) async {
    final data = await _client
        .from(_table)
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;

    return UserProfileData.fromMap(data);
  }

  /// Update the current user with new values.
  /// Throws [Exception] if the current user is not authenticated or trying to update a different user.
  /// Throws [PostgresException] if there is an issue updating the user in the database.
  Future<void> updateMyUser(UserProfileData updatedUser) async {
    User myUser = getCurrentUser();

    final userId = myUser.id;
    if (userId != updatedUser.id) {
      logger.e(
        'Current user $userId is not allowed to perform updates for user ${updatedUser.id}',
      );
      throw Exception('Current user is not allowed to perform update');
    }

    await _client.from(_table).update(updatedUser.toMap()).eq('id', userId);
  }

  Future<void> upsertMyUser(UserProfileData updatedUser) async {
    User myUser = getCurrentUser();

    final userId = myUser.id;
    if (userId != updatedUser.id) {
      logger.e(
        'Current user $userId is not allowed to perform updates for user ${updatedUser.id}',
      );
      throw Exception('Current user is not allowed to perform update');
    }
    await _client.from(_table).upsert(updatedUser.toMap());
  }
}
