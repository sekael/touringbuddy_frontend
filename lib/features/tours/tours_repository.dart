import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/core/exceptions/unauthorized_user_exception.dart';
import 'package:touringbuddy_frontend/models/tour.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class ToursRepository {
  final String _table = 'tours';
  final String _viewTable = 'tours_view';
  final SupabaseClient _client = Supabase.instance.client;

  void _validateUserAuthorization(String userId) {
    final loggedInUserId = getCurrentUser().id;
    if (loggedInUserId != userId) {
      throw UnauthorizedUserException(
        'User $userId is not authorized to perform this action',
      );
    }
  }

  Future<String> insertNewTour(Tour tour) async {
    final response = await _client.from(_table).insert(tour).select('id');
    return response.first['id'];
  }

  Future<List<Tour>> listToursForUser(String userId) async {
    _validateUserAuthorization(userId);

    final rows = await _client
        .from(_viewTable)
        .select('id, user_id, planned_date, name, lon, lat')
        .eq('user_id', userId)
        .order('name');

    return (rows as List)
        .map((e) => Tour.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
