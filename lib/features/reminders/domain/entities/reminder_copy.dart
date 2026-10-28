import 'package:fasomo/core/calendar/fasting_type.dart';

/// Localized notification text. Implemented in the presentation layer for
/// the app's current language.
abstract interface class ReminderCopy {
  /// e.g. "Tomorrow: White Days" when [daysBefore] is 1.
  String title(FastingType type, {required int daysBefore});

  /// The default body when the user has not written a custom message.
  String body(FastingType type);
}
