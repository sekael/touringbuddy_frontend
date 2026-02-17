// Private helper for those repetitive round buttons
import 'package:flutter/material.dart';

class RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const RoundActionButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        padding: const EdgeInsets.all(28),
        shape: const CircleBorder(),
      ),
      child: Icon(icon),
    );
  }
}
