import 'package:flutter/services.dart';
import 'package:touringbuddy_frontend/features/map/domain/base_map_style.dart';

class SwisstopoStyles {
  static const String base =
      'https://vectortiles.geo.admin.ch/styles/ch.swisstopo.basemap.vt/style.json';
  static String _fullColorJson = '';
  static String get fullColor => _fullColorJson;

  static final List<BaseMapStyle> all = [
    const BaseMapStyle('Base', base),
    BaseMapStyle('Full Color', _fullColorJson),
  ];

  static Future<void> initialize() async {
    _fullColorJson = await rootBundle.loadString(
      'assets/swisstopo_wmts_style.json',
    );
  }
}
