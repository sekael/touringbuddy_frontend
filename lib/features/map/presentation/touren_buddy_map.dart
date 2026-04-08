import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/map/data/swisstopo_styles.dart';
import 'package:touringbuddy_frontend/features/tours/map/tours_marker_layer.dart';
import 'package:touringbuddy_frontend/features/tours/presentation/tour_info_sheet.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';

class TourenBuddyMap extends StatefulWidget {
  const TourenBuddyMap({super.key});

  @override
  State<TourenBuddyMap> createState() => _TourenBuddyMapState();
}

class _TourenBuddyMapState extends State<TourenBuddyMap> {
  late final ToursMarkerLayer _toursLayer;
  MapViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _toursLayer = ToursMarkerLayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache reference to MapViewModel for cleanup later
    _viewModel = context.read<MapViewModel>();
  }

  @override
  void dispose() {
    _viewModel?.detachController();
    _toursLayer.detach();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _viewModel?.attachController(controller);
    _toursLayer.attach(controller);
    controller.onCircleTapped.add(_onCircleTapped);
  }

  void _onCircleTapped(Circle circle) {
    final String? tourId = circle.data?['tourId'];
    if (tourId == null) return;

    final toursService = context.read<ToursService>();
    final tour = toursService.tours.firstWhere((t) => t.id == tourId);

    final viewModel = context.read<MapViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;
    viewModel.markTourSelected(tour);

    logger.i('Selected tour: ${tour.toGeoJsonFeature()}');
    final sheetKey = GlobalKey();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final box = sheetKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          viewModel.selectTour(
            tour,
            14.0,
            screenHeight: screenHeight,
            bottomSheetHeight: box.size.height,
          );
        });
        return Container(
          key: sheetKey,
          decoration: BoxDecoration(
            color: tourenBuddyTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: TourInfoSheet(tour: tour),
        );
      },
    ).then((_) {
      viewModel.resetCameraView();
    });
  }

  Future<void> onStyleLoaded() async {
    // Refresh data from service
    if (!mounted) return;
    final tours = context.read<ToursService>().tours;
    await _toursLayer.setTours(tours);
  }

  Future<void> _updateCircleLayer() async {
    if (!mounted) return;
    final tours = context.read<ToursService>().tours;
    final selectedId = context.read<MapViewModel>().selectedTourId;
    await _toursLayer.setTours(tours, selectedTourId: selectedId);
  }

  @override
  Widget build(BuildContext context) {
    final currentStyleIndex = context.select<MapViewModel, int>(
      (vm) => vm.currentStyleIndex,
    );

    // Reactively update tours
    context.watch<ToursService>();
    context.watch<MapViewModel>().selectedTourId;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCircleLayer());

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: MapLibreMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(46.8, 8.2),
          zoom: 8,
        ),
        styleString: SwisstopoStyles.all[currentStyleIndex].styleString,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: () async {
          await onStyleLoaded();
        },
        trackCameraPosition: true,
        attributionButtonPosition: AttributionButtonPosition.topRight,
      ),
    );
  }
}
