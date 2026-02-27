import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/core/exceptions/unauthorized_user_exception.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class ToursRepository {
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

  Future<String> insertNewTour(Tour tour, List<String> partnerIds) async {
    return await _client.rpc(
      'create_tour_with_partners',
      params: {
        'p_id': tour.id,
        'p_planned_date': tour.plannedDate?.toIso8601String(),
        'p_name': tour.name,
        'p_goal':
            'SRID=4326;POINT(${tour.goal.longitude} ${tour.goal.latitude})',
        'p_partner_ids': partnerIds,
      },
    );
  }

  Future<List<Tour>> listToursForUser(String userId) async {
    _validateUserAuthorization(userId);

    final rows = await _client
        .from(_viewTable)
        .select('id, user_id, planned_date, name, lon, lat, partner_ids')
        .eq('user_id', userId)
        .order('name');

    return (rows as List)
        .map((e) => Tour.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
