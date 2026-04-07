import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/text/button.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';

class UserProfileSheet extends StatelessWidget {
  const UserProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();

    final firstName = userService.profileData?.firstName ?? '';
    final lastName = userService.profileData?.lastName ?? '';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your Profile',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: tourenBuddySpacings.sm),
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: Text(
            '$firstName $lastName'.trim().isEmpty
                ? '—'
                : '$firstName $lastName',
          ),
          subtitle: const Text('Name'),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: Text(email.isEmpty ? '—' : email),
          subtitle: const Text('Email'),
        ),
        SizedBox(height: tourenBuddySpacings.sm),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: ButtonText(buttonText: 'Sign out'),
            onPressed: () async {
              await userService.handleSignOut();
              if (context.mounted) Navigator.of(context).pop();
              rootNavigatorKey.currentState?.popUntil((r) => r.isFirst);
            },
          ),
        ),
      ],
    );
  }
}
