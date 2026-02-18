import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/core/config/tokens.dart';
import 'package:touringbuddy_frontend/core/config/typography.dart';

bool get _isCupertinoPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

final ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.orange,
  brightness: Brightness.light,
);

final ThemeData touringBuddyTheme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: buildTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    elevation: 0,
    centerTitle:
        _isCupertinoPlatform, // centers titles on iOS like UINavigationBar
  ),
  // Custom tokens (spacing, radii, etc.)
  extensions: const <ThemeExtension<dynamic>>[SpacingTokens(), RadiusTokens()],
);

final touringBuddySpacings = touringBuddyTheme.extension<SpacingTokens>()!;
