import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String titleText;
  final Color? colorOverride;
  final TextStyle? styleOverride;

  const TitleText({
    super.key,
    required this.titleText,
    this.colorOverride,
    this.styleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        titleText,
        style:
            styleOverride ??
            Theme.of(context).textTheme.displayMedium?.copyWith(
              color: colorOverride ?? Theme.of(context).colorScheme.onSurface,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
