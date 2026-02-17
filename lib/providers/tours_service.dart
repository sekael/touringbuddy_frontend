import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/features/tours/data/tours_repository.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';
import 'package:touringbuddy_frontend/features/tours/presentation/tours_details_sheet.dart';
import 'package:touringbuddy_frontend/supabase.dart';
import 'package:uuid/uuid.dart';

class ToursService extends ChangeNotifier {
  Uuid uuid = Uuid();
  final ToursRepository _repository = ToursRepository();

  List<Tour> _tours = [];

  List<Tour> get tours {
    return List.unmodifiable(_tours);
  }

  Future<String> newTourFromLocation(LatLng location) {
    String userId = getCurrentUser().id;
    String id = uuid.v4();

    Tour newTour = Tour(id: id, userId: userId, goal: location);
    return _repository.insertNewTour(newTour);
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
    return _repository.insertNewTour(newTour);
  }

  Future<void> getToursForCurrentUser() async {
    final userId = getCurrentUser().id;
    final tours = await _repository.listToursForUser(userId);
    _tours = tours;
    notifyListeners();
  }

  void clear() {
    _tours = [];
    notifyListeners();
  }
}
