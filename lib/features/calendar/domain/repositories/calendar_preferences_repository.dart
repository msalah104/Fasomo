import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// The calendar's own display preferences, kept on the device.
abstract interface class CalendarPreferencesRepository {
  /// Whether each day cell also shows its Gregorian day number; `false` until
  /// the user turns it on. Synchronous so the calendar opens already showing
  /// the saved choice.
  Result<bool, StorageFailure> getShowGregorianDays();

  /// Saves [show] for [getShowGregorianDays].
  Future<Result<void, StorageFailure>> saveShowGregorianDays({
    required bool show,
  });
}
