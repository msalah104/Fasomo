import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// One feature's part of a backup file: the `sections.<id>` object.
///
/// Each feature implements its own section in its data layer, and the
/// composition root hands every section to the backup service, so core never
/// depends on a feature. Values are canonical: ISO-8601 dates, enum names and
/// plain integers, never localized text or numerals.
///
/// Restore replaces a section's data whole. A section missing from a file
/// leaves that data untouched.
abstract interface class BackupSection {
  /// The section's key in the file. Stable: renaming it orphans every
  /// existing backup's copy of this data.
  String get id;

  /// The stored keys [restore] writes. They are captured before a restore
  /// and put back if any section fails, so a restore is all-or-nothing.
  Set<String> get storageKeys;

  /// The section's current data, or [BackupStorageFailed] when it cannot be
  /// read.
  Result<Map<String, Object?>, BackupFailure> export();

  /// Checks [json] without writing anything: [BackupMalformed] with this
  /// section's [id] when it is not valid data for this section.
  Result<void, BackupFailure> validate(Map<String, Object?> json);

  /// Replaces this section's data with [json], which [validate] accepted.
  /// [BackupStorageFailed] when a write fails.
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json);
}
