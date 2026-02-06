import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  int _currentIndex = 0;
  bool _isSwitching = false;
  final bool _isPickingMode = true;

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

  Future<void> _applyStyle(int index) async {
    if (_controller == null) return;
    setState(() => _isSwitching = true);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Stack(
        children: [
          MouseRegion(
            cursor: _isPickingMode
                ? SystemMouseCursors.precise
                : SystemMouseCursors.basic,
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
          Positioned(
            bottom: 16,
            right: 16,
            child: SafeArea(
              child: _LayerPickerFab(
                styles: _styles,
                selectedIndex: _currentIndex,
                isSwitching: _isSwitching,
                onSelected: (index) async {
                  if (index == _currentIndex) return;
                  _currentIndex = index;
                  await _applyStyle(index);
                  if (mounted) setState(() {});
                },
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

class _LayerPickerFab extends StatelessWidget {
  final List<StyleEntry> styles;
  final int selectedIndex;
  final bool isSwitching;
  final ValueChanged<int> onSelected;

  const _LayerPickerFab({
    required this.styles,
    required this.selectedIndex,
    required this.isSwitching,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      enabled: !isSwitching,
      tooltip: 'Map layers',
      position: PopupMenuPosition.over,
      onSelected: onSelected,
      itemBuilder: (context) {
        return List.generate(styles.length, (i) {
          final entry = styles[i];
          final isSelected = i == selectedIndex;

          return PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: theme.colorScheme.primary,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        });
      },
      child: Material(
        elevation: 6,
        shape: const CircleBorder(),
        color: theme.colorScheme.surface,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isSwitching
              ? null
              : null, // PopupMenuButton handles taps via child
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: isSwitching
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.layers_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
