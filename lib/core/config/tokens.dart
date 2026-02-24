import 'package:flutter/material.dart';

@immutable
class SpacingTokens extends ThemeExtension<SpacingTokens> {
  final double xxs, xs, sm, md, lg, xl, xxl;
  const SpacingTokens({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 20,
    this.xl = 24,
    this.xxl = 32,
  });

  @override
  SpacingTokens copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return SpacingTokens(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  SpacingTokens lerp(ThemeExtension<SpacingTokens>? other, double t) => this;
}

@immutable
class RadiusTokens extends ThemeExtension<RadiusTokens> {
  final double sm, md, lg;
  const RadiusTokens({this.sm = 8, this.md = 16, this.lg = 24});

  @override
  RadiusTokens copyWith({double? sm, double? md, double? lg}) {
    return RadiusTokens(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }

  @override
  RadiusTokens lerp(ThemeExtension<RadiusTokens>? other, double t) => this;
}
