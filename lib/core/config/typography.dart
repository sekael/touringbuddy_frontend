import 'package:flutter/material.dart';

TextTheme buildTextTheme() {
  final base = Typography.blackMountainView;

  // Scale & refine a few roles you actually use
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(letterSpacing: 0.15),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.3),
    labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.2),
  );
}
