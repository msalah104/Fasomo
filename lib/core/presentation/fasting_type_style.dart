import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The colour and icon used for each [FastingType] across the app. Colour is
/// always paired with the icon and the label, so state is never conveyed by
/// colour alone.
extension FastingTypeStyle on FastingType {
  /// The type's colour from the current theme's [colors].
  Color color(AppColors colors) => switch (this) {
    FastingType.ramadan => colors.fastRamadan,
    FastingType.arafah ||
    FastingType.ashura ||
    FastingType.tasua => colors.fastSpecial,
    FastingType.shawwal => colors.fastShawwal,
    FastingType.whiteDays => colors.fastWhiteDays,
    FastingType.mondayThursday => colors.fastWeekly,
  };

  /// The colour for an icon drawn on [color].
  Color onColor(AppColors colors) => switch (this) {
    FastingType.ramadan => colors.onFastRamadan,
    FastingType.arafah ||
    FastingType.ashura ||
    FastingType.tasua => colors.onFastSpecial,
    FastingType.shawwal => colors.onFastShawwal,
    FastingType.whiteDays => colors.onFastWhiteDays,
    FastingType.mondayThursday => colors.onFastWeekly,
  };

  /// The background of a highlighted day. The White Days colour is already
  /// pale, so it has its own fill slot instead of a tint.
  Color fill(AppColors colors) => this == FastingType.whiteDays
      ? colors.fastWhiteDaysFill
      : colors.tint(color(colors));

  /// Outlined icons matching the Hilal concept: crescent for Ramadan, a peak
  /// for the special days, a sparkle for Shawwal, the full moon for the White
  /// Days and a calendar page for Monday and Thursday.
  IconData get icon => switch (this) {
    FastingType.ramadan => Icons.dark_mode_outlined,
    FastingType.arafah ||
    FastingType.ashura ||
    FastingType.tasua => Icons.landscape_outlined,
    FastingType.shawwal => Icons.auto_awesome_outlined,
    FastingType.whiteDays => Icons.circle_outlined,
    FastingType.mondayThursday => Icons.calendar_month_outlined,
  };
}
