import 'dart:convert';

import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';

/// The data format the native home-screen widgets read. The sole Dart owner.
///
/// Mirrored by hand in
/// `android/app/src/main/kotlin/app/fasomo/fasomo/widget/FasomoWidgetContract.kt`
/// and `ios/FasomoWidget/FasomoWidgetContract.swift`: change all three in the
/// same commit, and bump [version] for any change a widget built from the
/// old mirror would misread.
abstract final class HomeWidgetContract {
  static const int version = 1;

  /// The one key the snapshot is stored under, as a JSON string.
  static const String storageKey = 'fasomo_widget_snapshot';

  static const String versionField = 'v';
  static const String generatedForField = 'generatedFor';
  static const String rtlField = 'rtl';
  static const String staleTextField = 'staleText';

  /// An object keyed by [dateKey], one entry per day.
  static const String daysField = 'days';
  static const String hijriField = 'hijri';
  static const String gregorianField = 'gregorian';
  static const String nextFastField = 'nextFast';
  static const String fastingDayField = 'fastingDay';

  /// The local calendar day of [date] as `yyyy-MM-dd`, the way the widgets
  /// key their lookup of today's entry.
  static String dateKey(DateTime date) {
    String pad(int value, int width) => '$value'.padLeft(width, '0');
    return '${pad(date.year, 4)}-${pad(date.month, 2)}-${pad(date.day, 2)}';
  }

  /// [snapshot] encoded as the JSON string stored under [storageKey].
  static String encode(HomeWidgetSnapshot snapshot) => jsonEncode({
    versionField: version,
    generatedForField: dateKey(snapshot.generatedFor),
    rtlField: snapshot.isRightToLeft,
    staleTextField: snapshot.staleText,
    daysField: {
      for (final day in snapshot.days)
        dateKey(day.date): {
          hijriField: day.hijriText,
          gregorianField: day.gregorianText,
          nextFastField: day.nextFastText,
          fastingDayField: day.isFastingDay,
        },
    },
  });

  /// The moments the widget must be redrawn to move on to the next entry:
  /// the midnight that starts each day after the snapshot's first, up to
  /// and including the one after its last entry, when it turns stale.
  static List<DateTime> refreshTimes(HomeWidgetSnapshot snapshot) => [
    for (final day in snapshot.days) CalendarDays.addDays(day.date, 1),
  ];
}
