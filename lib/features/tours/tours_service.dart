import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/features/tours/tours_details_sheet.dart';
import 'package:touringbuddy_frontend/features/tours/tours_domain.dart';
import 'package:touringbuddy_frontend/features/tours/tours_repository.dart';
import 'package:touringbuddy_frontend/supabase.dart';
import 'package:uuid/uuid.dart';

class ToursService {
  Uuid uuid = Uuid();
  ToursRepository repository = ToursRepository();

  Future<String> newTourFromLocation(LatLng location) {
    String userId = getCurrentUser().id;
    String id = uuid.v4();

    Tour newTour = Tour(id: id, userId: userId, goal: location);
    return repository.insertNewTour(newTour);
  }

  Future<String> newTourFromDraft(TourDraft draft, LatLng location) {
    String userId = getCurrentUser().id;
    String id = uuid.v4();
    Tour newTour = Tour(
      id: id,
      userId: userId,
      goal: location,
      plannedDate: draft.plannedDate,
      name: draft.name,
    );
    return repository.insertNewTour(newTour);
  }
}
