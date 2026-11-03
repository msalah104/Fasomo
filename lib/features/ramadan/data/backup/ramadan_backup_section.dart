import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/data/repositories/ramadan_checklist_repository_impl.dart';
import 'package:fasomo/features/ramadan/data/repositories/suhoor_iftar_settings_repository_impl.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/ramadan_checklist_repository.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';

/// The suhoor and iftar reminder settings and the daily checklists in a
/// backup. Days are local calendar dates as `yyyy-MM-dd`, sorted:
///
/// ```json
/// "ramadan": {
///   "reminders": {"suhoor": true, "suhoorMinutes": 45, "iftar": true,
///                 "iftarMinutes": 0, "otherDays": false},
///   "checklist": [{"date": "2027-02-19", "taraweeh": true, "quranPages": 5}]
/// }
/// ```
final class RamadanBackupSection implements BackupSection {
  const new({required this.checklist, required this.reminders});

  final RamadanChecklistRepository checklist;
  final SuhoorIftarSettingsRepository reminders;

  @override
  String get id => 'ramadan';

  @override
  Set<String> get storageKeys => const {
    RamadanChecklistRepositoryImpl.storageKey,
    SuhoorIftarSettingsRepositoryImpl.storageKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() => switch ((
    reminders.getSettings(),
    checklist.allChecklists(),
  )) {
    (Ok(value: final settings), Ok(value: final days)) => Ok({
      'reminders': SuhoorIftarSettingsRepositoryImpl.encode(settings),
      'checklist': [
        for (final day in [...days]..sort((a, b) => a.date.compareTo(b.date)))
          {
            'date': BackupValues.date(day.date),
            'taraweeh': day.prayedTaraweeh,
            'quranPages': day.quranPages,
          },
      ],
    }),
    _ => Err(BackupStorageFailed(id)),
  };

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      _parse(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final parsed = _parse(json);
    if (parsed == null) return Err(BackupMalformed(sectionId: id));
    final (settings, days) = parsed;
    if (await reminders.saveSettings(settings) case Err()) {
      return Err(BackupStorageFailed(id));
    }
    return switch (await checklist.replaceAll(days)) {
      Ok() => const Ok(null),
      Err() => Err(BackupStorageFailed(id)),
    };
  }

  static (SuhoorIftarSettings, List<RamadanChecklist>)? _parse(
    Map<String, Object?> json,
  ) {
    final settings = SuhoorIftarSettingsRepositoryImpl.decode(
      json['reminders'],
    );
    final days = _parseChecklists(json['checklist']);
    if (settings == null || days == null) return null;
    return (settings, days);
  }

  /// The checklists in [raw], or `null` when [raw] is not a list of valid
  /// entries for distinct days.
  static List<RamadanChecklist>? _parseChecklists(Object? raw) {
    if (raw is! List<Object?>) return null;
    final days = <DateTime, RamadanChecklist>{};
    for (final entry in raw) {
      if (entry
          case {
            'date': final Object date,
            'taraweeh': final bool taraweeh,
            'quranPages': final int pages,
          }
          when pages >= 0 && pages <= RamadanChecklist.maxQuranPages) {
        final day = BackupValues.parseDate(date);
        if (day == null || days.containsKey(day)) return null;
        days[day] = RamadanChecklist(
          date: day,
          prayedTaraweeh: taraweeh,
          quranPages: pages,
        );
      } else {
        return null;
      }
    }
    return days.values.toList();
  }
}
