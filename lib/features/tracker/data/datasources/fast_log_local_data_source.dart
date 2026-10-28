import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the fasting log in shared preferences: days as
/// `yyyy-MM-dd` strings under one key per set, and the extra days owed as
/// `year:count` strings.
///
/// Throws [FormatException] for undecodable data and [StorageWriteException]
/// when the platform refuses a write; the repository converts both into
/// typed failures.
abstract interface class FastLogLocalDataSource {
  FastLog getLog();
  Future<void> saveLog(FastLog log);
}

class FastLogLocalDataSourceImpl implements FastLogLocalDataSource {
  const new({required this.sharedPreferences});

  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final RegExp _owedPattern = RegExp(r'^(\d{4}):(\d{1,3})$');

  final SharedPreferences sharedPreferences;

  @override
  FastLog getLog() => FastLog(
    fastedDays: _readDays(AppConstants.fastLogKey),
    makeUpDays: _readDays(AppConstants.makeUpDaysKey),
    missedRamadanDays: _readDays(AppConstants.missedRamadanKey),
    extraOwed: Map.fromEntries(
      _read(AppConstants.extraOwedKey).map(_decodeOwed),
    ),
  );

  @override
  Future<void> saveLog(FastLog log) async {
    await _write(AppConstants.fastLogKey, _encodeDays(log.fastedDays));
    await _write(AppConstants.makeUpDaysKey, _encodeDays(log.makeUpDays));
    await _write(
      AppConstants.missedRamadanKey,
      _encodeDays(log.missedRamadanDays),
    );
    final years = log.extraOwed.keys.toList()..sort();
    await _write(AppConstants.extraOwedKey, [
      for (final year in years) '$year:${log.extraOwed[year]}',
    ]);
  }

  List<String> _read(String key) =>
      sharedPreferences.getStringList(key) ?? const [];

  Set<DateTime> _readDays(String key) => {
    for (final value in _read(key)) _decode(value),
  };

  Future<void> _write(String key, List<String> values) async {
    if (!await sharedPreferences.setStringList(key, values)) {
      throw StorageWriteException(key);
    }
  }

  static List<String> _encodeDays(Set<DateTime> days) => [
    for (final day in days.toList()..sort()) _encode(day),
  ];

  static String _encode(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static MapEntry<int, int> _decodeOwed(String value) {
    final match = _owedPattern.firstMatch(value);
    if (match == null) throw FormatException('Malformed days owed', value);
    return MapEntry(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

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
