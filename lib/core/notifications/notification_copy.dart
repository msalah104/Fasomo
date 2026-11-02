import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';

/// Localized notification text. Implemented in the presentation layer for
/// the app's current language.
abstract interface class NotificationCopy {
  /// e.g. "Tomorrow: White Days" when [daysBefore] is 1.
  String fastingTitle(FastingType type, {required int daysBefore});

  /// The default body when the user has not written a custom message.
  String fastingBody(FastingType type);

  /// e.g. "Tomorrow: a day for a make-up fast".
  String qadaTitle({required int daysBefore});

  /// e.g. "You have 4 make-up days left."
  String qadaBody(int remaining);

  /// The suggested pace, added to a make-up day it planned, e.g. "To
  /// finish before Ramadan, fast 1 make-up day a week."
  String qadaPace(QadaPaceRate pace);

  /// A fasting day that is also a suggested make-up day, e.g.
  /// "Tomorrow: White Days and a make-up fast".
  String mergedTitle(FastingType type, {required int daysBefore});

  /// Says that one fast counts for both, and how many days are left.
  String mergedBody(FastingType type, int remaining);

  /// e.g. "Ramadan in 30 days".
  String ramadanCountdownTitle(int daysUntilRamadan);

  /// e.g. "You still owe 4 make-up fasts before Ramadan."
  String ramadanCountdownBody(int daysUntilRamadan, int remaining);

  /// e.g. "Suhoor ends in 45 minutes".
  String suhoorTitle(int minutesBeforeFajr);

  /// Says when Fajr ([fajr], UTC) is, in the local time.
  String suhoorBody(DateTime fajr);

  /// e.g. "It's time for iftar", or "Iftar in 5 minutes".
  String iftarTitle(int minutesBeforeMaghrib);

  /// Says when Maghrib ([maghrib], UTC) is, in the local time.
  String iftarBody(DateTime maghrib);
}
