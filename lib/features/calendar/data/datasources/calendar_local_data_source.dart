import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the calendar's display preferences in shared preferences.
///
/// Throws [FormatException] when a stored value has the wrong type and
/// [StorageWriteException] when the platform refuses a write; the repository
/// converts both into typed failures.
abstract interface class CalendarLocalDataSource {
  /// The saved choice, or `null` when none was saved.
  bool? getShowGregorianDays();
  Future<void> saveShowGregorianDays({required bool show});
}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  const new({required this.sharedPreferences});

  /// Owned by the calendar feature, so it lives here rather than in the
  /// shared constants.
  static const String showGregorianDaysKey = 'calendar_show_gregorian_days';

  final SharedPreferences sharedPreferences;

  @override
  bool? getShowGregorianDays() {
    final stored = sharedPreferences.get(showGregorianDaysKey);
    return switch (stored) {
      null => null,
      final bool show => show,
      _ => throw FormatException('Not a bool', stored),
    };
  }

  @override
  Future<void> saveShowGregorianDays({required bool show}) async {
    final saved = await sharedPreferences.setBool(showGregorianDaysKey, show);
    if (!saved) throw const StorageWriteException(showGregorianDaysKey);
  }
}
