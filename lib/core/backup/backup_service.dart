import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/backup/backup_envelope.dart';
import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_snapshot_store.dart';
import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// A finished backup, ready to be written to a file and shared.
final class BackupFile extends Equatable {
  const new({required this.fileName, required this.contents});

  /// E.g. `fasomo-backup-2026-11-02-1015.json`, from the UTC export time.
  final String fileName;

  final String contents;

  @override
  List<Object> get props => [fileName, contents];
}

/// What a successful restore did.
final class RestoreReport extends Equatable {
  const new({
    required this.restoredSections,
    required this.skippedSections,
    required this.exportedAtUtc,
  });

  /// The sections whose data was replaced, in registration order.
  final List<String> restoredSections;

  /// Sections in the file this app does not know, e.g. from a newer
  /// version; sorted. Their data was ignored.
  final List<String> skippedSections;

  /// When the backup was made.
  final DateTime exportedAtUtc;

  @override
  List<Object> get props => [restoredSections, skippedSections, exportedAtUtc];
}

/// Builds backup files from the registered [BackupSection]s and restores
/// them, all-or-nothing.
///
/// Policy: a restore replaces, per section. Each section present in the file
/// replaces that data whole; a section missing from the file leaves its data
/// untouched; a section this app does not know is skipped and reported.
final class BackupService {
  new({
    required this.sections,
    required this.snapshots,
    required this.clock,
    required this.appVersion,
  }) : assert(
         sections.map((s) => s.id).toSet().length == sections.length,
         'backup section ids must be unique',
       );

  final List<BackupSection> sections;
  final BackupSnapshotStore snapshots;
  final Clock clock;

  /// Written into every file, for support.
  final String appVersion;

  /// Every section's current data in a new backup file.
  Result<BackupFile, BackupFailure> export() {
    final data = <String, Object?>{};
    for (final section in sections) {
      switch (section.export()) {
        case Ok(:final value):
          data[section.id] = value;
        case Err(:final failure):
          return Err(failure);
      }
    }
    final exportedAtUtc = clock.now().toUtc();
    final envelope = BackupEnvelope(
      formatVersion: BackupEnvelope.currentFormatVersion,
      appVersion: appVersion,
      exportedAtUtc: exportedAtUtc,
      sections: data,
    );
    return Ok(
      BackupFile(
        fileName: fileNameFor(exportedAtUtc),
        contents: envelope.encode(),
      ),
    );
  }

  /// Restores the backup in [contents].
  ///
  /// Reads the header, verifies the checksum and validates every section
  /// before anything is written. If a write then fails, every key the
  /// restore could have touched is put back as it was.
  Future<Result<RestoreReport, BackupFailure>> restore(String contents) async {
    final BackupEnvelope envelope;
    switch (BackupEnvelope.decode(contents)) {
      case Ok(:final value):
        envelope = value;
      case Err(:final failure):
        return Err(failure);
    }

    final plan = <(BackupSection, Map<String, Object?>)>[];
    for (final section in sections) {
      switch (envelope.sections[section.id]) {
        case null:
          continue;
        case final Map<String, Object?> json:
          if (section.validate(json) case Err(:final failure)) {
            return Err(failure);
          }
          plan.add((section, json));
        default:
          return Err(BackupMalformed(sectionId: section.id));
      }
    }
    // A file with nothing this app can restore is not a usable backup.
    if (plan.isEmpty) return const Err(BackupMalformed());

    final known = {for (final section in sections) section.id};
    final report = RestoreReport(
      restoredSections: [for (final (section, _) in plan) section.id],
      skippedSections: [
        ...envelope.sections.keys.where((id) => !known.contains(id)),
      ]..sort(),
      exportedAtUtc: envelope.exportedAtUtc,
    );

    final snapshot = snapshots.capture({
      for (final (section, _) in plan) ...section.storageKeys,
    });
    var completed = false;
    try {
      for (final (section, json) in plan) {
        if (await section.restore(json) case Err(:final failure)) {
          return Err(failure);
        }
      }
      completed = true;
      return Ok(report);
    } finally {
      // Also on an unexpected throw, so no restore is ever left half-done.
      if (!completed) await snapshots.putBack(snapshot);
    }
  }

  /// The file name for a backup made at [exportedAtUtc].
  static String fileNameFor(DateTime exportedAtUtc) {
    final utc = exportedAtUtc.toUtc();
    final time =
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}';
    return 'fasomo-backup-${BackupValues.date(utc)}-$time.json';
  }
}
