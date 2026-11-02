part of 'backup_bloc.dart';

enum BackupStatus {
  /// Nothing running; also after the user cancelled.
  idle,
  exporting,
  exported,
  exportFailed,
  restoring,
  restored,
  restoreFailed,
}

final class BackupState extends Equatable {
  const new({this.status = BackupStatus.idle, this.failure, this.report});

  final BackupStatus status;

  /// Why the last export or restore failed.
  final BackupFailure? failure;

  /// What the last restore did, once [BackupStatus.restored].
  final RestoreReport? report;

  bool get isBusy =>
      status == BackupStatus.exporting || status == BackupStatus.restoring;

  @override
  List<Object?> get props => [status, failure, report];
}
