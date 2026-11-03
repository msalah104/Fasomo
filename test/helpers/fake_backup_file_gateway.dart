import 'package:fasomo/core/backup/backup_file_gateway.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// Records shared files and hands out a chosen file's text, or a failure.
class FakeBackupFileGateway implements BackupFileGateway {
  final List<BackupFile> shared = [];

  /// What [share] returns after recording the file.
  Result<void, BackupFailure> shareResult = const Ok(null);

  /// What [pick] returns.
  Result<String, BackupFailure> pickResult = const Err(BackupCancelled());

  int pickCount = 0;

  @override
  Future<Result<void, BackupFailure>> share(BackupFile file) async {
    shared.add(file);
    return shareResult;
  }

  @override
  Future<Result<String, BackupFailure>> pick() async {
    pickCount++;
    return pickResult;
  }
}
