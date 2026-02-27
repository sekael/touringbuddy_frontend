import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/components/text/button.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/map/presentation/location_picker.dart';
import 'package:touringbuddy_frontend/features/map/presentation/map_action_overlay.dart';
import 'package:touringbuddy_frontend/features/map/presentation/touringbuddy_map.dart';
import 'package:touringbuddy_frontend/features/tours/map/tours_marker_layer.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final ToursMarkerLayer _toursSymbolLayer;

  final String _githubUsername = 'sekael';
  final String _repoName = 'touringbuddy_frontend';

  @override
  void initState() {
    super.initState();
    _toursSymbolLayer = ToursMarkerLayer();
  }

  @override
  void dispose() {
    _toursSymbolLayer.detach();
    super.dispose();
  }

  Future<void> _launchFeedbackUrl() async {
    final Uri url = Uri.parse(
      'https://github.com/sekael/touringbuddy_frontend/issues/new?template=beta_feedback.yml',
    );

    logger.i('Launching feedback URL: $url');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        rootMessengerKey.currentState?.showSnackBar(
          ErrorSnackbar(message: 'Could not open feedback page').build(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Touring Buddy'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: ElevatedButton(
                onPressed: _launchFeedbackUrl,
                style: ElevatedButton.styleFrom(
                  // You can customize colors here to make it stand out
                  elevation: 2,
                ),
                child: const ButtonText(buttonText: 'Feedback'), //
              ),
            ),
          ],
        ),
        body: Stack(
          children: [TouringBuddyMap(), MapActionOverlay(), LocationPicker()],
        ),
      ),
    );
  }
}
