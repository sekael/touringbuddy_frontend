import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

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
}
