import 'package:touringbuddy_frontend/features/map/domain/base_map_style.dart';

class SwisstopoStyles {
  static const String base =
      'https://vectortiles.geo.admin.ch/styles/ch.swisstopo.basemap.vt/style.json';
  static const String fullColor = 'assets/swisstopo_wmts_style.json';

  static final List<BaseMapStyle> all = [
    const BaseMapStyle('Base', base),
    const BaseMapStyle('Full Color', fullColor),
  ];
}
