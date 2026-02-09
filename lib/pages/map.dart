import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/components/crosshair.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map_layers.dart';
import 'package:touringbuddy_frontend/features/tours/tours_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  int _currentIndex = 0;
  bool _isSwitchingLayer = false;
  bool _isPickingLocation = false;

  // Middle of alpine Switzerland
  static const _initial = CameraPosition(target: LatLng(46.8, 8.2), zoom: 8);
  CameraPosition? _lastCamera;

  static const String _swissTopoBaseStyle =
      'https://vectortiles.geo.admin.ch/styles/ch.swisstopo.basemap.vt/style.json';
  static const String _swissTopoFullStyle = 'assets/swisstopo_wmts_style.json';

  late final List<StyleEntry> _styles = [
    const StyleEntry('Swisstopo Base', _swissTopoBaseStyle),
    const StyleEntry('Swisstopo Full Color', _swissTopoFullStyle),
  ];

  void _onMapCreated(MapLibreMapController c) {
    _controller = c;
    c.addListener(() {
      if (!c.isCameraMoving) return;
      _lastCamera = c.cameraPosition;
    });
  }

  Future<void> _onStyleLoaded() async {
    if (_lastCamera != null && _controller != null) {
      await _controller!.moveCamera(
        CameraUpdate.newCameraPosition(_lastCamera!),
      );
    }
    if (mounted) {
      setState(() {
        _isSwitchingLayer = false;
      });
    }
  }

  void _onCameraIdle() {
    if (_controller == null) return;
    _lastCamera ??= _initial;
  }

  Future<void> _applyStyle(int index) async {
    if (_controller == null) return;
    setState(() => _isSwitchingLayer = true);

    final entry = _styles[index];
    logger.i('Switching to style ${entry.label}');

    try {
      await _controller!.setStyle(entry.styleString);
    } catch (e, st) {
      logger.e('Failed to set style ${entry.label}', (e, st));
      await _controller!.setStyle(_swissTopoBaseStyle);
      _currentIndex = 0;
    }
  }

  void _confirmGoal() async {
    if (_controller == null) return;

    // This gets exactly where the crosshair is pointing
    final LatLng point = _controller!.cameraPosition!.target;

    // Logic to save goal or open a details form goes here
    String tourId = await ToursService().newTourFromLocation(point);
    logger.i(
      'Added new tour $tourId with coordinates: ${point.latitude}, ${point.longitude}',
    );

    setState(() => _isPickingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Touring Buddy')),
      body: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: MapLibreMap(
              styleString: _styles[_currentIndex].styleString,
              trackCameraPosition: true,
              initialCameraPosition: _initial,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              onCameraIdle: _onCameraIdle,
              attributionButtonPosition: AttributionButtonPosition.topRight,
            ),
          ),
          if (_isPickingLocation)
            IgnorePointer(
              child: Center(
                child: CustomPaint(
                  size: const Size(100, 100),
                  painter: CrosshairPainter(Colors.redAccent),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!_isPickingLocation) ...[
                    LayerPickerFab(
                      styles: _styles,
                      selectedIndex: _currentIndex,
                      isSwitching: _isSwitchingLayer,
                      onSelected: (index) async {
                        if (index == _currentIndex) return;
                        _currentIndex = index;
                        await _applyStyle(index);
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      backgroundColor: theme.colorScheme.surface,
                      shape: CircleBorder(),
                      onPressed: () =>
                          setState(() => _isPickingLocation = true),
                      child: const Icon(Icons.add_location),
                    ),
                  ] else ...[
                    // Goal Mode Buttons
                    SizedBox(
                      width: 150,
                      child: FloatingActionButton.extended(
                        heroTag: 'confirmGoal',
                        onPressed: _confirmGoal,
                        label: const Text('Continue'),
                        icon: const Icon(Icons.check),
                        backgroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 150,
                      child: FloatingActionButton.extended(
                        heroTag: 'cancelGoal',
                        onPressed: () =>
                            setState(() => _isPickingLocation = false),
                        label: const Text('Cancel'),
                        icon: const Icon(Icons.close),
                        backgroundColor: theme.colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
