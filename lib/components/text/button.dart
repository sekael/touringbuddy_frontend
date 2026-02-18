import 'package:flutter/material.dart';

class ButtonText extends StatelessWidget {
  final String buttonText;
  final Color? colorOverride;
  final TextStyle? styleOverride;

  const ButtonText({
    super.key,
    required this.buttonText,
    this.colorOverride,
    this.styleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        buttonText,
        textAlign: TextAlign.center,
        style:
            styleOverride ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  colorOverride ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
