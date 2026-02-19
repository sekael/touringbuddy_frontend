import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';

class MapViewModel extends ChangeNotifier {
  MapLibreMapController? _mapController;
  MapLibreMapController? get mapController => _mapController;

  void attachController(MapLibreMapController controller) {
    _mapController = controller;
  }

  void detachController() {
    _mapController = null;
  }

  bool _isPickingLocation = false;
  bool get isPickingLocation => _isPickingLocation;

  void setPickingLocation(bool picking) {
    _isPickingLocation = picking;
    notifyListeners();
  }

  int _currentStyleIndex = 0;
  int get currentStyleIndex => _currentStyleIndex;

  void setStyleIndex(int index) {
    _currentStyleIndex = index;
    notifyListeners();
  }

  String? _selectedTourId;
  String? get selectedTourId => _selectedTourId;

  Future<void> selectTour(Tour? tour, double zoom) async {
    _selectedTourId = tour?.id;
    notifyListeners();

    if (_mapController == null || tour == null) return;

    if (kIsWeb) {
      // WEB WORKAROUND: Offset the LatLng manually
      // We calculate a latitude offset based on the current zoom.
      // 360 / 2^(zoom + 8) is a rough approximation for deg/pixel at the equator.
      final double latOffset = 250 * (360 / pow(2, zoom + 8));
      final LatLng offsetTarget = LatLng(
        tour.goal.latitude - latOffset,
        tour.goal.longitude,
      );

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(offsetTarget, zoom),
      );
    } else {
      // MOBILE: Use native Content Insets
      try {
        await _mapController!.updateContentInsets(
          const EdgeInsets.only(bottom: 300),
          true,
        );
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(tour.goal, zoom),
        );
      } catch (e) {
        // Fallback for unexpected platform errors
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(tour.goal, zoom),
        );
      }
    }
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(tour.goal, zoom),
    );
  }

  // Method to reset the camera view when the tour info sheet is closed
  Future<void> resetCameraView() async {
    if (_mapController == null) return;
    _selectedTourId = null;
    notifyListeners();

    if (!kIsWeb) {
      await _mapController!.updateContentInsets(EdgeInsets.zero, true);
    }
  }
}
