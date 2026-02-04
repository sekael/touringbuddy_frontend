import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _controllerCompleter = Completer<MapLibreMapController>();
  bool _styleLoaded = false;

  static const _initial = CameraPosition(target: LatLng(46.8, 8.2), zoom: 8);

  Future<void> _goHome() async {
    final c = await _controllerCompleter.future;
    await c.animateCamera(CameraUpdate.newCameraPosition(_initial));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      floatingActionButton: _styleLoaded
          ? FloatingActionButton(
              onPressed: _goHome,
              child: const Icon(Icons.explore),
            )
          : null,
      body: MapLibreMap(
        styleString:
            "https://vectortiles.geo.admin.ch/styles/ch.swisstopo.basemap.vt/style.json",
        initialCameraPosition: _initial,
        onMapCreated: (c) => _controllerCompleter.complete(c),
        onStyleLoadedCallback: () => setState(() => _styleLoaded = true),
      ),
    );
  }
}
