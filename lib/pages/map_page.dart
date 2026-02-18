import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/map/presentation/location_picker.dart';
import 'package:touringbuddy_frontend/features/map/presentation/map_action_overlay.dart';
import 'package:touringbuddy_frontend/features/map/presentation/touringbuddy_map.dart';
import 'package:touringbuddy_frontend/features/tours/map/tours_symbol_layer.dart';

// TODO: make goals clickable
// TODO: attach contacts to goals
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final ToursSymbolLayer _toursSymbolLayer;

  @override
  void initState() {
    super.initState();
    _toursSymbolLayer = ToursSymbolLayer();
  }

  @override
  void dispose() {
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
