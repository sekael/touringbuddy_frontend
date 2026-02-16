import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/crosshair.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/base_maps.dart';
import 'package:touringbuddy_frontend/features/tours/tours_details_sheet.dart';
import 'package:touringbuddy_frontend/features/tours/tours_symbol_layer.dart';
import 'package:touringbuddy_frontend/features/user/user_profile_sheet.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  late final ToursSymbolLayer _toursSymbolLayer;

  late ToursService _toursService;
  late UserService _userService;
  VoidCallback? _toursListener;
  VoidCallback? _userListener;

  int _currentIndex = 0;
  bool _isSwitchingLayer = false;
  bool _isPickingLocation = false;
  bool _disposed = false;
  int _authOperationToken =
      0; // Increments to invalidate in-flight async operations

  // Middle of alpine Switzerland
  static const _initial = CameraPosition(target: LatLng(46.8, 8.2), zoom: 8);
  static const String _swissTopoBaseStyle =
      'https://vectortiles.geo.admin.ch/styles/ch.swisstopo.basemap.vt/style.json';
  static const String _swissTopoFullStyle = 'assets/swisstopo_wmts_style.json';
  late final List<StyleEntry> _styles = [
    const StyleEntry('Swisstopo Base', _swissTopoBaseStyle),
    const StyleEntry('Swisstopo Full Color', _swissTopoFullStyle),
  ];

  @override
  void initState() {
    super.initState();
    _toursSymbolLayer = ToursSymbolLayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _toursService = context.read<ToursService>();
    _userService = context.read<UserService>();
    _removeListeners();

    _toursListener = () {
      if (_disposed) return;
      // Any change in ToursService updates symbols
      _toursSymbolLayer.setTours(_toursService.tours);
    };

    _userListener = () {
      _handleAuthChanged(_userService.isLoggedIn);
    };

    _toursService.addListener(_toursListener!);
    _userService.addListener(_userListener!);

    // Initial sync
    _handleAuthChanged(_userService.isLoggedIn);
  }

  Future<void> _handleAuthChanged(bool isLoggedIn) async {
    if (_disposed) return;

    final token = ++_authOperationToken; // invalidate previous auth ops

    if (isLoggedIn) {
      try {
        await _toursService.getToursForCurrentUser();
        if (_disposed || token != _authOperationToken) return;

        // Only touch layer if controller/style are ready-ish
        await _toursSymbolLayer.setTours(_toursService.tours);
      } catch (e) {
        logger.w('Error handling auth changes in map page: $e');
      }
    } else {
      // Clear app state synchronously
      _toursService.clear();

      // Best-effort clear layer (don’t await if it causes issues on dispose)
      try {
        await _toursSymbolLayer.clear();
      } catch (_) {}
    }
  }

  void _removeListeners() {
    final tl = _toursListener;
    if (tl != null) {
      _toursService.removeListener(tl);
      _toursListener = null;
    }

    final ul = _userListener;
    if (ul != null) {
      _userService.removeListener(ul);
      _userListener = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authOperationToken++;
    _removeListeners();

    _toursSymbolLayer.detach();
    _controller = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController c) {
    _controller = c;
    _toursSymbolLayer.attach(_controller!);
  }

  Future<void> _onStyleLoaded() async {
    // Recreate symbol layer after every style load
    await _toursSymbolLayer.onStyleLoaded();

    // Make sure current state is applied (if tours loaded already)
    if (!mounted) return;
    final toursService = context.read<ToursService>();
    await _toursSymbolLayer.setTours(toursService.tours);
    setState(() {
      _isSwitchingLayer = false;
    });
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

  Future<void> _confirmGoal() async {
    if (_controller == null) return;

    final LatLng point = _controller!.cameraPosition!.target;

    // Exit "picking" mode (so crosshair/buttons go away behind the sheet)
    setState(() => _isPickingLocation = false);

    final result = await showModalBottomSheet<TourDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TourDetailsSheet(goal: point),
    );

    // User dismissed / cancelled
    if (result == null) return;

    // Save tour with optional fields
    if (!mounted) return;
    final tourId = await context.read<ToursService>().newTourFromDraft(
      result,
      point,
    );

    logger.i(
      'Added new tour $tourId with coordinates: ${point.latitude}, ${point.longitude} '
      'name=${result.name} plannedDate=${result.plannedDate}',
    );

    if (!mounted) return;
    await context.read<ToursService>().getToursForCurrentUser();
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [const UserProfileSheet()],
          ),
        ),
      ),
    );
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                    ElevatedButton(
                      onPressed: () {
                        _showProfileSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        disabledBackgroundColor: theme.colorScheme.secondary,
                        disabledForegroundColor: theme.colorScheme.onSecondary,
                        padding: EdgeInsets.all(28.0),
                        shape: CircleBorder(),
                      ),
                      child: Icon(
                        context.watch<UserService>().isLoggedIn
                            ? Icons.person
                            : Icons.person_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tooltip(
                      message: context.read<UserService>().isLoggedIn
                          ? 'Pick a new location'
                          : 'You must be logged in to use the location picker',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          disabledBackgroundColor: theme.colorScheme.secondary,
                          disabledForegroundColor:
                              theme.colorScheme.onSecondary,
                          padding: EdgeInsets.all(28.0),
                          shape: CircleBorder(),
                        ),
                        onPressed: context.read<UserService>().isLoggedIn
                            ? () => setState(() => _isPickingLocation = true)
                            : null,
                        child: const Icon(Icons.add_location),
                      ),
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
