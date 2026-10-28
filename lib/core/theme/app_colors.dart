import 'dart:ui' show lerpDouble;

import 'package:fasomo/core/theme/primitives.dart';
import 'package:flutter/material.dart';

/// Semantic colour slots for the Hilal theme, attached to both the light and
/// the dark `ThemeData`.
///
/// Widgets read colours through [AppColors.of] and never touch a primitive.
/// Every `on…` slot is the colour for text or icons drawn on its partner slot.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const new({
    required this.surface,
    required this.card,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.hairline,
    required this.brand,
    required this.onBrand,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.danger,
    required this.onDanger,
    required this.fastRamadan,
    required this.onFastRamadan,
    required this.fastSpecial,
    required this.onFastSpecial,
    required this.fastShawwal,
    required this.onFastShawwal,
    required this.fastWhiteDays,
    required this.onFastWhiteDays,
    required this.fastWhiteDaysFill,
    required this.fastWeekly,
    required this.onFastWeekly,
    required this.tintOpacity,
  });

  /// Page background.
  final Color surface;

  /// Raised cards and sheets.
  final Color card;
  final Color onSurface;

  /// Secondary text and icons on [surface] or [card].
  final Color onSurfaceMuted;

  /// Dividers and card outlines.
  final Color hairline;

  /// The night-blue identity colour: app bar and the Home date card.
  final Color brand;
  final Color onBrand;

  /// Interactive colour for buttons, switches and selection.
  final Color accent;
  final Color onAccent;

  /// Soft gold fill for chips and the selected navigation item.
  final Color accentContainer;
  final Color onAccentContainer;

  final Color danger;
  final Color onDanger;

  final Color fastRamadan;
  final Color onFastRamadan;

  /// Arafah, Ashura and Tasua.
  final Color fastSpecial;
  final Color onFastSpecial;
  final Color fastShawwal;
  final Color onFastShawwal;
  final Color fastWhiteDays;
  final Color onFastWhiteDays;

  /// Background of a White Day in the calendar; text sits on it.
  final Color fastWhiteDaysFill;

  /// Monday and Thursday.
  final Color fastWeekly;
  final Color onFastWeekly;

  /// Opacity of a soft background tint made from a strong colour.
  final double tintOpacity;

  /// The [AppColors] of the nearest theme. Asserts when the theme was not
  /// built by `buildAppTheme`, rather than falling back to unverified colours.
  static AppColors of(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    assert(
      colors != null,
      'AppColors missing. Build ThemeData via buildAppTheme().',
    );
    return colors!;
  }

  /// A soft background tint of [color], for icon wells and highlighted rows.
  Color tint(Color color) => color.withValues(alpha: tintOpacity);

  @override
  AppColors copyWith({
    Color? surface,
    Color? card,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? hairline,
    Color? brand,
    Color? onBrand,
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? danger,
    Color? onDanger,
    Color? fastRamadan,
    Color? onFastRamadan,
    Color? fastSpecial,
    Color? onFastSpecial,
    Color? fastShawwal,
    Color? onFastShawwal,
    Color? fastWhiteDays,
    Color? onFastWhiteDays,
    Color? fastWhiteDaysFill,
    Color? fastWeekly,
    Color? onFastWeekly,
    double? tintOpacity,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      card: card ?? this.card,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      hairline: hairline ?? this.hairline,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      fastRamadan: fastRamadan ?? this.fastRamadan,
      onFastRamadan: onFastRamadan ?? this.onFastRamadan,
      fastSpecial: fastSpecial ?? this.fastSpecial,
      onFastSpecial: onFastSpecial ?? this.onFastSpecial,
      fastShawwal: fastShawwal ?? this.fastShawwal,
      onFastShawwal: onFastShawwal ?? this.onFastShawwal,
      fastWhiteDays: fastWhiteDays ?? this.fastWhiteDays,
      onFastWhiteDays: onFastWhiteDays ?? this.onFastWhiteDays,
      fastWhiteDaysFill: fastWhiteDaysFill ?? this.fastWhiteDaysFill,
      fastWeekly: fastWeekly ?? this.fastWeekly,
      onFastWeekly: onFastWeekly ?? this.onFastWeekly,
      tintOpacity: tintOpacity ?? this.tintOpacity,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      surface: mix(surface, other.surface),
      card: mix(card, other.card),
      onSurface: mix(onSurface, other.onSurface),
      onSurfaceMuted: mix(onSurfaceMuted, other.onSurfaceMuted),
      hairline: mix(hairline, other.hairline),
      brand: mix(brand, other.brand),
      onBrand: mix(onBrand, other.onBrand),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentContainer: mix(accentContainer, other.accentContainer),
      onAccentContainer: mix(onAccentContainer, other.onAccentContainer),
      danger: mix(danger, other.danger),
      onDanger: mix(onDanger, other.onDanger),
      fastRamadan: mix(fastRamadan, other.fastRamadan),
      onFastRamadan: mix(onFastRamadan, other.onFastRamadan),
      fastSpecial: mix(fastSpecial, other.fastSpecial),
      onFastSpecial: mix(onFastSpecial, other.onFastSpecial),
      fastShawwal: mix(fastShawwal, other.fastShawwal),
      onFastShawwal: mix(onFastShawwal, other.onFastShawwal),
      fastWhiteDays: mix(fastWhiteDays, other.fastWhiteDays),
      onFastWhiteDays: mix(onFastWhiteDays, other.onFastWhiteDays),
      fastWhiteDaysFill: mix(fastWhiteDaysFill, other.fastWhiteDaysFill),
      fastWeekly: mix(fastWeekly, other.fastWeekly),
      onFastWeekly: mix(onFastWeekly, other.onFastWeekly),
      tintOpacity: lerpDouble(tintOpacity, other.tintOpacity, t)!,
    );
  }

  /// Hilal light: night blue and moon gold on warm ivory.
  static const light = AppColors(
    surface: Primitives.ivory96,
    card: Primitives.ivory99,
    onSurface: Primitives.slate24,
    onSurfaceMuted: Primitives.slate50,
    hairline: Primitives.ivory89,
    brand: Primitives.indigo27,
    onBrand: Primitives.ivory96,
    accent: Primitives.indigo27,
    onAccent: Primitives.ivory96,
    accentContainer: Primitives.gold92,
    onAccentContainer: Primitives.gold38,
    danger: Primitives.red45,
    onDanger: Primitives.white,
    fastRamadan: Primitives.violet40,
    onFastRamadan: Primitives.white,
    fastSpecial: Primitives.clay48,
    onFastSpecial: Primitives.white,
    fastShawwal: Primitives.teal50,
    onFastShawwal: Primitives.white,
    fastWhiteDays: Primitives.moon86,
    onFastWhiteDays: Primitives.indigo27,
    fastWhiteDaysFill: Primitives.moon86,
    fastWeekly: Primitives.gold75,
    onFastWeekly: Primitives.indigo27,
    tintOpacity: 0.16,
  );

  /// Hilal dark: hand-tuned, not an inversion. Fasting hues are lifted so they
  /// stay distinct and legible on the night surfaces.
  static const dark = AppColors(
    surface: Primitives.indigo16,
    card: Primitives.indigo22,
    onSurface: Primitives.ivory93,
    onSurfaceMuted: Primitives.slate74,
    hairline: Primitives.indigo35,
    brand: Primitives.indigo31,
    onBrand: Primitives.ivory96,
    accent: Primitives.gold80,
    onAccent: Primitives.indigo16,
    accentContainer: Primitives.gold30,
    onAccentContainer: Primitives.gold80,
    danger: Primitives.red80,
    onDanger: Primitives.red20,
    fastRamadan: Primitives.violet74,
    onFastRamadan: Primitives.indigo16,
    fastSpecial: Primitives.clay72,
    onFastSpecial: Primitives.indigo16,
    fastShawwal: Primitives.teal76,
    onFastShawwal: Primitives.indigo16,
    fastWhiteDays: Primitives.moon91,
    onFastWhiteDays: Primitives.indigo16,
    fastWhiteDaysFill: Primitives.moon32,
    fastWeekly: Primitives.gold80,
    onFastWeekly: Primitives.indigo16,
    tintOpacity: 0.22,
  );
}
