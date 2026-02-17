import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view.dart';
import 'package:touringbuddy_frontend/features/map/presentation/location_picker.dart';
import 'package:touringbuddy_frontend/features/map/presentation/map_action_overlay.dart';
import 'package:touringbuddy_frontend/features/map/presentation/touringbuddy_map.dart';
import 'package:touringbuddy_frontend/features/tours/map/tours_symbol_layer.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';

// TODO: simplify MapPage -> handle listeners
// TODO: make goals clickable
// TODO: attach contacts to goals
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final ToursSymbolLayer _toursSymbolLayer;

  late ToursService _toursService;
  late UserService _userService;
  VoidCallback? _toursListener;
  VoidCallback? _userListener;

  bool _disposed = false;
  int _authOperationToken =
      0; // Increments to invalidate in-flight async operations

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Touring Buddy'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [TouringBuddyMap(), MapActionOverlay(), LocationPicker()],
        ),
      ),
    );
  }
}
