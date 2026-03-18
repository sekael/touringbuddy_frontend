import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/components/text/body.dart';
import 'package:touringbuddy_frontend/components/text/button.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/map/presentation/location_picker.dart';
import 'package:touringbuddy_frontend/features/map/presentation/map_action_overlay.dart';
import 'package:touringbuddy_frontend/features/map/presentation/touringbuddy_map.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showFeedbackOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(
            touringBuddySpacings.lg,
          ), // Using your theme spacings
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchGithubIssue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 4,
                  ),
                  child: ButtonText(
                    buttonText: 'Open Issue on GitHub',
                    styleOverride: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: touringBuddySpacings.md),
              CenterAlignedBodyText(
                bodyText:
                    "If you don't have a GitHub account, you can always reach out to us at feedback@tourenbuddy.ch",
              ),
              SizedBox(height: touringBuddySpacings.lg),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchGithubIssue() async {
    final Uri url = Uri.parse(
      'https://github.com/sekael/touringbuddy_frontend/issues/new?template=beta_feedback.yml',
    );

    logger.i('Launching Github issue URL: $url');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        rootMessengerKey.currentState?.showSnackBar(
          ErrorSnackbar(message: 'Could not open Github issues page').build(),
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
                onPressed: () => _showFeedbackOptions(context),
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
