import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the fasted days as `yyyy-MM-dd` strings in shared
/// preferences.
///
/// Throws [FormatException] for undecodable data and [StorageWriteException]
/// when the platform refuses a write; the repository converts both into
/// typed failures.
abstract interface class FastLogLocalDataSource {
  /// Local midnights of the fasted days.
  Set<DateTime> getFastedDays();
  Future<void> saveFastedDays(Set<DateTime> days);
}

class FastLogLocalDataSourceImpl implements FastLogLocalDataSource {
  const new({required this.sharedPreferences});

  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final SharedPreferences sharedPreferences;

  @override
  Set<DateTime> getFastedDays() {
    final encoded =
        sharedPreferences.getStringList(AppConstants.fastLogKey) ?? const [];
    return {for (final value in encoded) _decode(value)};
  }

  @override
  Future<void> saveFastedDays(Set<DateTime> days) async {
    final sorted = days.toList()..sort();
    final saved = await sharedPreferences.setStringList(
      AppConstants.fastLogKey,
      [for (final day in sorted) _encode(day)],
    );
    if (!saved) throw const StorageWriteException(AppConstants.fastLogKey);
  }

  static String _encode(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static DateTime _decode(String value) {
    final match = _datePattern.firstMatch(value);
    if (match == null) throw FormatException('Malformed fast log day', value);
    final [year, month, day] = [
      for (var group = 1; group <= 3; group++) int.parse(match.group(group)!),
    ];
    final date = DateTime(year, month, day);
    // Rejects out-of-range parts such as 2026-02-31, which DateTime rolls over.
    if (date.month != month || date.day != day) {
      throw FormatException('Malformed fast log day', value);
    }
    return date;
  }
}
