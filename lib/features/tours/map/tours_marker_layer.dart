import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/features/tours/domain/tour.dart';

class ToursMarkerLayer {
  MapLibreMapController? _controller;

  static const double _defaultRadius = 8.0;
  static const double _selectedRadius = 16.0;
  static final String _circleColor = Colors.red.toHexStringRGB();

  void attach(MapLibreMapController controller) {
    _controller = controller;
  }

  void detach() {
    _controller = null;
  }

  Future<void> setTours(List<Tour> tours, {String? selectedTourId}) async {
    final c = _controller;
    if (c == null || c.circleManager == null) return;

    c.clearCircles();

    final optionsList = tours.map((t) {
      final isSelected = t.id == selectedTourId;
      return CircleOptions(
        geometry: t.goal,
        circleRadius: isSelected ? _selectedRadius : _defaultRadius,
        circleColor: _circleColor,
        circleOpacity: 0.8,
        circleStrokeWidth: isSelected ? 2.0 : 0.0,
        circleStrokeColor: '#FFFFFF',
      );
    }).toList();

    // 3. Map metadata to the annotations
    final dataList = tours.map((t) => {'tourId': t.id}).toList();

    // 4. Batch add to map
    if (optionsList.isNotEmpty) {
      await c.addCircles(optionsList, dataList);
    }
  }

  Future<void> clear() => setTours(const []);
}
