import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/features/tours/tours_domain.dart';

class ToursRepository {
  final String _table = 'tours';
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> insertNewTour(Tour tour) async {
    final response = await _client.from(_table).insert(tour).select('id');
    return response.first['id'];
  }
}
