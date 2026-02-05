import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  int _currentIndex = 0;
  bool _isSwitching = false;

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
        _isSwitching = false;
      });
    }
  }

  void _onCameraIdle() {
    if (_controller == null) return;
    _lastCamera ??= _initial;
  }

  Future<void> _cycleStyle() async {
    if (_isSwitching) return;

    _currentIndex = (_currentIndex + 1) % _styles.length;
    await _applyStyle(_currentIndex);
    setState(() {});
  }

  Future<void> _applyStyle(int index) async {
    if (_controller == null) return;
    setState(() => _isSwitching = true);

    final entry = _styles[index];
    log('Switching to style ${entry.label}');

    try {
      await _controller!.setStyle(entry.styleString);
    } catch (e, st) {
      log('Failed to set style ${entry.label}: $e', stackTrace: st);
      await _controller!.setStyle(_swissTopoBaseStyle);
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _styles[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _swissTopoBaseStyle,
            trackCameraPosition: true,
            initialCameraPosition: _initial,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            onCameraIdle: _onCameraIdle,
            attributionButtonPosition: AttributionButtonPosition.topRight,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Current style: ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              children: [
                                TextSpan(
                                  text: current.label,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isSwitching)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Switching...'),
                              ],
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: _cycleStyle,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Change'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StyleEntry {
  final String label;
  final String styleString;
  const StyleEntry(this.label, this.styleString);
}
