import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touringbuddy_frontend/components/round_action_button.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/features/contacts/presentation/contact_creation_sheet.dart';
import 'package:touringbuddy_frontend/features/map/data/map_view_model.dart';
import 'package:touringbuddy_frontend/features/map/data/swisstopo_styles.dart';
import 'package:touringbuddy_frontend/features/map/presentation/base_map_picker.dart';
import 'package:touringbuddy_frontend/features/user/presentation/user_profile_sheet.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';

class MapActionOverlay extends StatelessWidget {
  const MapActionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    final userService = context.watch<UserService>();

    // If we are in "Picking" mode, we hide the standard UI
    // to focus on the crosshair/confirm buttons.
    if (viewModel.isPickingLocation) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      right: 16,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BaseMapPicker(
              styles: SwisstopoStyles.all,
              selectedIndex: viewModel.currentStyleIndex,
              onSelected: (index) => viewModel.setStyleIndex(index),
            ),
            SizedBox(height: tourenBuddySpacings.sm),
            Tooltip(
              message: 'User profile',
              child: RoundActionButton(
                icon: Icons.account_circle,
                onPressed: () => _showProfileSheet(context),
              ),
            ),
            SizedBox(height: tourenBuddySpacings.sm),
            Tooltip(
              message: 'Add contact',
              child: RoundActionButton(
                icon: Icons.person_add,
                onPressed: () => _showContactSheet(context),
              ),
            ),
            SizedBox(height: tourenBuddySpacings.sm),
            Tooltip(
              message: 'Pick a new location',
              child: RoundActionButton(
                icon: Icons.add_location,
                onPressed: userService.isLoggedIn
                    ? () => viewModel.setPickingLocation(true)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: tourenBuddyTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: const UserProfileSheet(),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: tourenBuddyTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: const ContactCreationSheet(),
      ),
    );
  }
}
