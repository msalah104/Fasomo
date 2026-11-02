import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/backup/domain/usecases/export_backup.dart';
import 'package:fasomo/features/backup/domain/usecases/restore_backup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'backup_event.dart';
part 'backup_state.dart';

/// Export and restore of the backup file.
///
/// A [BackupStatus.restored] state means every feature's stored data may
/// have changed: the app shell then reloads every screen and reschedules
/// the reminders.
class BackupBloc extends Bloc<BackupEvent, BackupState> {
  new({required this.exportBackup, required this.restoreBackup})
    : super(const BackupState()) {
    // One operation at a time; taps while one runs are ignored.
    on<BackupEvent>(_onEvent, transformer: droppable());
  }

  final ExportBackup exportBackup;
  final RestoreBackup restoreBackup;

  Future<void> _onEvent(BackupEvent event, Emitter<BackupState> emit) async {
    switch (event) {
      case BackupExportRequested():
        emit(const BackupState(status: BackupStatus.exporting));
        emit(switch (await exportBackup(const NoParams())) {
          Ok() => const BackupState(status: BackupStatus.exported),
          Err(failure: BackupCancelled()) => const BackupState(),
          Err(:final failure) => BackupState(
            status: BackupStatus.exportFailed,
            failure: failure,
          ),
        });
      case BackupRestoreRequested():
        emit(const BackupState(status: BackupStatus.restoring));
        emit(switch (await restoreBackup(const NoParams())) {
          Ok(value: final report) => BackupState(
            status: BackupStatus.restored,
            report: report,
          ),
          Err(failure: BackupCancelled()) => const BackupState(),
          Err(:final failure) => BackupState(
            status: BackupStatus.restoreFailed,
            failure: failure,
          ),
        });
    }
  }
}
