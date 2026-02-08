import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/tours/tours_domain.dart';
import 'package:touringbuddy_frontend/features/tours/tours_repository.dart';
import 'package:uuid/uuid.dart';

class ToursService {
  Uuid uuid = Uuid();
  ToursRepository repository = ToursRepository();

  Future<String> newTourFromLocation(LatLng location) {
    String? userId = Supabase.instance.client.auth.();
    if (userId == null) {
      logger.e('User is not logged in.');
      throw Exception('No user is currently logged in');
    }

    String id = uuid.v4();
    Tour newTour = Tour(id: id, userId: userId, goal: location);
    return repository.insertNewTour(newTour);
  }
}
