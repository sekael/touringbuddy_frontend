import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/crosshair.dart';
import 'package:touringbuddy_frontend/components/text/button.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/tours/presentation/tour_creation_sheet.dart';
import 'package:touringbuddy_frontend/providers/tours_service.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    if (!viewModel.isPickingLocation) return const SizedBox.shrink();

    return Stack(
      children: [
        // The Crosshair
        IgnorePointer(
          child: Center(
            child: CustomPaint(
              size: const Size(80, 80),
              painter: CrosshairPainter(Colors.redAccent),
            ),
          ),
        ),
        // The Confirmation Buttons
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                heroTag: 'cancelGoal',
                onPressed: () => viewModel.setPickingLocation(false),
                label: const ButtonText(buttonText: 'Cancel'),
                icon: const Icon(Icons.close),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 16),
              FloatingActionButton.extended(
                heroTag: 'confirmGoal',
                onPressed: () => _handleConfirm(context),
                label: const ButtonText(buttonText: 'Continue'),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    final viewModel = context.read<MapViewModel>();
    final controller = viewModel.mapController;
    if (controller == null) return;

    final LatLng point = controller.cameraPosition!.target;

    viewModel.setPickingLocation(false);

    final result = await showModalBottomSheet<TourDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TourCreationSheet(goal: point),
    );

    if (result != null && context.mounted) {
      final tourId = await context.read<ToursService>().newTourFromDraft(
        result,
        point,
      );
      logger.i(
        'Added new tour $tourId with coordinates: ${point.latitude}, ${point.longitude} '
        'name=${result.name} plannedDate=${result.plannedDate}',
      );
    }
  }
}
