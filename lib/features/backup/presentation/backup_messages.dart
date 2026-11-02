import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// What to tell the user about [state], or `null` when there is nothing to
/// say (still working, idle, or cancelled).
String? backupMessage(AppLocalizations localization, BackupState state) =>
    switch (state.status) {
      BackupStatus.idle ||
      BackupStatus.exporting ||
      BackupStatus.restoring => null,
      BackupStatus.exported => localization.backupExported,
      BackupStatus.restored =>
        (state.report?.skippedSections.isNotEmpty ?? false)
            ? localization.backupRestoredWithSkipped
            : localization.backupRestored,
      BackupStatus.exportFailed => switch (state.failure) {
        BackupCancelled() || null => null,
        _ => localization.backupErrorExport,
      },
      BackupStatus.restoreFailed => switch (state.failure) {
        null || BackupCancelled() => null,
        BackupFormatTooNew() => localization.backupErrorNewerVersion,
        BackupMalformed() => localization.backupErrorCorrupt,
        BackupChecksumMismatch() => localization.backupErrorChecksum,
        BackupStorageFailed() => localization.backupErrorRestoreStorage,
        BackupFileFailed() => localization.backupErrorFile,
      },
    };
