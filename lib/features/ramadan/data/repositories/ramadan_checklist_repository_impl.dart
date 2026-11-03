import 'dart:convert';

import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/repositories/ramadan_checklist_repository.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps every day's checklist in [SharedPreferences] as one JSON object
/// keyed by local ISO date:
/// `{"2027-02-19": {"taraweeh": true, "quranPages": 5}}`. An empty day is
/// removed rather than stored.
class RamadanChecklistRepositoryImpl implements RamadanChecklistRepository {
  const new({required this.sharedPreferences});

  static const String storageKey = 'ramadan.checklist';

  final SharedPreferences sharedPreferences;

  @override
  Result<RamadanChecklist, StorageFailure> checklistFor(DateTime date) {
    final day = CalendarDays.dateOnly(date);
    return switch (_readAll()) {
      Ok(value: final all) => switch (all[_isoDate(day)]) {
        null => Ok(RamadanChecklist(date: day)),
        final entry => switch (_decodeDay(day, entry)) {
          final checklist? => Ok(checklist),
          null => const Err(StorageReadFailed(storageKey)),
        },
      },
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<void, StorageFailure>> save(RamadanChecklist checklist) async {
    final Map<String, Object?> all;
    switch (_readAll()) {
      case Ok(:final value):
        all = {...value};
      // Unreadable history is replaced rather than blocking today's entry.
      case Err():
        all = {};
    }
    final key = _isoDate(checklist.date);
    if (checklist.isEmpty) {
      all.remove(key);
    } else {
      all[key] = _encodeDay(checklist);
    }
    return await _write(all);
  }

  @override
  Result<List<RamadanChecklist>, StorageFailure> allChecklists() {
    switch (_readAll()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final all):
        final checklists = <RamadanChecklist>[];
        for (final MapEntry(:key, :value) in all.entries) {
          final checklist = switch (BackupValues.parseDate(key)) {
            final day? => _decodeDay(day, value),
            null => null,
          };
          if (checklist == null) {
            return const Err(StorageReadFailed(storageKey));
          }
          checklists.add(checklist);
        }
        return Ok(checklists);
    }
  }

  @override
  Future<Result<void, StorageFailure>> replaceAll(
    List<RamadanChecklist> checklists,
  ) => _write({
    for (final checklist in checklists)
      if (!checklist.isEmpty) _isoDate(checklist.date): _encodeDay(checklist),
  });

  Future<Result<void, StorageFailure>> _write(Map<String, Object?> all) async {
    try {
      final saved = await sharedPreferences.setString(
        storageKey,
        jsonEncode(all),
      );
      return saved ? const Ok(null) : const Err(StorageWriteFailed(storageKey));
    } on PlatformException catch (e, st) {
      AppLog.error('ramadan.checklist.write', e, st);
      return const Err(StorageWriteFailed(storageKey));
    }
  }

  static Map<String, Object?> _encodeDay(RamadanChecklist checklist) => {
    'taraweeh': checklist.prayedTaraweeh,
    'quranPages': checklist.quranPages,
  };

  static RamadanChecklist? _decodeDay(DateTime day, Object? json) =>
      switch (json) {
        {'taraweeh': final bool taraweeh, 'quranPages': final int pages}
            when pages >= 0 && pages <= RamadanChecklist.maxQuranPages =>
          RamadanChecklist(
            date: day,
            prayedTaraweeh: taraweeh,
            quranPages: pages,
          ),
        _ => null,
      };

  Result<Map<String, Object?>, StorageFailure> _readAll() {
    final raw = sharedPreferences.get(storageKey);
    if (raw == null) return const Ok({});
    if (raw is! String) return const Err(StorageReadFailed(storageKey));
    try {
      return switch (jsonDecode(raw)) {
        final Map<String, Object?> all => Ok(all),
        _ => const Err(StorageReadFailed(storageKey)),
      };
    } on FormatException catch (e, st) {
      AppLog.error('ramadan.checklist.read', e, st);
      return const Err(StorageReadFailed(storageKey));
    }
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
