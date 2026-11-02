part of 'backup_bloc.dart';

sealed class BackupEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The user wants a backup file to save or send.
final class BackupExportRequested extends BackupEvent {
  const new();
}

/// The user confirmed that a backup should replace their data, and now
/// picks the file.
final class BackupRestoreRequested extends BackupEvent {
  const new();
}
