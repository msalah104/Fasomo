import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Corner radii for the app. Components ask for a shape by role, so the whole
/// app can be re-shaped from here.
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  const new({
    required this.radiusSmall,
    required this.radiusCard,
    required this.radiusSheet,
  });

  /// Icon wells, day cells and inset boxes.
  final double radiusSmall;
  final double radiusCard;

  /// The top corners of a bottom sheet.
  final double radiusSheet;

  static const standard = AppShapes(
    radiusSmall: 8,
    radiusCard: 16,
    radiusSheet: 20,
  );

  /// The [AppShapes] of the nearest theme. Asserts when the theme was not
  /// built by `buildAppTheme`.
  static AppShapes of(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapes>();
    assert(
      shapes != null,
      'AppShapes missing. Build ThemeData via buildAppTheme().',
    );
    return shapes!;
  }

  BorderRadius get smallRadius => BorderRadius.circular(radiusSmall);

  BorderRadius get cardRadius => BorderRadius.circular(radiusCard);

  RoundedRectangleBorder get cardShape =>
      RoundedRectangleBorder(borderRadius: cardRadius);

  RoundedRectangleBorder get sheetShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSheet)),
  );

  @override
  AppShapes copyWith({
    double? radiusSmall,
    double? radiusCard,
    double? radiusSheet,
  }) {
    return AppShapes(
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusSheet: radiusSheet ?? this.radiusSheet,
    );
  }

  @override
  AppShapes lerp(covariant AppShapes? other, double t) {
    if (other == null) return this;
    return AppShapes(
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusSheet: lerpDouble(radiusSheet, other.radiusSheet, t)!,
    );
  }
}
