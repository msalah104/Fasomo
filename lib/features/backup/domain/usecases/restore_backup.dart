import 'package:fasomo/core/backup/backup_file_gateway.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Lets the user pick a backup file and restores it, all-or-nothing.
class RestoreBackup
    implements UseCase<Future<Result<RestoreReport, BackupFailure>>, NoParams> {
  const new({required this.service, required this.files});

  final BackupService service;
  final BackupFileGateway files;

  @override
  Future<Result<RestoreReport, BackupFailure>> call(NoParams params) async =>
      switch (await files.pick()) {
        Ok(value: final contents) => await service.restore(contents),
        Err(:final failure) => Err(failure),
      };
}
