import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// Localized home-screen widget text. Implemented in the presentation layer
/// for the app's current language.
abstract interface class HomeWidgetCopy {
  /// Whether the language is written right to left.
  bool get isRightToLeft;

  /// e.g. "13 Jumada al-Akhirah 1448 AH".
  String hijriDate(HijriDate date);

  /// e.g. "Monday, November 23".
  String gregorianDate(DateTime date);

  /// e.g. "Today: Day of Arafah", "Tomorrow: Monday & Thursday" or
  /// "White Days in 3 days".
  String nextFast(FastingType type, {required int daysUntil});

  /// When no fasting day falls within the look-ahead window.
  String get noUpcomingFast;

  /// When the widget has no entry for today, because the app has not been
  /// opened for a while.
  String get openAppToUpdate;
}
