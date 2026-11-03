import 'package:fasomo/core/backup/backup_file_gateway.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Backs everything up to a file and offers it through the share sheet.
class ExportBackup
    implements UseCase<Future<Result<void, BackupFailure>>, NoParams> {
  const new({required this.service, required this.files});

  final BackupService service;
  final BackupFileGateway files;

  @override
  Future<Result<void, BackupFailure>> call(NoParams params) async =>
      switch (service.export()) {
        Ok(value: final file) => await files.share(file),
        Err(:final failure) => Err(failure),
      };
}
