import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view.dart';
import 'package:touringbuddy_frontend/features/map/data/swisstopo_styles.dart';
import 'package:touringbuddy_frontend/features/tours/map/tours_symbol_layer.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';

class TouringBuddyMap extends StatefulWidget {
  const TouringBuddyMap({super.key});

  @override
  State<TouringBuddyMap> createState() => _TouringBuddyMapState();
}

class _TouringBuddyMapState extends State<TouringBuddyMap> {
  late final ToursSymbolLayer _toursLayer;

  @override
  void initState() {
    super.initState();
    _toursLayer = ToursSymbolLayer();
  }

  @override
  void dispose() {
    context.read<MapViewModel>().detachController();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    context.read<MapViewModel>().attachController(controller);
    _toursLayer.attach(controller);
  }

  Future<void> _onStyleLoaded() async {
    await _toursLayer.onStyleLoaded();

    // Refresh data from service
    if (!mounted) return;
    final tours = context.read<ToursService>().tours;
    await _toursLayer.setTours(tours);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: MapLibreMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(46.8, 8.2),
          zoom: 8,
        ),
        styleString:
            SwisstopoStyles.all[viewModel.currentStyleIndex].styleString,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoaded,
        trackCameraPosition: true,
        attributionButtonPosition: AttributionButtonPosition.topRight,
      ),
    );
  }
}
