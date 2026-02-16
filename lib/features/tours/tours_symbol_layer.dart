import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/models/tour.dart';

class ToursSymbolLayer {
  MapLibreMapController? _controller;
  static const _sourceId = 'symbol_source';
  static const _layerId = 'symbol_layer';
  static const _symbolName = 'custom_marker';
  static const _assetPath = 'assets/icons/location-icon.png';

  bool _imageAdded = false;
  bool _sourceAdded = false;
  bool _layerAdded = false;

  List<Tour> _cachedTours = const [];

  void attach(MapLibreMapController controller) {
    _controller = controller;
  }

  void detach() {
    _controller = null;
    _imageAdded = false;
    _sourceAdded = false;
    _layerAdded = false;
    _cachedTours = const [];
  }

  Future<void> setTours(List<Tour> tours) async {
    _cachedTours = tours;
    final c = _controller;
    if (c == null) return;
    final featureCollection = _featureCollectionJson(tours);
    c.setGeoJsonSource(_sourceId, featureCollection);
  }

  Future<void> clear() => setTours(const []);

  Future<void> onStyleLoaded() async {
    final c = _controller;
    if (c == null) return;

    _imageAdded = false;
    _sourceAdded = false;
    _layerAdded = false;

    await _ensureImageLoaded();
    await _ensureGeoJsonSourceAdded();
    await _ensureSymbolLayerAdded();

    await setTours(_cachedTours);
  }

  Future<void> _ensureImageLoaded() async {
    if (_imageAdded) return;
    final c = _controller;
    if (c == null) return;

    try {
      final bytes = await rootBundle.load(_assetPath);
      await c.addImage(_symbolName, bytes.buffer.asUint8List());
    } catch (e) {
      logger.w('Adding image to map controller failed: $e');
    } finally {
      _imageAdded = true;
    }
  }

  Future<void> _ensureGeoJsonSourceAdded() async {
    if (_sourceAdded) return;
    final c = _controller;
    if (c == null) return;

    final empty = const {'type': 'FeatureCollection', 'features': []};
    await c.addGeoJsonSource(_sourceId, empty);
    _sourceAdded = true;
  }

  Future<void> _ensureSymbolLayerAdded() async {
    if (_layerAdded) return;
    final c = _controller;
    if (c == null) return;

    try {
      // Add symbol layer
      await c.addSymbolLayer(
        _sourceId,
        _layerId,
        SymbolLayerProperties(
          // Icon properties
          iconImage: _symbolName,
          iconSize: 1.0,
          iconOffset: [0, 0],
          iconAllowOverlap: true,
          iconIgnorePlacement: false,
          // Text properties
          symbolPlacement: 'point',
          symbolSpacing: 250.0,
          symbolAvoidEdges: false,
        ),
      );
    } catch (e) {
      logger.e('Error adding symbol layer: $e');
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(message: 'Error adding symbol layer: $e').build(),
      );
    } finally {
      _layerAdded = true;
    }
  }

  Map<String, dynamic> _featureCollectionJson(List<Tour> tours) {
    final features = tours.map((t) => t.toGeoJsonFeature()).toList();
    return {'type': 'FeatureCollection', 'features': features};
  }
}
