import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// The port to the device's files: the share sheet a backup leaves through
/// and the picker a backup comes back through. Both run only on an explicit
/// user action; nothing is uploaded on its own.
abstract interface class BackupFileGateway {
  /// Writes [file] to a temporary file, published only once complete, and
  /// opens the share sheet with it, so the user can save or send it.
  ///
  /// [BackupCancelled] when the user dismisses the sheet.
  Future<Result<void, BackupFailure>> share(BackupFile file);

  /// Lets the user choose a file and returns its text.
  ///
  /// [BackupCancelled] when the user closes the picker, [BackupMalformed]
  /// when the file is too large or not UTF-8 text.
  Future<Result<String, BackupFailure>> pick();
}
